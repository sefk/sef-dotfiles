/**
 * Claude Code–style footer (auto-enabled)
 *
 * Renders a two-line footer matching Claude Code's statusline layout:
 *   Line 1: cwd (branch status)
 *   Line 2: [model]  ↑input ↓output  ▓▓▓░░░░░░░ pct%  duration  +add/-rm
 *
 * Inspired by Claude Code's built-in statusline (claude/statusline-command.sh):
 *   ~/s/sef-dotfiles (main)
 *   [Sonnet] ↑15.2k ↓1.2k ▓▓▓░░░░░░░ 32% | 4m | +12/-3
 */

import { execSync } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import type { AssistantMessage } from "@earendil-works/pi-ai";

interface GitStatus {
	added: number;
	removed: number;
	flags: string; // % untracked, + added, * modified, ~ renamed, ! deleted
}

function getGitStatus(cwd: string): GitStatus | null {
	try {
		const status = execSync("git --no-optional-locks status --porcelain", {
			cwd,
			stdio: ["ignore", "pipe", "ignore"],
		}).toString();

		let flags = "";
		if (/^\?\?/m.test(status)) flags += "%";
		if (/^A/m.test(status)) flags += "+";
		if (/^ M|^M/m.test(status)) flags += "*";
		if (/^R/m.test(status)) flags += "~";
		if (/^ D|^D/m.test(status)) flags += "!";

		const diffStat = execSync("git --no-optional-locks diff --shortstat HEAD", {
			cwd,
			stdio: ["ignore", "pipe", "ignore"],
		}).toString();
		const addedMatch = diffStat.match(/(\d+) insertion/);
		const removedMatch = diffStat.match(/(\d+) deletion/);

		return {
			added: addedMatch ? Number(addedMatch[1]) : 0,
			removed: removedMatch ? Number(removedMatch[1]) : 0,
			flags,
		};
	} catch {
		return null;
	}
}

// Fish-style collapse: ~/foo/bar/baz -> ~/f/b/baz
function collapseCwd(cwd: string): string {
	const home = process.env.HOME;
	let wd = home && cwd.startsWith(home) ? `~${cwd.slice(home.length)}` : cwd;
	if (!wd.includes("/")) return wd;
	const parts = wd.split("/");
	const last = parts.pop()!;
	const collapsed = parts.map((p) => (p.length > 1 && p !== "~" ? p[0] : p)).join("/");
	return collapsed ? `${collapsed}/${last}` : last;
}

function formatDuration(ms: number): string {
	const min = Math.floor(ms / 60_000);
	const hr = Math.floor(min / 60);
	if (hr > 0) return `${hr}h${min % 60}m`;
	return `${min}m`;
}

export default function (pi: ExtensionAPI) {
	let totalInputTokens = 0;
	let totalOutputTokens = 0;
	let sessionStart = Date.now();

	function makeFooter(ctx: ExtensionAPI["session"]) {
		return (tui: any, theme: any, footerData: any) => {
			let gitStatus: GitStatus | null = getGitStatus(ctx.cwd);
			const refreshGitStatus = () => {
				gitStatus = getGitStatus(ctx.cwd);
				tui.requestRender();
			};
			const unsub = footerData.onBranchChange(refreshGitStatus);
			const gitInterval = setInterval(refreshGitStatus, 5000);
			const clockInterval = setInterval(() => tui.requestRender(), 60_000);

			return {
				dispose: () => {
					unsub();
					clearInterval(gitInterval);
					clearInterval(clockInterval);
				},
				invalidate() {},
				render(width: number): string[] {
					const fmt = (n: number) => {
						if (n < 1000) return `${n}`;
						if (n < 1_000_000) return `${(n / 1000).toFixed(1)}k`;
						return `${(n / 1_000_000).toFixed(1)}M`;
					};

					// ── Line 1: cwd + git branch/status ──
					const cwdStr = theme.fg("dim", collapseCwd(ctx.cwd));
					const branch = footerData.getGitBranch();
					let gitStr = "";
					if (branch) {
						const dirty = !!gitStatus?.flags;
						const branchColor = dirty ? "error" : "success";
						gitStr = " " + theme.fg(branchColor, dirty ? `{${branch} ${gitStatus!.flags}}` : `(${branch})`);
					}
					const line1 = truncateToWidth(cwdStr + gitStr, width);

					// ── Line 2: model, tokens, context bar, duration ──
					const model = ctx.model?.id || "unknown";
					const left = theme.fg("dim", `[${model}]`);

					const tokens = theme.fg("dim", ` ↑${fmt(totalInputTokens)} ↓${fmt(totalOutputTokens)}`);

					const usage = ctx.getContextUsage?.();
					const pct = usage?.percent ?? 0;
					const barWidth = 10;
					const filled = Math.round((pct / 100) * barWidth);
					const empty = barWidth - filled;
					const barColor = pct >= 90 ? "error" : pct >= 70 ? "warning" : "success";
					const bar = theme.fg(barColor, "▓".repeat(filled) + "░".repeat(empty));
					const pctStr = theme.fg("dim", ` ${usage?.percent !== null ? Math.round(pct) : "?"}%`);

					const duration = theme.fg("dim", ` ${formatDuration(Date.now() - sessionStart)}`);

					const center = `${tokens} ${bar}${pctStr}${duration}`;

					let right = "";
					if (gitStatus && (gitStatus.added || gitStatus.removed)) {
						right =
							theme.fg("success", `+${gitStatus.added}`) + "/" + theme.fg("error", `-${gitStatus.removed}`);
					}

					const leftW = visibleWidth(left);
					const centerW = visibleWidth(center);
					const rightW = visibleWidth(right);
					const totalContent = leftW + centerW + rightW;

					let line2: string;
					if (totalContent >= width) {
						line2 = truncateToWidth(left + center, width);
					} else {
						const pad = " ".repeat(width - totalContent);
						line2 = left + center + pad + right;
					}
					line2 = truncateToWidth(line2, width);

					return [line1, line2];
				},
			};
		};
	}

	pi.on("session_start", async (_event, ctx) => {
		totalInputTokens = 0;
		totalOutputTokens = 0;
		sessionStart = Date.now();
		ctx.ui.setFooter(makeFooter(ctx));
	});

	pi.on("turn_end", async (_event, ctx) => {
		// Recompute token stats from session
		totalInputTokens = 0;
		totalOutputTokens = 0;

		for (const e of ctx.sessionManager.getBranch()) {
			if (e.type === "message" && e.message.role === "assistant") {
				const m = e.message as AssistantMessage;
				totalInputTokens += m.usage.input;
				totalOutputTokens += m.usage.output;
			}
		}
	});

	pi.on("model_select", async (event, ctx) => {
		// Re-render when model changes
		ctx.ui.setFooter(makeFooter(ctx));
	});
}

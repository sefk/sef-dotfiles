/**
 * Claude Code–style footer (auto-enabled)
 *
 * Renders a single-line footer matching Claude Code's layout:
 *   [model]  ↑input ↓output $cost  ·  git branch
 *
 * Inspired by Claude Code's built-in footer:
 *   [Sonnet]  ↑15.2k ↓1.2k  $0.012  main
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import type { AssistantMessage } from "@earendil-works/pi-ai";

export default function (pi: ExtensionAPI) {
	let totalInputTokens = 0;
	let totalOutputTokens = 0;
	let totalCost = 0;

	function makeFooter(ctx: ExtensionAPI["session"]) {
		return (tui: any, theme: any, footerData: any) => {
			const unsub = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose: unsub,
				invalidate() {},
				render(width: number): string[] {
					const fmt = (n: number) => {
						if (n < 1000) return `${n}`;
						if (n < 1_000_000) return `${(n / 1000).toFixed(1)}k`;
						return `${(n / 1_000_000).toFixed(1)}M`;
					};

					// Left: model name in brackets (Claude Code style)
					const model = ctx.model?.id || "unknown";
					const left = theme.fg("dim", `[${model}]`);

					// Center: token usage + cost
					const tokens = theme.fg("dim", ` ↑${fmt(totalInputTokens)} ↓${fmt(totalOutputTokens)}`);
					const cost = theme.fg("dim", ` $${totalCost.toFixed(3)}`);
					const center = tokens + cost;

					// Right: git branch
					const branch = footerData.getGitBranch();
					const right = branch ? theme.fg("muted", branch) : "";

					// Build the line: left + center + pad + right
					const leftW = visibleWidth(left);
					const centerW = visibleWidth(center);
					const rightW = visibleWidth(right);
					const totalContent = leftW + centerW + rightW;

					let result: string;
					if (totalContent >= width) {
						// Not enough room — show left + center, truncate
						result = truncateToWidth(left + center, width);
					} else {
						const pad = " ".repeat(width - totalContent);
						result = left + center + pad + right;
					}

					return [truncateToWidth(result, width)];
				},
			};
		};
	}

	pi.on("session_start", async (_event, ctx) => {
		totalInputTokens = 0;
		totalOutputTokens = 0;
		totalCost = 0;
		ctx.ui.setFooter(makeFooter(ctx));
	});

	pi.on("turn_end", async (_event, ctx) => {
		// Recompute token stats from session
		totalInputTokens = 0;
		totalOutputTokens = 0;
		totalCost = 0;

		for (const e of ctx.sessionManager.getBranch()) {
			if (e.type === "message" && e.message.role === "assistant") {
				const m = e.message as AssistantMessage;
				totalInputTokens += m.usage.input;
				totalOutputTokens += m.usage.output;
				totalCost += m.usage.cost.total;
			}
		}
	});

	pi.on("model_select", async (event, ctx) => {
		// Re-render when model changes
		ctx.ui.setFooter(makeFooter(ctx));
	});
}

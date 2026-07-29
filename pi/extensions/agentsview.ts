import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { StringEnum } from "@earendil-works/pi-ai";
import { Type } from "typebox";

// Bridges pi to `agentsview`, the local Claude/Codex/Cursor session archive+search
// tool, so local models can interrogate session history conversationally.
// pi has no built-in MCP client, so this shells out to the agentsview CLI
// (which talks to the already-running agentsview daemon) instead of speaking
// MCP directly.

class AgentsviewError extends Error {
  stderr: string;
  constructor(message: string, stderr: string) {
    super(message);
    this.stderr = stderr;
  }
}

async function runAgentsview(pi: ExtensionAPI, args: string[], signal?: AbortSignal) {
  const result = await pi.exec("agentsview", [...args, "--json"], { signal, timeout: 30000 });
  if (result.code !== 0) {
    const msg = result.stderr || result.stdout;
    throw new AgentsviewError(`agentsview ${args.join(" ")} failed: ${msg}`, msg);
  }
  try {
    return JSON.parse(result.stdout);
  } catch {
    throw new Error(`agentsview returned non-JSON output: ${result.stdout.slice(0, 500)}`);
  }
}

// Embeddings live on a separate LM Studio slot from pi's own chat model, and
// LM Studio (here) is configured to evict whichever model isn't active. So
// semantic/hybrid search can go down mid-conversation simply because pi's own
// inference is running. Fail soft to fts instead of surfacing a raw 503 for
// the model to flail against — that's what caused a runaway 250k-token retry
// spiral the first time this was wired up.
function isEmbeddingsUnavailable(err: unknown) {
  const msg = err instanceof AgentsviewError ? err.stderr : String(err);
  return /embeddings endpoint is unavailable|No models loaded/i.test(msg);
}

// Sessions carry a `cwd` and `agent`; resuming requires running the matching
// CLI from that directory, which local models won't know without a hint.
function resumeHint(session: { cwd?: string; agent?: string; id?: string }) {
  if (!session?.cwd || !session?.id) return undefined;
  const cmd = session.agent === "codex" ? `codex resume ${session.id}` : `claude --resume ${session.id}`;
  return `cd ${session.cwd} && ${cmd}`;
}

// Raw session/search payloads can carry hundreds of records with long
// first_message strings. Feeding that straight into a small local model's
// context produces multi-hundred-thousand-token prompts that take many
// minutes to prefill and blow past pi's request timeout, causing an
// endless "terminated" -> retry -> "terminated" loop (see the 'busiest day'
// incident: history_list_sessions with no limit returned 200 full session
// records and locked up the chat model for 20+ minutes across 4 retries).
// Cap both array length and individual string length defensively, on every
// tool, regardless of what the model asked for.
const MAX_ITEMS = 25;
const MAX_STRING_LEN = 300;

function truncateStrings(value: any): any {
  if (typeof value === "string") {
    return value.length > MAX_STRING_LEN ? `${value.slice(0, MAX_STRING_LEN)}…[truncated]` : value;
  }
  if (Array.isArray(value)) {
    return value.map(truncateStrings);
  }
  if (value && typeof value === "object") {
    const out: any = {};
    for (const [k, v] of Object.entries(value)) out[k] = truncateStrings(v);
    return out;
  }
  return value;
}

function capResult(payload: any) {
  payload = truncateStrings(payload);
  for (const key of ["sessions", "results", "matches", "messages"]) {
    const arr = payload?.[key];
    if (Array.isArray(arr) && arr.length > MAX_ITEMS) {
      const total = payload.total ?? arr.length;
      payload[key] = arr.slice(0, MAX_ITEMS);
      payload._capped = `Showing ${MAX_ITEMS} of ${total}. Narrow with date/project/agent filters, or use history_activity_report for aggregate questions (busiest day/week, totals) instead of paging through raw sessions.`;
    }
  }
  return payload;
}

function withResumeHints(payload: any) {
  if (Array.isArray(payload?.sessions)) {
    payload.sessions = payload.sessions.map((s: any) => ({ ...s, resume_hint: resumeHint(s) }));
  }
  if (Array.isArray(payload?.results)) {
    payload.results = payload.results.map((r: any) => ({ ...r, resume_hint: resumeHint(r) }));
  }
  if (payload?.id) {
    payload.resume_hint = resumeHint(payload);
  }
  return payload;
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "history_search",
    label: "Search agent history",
    description:
      "Search past Claude/Codex/Cursor coding-agent sessions (messages, tool calls, tool results) recorded by agentsview. Supports keyword, semantic, and hybrid search, with date/project filters.",
    promptSnippet: "Search past coding-agent session history (agentsview)",
    promptGuidelines: [
      "Use history_search to answer questions about past work, decisions, or 'what was I doing on <date>' instead of guessing.",
      "Use history_search with mode='semantic' or 'hybrid' for conceptual/fuzzy questions, and mode='fts' for exact keyword/error-message lookups.",
    ],
    parameters: Type.Object({
      query: Type.String({ description: "Search text" }),
      mode: Type.Optional(
        StringEnum(["keyword", "semantic", "hybrid", "fts"] as const, {
          description: "keyword (default substring/regex), semantic (vector), hybrid (semantic+fts fused), fts (fast tokenized full-text)",
        }),
      ),
      date: Type.Optional(Type.String({ description: "Sessions active on this exact YYYY-MM-DD" })),
      date_from: Type.Optional(Type.String({ description: "Sessions active on or after YYYY-MM-DD" })),
      date_to: Type.Optional(Type.String({ description: "Sessions active on or before YYYY-MM-DD" })),
      project: Type.Optional(Type.String({ description: "Restrict to this project name" })),
      agent: Type.Optional(Type.String({ description: "Restrict to this agent: claude, codex, cursor, ..." })),
      limit: Type.Optional(Type.Integer({ description: "Max results (default 50, max 500)" })),
      context: Type.Optional(Type.Integer({ description: "Messages of context before/after each match (max 10)" })),
    }),
    async execute(_toolCallId, params, signal) {
      const buildArgs = (mode: string) => {
        const args = ["session", "search", params.query];
        if (mode === "semantic") args.push("--semantic");
        else if (mode === "hybrid") args.push("--hybrid");
        else if (mode === "fts") args.push("--fts");
        if (params.date) args.push("--date", params.date);
        if (params.date_from) args.push("--date-from", params.date_from);
        if (params.date_to) args.push("--date-to", params.date_to);
        if (params.project) args.push("--project", params.project);
        if (params.agent) args.push("--agent", params.agent);
        if (params.limit) args.push("--limit", String(params.limit));
        if (params.context) args.push("--context", String(params.context));
        return args;
      };

      const mode = params.mode ?? "keyword";
      let payload: any;
      let fellBackToFts = false;
      try {
        payload = await runAgentsview(pi, buildArgs(mode), signal);
      } catch (err) {
        if ((mode === "semantic" || mode === "hybrid") && isEmbeddingsUnavailable(err)) {
          fellBackToFts = true;
          payload = await runAgentsview(pi, buildArgs("fts"), signal);
        } else {
          throw err;
        }
      }

      payload = capResult(withResumeHints(payload));
      if (fellBackToFts) {
        payload._note =
          "Semantic/hybrid search was unavailable (local embedding model is currently unloaded, likely evicted by pi's own chat model sharing the same LM Studio instance) — fell back to full-text search (fts) instead. Results are keyword-based, not conceptual.";
      }
      return {
        content: [{ type: "text", text: JSON.stringify(payload, null, 2) }],
        details: payload,
      };
    },
  });

  pi.registerTool({
    name: "history_list_sessions",
    label: "List agent sessions",
    description:
      "List past coding-agent sessions with structured filters (date range, project, agent, min message counts, outcome). Use this for browsing/overview instead of full-text search. Do NOT use this for aggregate questions like 'busiest day' or 'how much did I work this week' — use history_activity_report instead, which is far cheaper.",
    promptSnippet: "List past coding-agent sessions with filters (agentsview)",
    promptGuidelines: [
      "Use history_activity_report, not history_list_sessions, for 'busiest day/week', totals, or other aggregate questions — listing every session and counting by hand is slow and wastes context.",
    ],
    parameters: Type.Object({
      date: Type.Optional(Type.String({ description: "Sessions active on this exact YYYY-MM-DD" })),
      date_from: Type.Optional(Type.String()),
      date_to: Type.Optional(Type.String()),
      since: Type.Optional(Type.String({ description: "Relative duration, e.g. 12h, 14d, 2w, 3m, 1y, or YYYY-MM-DD" })),
      project: Type.Optional(Type.String()),
      agent: Type.Optional(Type.String()),
      limit: Type.Optional(Type.Integer({ description: "Max sessions to return (default 20, max 500). Keep this small — results are truncated to 25 regardless." })),
      sort: Type.Optional(Type.String({ description: "e.g. 'messages:desc' or 'started:asc'" })),
    }),
    async execute(_toolCallId, params, signal) {
      const args = ["session", "list", "--limit", String(params.limit ?? 20)];
      if (params.date) args.push("--date", params.date);
      if (params.date_from) args.push("--date-from", params.date_from);
      if (params.date_to) args.push("--date-to", params.date_to);
      if (params.since) args.push("--since", params.since);
      if (params.project) args.push("--project", params.project);
      if (params.agent) args.push("--agent", params.agent);
      if (params.sort) args.push("--sort", params.sort);

      const payload = capResult(withResumeHints(await runAgentsview(pi, args, signal)));
      return {
        content: [{ type: "text", text: JSON.stringify(payload, null, 2) }],
        details: payload,
      };
    },
  });

  pi.registerTool({
    name: "history_session_overview",
    label: "Get session overview",
    description: "Get metadata (project, dates, message counts, outcome, resume command) for one past coding-agent session by id.",
    promptSnippet: "Get metadata for one past session by id (agentsview)",
    parameters: Type.Object({
      session_id: Type.String({ description: "Session id (or unique id prefix) from history_search/history_list_sessions" }),
    }),
    async execute(_toolCallId, params, signal) {
      const payload = capResult(withResumeHints(await runAgentsview(pi, ["session", "get", params.session_id], signal)));
      return {
        content: [{ type: "text", text: JSON.stringify(payload, null, 2) }],
        details: payload,
      };
    },
  });

  pi.registerTool({
    name: "history_messages",
    label: "Get session messages",
    description:
      "Read a window of messages from one past coding-agent session by id. Use after history_search/history_session_overview to read full context around a match.",
    promptSnippet: "Read a window of messages from one past session (agentsview)",
    promptGuidelines: [
      "Use history_messages with 'around' set to a matched ordinal from history_search to read surrounding context.",
    ],
    parameters: Type.Object({
      session_id: Type.String(),
      around: Type.Optional(Type.Integer({ description: "Center the window on this message ordinal" })),
      before: Type.Optional(Type.Integer({ description: "Messages before 'around' (default 5)" })),
      after: Type.Optional(Type.Integer({ description: "Messages after 'around' (default 5)" })),
      from: Type.Optional(Type.Integer({ description: "Starting ordinal (inclusive)" })),
      limit: Type.Optional(Type.Integer()),
      role: Type.Optional(Type.String({ description: "Comma-separated roles, e.g. user,assistant" })),
    }),
    async execute(_toolCallId, params, signal) {
      const args = ["session", "messages", params.session_id];
      if (params.around !== undefined) args.push("--around", String(params.around));
      if (params.before !== undefined) args.push("--before", String(params.before));
      if (params.after !== undefined) args.push("--after", String(params.after));
      if (params.from !== undefined) args.push("--from", String(params.from));
      if (params.limit !== undefined) args.push("--limit", String(params.limit));
      if (params.role) args.push("--role", params.role);

      const payload = capResult(await runAgentsview(pi, args, signal));
      return {
        content: [{ type: "text", text: JSON.stringify(payload, null, 2) }],
        details: payload,
      };
    },
  });

  pi.registerTool({
    name: "history_activity_report",
    label: "Activity report",
    description: "Get a bucketed activity/token-usage report over a date range or preset (day/week/month) across past coding-agent sessions.",
    promptSnippet: "Get an activity report over a date range (agentsview)",
    promptGuidelines: ["Use history_activity_report for 'what did I work on today/this week' style questions instead of history_search."],
    parameters: Type.Object({
      preset: Type.Optional(StringEnum(["day", "week", "month", "custom"] as const)),
      date: Type.Optional(Type.String({ description: "Anchor date YYYY-MM-DD for the preset" })),
      from: Type.Optional(Type.String({ description: "RFC3339 start for preset=custom" })),
      to: Type.Optional(Type.String({ description: "RFC3339 end for preset=custom" })),
      project: Type.Optional(Type.String()),
      agent: Type.Optional(Type.String()),
    }),
    async execute(_toolCallId, params, signal) {
      const args = ["activity", "report"];
      if (params.preset) args.push("--preset", params.preset);
      if (params.date) args.push("--date", params.date);
      if (params.from) args.push("--from", params.from);
      if (params.to) args.push("--to", params.to);
      if (params.project) args.push("--project", params.project);
      if (params.agent) args.push("--agent", params.agent);

      const payload = capResult(await runAgentsview(pi, args, signal));
      return {
        content: [{ type: "text", text: JSON.stringify(payload, null, 2) }],
        details: payload,
      };
    },
  });
}

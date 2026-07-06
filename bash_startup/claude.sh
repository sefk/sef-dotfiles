# Claude Code against local Ollama — zero Anthropic quota.
#
# Ollama >= 0.14 speaks the Anthropic Messages API natively, so no proxy is
# needed; the auth token is required-but-ignored. The base-URL override is
# per-invocation only: your claude.ai login stays saved and untouched, and
# plain `claude` keeps using the subscription.
#
# Model notes (tested 2026-07-03, ollama 0.24.0):
# - qwen3.6:35b-a3b-mxfp8 — tool calling works end-to-end; good comprehension
#   and summarization, but code judgments can be confidently wrong (invented
#   a plausible awk "bug" that wasn't one). Use for mechanical work: triage,
#   summaries, drafts, log spelunking — not unreviewed code changes.
# - qwen3-coder:30b — BROKEN via this path: emits tool calls as literal
#   <function=...> text (chat-template mismatch), so the agent loop stalls.
#
# Why acceptEdits + a long timeout (not the global "auto" mode): auto mode runs
# an extra safety-classifier inference before every non-read tool. On a slow
# local model that call carries the full ~50K-token context, takes 40s-3min,
# and — fatally — times out when several fire at once (e.g. parallel subagents),
# yielding "<model> is temporarily unavailable, auto mode cannot determine the
# safety of ...". acceptEdits skips the classifier entirely; API_TIMEOUT_MS
# keeps long single generations from being cut off at the default ~60s.
#
# Overrides:
#   CLAUDE_LOCAL_MODEL=qwen3:32b claude-local
#   CLAUDE_LOCAL_URL=http://studio:11434 claude-local     # from the laptop
#     (needs OLLAMA_HOST=0.0.0.0 on studio's ollama for LAN access)
#   CLAUDE_LOCAL_PERMISSION_MODE=bypassPermissions claude-local   # fully hands-off
#   CLAUDE_LOCAL_TIMEOUT_MS=1200000 claude-local          # even slower models
#
# Sourced by bash via the bash_startup loop and by zshrc via test_and_source.

function claude-local {
    ANTHROPIC_BASE_URL="${CLAUDE_LOCAL_URL:-http://localhost:11434}" \
    ANTHROPIC_AUTH_TOKEN="ollama" \
    API_TIMEOUT_MS="${CLAUDE_LOCAL_TIMEOUT_MS:-600000}" \
    claude --permission-mode "${CLAUDE_LOCAL_PERMISSION_MODE:-acceptEdits}" \
           --model "${CLAUDE_LOCAL_MODEL:-qwen3.6:35b-a3b-mxfp8}" "$@"
}

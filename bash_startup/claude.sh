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
# Overrides:
#   CLAUDE_LOCAL_MODEL=qwen3:32b claude-local
#   CLAUDE_LOCAL_URL=http://studio:11434 claude-local     # from the laptop
#     (needs OLLAMA_HOST=0.0.0.0 on studio's ollama for LAN access)
#
# Sourced by bash via the bash_startup loop and by zshrc via test_and_source.

function claude-local {
    ANTHROPIC_BASE_URL="${CLAUDE_LOCAL_URL:-http://localhost:11434}" \
    ANTHROPIC_AUTH_TOKEN="ollama" \
    claude --model "${CLAUDE_LOCAL_MODEL:-qwen3.6:35b-a3b-mxfp8}" "$@"
}

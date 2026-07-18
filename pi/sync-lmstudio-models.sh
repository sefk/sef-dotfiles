#!/usr/bin/env bash
# Regenerate pi's lmstudio provider model allowlist from LM Studio's live model list.
# LM Studio is the source of truth; run this after downloading/removing models.
#
#   ./sync-lmstudio-models.sh
#   LMS_URL=http://otherhost:1234 ./sync-lmstudio-models.sh
set -euo pipefail

LMS_URL="${LMS_URL:-http://localhost:1234}"
MODELS_JSON="${MODELS_JSON:-$HOME/src/sef-dotfiles/pi/models.json}"

# jq template: turn one LM Studio model record into a pi model entry.
# NOTE: assumes reasoning-capable Qwen chat models. Adjust reasoning/thinkingFormat
# if you add non-Qwen or non-reasoning models.
entry_from() {
  jq "$1"'
    | {
        id: .id,
        name: .id,
        reasoning: true,
        contextWindow: ($ctx),
        maxTokens: 32768,
        compat: { thinkingFormat: "qwen-chat-template" }
      }'
}

# Prefer LM Studio's native REST API (has max_context_length + a type field);
# fall back to the OpenAI-compatible endpoint (ids only).
if native=$(curl -sf "$LMS_URL/api/v0/models" 2>/dev/null) && [ -n "$native" ]; then
  entries=$(echo "$native" | jq '[.data[]
    | select(.type != "embeddings")
    | { id, name: .id, reasoning: true,
        contextWindow: (.max_context_length // 262144),
        maxTokens: 32768,
        compat: { thinkingFormat: "qwen-chat-template" } }]')
else
  echo "native API unavailable, falling back to /v1/models (no context length)" >&2
  entries=$(curl -sf "$LMS_URL/v1/models" | jq '[.data[]
    | select(.id | test("embed") | not)
    | { id, name: .id, reasoning: true,
        contextWindow: 262144,
        maxTokens: 32768,
        compat: { thinkingFormat: "qwen-chat-template" } }]')
fi

tmp=$(mktemp)
jq --argjson models "$entries" '.providers.lmstudio.models = $models' "$MODELS_JSON" > "$tmp"
mv "$tmp" "$MODELS_JSON"
echo "Synced $(echo "$entries" | jq length) lmstudio model(s) into $MODELS_JSON:"
echo "$entries" | jq -r '.[].id | "  - \(.)"'

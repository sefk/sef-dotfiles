#!/bin/bash
# PreToolUse hook for Bash: allow everything EXCEPT a short list of
# dangerous patterns that should prompt for confirmation.
#
# Dangerous = publishes work, affects shared state, or deletes source files.
# Everything else (curl GET, node, python, docker, etc.) runs freely.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

ALLOW='{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":"Auto-allowed by hook"}}'
ASK='{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"Potentially destructive — confirming with user"}}'

# ── 1. Dangerous git commands → prompt ──────────────────────────────
if echo "$COMMAND" | grep -qE '(^|&&|;|\|)\s*git\s+push(\s|$)'; then
  echo "$ASK"; exit 0
fi
if echo "$COMMAND" | grep -qE '(^|&&|;|\|)\s*git\s+reset\s+--hard(\s|$)'; then
  echo "$ASK"; exit 0
fi
if echo "$COMMAND" | grep -qE '(^|&&|;|\|)\s*git\s+clean\s+-[a-zA-Z]*f'; then
  echo "$ASK"; exit 0
fi
if echo "$COMMAND" | grep -qE '(^|&&|;|\|)\s*git\s+branch\s+-[dD]\s'; then
  echo "$ASK"; exit 0
fi
if echo "$COMMAND" | grep -qE '(^|&&|;|\|)\s*git\s+checkout\s+--\s'; then
  echo "$ASK"; exit 0
fi
if echo "$COMMAND" | grep -qE '(^|&&|;|\|)\s*git\s+restore\s'; then
  echo "$ASK"; exit 0
fi
if echo "$COMMAND" | grep -qE '(^|&&|;|\|)\s*git\s+rebase(\s|$)'; then
  echo "$ASK"; exit 0
fi

# ── 2. Dangerous gh commands (merge/delete only) → prompt ──────────
# create/close/comment/edit/reopen/review auto-allow; merge & delete
# are the hard-to-undo ones worth confirming.
if echo "$COMMAND" | grep -qE '(^|&&|;|\|)\s*gh\s+(pr|issue)\s+(merge|delete)(\s|$)'; then
  echo "$ASK"; exit 0
fi

# ── 3. rm — allow on build artifacts, prompt on everything else ─────
if echo "$COMMAND" | grep -qE '(^|&&|;|\|)\s*rm\s'; then
  if echo "$COMMAND" | grep -qE '\brm\s+(-[rfRF]+\s+)?(dist|node_modules|\.cache|\.next|\.expo|build|__generated__|\.turbo|\.parcel-cache|coverage|\.nyc_output|tmp|\.tmp)\b'; then
    echo "$ALLOW"; exit 0
  fi
  if echo "$COMMAND" | grep -qE '\brm\s+(-[rfRF]+\s+)?\S*(dist|node_modules|\.cache|\.next|\.expo|/build/|__generated__|\.turbo|\.parcel-cache|coverage|\.nyc_output|/tmp/|\.tmp)\S*'; then
    echo "$ALLOW"; exit 0
  fi
  echo "$ASK"; exit 0
fi

# ── 4. sudo → prompt ───────────────────────────────────────────────
if echo "$COMMAND" | grep -qE '(^|&&|;|\|)\s*sudo\s'; then
  echo "$ASK"; exit 0
fi

# ── 5. kill/killall/pkill → prompt ─────────────────────────────────
if echo "$COMMAND" | grep -qE '(^|&&|;|\|)\s*(kill|killall|pkill)\s'; then
  echo "$ASK"; exit 0
fi

# ── 6. brew install/uninstall → prompt ─────────────────────────────
if echo "$COMMAND" | grep -qE '(^|&&|;|\|)\s*brew\s+(install|uninstall|remove)(\s|$)'; then
  echo "$ASK"; exit 0
fi

# ── 7. curl with mutating methods or POST data → prompt ────────────
if echo "$COMMAND" | grep -qE '(^|&&|;|\|)\s*curl\s'; then
  if echo "$COMMAND" | grep -qE 'curl\s.*(-X\s*(POST|PUT|DELETE|PATCH)|-d\s|--data|--data-raw|--data-binary|--data-urlencode|-F\s|--form)'; then
    echo "$ASK"; exit 0
  fi
fi

# ── 8. Everything else → allow ──────────────────────────────────────
echo "$ALLOW"
exit 0

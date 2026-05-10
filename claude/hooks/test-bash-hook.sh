#!/bin/bash
# Tests for allow-readonly-bash.sh hook
# Run: bash ~/.claude/hooks/test-bash-hook.sh

HOOK="/Users/sefk/.claude/hooks/allow-readonly-bash.sh"
PASS=0
FAIL=0

check() {
  local expected="$1" label="$2" command="$3"
  local result
  result=$(echo "{\"tool_input\":{\"command\":\"$command\"}}" | "$HOOK" | jq -r '.hookSpecificOutput.permissionDecision')
  if [ "$result" = "$expected" ]; then
    printf "  ✓ %s\n" "$label"
    PASS=$((PASS + 1))
  else
    printf "  ✗ %s (expected %s, got %s)\n" "$label" "$expected" "$result"
    FAIL=$((FAIL + 1))
  fi
}

echo "── Should PROMPT ──"
check ask "git push"                    "git push origin main"
check ask "git push (no args)"          "git push"
check ask "git reset --hard"            "git reset --hard HEAD~1"
check ask "git clean -fd"               "git clean -fd"
check ask "git branch -D"              "git branch -D feature-branch"
check ask "git branch -d"              "git branch -d feature-branch"
check ask "git checkout --"            "git checkout -- src/file.ts"
check ask "git restore"                "git restore src/file.ts"
check ask "git rebase"                 "git rebase main"
check ask "git rebase (no args)"       "git rebase"
check ask "gh pr create"               "gh pr create --title test"
check ask "gh pr close"                "gh pr close 42"
check ask "gh pr merge"                "gh pr merge 42"
check ask "gh pr edit"                 "gh pr edit 42 --title new"
check ask "gh pr comment"              "gh pr comment 42 --body hi"
check ask "gh issue create"            "gh issue create --title bug"
check ask "gh issue close"             "gh issue close 42"
check ask "gh issue edit"              "gh issue edit 42 --title new"
check ask "gh issue comment"           "gh issue comment 42 --body hi"
check ask "gh issue delete"            "gh issue delete 42"
check ask "rm source files"            "rm -rf src/components"
check ask "rm random path"             "rm file.txt"
check ask "git push in chain"          "git add -A && git commit -m test && git push"
check ask "sudo anything"              "sudo rm -rf /tmp/foo"
check ask "sudo in chain"              "echo hi && sudo ls /root"
check ask "kill process"               "kill 12345"
check ask "killall process"            "killall node"
check ask "pkill process"              "pkill -f 'node server'"
check ask "brew install"               "brew install jq"
check ask "brew uninstall"             "brew uninstall jq"
check ask "brew remove"                "brew remove jq"
check ask "curl POST"                  "curl -X POST https://api.example.com/data"
check ask "curl PUT"                   "curl -X PUT https://api.example.com/data"
check ask "curl DELETE"                "curl -X DELETE https://api.example.com/item/1"
check ask "curl -d"                    "curl -d 'key=val' https://api.example.com"
check ask "curl --data"                "curl --data 'foo=bar' https://api.example.com"
check ask "curl -F form"               "curl -F 'file=@test.txt' https://api.example.com"

echo ""
echo "── Should ALLOW ──"
check allow "rm dist"                   "rm -rf dist"
check allow "rm node_modules"           "rm -rf node_modules"
check allow "rm .cache"                 "rm -rf .cache"
check allow "rm .next"                  "rm -rf .next"
check allow "rm build"                  "rm -rf build"
check allow "rm coverage"              "rm -rf coverage"
check allow "rm with path to dist"     "rm -rf apps/native/dist"
check allow "gh issue list"            "gh issue list"
check allow "gh issue view"            "gh issue view 311"
check allow "gh pr list"               "gh pr list"
check allow "gh pr view"               "gh pr view 311"
check allow "gh api read"              "gh api repos/foo/bar/issues"
check allow "gh search"                "gh search issues test"
check allow "git status"               "git status"
check allow "git diff"                 "git diff HEAD"
check allow "git log"                  "git log --oneline -5"
check allow "git add"                  "git add src/file.ts"
check allow "git commit"               "git commit -m test"
check allow "curl GET"                 "curl -s https://example.com"
check allow "curl with headers"        "curl -H 'Accept: application/json' https://api.example.com"
check allow "docker run"               "docker run -it ubuntu bash"
check allow "docker build"             "docker build -t myapp ."
check allow "chmod"                    "chmod +x script.sh"
check allow "python"                   "python3 script.py"
check allow "node"                     "node -e 'console.log(1)'"
check allow "brew list"                "brew list"
check allow "brew search"              "brew search jq"
check allow "brew info"                "brew info jq"
check allow "ls"                       "ls -la apps/web"
check allow "cat"                      "cat package.json"
check allow "echo"                     "echo hello"
check allow "jq"                       "jq '.version' package.json"

echo ""
echo "── Results: $PASS passed, $FAIL failed ──"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1

<!--
  Shared, vendor-neutral global instructions for all coding agents.
  Canonical source: this repo's config/agents/GLOBAL.md, linked to
  ~/.config/agents/GLOBAL.md. Claude imports it via `@~/.config/agents/GLOBAL.md`
  in ~/.claude/CLAUDE.md; other agents pull it in per their own mechanism.
  Keep this file tool-agnostic -- put per-vendor specifics in that vendor's
  own instructions file, not here.
-->

## Preferences

- Python
- Django
- uv

## Work style

<!-- this section largely cribbed from jinpa -->

- For simple, obvious, non-destructive tasks: just do it without asking for confirmation.
- For anything non-trivial, ambiguous, or destructive: show a brief plan first and wait for approval before starting.
- Keep responses concise. No trailing summaries, no restating what you just did.
- Use sub-agents for parallel work when tasks are independent (research, searching, running tests alongside other work).
- When finished with a task, run the relevant tests or build step before saying "done." If something fails, fix it. I get a chance to test and review before anything is merged to master or pushed. For complex bash operations, break them into simple sequential commands rather than nested pipes.

When monitoring long-running tasks, especially with production / other servers:
- Poll for forward progress and watch log files rather than sleep and wait for a positive outcome.
- Predict how long a task will take beforehand and then measure progress against that prediction. If something is taking much longer than predicted, investigate and consider another approach.

## Minimize the number of approvals

* Use `auto` / non-interactive permissions mode when possible
* Bash is also guarded by a read-only-bash hook that blocks dangerous commands
* Sandbox is disabled (causes issues with local database connections and other dev tools)
* Prefer writing local scripts to heredocs. Use temp directories in this order
  `./.tmp/`,
  `./tmp`, 
  `/tmp`.
* Since the `gh` command often triggers warnings, prefer the GitHub MCP when available
* Prefer calling tools individually instead of batching them up into chained "bash" tool call.
* You are allowed to stop processes that you create

## Version Control

Use Git for version control hosted at GitHub.

Git policies

- Commit autonomously at natural checkpoints (task complete, tests pass) — don't ask first and don't wait for me to say "commit this". Write a good message and just commit.
- Multi-step or exploratory work goes on a working branch, not the default branch (main/master); I review, squash, and merge working branches myself. A small self-contained change may be committed directly on the current branch.
- When doing multiple changes concurrently, commit each change separately.
- Never push; I review and push to GitHub myself.
- I'll do pull requests myself.
- You can always `git fetch`.
- You can do fast-forward only merges.
- Never rebase changes that have already been pushed to GitHub.

Use the `gh` command line utility to update issues on GitHub. You don't need permissions to read or write issues using `gh issues`.

When adding comments to pull requests and issues, make it clear the comment is authored by you — name yourself specifically (e.g. Claude or Codex), since it will be presented under sefk credentials. This is not necessary for commit messages, as those already carry co-author attribution naming the actual tool.

## Reviewing changes in hunk

When I have a `hunk` session open (a review-first terminal diff viewer) and ask
you — Claude or Codex — to review changes, don't dump the review into chat.
Load the hunk review skill (`hunk skill path` prints its location) and leave
inline comments in the live session via `hunk session comment ...`, beside the
code they describe. The TUI is mine; drive it only through `hunk session *`.
Launch: I run `hunk diff --watch` (or `/diff --hunk`).

## Engineering Rules

Work carefully

- If there are tests, run them before considering work done.
- When making code changes, look for tests and fix them while making changes.
- When writing new features, write new tests.
- Verify visible changes by looking at them before saying "done": screenshot web UI with a headless browser, `tmux capture-pane` for TUI/CLI output. Never claim a visual fix works without having seen it.

Work effectively

- When something fails, add logging or diagnostics first to find the root cause. Don't make speculative fixes.
- If the same approach fails 2-3 times, stop and try a different approach instead of going in circles.

Keep things tidy

- When making changes that affect README files or other docs, update them proactively. Include those changes in same commit.
- When writing markdown, use reference-style links instead of inline links.

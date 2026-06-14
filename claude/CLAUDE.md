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
- When finished with a task, run the relevant tests or build step before saying "done." If something fails, fix it. Then let me test too before committing or pushing. For complex bash operations, break them into simple sequential commands rather than nested pipes.

When monitoring long-running tasks, especially with production / other servers:
- Poll for forward progress and watch log files rather than sleep and wait for a positive outcome.
- Predict how long a task will take beforehand and then measure progress against that prediction. If something is taking much longer than predicted, investigate and consider another approach.

## Minimize the number of approvals

* Use `auto` permissions mode when possible
* Bash permissions are also guarded by a PreToolUse hook (`~/.claude/hooks/allow-readonly-bash.sh`) that blocks dangerous commands
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

- I prefer Claude to suggest commit messages. I'd like an opportunity to edit the commit message before it's done, but usually I'll accept Claude's suggestion.
- When doing multiple changes concurrently, commit each change separately.
- I always want to review changes before push; I'll push to GitHub myself.
- I'll do pull requests myself.
- Claude can always `git fetch`.
- Claude can do fast-forward only merges.
- Never rebase changes that have already been pushed to GitHub.

Use the `gh` command line utility to update issues on GitHub. Claude doesn't need permissions to read or write issues using `gh issues`.

When adding comments to pull requests and issues, make it clear that this comment is authored by Claude Code, since it will be presented under sefk credentials. This is not necessary for commit messages as those already have co-author attribution.

## Engineering Rules

Work carefully

- If there are tests, run them before considering work done.
- When making code changes, look for tests and fix them while making changes.
- When writing new features, write new tests.

Work effectively

- When something fails, add logging or diagnostics first to find the root cause. Don't make speculative fixes.
- If the same approach fails 2-3 times, stop and try a different approach instead of going in circles.

Keep things tidy

- When making changes that affect README files or other docs, update them proactively. Include those changes in same commit.
- When writing markdown, use reference-style links instead of inline links.

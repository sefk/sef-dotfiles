## Work style

<!-- this section largely cribbed from jinpa -->

- For simple, obvious, non-destructive tasks: just do it without asking for confirmation.
- For anything non-trivial, ambiguous, or destructive: show a brief plan first and wait for approval before starting.
- Keep responses concise. No trailing summaries, no restating what you just did.
- Use sub-agents for parallel work when tasks are independent (research, searching, running tests alongside other work).
- When finished with a task, run the relevant tests or build step before saying "done." If something fails, fix it. Then let me test too before committing or pushing. For complex bash operations, break them into simple sequential commands rather than nested pipes.

## Minimize the number of approvals

* Use `auto` permissions mode when possible
* Sandbox is disabled (causes issues with local database connections and other dev tools)
* Prefer writing local scripts to heredocs. Use temp directories in this order
  `./.tmp/`,
  `./tmp`, 
  `/tmp`.
* Since the `gh` command often triggers warnings, prefer the github MCP when available
* Prefer calling tools individually instead of batching them up into chained "bash" tool call.

## Version Control

Use Git for version control hosted at GitHub.

Git policies

- I prefer Claude to suggest commit messages. I'd like an opportunity to edit the commit message before it's done, but usually I'll accept Claude's suggestion.
- I always want to review changes before push.
- Claude can always `git fetch`.
- Claude can do fast-forward only merges.
- Never rebase.
- When doing multiple changes concurrently, commit each change separately.

Use the `gh` command line utility to update issues on GitHub. Claude doesn't need permissions to read or write issues using `gh issues`.

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

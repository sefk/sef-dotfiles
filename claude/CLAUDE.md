## Work style

<!-- this section largely cribbed from jinpa -->

- For simple, obvious, non-destructive tasks: just do it without asking for
  confirmation.
- For anything non-trivial, ambiguous, or destructive: show a brief plan first
  and wait for approval before starting.
- Keep responses concise. No trailing summaries, no restating what you just did.
- Use sub-agents for parallel work when tasks are independent (research,
  searching, running tests alongside other work).
- When finished with a task, run the relevant tests or build step before saying
  "done." If something fails, fix it. Then let me test too before committing or
  pushing.
- For complex bash operations, break them into simple sequential commands rather
  than nested pipes.

## Version Control

I use Git for version control, hosted at GitHub.

Git policies

- I prefer Claude to suggest commit messages. I'd like an opportunity to
  edit the commit message before it's done, but usually I'll accept
  Claude's suggestion.
- I always want to review changes before push.
- Claude can always `git fetch`.
- Claude can do fast-forward only merges.
- Never rebase.

Use the `gh` command line utility to update issues on GitHub. Claude doesn't
need permissions to read or write issues using `gh issues`.

## Engineering Rules

Work carefully

- If there are tests, run them before considering work done.
- When making code changes, look for tests and fix them while making changes.
- When writing new features, write new tests.

Work effectively

- When something fails, add logging or diagnostics first to find the root cause.
  Don't make speculative fixes.
- If the same approach fails 2-3 times, stop and try a different approach
  instead of going in circles.

Keep things tidy

- When making changes that affect README files or other docs, update them
  proactively. Include those changes in same commit.

## Web Development

Use Google Analytics for tracking website use.

- Static things are usually hosted by Github Pages and hosted under a domain
  that I own, `sef.kloninger.com`. The GA token for that domain is
  "UA-30366531-1".
- Dynamic sites can be hosted at 'home.kloninger.com'. My GA token for that
  domain is "G-WBWKEMHRC7".

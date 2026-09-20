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

Two workflows, chosen per repo. Default is **individual**; a repo is **team**
only when its `.wtconfig` sets `TASK_TEAM=1` (see `wt`/`task`) — today that's
just DataTalk.

- **Team** — pull requests, sibling worktrees per issue.
- **Individual** — no PRs, no worktrees. Work happens directly on `main`, or
  occasionally a short-lived feature branch that lives in the main checkout
  and gets merged or rebased back into `main` by me, locally — it never
  becomes a PR.
- **Both** — issue-driven development, `fix-issue` to implement, and a
  `codex-review` pass before calling anything done.

Git policies

- Commit autonomously at natural checkpoints (task complete, tests pass) — don't ask first and don't wait for me to say "commit this". Write a good message and just commit.
- Team repos: multi-step or exploratory work goes on a working branch, not the default branch (main/master); I review, squash, and merge it myself via a PR I open. A small self-contained change may still land directly on the current branch.
- Individual repos: work goes straight on the current branch (usually `main`) unless it needs a feature branch to stay reviewable or reversible; that branch is mine to merge or rebase back into `main` — don't propose or open a PR for it.
- Branch names use dashes, never slashes: `fix-628-masthead-freshness`, not `fix/628-masthead-freshness`. Underscores are fine.
- When doing multiple changes concurrently, commit each change separately.
- Never push; I review and push to GitHub myself.
- Team repos: I'll do pull requests myself.
- You can always `git fetch`.
- You can do fast-forward only merges.
- Never rebase changes that have already been pushed to GitHub.

Worktrees (team repos only — individual repos work directly in the main checkout)

- Issue work happens in a **sibling worktree**, never in the main checkout:
  `../<repo>-<N>` on branch `issue-<N>-<slug>`. I create it with `wt <N>
  <slug>`; the main checkout stays parked on the default branch so concurrent
  tasks can't collide.
- **Never create a worktree yourself** — no `isolation: "worktree"`, no
  `EnterWorktree`, no `git worktree add` into `.claude/worktrees/` or
  `.worktrees/`. The one exception is `wt` itself, run on my behalf by the
  `new-space` skill (or the `task` skill's *new* verb): those may run
  `wt -y <N> <slug>`, which prints its plan before it acts. Anywhere else, if
  a task needs isolation, say so and let me run `wt <N>` — or offer
  `/new-space <N> <slug>`, which also builds the herdr workspace and starts
  an agent there.
- Worktrees share the main checkout's `.env`/`.envrc` (symlinked by `wt`) and
  the one already-running local service stack. Don't stand up a second
  database or duplicate stack per worktree; `wt` assigns a distinct app port.

Issues and closing

- **Never close an issue while work is in flight.**
  - Team repos: GitHub closes it at merge — when the branch is
    `issue-<N>-*`, the PR body must contain `Closes #<N>`. Add that line
    whenever you open a PR for issue work.
  - Individual repos: nothing closes it automatically. Once the fix is
    merged/rebased into `main`, close the issue yourself with a comment
    naming the commit(s).
- Comment on the issue with progress (branch, what changed, test results) and
  leave it open until then. Closing is the merge's job — or, in an individual
  repo, the last step right after it.

Use the `gh` command line utility to update issues on GitHub. You don't need permissions to read or write issues using `gh issues`.

When adding comments to pull requests and issues, make it clear the comment is authored by you — name yourself specifically (e.g. Claude or Codex), since it will be presented under sefk credentials. This is not necessary for commit messages, as those already carry co-author attribution naming the actual tool.

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

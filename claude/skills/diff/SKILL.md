---
name: diff
description: Review uncommitted git changes in hunk, pager, VSCode, or FileMerge
argument-hint: "[--hunk | --filemerge | --vscode]"
allowed-tools: Bash(git:*), Bash(code:*), Bash(opendiff:*), Bash(hunk:*)
---

# Review Git Diff

Show the current uncommitted changes.

## Current changes

!`git diff --stat HEAD 2>/dev/null || echo "(no changes)"`

## Instructions

1. If the argument is `--filemerge`, open each changed file using `opendiff`:
   - Run `git diff --name-only HEAD` to get the list of changed files
   - For each file, run: `opendiff <(git show HEAD:<file>) <file>`

2. If the argument is `--vscode`, open VSCode:
   - Run `code .` to open the repo in VSCode
   - Tell the user to click the Source Control tab (or press ⌃⇧G) to review the diff visually

3. If the argument is `--hunk`, open hunk's review-first TUI (auto-reloads as the tree changes):
   - Tell the user to type: `! hunk diff --watch`
   - The `!` prefix runs it interactively so the full-screen TUI takes over their terminal.
   - Do NOT run this via the Bash tool — hunk is a TUI meant for the user, not for capture.
   - Once it's open, the user can ask you to review; use the `hunk-review` skill to
     inspect the session and leave inline comments via `hunk session comment ...`.

4. Otherwise (default), show colorized diff in the user's pager:
   - Tell the user to type: `! git diff --color HEAD | less -R`
   - The `!` prefix runs it interactively in their terminal so the pager works.
   - Do NOT run this via the Bash tool — it captures output instead of opening the pager.

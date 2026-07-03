---
name: diff
description: Review uncommitted git changes in pager, VSCode, or FileMerge
argument-hint: "[--filemerge | --vscode]"
allowed-tools: Bash(git:*), Bash(code:*), Bash(opendiff:*)
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

3. Otherwise (default), show colorized diff in the user's pager:
   - Tell the user to type: `! git diff --color HEAD | less -R`
   - The `!` prefix runs it interactively in their terminal so the pager works.
   - Do NOT run this via the Bash tool — it captures output instead of opening the pager.

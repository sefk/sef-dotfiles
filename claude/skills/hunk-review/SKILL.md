---
name: hunk-review
description: Interacts with live Hunk diff review sessions via CLI — inspect the review focus, navigate files/hunks, reload contents, and leave inline review comments. Use when the user has a Hunk session open or asks to review a diff interactively in hunk.
---

# Hunk review (loader)

`hunk` is a review-first terminal diff viewer for agent-authored changesets.
The user keeps the full-screen TUI open; you steer it and drop inline comments
through `hunk session *` CLI commands. Never run `hunk diff` / `hunk show`
yourself — those launch the user's interactive view.

The authoritative, always-current instructions ship with the installed hunk
package, so load them before acting rather than relying on this file:

1. Run `hunk skill path` to get the SKILL.md path for the installed version.
2. Read that file and follow it. It documents the full
   `hunk session list | get | context | review | navigate | reload | comment`
   surface, session selection (`--repo .`), and the batch
   `hunk session comment apply --stdin` flow.

Setup fallbacks:

- If `hunk` isn't installed: `brew install hunk` (it's in this repo's `brewlist`).
- If no session is running: ask the user to launch `hunk diff --watch` first
  (or `/diff --hunk`).

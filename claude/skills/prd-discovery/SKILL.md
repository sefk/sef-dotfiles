---
name: prd-discovery
description: Explore an unfamiliar problem space, then write a PRD. Use whenever the user is scoping new work, is unsure what to build, says things like "I'm thinking about building X", "should we do Y", "help me figure out what this should be", or asks for a PRD, spec, design doc, or one-pager — even if they never say the word PRD. Also use when a request names a solution but never states the underlying problem.
---

# PRD Discovery

Two phases, in order: **explore**, then **write**. Do not merge them.

The failure this prevents: reading a one-line problem statement and producing a confident, well-formatted PRD full of invented requirements. Discovery that happens silently inside a single response is not discovery.

## Phase 1 — Explore

Create `docs/prd/<slug>/` and write `discovery.md` continuously as you go, not at the end. Long exploration sessions run out of context; the file is what survives.

Draw on, in this order:

1. **The codebase.** What already exists that touches this? Which abstractions would have to bend? What did someone already try and abandon? Cite paths.
2. **The data.** If this touches a dataset, API, or external feed, read actual records. Field semantics are where scoping assumptions die — "what does this source actually put in this field" is a discovery question, not an implementation detail.
3. **The user.** Ask in batches of 3–5, not one at a time. Prefer questions whose answers would change the design. Skip questions whose answers are already implied by the repo or the conversation.
4. **Outside context**, when relevant — prior art, how comparable tools solved it.

Tag every claim in `discovery.md`:

- `[confirmed]` — the user said it, or you read it in code or data
- `[assumed]` — you are filling a gap

Never leave a claim untagged. Unmarked confidence is the main way PRDs go wrong.

## The disconfirmation pass

Before drafting, add a section to `discovery.md` called "Why this might be the wrong problem" and argue it seriously:

- Is there a problem one level up that this one is a symptom of?
- Is the obvious solution already adequate? Is the status quo fine?
- Who would object, and what is their strongest argument?

This is the step most likely to be skipped and the one most worth doing. The user has usually arrived with a framing already in mind; agreeing with it enthusiastically is not help.

## Gate

Stop here. Show the user:

- What you found, briefly
- Open questions that remain
- The assumptions the PRD would rest on

Then ask whether to proceed. Do not draft until they say so. If a load-bearing assumption is unresolved, name it and say what it would change — don't quietly draft around it.

## Phase 2 — Write the PRD

Read `assets/prd-template.md` and follow it. Write to `docs/prd/<slug>/prd.md`.

- **Diagrams over prose.** If a flow, relationship, state machine, or boundary can be drawn, draw it in Mermaid instead of describing it. A diagram plus two sentences beats four paragraphs.
- **Delete every section with nothing real in it.** An empty "Success Metrics" heading is worse than no heading. The template is a ceiling, not a floor.
- **Assumptions get their own section**, carried from `discovery.md` — not smoothed into the prose.
- **No filler.** No "this document outlines," no restating the heading in the first sentence, no preamble summarizing what follows.

Keep it short enough to read in one sitting. If the PRD runs long, the problem is under-explored, not under-documented.

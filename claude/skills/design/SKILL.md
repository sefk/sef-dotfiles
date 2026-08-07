---
name: design
description: Produce a design for a problem or GitHub issue — explore the codebase, develop genuinely distinct alternatives, spar with Codex over them, and write up the recommendation. Design only, no implementation. Use when asked to design a solution or weigh approaches, e.g. "/design 42", "design a fix for #42", "write a design doc for X", "what are our options for Y". For product-level "what should we even build" scoping, use prd-discovery instead.
argument-hint: "[issue number | problem statement] [extra guidance]"
---

# Design a solution — no implementation

The argument is a GitHub issue number or a free-form problem statement,
optionally with extra guidance. The deliverable is a design document, not
code. Do not implement, even when the winning approach looks trivial —
offer `/fix-issue` as the follow-up instead. Global git policies apply
(autonomous commits, never push).

1. **Read** — for an issue, `gh issue view <N> --comments`; follow linked
   issues/PRs that matter. Restate the problem to the user in a line or
   two. If the problem itself is unsettled — "what should this even do"
   rather than "how should we do this" — that's `prd-discovery` territory;
   say so and switch.

2. **Explore** — investigate before ideating: what already exists that
   touches this, which abstractions would bend, what was tried and
   abandoned (git log, closed PRs). If the design hinges on data shape,
   read real records rather than assuming. Collect the constraints;
   they're what makes alternatives comparable. Tag what you *verified*
   vs. what you're *assuming*.

3. **Alternatives** — develop 2–4 genuinely distinct approaches, not one
   idea and two straw men. Include the minimal/do-nothing option when
   it's defensible. For each: mechanism sketch, what it costs, what it
   risks, what it forecloses. Develop each seriously before ranking —
   don't anchor on your first idea. Then form a provisional
   recommendation.

4. **Spar with Codex** — mandatory, before any doc is written. Codex gets
   read access to the repo and your full brief:

   ```
   codex exec -s read-only -C <repo-root> -o <scratch>/codex-round1.md "<brief>"
   ```

   Run it in the background (takes minutes). The brief must contain: the
   problem, the constraints you found, every alternative with its
   trade-offs, and your provisional pick with reasoning. Then the asks —
   attack the recommendation, name alternatives I missed, flag assumptions
   that are wrong or unverified; check the actual code where it bears on
   the argument.

   Loop:
   - Triage the response against the codebase before trusting it — Codex
     misreads repos sometimes. Classify each point: **adopt**, **rebut**
     (with evidence), or **judgment call**.
   - A genuinely new alternative from Codex goes through the same step-3
     analysis as your own — not straight into the doc.
   - Reply with your adoptions and rebuttals and ask whether it now
     concurs: `codex exec resume <session-id> -s read-only ...` (the id is
     printed by the first run; use `resume --last` only if you failed to
     capture it — another Codex session may have run since).
   - Converge when Codex concurs with the (possibly revised)
     recommendation with no substantive objection, or ~2–3 rounds pass
     without movement.

   **Escape hatch — record, don't override.** If Codex still dissents
   after a few rounds, the disagreement goes into the doc as both
   positions with the deciding question spelled out for the user. Don't
   silently write up your pick as settled, and don't loop indefinitely.

5. **Write the doc** — follow the repo's existing convention for design
   docs (e.g. `docs/specs/YYYY-MM-DD-<slug>-design.md`); if there is
   none, use `docs/design/<slug>.md`. Contents:
   - Problem and context, linking the issue.
   - Constraints — discovered ones cited to code/data, assumptions tagged
     as assumptions.
   - Recommended design, in enough detail that an implementer needs no
     further design decisions: components, data flow, migration path.
     Diagrams over prose where a flow or boundary can be drawn.
   - Alternatives considered — each with the real reason it lost, not a
     dismissal. Credit ideas that came from the sparring rounds; if a
     disagreement survived, present both positions here.
   - Risks and open questions.
   - Implementation sketch: rough milestones, not code.

   Short enough to read in one sitting; if it runs long, the design is
   under-decided, not under-documented.

6. **Commit** — the doc as its own commit, referencing the issue
   (`#<N>`) when there is one.

7. **Close the loop** — for an issue: comment with the recommendation in
   a few lines and where the doc lives, marked as authored by Claude.
   Leave the issue open — a design is not a fix.

8. **Report** — the recommendation in a couple of lines, doc path, and
   how the sparring ended (Codex concurred after N rounds / dissents on
   X). No long recap.

---
description: Execute one phase of docs/PLAN.md (usage: /phase 0)
argument-hint: <phase number 0-5>
---

Execute **Phase $ARGUMENTS** of `docs/PLAN.md`.

1. Read `CLAUDE.md`, then `docs/PLAN.md` (whole file), then `docs/design-tokens.md` if the phase touches UI.
2. Update `Development` (`git checkout Development && git pull`), then create or switch to the branch named for Phase $ARGUMENTS in PLAN.md §5 from it.
3. Make a task list from that phase's checklist and work through it in order.
4. For UI work, open the existing screen code and the matching `docs/mockups/*.dc.html` (PLAN.md §3 maps both). Extend existing code; build from scratch only screens marked Missing.
5. After each task: `fvm dart format .`, `fvm flutter analyze` (0 issues), `fvm flutter test`; then commit.
6. Stop when every "Done when" check for Phase $ARGUMENTS passes. Report what passed, anything skipped, and any decision you need from me. Do not start the next phase.

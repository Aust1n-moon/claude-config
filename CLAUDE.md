# Global instructions for Claude Code

## Authority
- These instructions override plugin, skill, and default behavior, except superpowers when it is on (see Skills and subagents).
- Answers, reviews, diagnoses, and plans are read-only. Inspect and report. Don't change files unless I ask.
- For changes and builds:
  1. State what you will do. Wait for my explicit go-ahead in this conversation. A prior request states intent; it is not the go-ahead.
  2. Make the smallest effective change.
  3. Verify with non-destructive checks (see Testing and verification).
- Ask separately before delete, install, or external calls, even after a go-ahead.

## Communication
- Write concisely and informatively, in ASD-STE100 style.
- Lead with the answer. No preamble, and don't restate my question.
- Keep reasoning brief, with enough detail for me to understand why.
- Prefer a direct sentence over a list, and a short list over padded prose.
- If my intent is unclear, ask. Don't assume.
- In plans, skip standing CLAUDE.md instructions. Include only task-specific constraints, decisions, and risks.
- No em dashes anywhere: code, comments, docs, UI strings. Use a hyphen, colon, or comma instead.

## Git
- Don't run push, merge, rebase, checkout, switch, or reset without my explicit permission in this session. This includes safe forms such as fast-forwards and `switch` to an existing branch. Moving a branch pointer is my call. If a branch is stale, say so and ask.
- I may commit, pull, or push while you work. Expect commits you didn't author. Don't revert or amend them unless I ask.
- Commit per sub-feature: one nameable slice, worth one bullet in a PR description. Passing tests are required, but they don't trigger a commit. Put "add helper" or "fix previous commit" work into its sub-feature's commit (keep working, or amend). Don't put a whole session in one commit. For docs and notes, commit once per discussion, at a close point.
- Never amend, rebase, or force-push a pushed commit without my explicit permission in this session.
- You may amend unpushed commits that you authored this session. Prefer this to a "fix previous commit" commit. Never amend or rebase commits you didn't author.
- Before any amend, confirm the commit is unpushed with `git log @{u}..`. Don't rely on memory. No upstream counts as unpushed.
- Before a code review or diff check, run `git fetch` and confirm `main` matches `origin/main`. If it doesn't, say so and ask.
- For `CLAUDE.md` and other `~/.claude` config: `git pull --rebase` before editing; commit and push after. This is standing permission for those steps only.

## Code
- When rules conflict: correctness > verification > minimal change > clarity > maintainability.
- Read files before editing. Never assume a file, API, function, schema, or dependency exists. Check it.
- Write only what I asked for. No extra features, abstractions, config options, or error handling for impossible cases.
- Use the simplest code that works. If 200 lines could be 50, write 50.
- Touch only what the task needs. Match existing style. Don't refactor, reformat, or "improve" adjacent code.
- Remove only what your change made unused. Mention other dead code or issues; don't fix them.
- If several interpretations or approaches exist, list them briefly and recommend one. Don't pick silently.
- Python: no `Any`. Use specific types, generics, or `Protocol`. Allow `Any` only at untyped boundaries, with a comment.
- C++: avoid templates beyond what the task forces, operator overloading, clever pointer arithmetic, dense STL algorithm chains (prefer a plain loop), macros, deep one-liners.

## Comments
- Default to no comment. Add one only to prevent a specific misunderstanding: non-obvious intent, a workaround, or a deliberate choice against the obvious option.
- One line, sometimes two. A paragraph only for truly complex logic.
- Write for the next reader, not the reviewer. Justifications of a change go in the PR description.
- Cite issues as `#123`. Cite external sources only with a durable link. No ticket codenames or phase names.
- Use timeless present tense. No "now", "previously", "no longer", or comparisons with removed code.

## Testing and verification
- Use TDD for code with testable behavior: write the test, confirm it fails, implement, confirm it passes.
- Skip TDD for simple tasks where it isn't worth it (one-liners, throwaway scripts, exploration, visual tweaks). Say briefly why.
- Without testable behavior, state a verifiable success criterion before starting.
- Test behavior that could plausibly break. No tests for trivia.
- Assert behavior (the call, the state change, the error kind), not exact user-facing text. If text matters, match one keyword. Never change source to fit a test's text.
- After implementing, run the available lint and test scripts. Use the narrowest command that proves the change. Report the exact commands and results.
- Never claim success without verification. If you can't verify something, say so.
- If blocked, stop. State the blocker, what is missing, and what you verified. Never fabricate progress.

## Skills and subagents
- Load `ponytail:ponytail` before writing code. It governs code only, not design decisions or artifacts where the content is the deliverable.
- Use `frontend-design:frontend-design` for any frontend work.
- Don't start superpowers on your own. If a feature looks complex enough to need it, ask whether to turn it on and say briefly why. Don't suggest it for simpler work; otherwise I start it myself.
- Once superpowers is on, it takes priority until I say stop. It controls process, planning, and tests, and overrides ponytail, TDD skips, and communication style where they conflict. It never overrides the go-ahead rule, ask-before rules, or Git rules.
- Subagents: pick the cheapest model that fits the task (for example, Haiku for mechanical searches). Don't default to the session model. Never use a model more expensive than the session model unless I ask. Cost, high to low: Fable > Opus > Sonnet > Haiku.

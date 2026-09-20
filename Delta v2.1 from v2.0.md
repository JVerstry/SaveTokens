# Delta: v2.1 ← v2.0

## Section 1 — AI Configuration Audit

- **Skills architecture and extraction opportunity** *(new)*: evaluates whether the root
  configuration file has been partitioned into universal behavioral rules (must load every
  session) vs. task-specific procedural workflows (should load on demand only). Seven
  sub-checks:
  1. Has the root config been audited against the always-needed / task-specific distinction?
  2. Are task-specific procedures extracted into skill files rather than loaded unconditionally?
  3. Is each skill's frontmatter description under 150 characters and high-signal enough for
     accurate semantic routing?
  4. Does each skill have a single clearly bounded responsibility (fails if the title requires
     "and" to describe)?
  5. Is reference and explanatory knowledge in linked documents rather than embedded in skill
     bodies (which inflates their trigger footprint)?
  6. Is there a duplication check across the three layers — root configuration, skills, and
     documentation — to ensure single-layer-of-truth for each content type?
  7. Are implicit guardrails (rules that apply silently when working on a specific module, not
     user-invoked commands) implemented with a non-interactive flag (e.g. `user-invocable:
     false`) so they load automatically without requiring a slash command?

- **Per-session baseline budget** *(new)*: asks for the skills-architecture principle above to
  be made checkable with an actual number. Four sub-checks:
  1. Has the total always-on context — root config, skill descriptions, tool/MCP schemas, any
     auto-loaded memory or index — ever been measured as a single figure?
  2. Is a ceiling stated for that baseline, and is growth against it noticed rather than
     discovered later through a slower or costlier agent?
  3. Is the set of connected tools and MCP servers reviewed against actual project use, since
     every connected server contributes its schema to every session regardless of task?
  4. Are tool/server schemas loaded on demand where the harness supports it, rather than upfront?

- **Permission and approval friction** *(new)*: evaluates the per-event cost of routine approval
  prompts. Three sub-checks:
  1. Are common read-only operations pre-approved in project settings so they don't stop for a
     human prompt on every occurrence?
  2. Is that pre-approval committed in the repository rather than kept in one developer's local,
     personal configuration?
  3. Do genuinely destructive operations remain gated — an allowlist broad enough to swallow
     everything trades a small frequent cost for a large occasional one?

## Section 11 — Build Pipeline Audit

- **Feedback-loop latency against agent tool timeouts** *(new)*: evaluates the risk of a command
  outlasting the agent's tool-call timeout (commonly ~2 minutes), which fails the *call* rather
  than the command and produces a wrong diagnosis before anyone realizes the command just hadn't
  finished. Three sub-checks:
  1. Does the project know which of its commands (full build, full test suite, pre-commit hook)
     exceed roughly two minutes?
  2. Is there a documented background-and-poll pattern for running a slow command without
     waiting on it synchronously?
  3. Are pre-commit hooks scoped to fast checks only, with expensive verification deferred to CI
     or an explicit pre-push step?

## Section 12 — Testing Audit

- **Test parallelization and wall-clock budget** *(new)*: evaluates whether the test suite is
  configured and structurally able to run in parallel, and whether a fast subset exists for
  every-edit use. Four sub-checks, plus a cross-reference note to the Flakiness check in
  Section 11 (parallel execution is often what exposes order-dependent tests):
  1. Is the runner configured for parallel execution?
  2. Can the suite actually be parallelized — no shared fixtures, no single test database, no
     fixed ports, no order-dependent state — since this is a design property, not a flag?
  3. Is wall-clock time per test level known and recorded anywhere?
  4. Does a fast subset exist for the agent to run after every edit, distinct from the full
     suite reserved for pre-commit or CI?

## Section 16 — Governance & Maintainability Audit

- **Recommendation intake and disposition** *(new bullet)*: appended to the existing bulleted
  list, asking whether an audit or review of this kind has a defined home for its output —
  accepted recommendations tracked with a link back to the finding, rejected ones recorded with
  a reason, the record kept in the repository, and a later audit expected to read it before
  restating a prior finding as new.

## Section 20 — Context Continuity & Session Architecture

- **Environment and tooling friction log** *(new)*: distinct from the existing persistent
  cross-session memory check (which covers task state). Three sub-checks:
  1. Does the project or the developer's tooling setup maintain a running log of environment and
     tooling friction — a shell quirk, a CLI flag surprise, a library gotcha?
  2. Is the log actually consulted when tooling fails unfamiliarly, not just written to?
  3. Are entries scoped correctly — cross-project friction in a shared log, project-specific
     friction in the project's own docs — since a log that mixes the two stops being read?

---

Net: +261 lines (961 → 1222), seven new checks across five sections. No section was removed,
renumbered, or reworded elsewhere; every change in this delta is an addition.

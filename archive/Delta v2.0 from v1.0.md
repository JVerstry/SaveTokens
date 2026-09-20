# Delta: v2.0 ← v1.0

## Section 1 — AI Configuration Audit

- **Context token efficiency** expanded: added no-duplication check (CLAUDE.md should not repeat info already in package.json, tsconfig, linter config) and a token budget ceiling check (root config ≤ 2–3K tokens, periodic pruning).
- **Anti-hallucination rule coverage** *(new)*: per-framework check for explicitly named deprecated APIs, removed methods, and phantom features the AI is known to hallucinate.
- **Hierarchical context loading** *(new)*: base context ≤ 8K tokens; module-specific rules live in scoped files loaded only when relevant.
- **Referential rot** *(new)*: config files must not reference functions, files, or patterns that no longer exist in the codebase.
- **Context staleness on dependency upgrades** *(new)*: process to flag AI config for review after major version bumps.
- **Conversation lifecycle management** *(new)*: rule to start a fresh session when context approaches 50–60% capacity.

## Section 3 — Architecture Audit

- **Ubiquitous Language** *(new)*: shared vocabulary mapping identically across domain, code, tests, and docs.
- **Graceful degradation + per-client quotas** *(new)*: overload strategy with quotas isolating noisy consumers; reduced-quality responses under load rather than hard failures.
- **Database & caching patterns** *(new, conditional)*: replication model, partitioning strategy, and cache update pattern documented.
- **Capacity estimation** *(new, conditional)*: back-of-envelope load, storage, and bandwidth calculations explicit and dated.

## Section 6 — Security Audit

- **Agent execution sandboxing** *(new)*: explicit writable/read-only path boundaries and off-limits sensitive paths for AI agents.
- **SBOM / software provenance** *(new)*: automated Software Bill of Materials for rapid CVE triage.
- **Vulnerability disclosure policy** *(new)*: published contact, documented response SLA (90-day standard), internal triage process.

## Section 11 — Build Pipeline Audit

- **Commit message convention** *(new)*: structured format (e.g. Conventional Commits) enforced by commitlint at commit time; squash-merge policy for mainline cleanliness.
- **API contract validation** *(new)*: OpenAPI/Swagger spec maintained or generated, validated in CI against runtime behaviour.
- **Diff review gate for AI-generated changes** *(new)*: semantic review of every AI-produced diff for out-of-scope modifications, dependency changes, schema changes, and security-sensitive path edits.
- **Delivery performance metrics** *(new)*: DORA four key metrics measured and trended — deployment frequency, lead time, change failure rate, MTTR.

## Section 12 — Testing Audit

- **Snapshot and approval tests** *(new)*: committed `.approved` baselines for complex structured outputs (HTML, JSON transforms, reports); human-readable diff workflow.

## Section 14 — Observability Audit

Section substantially restructured and expanded with named subsections:

- **Log emission** *(expanded)*: added 12-Factor check — app writes unbuffered to stdout/stderr; log routing delegated to the execution environment, not the application.
- **Error reporting and alerting** *(expanded)*: added alert fatigue prevention — severity tiers, minimum-count guards, templated alert context.
- **Service level objectives** *(new)*: SLI → SLO → SLA triples with percentile-based latency targets; error budget as a deployment gate.
- **Four Golden Signals** *(new)*: Latency, Traffic, Errors, Saturation as minimum monitoring surface for user-facing systems.
- **Observability infrastructure portability** *(new)*: OpenTelemetry API (not vendor SDK) for all instrumentation; shared context propagation across traces, metrics, and logs; zero-code auto-instrumentation.

## Section 15 — Cost Audit

- **Model assignment strategy** *(new)*: documented mapping of model tiers (frontier vs. efficient) to task categories; using a frontier model for every task flagged as a measurable cost inefficiency.

## Section 16 — Governance & Maintainability Audit

- **Pre-computed navigation documents** *(new)*: ROUTES.md, DATABASE_SCHEMA.md, MODULES.md, API_SURFACE.md auto-generated at build time for fast AI orientation.
- **Keep a Changelog** *(new)*: [Unreleased] section maintained continuously; breaking changes, removals, and deprecations grouped separately; changelog updated as part of PR workflow.
- **Diataxis documentation framework** *(new)*: docs separated into four types — tutorials, how-to guides, reference, explanation — with maintained content boundaries.

## Section 18 — Deployment & Recovery Audit

- **Hermetic builds** *(new)*: deterministic reproduction on any machine; pinned dependency resolution; known and traceable release contents; cherry-pick to release branches.
- **Zero-downtime deployment strategy** *(new)*: explicit choice of pattern (blue-green, canary, rolling), documented with rollback procedure, exercised in staging under load.
- **Feature flags** *(new)*: flags decouple deployment from release; documented owner and retirement policy; controlled experiments (A/B, canary) to validate user impact before full rollout.
- **Blameless postmortems** *(new)*: triggered by predetermined criteria; systemic focus (not individual blame); findings distributed org-wide; action items tracked to closure.

## New Section 20 — Context Continuity & Session Architecture *(entirely new)*

- **Persistent cross-session memory**: structured `.context/` store covering active task context, system patterns, in-progress decisions, and work state.
- **Context compaction fidelity**: check that non-obvious constraints, implementation rationale, and in-progress state survive compaction.
- **Structured feature specifications (PRPs)**: versioned implementation briefs capturing intent, files, constraints, validation criteria, and definition of done — written before AI-assisted implementation begins.

## Structural change

- Old Section 20 (SEO) renumbered to **Section 21** to accommodate the new Section 20.

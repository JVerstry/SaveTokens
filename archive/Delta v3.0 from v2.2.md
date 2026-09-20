# Delta: v3.0 ← v2.2

Net: +396 lines (1451 → 1847). Three new numbered sections (Agent
Delegation and Orchestration, Agent Architecture Principles, Agent Platform
Governance, inserted as sections 3-5; every section that was 3-22 shifted to
6-25), and one removal (the "Mechanism selection" check that v2.2 introduced
in section 2). Major version bump, not a point release, because of the
scale of the addition — three sections is a larger structural change than
any prior version.

## Section 2 — Agent Skills Audit

- **Mechanism selection — skill, tool connection, retrieval, or memory**
  *(removed)*: this was the first check in v2.2's section 2. Discarded on
  review after being read live in the shipped prompt text - judged not
  mature or clear enough, with a real risk of causing confusion rather than
  clarifying anything. It was also the more speculatively-sourced of the two
  checks introduced from the same source video (built from the video's
  description of its own thesis, not its explanatory content, since neither
  a transcript nor chapters were available). The sibling check from the
  same research pass, "Explicit escalation conditions instead of guessing",
  was kept - it survived the same live-read scrutiny.

## Section 3 — Agent Delegation and Orchestration Audit *(new section)*

Evaluates how the project's own AI-assisted development process delegates
work to subagents, parallel sessions, or automated workflows - a distinct
concern from section 2's skills, which are what a single agent loads, not
how many agents are coordinating. Seven checks:

1. **Delegation boundaries**: whether the project distinguishes work worth
   delegating (broad searches, verbose logs) from work that is not (quick
   edits, iterative back-and-forth), since a subagent has no conversation
   history and its findings return only as a lossy summary.
2. **Choosing an orchestration mode and bounding its cost**: whether the
   project deliberately picks among single session / subagents / parallel
   sessions / teams / scripted workflows rather than defaulting to the
   heaviest, since each differs in cost by more than an order of magnitude.
   Explicitly has no fixed right answer - flag the absence of judgment, not
   a specific mode choice.
3. **Subagent definitions as versioned project assets**: whether recurring
   delegated roles exist as committed definition files with a
   routing-focused description, rather than being re-specified fresh every
   session.
4. **Least-privilege scoping of delegated agents**: tool allowlisting,
   read-only enforcement, deliberate model choice per role, and turn limits
   for agents that could loop.
5. **Isolation for concurrent agent work**: git worktree isolation and its
   practical usability (gitignored files, dependencies), plus whether the
   project notices concurrent agent work at all (duplicated effort, silent
   divergence) independent of the isolation mechanism.
6. **Trust and verification of agent-reported results**: whether findings
   are verified against the artifact rather than accepted from a summary,
   by something that did not produce the finding, applying in both
   directions - an agent's unverified claim about its own work and about
   another agent's work are the same failure.
7. **Codifying repeated orchestration**: whether multi-agent procedures the
   project repeats exist as saved, version-controlled scripts rather than
   being re-derived in prose each time.

## Section 4 — Agent Architecture Principles Audit *(new section)*

Evaluates whether an agentic feature the project builds as part of its own
product - not the coding agent building the project - was the right shape
to build in the first place. A design-time concern, distinct from section
5's governance of an agent already in production. Four checks:

1. **Complexity justification - agent versus workflow versus single call**:
   whether a simpler approach was tried and measured before an open-ended
   autonomous loop was built, since agentic errors compound across steps
   instead of surfacing once.
2. **Workflow pattern selection before an open-ended agent loop**: whether a
   fixed-shape task was checked against the five standard workflow patterns
   (chaining, routing, parallelization, orchestrator-workers,
   evaluator-optimizer) before reaching for full autonomy.
3. **Framework abstraction risk**: whether the actual prompt and API call an
   agent sends can be inspected directly, or whether diagnosis requires
   first reverse-engineering a framework's internal construction.
4. **Explicit agent planning-step transparency**: whether the agent surfaces
   its plan before or alongside an action with real-world effect, so a
   human or automated check can intervene before execution, not only debug
   after.

## Section 5 — Agent Platform Governance Audit *(new section)*

Evaluates a project that builds and operates an agent as part of its
product, with its own identity, network access, memory, and evaluation
surface - most projects will not yet have all of these in place, and the
section says so explicitly. Fourteen checks:

1. **Agent identity and credential lifecycle hygiene**: revocation on
   delete/redeploy (deleting an agent does not revoke its IAM bindings),
   periodic diffing of active bindings against deployed agents, dual
   identity logging.
2. **Network mediation for agent-to-agent and agent-to-tool calls**: whether
   outbound calls pass through an enforcing, logging mediation layer rather
   than going direct.
3. **Agent registry and catalog governance**: one inventory of agents,
   tools, and MCP servers with an owner per entry, checked before building
   something new or letting one agent call another.
4. **Governance-as-code packaging across agents**: one versioned source for
   cross-cutting policy (PII filtering, moderation) rather than duplicated
   per-agent logic that drifts.
5. **Human-in-the-loop escalation calibration**: risk-tiered approval
   requirements, a numeric escalation trigger, and the escalation rate
   itself tracked over time as a signal.
6. **Guardrail-layer precision and recall tuning**: guardrail classifiers
   tracked with their own precision/recall separate from end-task accuracy,
   since an untuned threshold is a cost tax on all traffic regardless of
   whether the main task succeeds.
7. **Long-term agent memory governance**: TTL/expiration, per-identity
   isolation actually tested, and data-residency compliance for persistent
   cross-session memory.
8. **Trace and telemetry data residency**: execution traces held to the same
   retention requirements as the primary data, since telemetry is often
   exempted from scrutiny as "just logs."
9. **Agent trajectory evaluation**: scoring the efficiency of an agent's
   tool-call path, not only its final output, since a wasteful path can
   still produce a correct-looking answer.
10. **Deterministic grounding checks versus LLM-judge cost**: a plain string
    match against structured tool output in place of a full model call,
    for claims that are actually verifiable that way.
11. **Agent interoperability protocol versioning**: A2A/MCP protocol version
    declared and checked at registration, since it is a dependency surface
    no package manifest tracks.
12. **Provider-managed conversation state lock-in**: billing clarity and
    portability for provider-hosted conversation history.
13. **Agent runtime cost shape**: scale-to-zero cold-start tradeoffs,
    unused persistent memory cost, and sandboxed execution cost tracked
    separately from model-inference cost.
14. **Checkpointing for triggered or scheduled agents**: resuming from a
    partial failure rather than rerunning a whole workflow from the top on
    every retry.

## Sections 6-25

Unchanged in content. Renumbered from what was 3-22 in v2.2, since three
sections are new. No wording changed as part of the renumbering beyond the
section header numbers themselves.

## Provenance note

Sections 3 and 5 draw on Anthropic, Google Gemini Enterprise Agent
Platform, and OpenAI documentation research; section 4 draws on Anthropic's
"Building Effective Agents" engineering post read directly. Within section
5, checks 4 (governance-as-code), 5 (HITL escalation), 6 (guardrail
tuning), 8 (trace/telemetry residency), 12 (provider state lock-in), and 14
(checkpointing) are OpenAI-sourced; the remaining eight are Gemini-sourced.
The OpenAI-sourced checks were flagged in
work-in-progress/TopicCandidates.md as more weakly sourced than the rest -
three of five source URLs failed to fetch directly and were substituted
with search-synthesized summaries - and integrated without that
verification being completed first. Flagged here so the gap is not lost;
see the audit finding on this same subject recorded when v3.0 was run
against this project itself.

# Topic Candidates for the Save Tokens Audit Prompt

Working file. Not part of the audit prompt itself.

Each candidate names the leak it catches, the section it would live in, where
the idea came from, and a rough line budget.

Status is one of:

- **Undecided** - not yet judged.
- **To investigate** - worth having, but something has to be settled first:
  an overlap with another candidate, a scope question, or a check against
  what the prompt already says.
- **Selected** - accepted for inclusion. This is a decision about the topic,
  not about which version carries it; sequencing is a separate question.
- **Rejected** - will not be included. The reason stays in the entry so a
  later version does not re-propose it.
- **Processed** - written into the audit prompt. The entry stays as the
  record of where that block came from.

The statuses below are proposed, not decided. Overrule freely.

**Integration rule**: only a Selected candidate may be written into an audit
prompt file, and that step is started by the maintainer, never begun
unprompted. Proposing, arguing and drafting entries here is unrestricted;
editing the prompt itself is not. A candidate becomes Processed only after its
block is in the prompt, so the status column always describes what the prompt
actually contains.

Target for the next version: pick the few that earn their lines. v2.1 added
exactly one block (50 lines, section 1) over v2.0, and was committed as-is
(1222 lines, 21 sections) - see Delta v2.1 from v2.0.md.

Text is deliberately plain ASCII. Working file: Save Tokens Audit v2.2.txt,
not yet committed (1451 lines, 22 sections) - see Delta v2.2 from v2.1.md.
Do not add further content to v2.1.txt; it is closed and matches its commit.

---

## C1. Test suite parallelization and wall-clock budget

- **Status**: Processed - written into Save Tokens Audit v2.1.txt, section 12
- **Source**: issue #1 (Auditing for testing parallelization)
- **Section**: 12 (Testing), possibly a shared note with 11 (Build Pipeline)
- **Budget**: ~25 lines

**Leak**: A suite that takes minutes serially is a suite the agent stops
running. It either skips verification and reports success it did not observe,
or it burns the wait repeatedly across a session. Both are expensive, and the
first is a correctness risk, not just a cost one.

**Evaluate**: whether the runner is configured for parallel execution at all
(most modern runners default to it and most projects never check); whether the
tests can actually be parallelized, which is a design property, not a flag -
shared fixtures, a single test database, fixed ports, a shared temp directory,
or order-dependent state all force serialization; whether wall-clock time per
level is known and recorded anywhere, since a project that cannot state how
long its tests take has no basis for the tradeoff; whether a fast subset exists
that an agent can run after every edit, distinct from the full suite that runs
before a commit.

**Note**: section 11 already levels the pipeline and covers flaky-test
quarantine. This block should reference that rather than restate it - flakiness
and parallelization are causally linked, since parallel execution is what
usually exposes order dependence.

---

## C2. Feedback-loop latency against the agent's tool timeout

- **Status**: Processed - written into Save Tokens Audit v2.1.txt, section 11
- **Source**: papercuts 2026-09-19 (pre-commit `lake build`, 6-12 min, hit the
  2-min tool timeout)
- **Section**: 11 (Build Pipeline)
- **Budget**: ~15 lines

**Leak**: Any command the agent must run to make progress - build, test, lint,
commit - that exceeds the agent's tool timeout produces a failed call, a
retry, and usually a wrong diagnosis before the agent works out that the
command did not fail but simply did not finish. The cost is paid every time,
by every session, until someone writes the workaround down.

**Evaluate**: whether the project knows which of its commands exceed roughly
two minutes; whether a documented background-and-poll pattern exists for those;
whether pre-commit hooks in particular are scoped to fast checks, with the
expensive verification moved to CI or an explicit pre-push step. A pre-commit
hook that runs a full build is the single most common instance of this.

**Note**: complements C1. C1 asks whether the suite is fast; this asks what the
agent is supposed to do when something is unavoidably slow.

---

## C3. Recommendation intake and disposition

- **Status**: Processed - written into Save Tokens Audit v2.1.txt, section 16
- **Source**: issue #2 (Integrate Agent recommendations)
- **Section**: 16 (Governance) or a new section
- **Budget**: ~20 lines

**Leak**: The audit produces a ranked list. Without a place for that list to
land, the next audit re-derives the same findings, and the team re-argues the
ones it already decided against. The re-derivation is paid in full every time,
and rejected advice is the most expensive kind, because rejecting it correctly
required thought that is now lost.

**Evaluate**: whether accepted recommendations become tracked work with a
traceable link back to the finding; whether rejected ones are recorded with a
reason; whether the record is in the repository rather than in an issue tracker
the agent cannot read; whether a later audit is expected to read it first.

**Note**: this file is an instance of the practice. Worth saying so in the
block - a concrete example costs three lines and makes the requirement
unambiguous.

---

## C4. Concurrent agent sessions in one repository

- **Status**: Rejected - content merged into C14
- **Source**: papercuts 2026-09-20 (two sessions wrote the same lemmas in the
  same namespace; the compiler did not catch it because no module imported
  both)
- **Section**: 19 (AI-Specific Risk)
- **Budget**: ~20 lines

**Leak**: Duplicated work is the obvious cost. The subtler one is silent
divergence - two agents build the same abstraction slightly differently, and
nothing fails until the two halves meet. The prompt currently has no mention of
parallel sessions, worktrees, or branch isolation at all.

**Evaluate**: whether concurrent sessions are isolated (separate worktrees or
branches) or share a working tree; whether an agent is expected to check recent
history for peer work before adding foundational code; whether there is a
convention for who owns which area during parallel work; whether the build
actually links everything, since a project where modules are independently
compiled will not surface duplication on its own.

**Merge note**: this entry is not written as its own block. Its content is
carried by C14, which covers the same ground from the mechanism side. Kept
here as the record of where that half of C14 came from, and of the incident
that prompted it.

---

## C5. Tool surface and connected-server footprint

- **Status**: Rejected - content merged into C6
- **Section**: 1 (AI Configuration)
- **Budget**: ~25 lines

**Leak**: Every connected tool or server contributes its schema to the context
of every session, whether or not the task needs it. This is the same cost
structure as the unconditionally-loaded configuration that v2.1 addressed for
skills, applied to tooling, and the prompt does not currently mention it.

**Evaluate**: whether the set of connected servers is reviewed against what the
project actually uses; whether tool schemas are loaded on demand rather than
upfront where the harness supports it; whether servers connected for a one-off
task were disconnected afterwards.

**Merge note**: not written as its own block. C6 carries this content as the
tool-surface half of the per-session baseline. Kept here as the record of the
argument: tooling is subject to the same unconditional-loading cost that v2.1
identified for skills.

---

## C6. Per-session baseline budget

- **Status**: Processed - written into Save Tokens Audit v2.1.txt, section 1
- **Section**: 1 (AI Configuration)
- **Budget**: ~30 lines (absorbs C5)

**Leak**: v2.1 established that task-specific content should not load
unconditionally. The missing half is measurement: what does load on every
session, and how large is it? Without a number, the question is unfalsifiable
and the answer drifts upward as configuration accumulates.

**Evaluate**: whether anyone has measured the always-on footprint - root
configuration, plus every skill description, plus tool schemas, plus any
auto-loaded memory or index; whether a ceiling is stated; whether growth in
that number is noticed. The check is mechanical and takes minutes, which is
what makes it worth asking for.

**Absorbs C5**: the block names the tool surface explicitly as part of the
baseline - every connected tool or server contributes its schema to every
session whether the task needs it or not - and asks whether that set is
reviewed against actual use, whether schemas load on demand where the harness
supports it, and whether servers connected for a one-off task were
disconnected afterwards. Without the measurement, that question has no
answer; without the tool surface, the measurement misses its largest
unexamined component.

**Note**: gives sections 1 and 20 a quantitative anchor. Consider requiring a
stated number in the final output format.

---

## C7. Permission and approval friction

- **Status**: Processed - written into Save Tokens Audit v2.1.txt, section 1
- **Section**: 1 (AI Configuration) or 16 (Governance)
- **Budget**: ~15 lines

**Leak**: Each approval prompt for a routine read-only command stalls the
agent and often produces a retry or a detour through a different tool. The
per-event cost is small and the frequency is high.

**Evaluate**: whether common read-only commands are allowlisted in project
settings; whether the allowlist is in the repository so every session and every
developer inherits it; whether genuinely destructive operations remain gated,
since an allowlist that swallows everything is a different and worse problem.

**Drafting constraint**: I proposed rejecting this as tied to one tool's
permission system; overruled, and the frequency argument carries it. Write the
block so it holds across harnesses: ask whether routine read-only operations
require repeated human approval, whether whatever mechanism the harness offers
for pre-approving them is used, and whether that configuration is in the
repository rather than in one developer's local settings. Name no specific
tool's syntax. The gate on destructive operations is the part that must
survive: an allowlist that swallows everything trades a small recurring cost
for a large occasional one.

---

## C8. Tooling friction log

- **Status**: Processed - written into Save Tokens Audit v2.1.txt, section 20
- **Source**: the papercuts practice itself
- **Section**: 20 (Context Continuity) or 16 (Governance)
- **Budget**: ~15 lines

**Leak**: Environment and tooling gotchas recur across sessions and across
projects, and each session re-derives the fix from scratch. The fix is usually
one line; finding it is not.

**Evaluate**: whether a running log of tooling friction exists; whether it is
consulted when tooling fails unexpectedly rather than only written to; whether
entries are scoped correctly - cross-project friction in a shared log,
project-specific gotchas in the project's own configuration or docs, since a
log that mixes the two stops being read.

**Note**: distinct from section 20's persistent memory, which covers task
state. This covers environment behaviour, which outlives the task.

---

## C9. Text encoding and console determinism

- **Status**: Rejected
- **Source**: papercuts 2026-09-19 (UnicodeEncodeError printing non-ASCII on
  the Windows console); also this session, where PowerShell 5.1 decoded a
  clean UTF-8 file as ANSI and produced a confident report of corruption that
  was not there
- **Section**: 19 (AI-Specific Risk)
- **Budget**: ~15 lines

**Leak**: An agent that misreads a file reasons correctly from wrong input, and
the output looks like a finding rather than an error. That is worse than a
crash, which at least announces itself. On Windows the default console codepage
makes this a routine hazard rather than an exotic one.

**Evaluate**: whether file encoding is stated and consistent; whether helper
scripts read and write with an explicit encoding rather than the platform
default; whether the project's text is safe to process with the tools the agent
actually reaches for first.

**Note**: narrow, and arguably belongs in a project's own documentation rather
than a general audit. Include only if the Windows case is judged common enough.

**Rejection reason**: platform-specific, and the projects it would catch are
the ones already keeping a friction log (C8). Recording the instance there
costs one line; asking every audit to check encoding costs fifteen. Revisit
if a second class of misread-input failure turns up that is not encoding.

---

## C10. Verification honesty

- **Status**: Rejected - content merged into C16
- **Section**: 19 (AI-Specific Risk)
- **Budget**: ~15 lines

**Leak**: The most expensive single failure in agent-assisted work is a change
reported as verified that was never run. Everything downstream is built on it,
and the cost of discovery grows the longer it stays hidden. Section 19 covers
unreviewed AI-generated tests and hallucinated documentation, but not
unverified claims of having run something.

**Evaluate**: whether the project requires the agent to distinguish what it ran
from what it believes; whether verification commands and their output are
expected to appear in the record; whether a convention exists for reporting a
skipped or failed check rather than rounding it up to success.

**Merge note**: not written as its own block. C16 carries this content as the
self-verification half of a single verification block, the narrower case of
one agent (itself) making an unverified claim rather than another agent making
one.

---

## Agent delegation and orchestration (C11 - C17)

Source for this group: code.claude.com/docs/en/agents and the pages it links -
sub-agents, worktrees, agent-teams, workflows. The current prompt has no
coverage here at all: zero occurrences of "parallel", "worktree" or "MCP", and
one incidental mention of "subagent". If several of these are accepted they
probably belong together as a new section 22 rather than scattered across
existing ones.

---

## C11. Subagent definitions as versioned project assets

- **Status**: Selected
- **Section**: new 22, or 1 (AI Configuration)
- **Budget**: ~25 lines

**Leak**: A delegated agent that is described fresh in the prompt each time is
re-specified at full price every session, and inconsistently, so its output
varies for reasons nobody can see. A definition file is written once and
reused. Definitions live in `.claude/agents/` (project, version-controlled),
`~/.claude/agents/` (user, invisible to everyone else) or nowhere.

**Evaluate**: whether recurring delegated roles - reviewer, test runner,
researcher - exist as definition files rather than as ad-hoc prompts; whether
they are in the project scope and committed, so the whole team and every
session inherits them, rather than in a personal directory; whether each
definition's `description` is written for routing, since that field decides
automatic delegation and is read every session while the body is not; whether
the combined descriptions have been kept small, since past roughly 15,000
tokens the tool itself warns, and detail belongs in the body.

**Note**: the "description is read every session, body is not" split is the
same on-demand-loading argument v2.1 made for skills. Worth stating as the
same principle applied to a second surface.

---

## C12. Least-privilege scoping of delegated agents

- **Status**: Selected
- **Section**: new 22, or 1
- **Budget**: ~25 lines

**Leak**: An agent given the full tool pool and the strongest model costs more
than the task needs, and can do more damage than the task warrants. A
search-and-summarize agent needs read tools and a cheap model; giving it write
access and the top model is pure overhead on both axes.

**Evaluate**: whether definitions restrict tools with an allowlist rather than
inheriting everything; whether read-only roles are actually read-only, which is
the cheapest safety property available and is usually one line; whether the
model is chosen per role rather than defaulting to the main conversation's;
whether bounds like a turn limit exist for agents that could loop; whether
permission mode is set deliberately rather than inherited by accident.

**Note**: pairs with C5 (tool surface). C5 asks what the session loads, this
asks what each delegated worker is allowed to use.

---

## C13. Delegation boundaries

- **Status**: Selected
- **Section**: new 22
- **Budget**: ~20 lines

**Leak**: Delegation is not free and not always a saving. A subagent starts
with no conversation history, so anything it needs must be restated, and its
findings come back as a summary that loses detail. Delegating a task that needs
iteration means paying the restatement cost repeatedly; not delegating a
log-heavy search means flooding the main context with output nobody will read
again.

**Evaluate**: whether the project says which work is worth delegating - broad
searches, verbose test or build output, anything whose bulk is read once and
discarded - and which is not: quick targeted edits, work needing back-and-forth,
phases that share context. Whether anyone has noticed the failure mode where an
agent is spawned for a task the main session could have finished in one tool
call.

---

## C14. Isolation for concurrent file edits

- **Status**: Selected
- **Section**: new 22, or 19 with C4
- **Budget**: ~20 lines

**Leak**: Two agents editing the same file overwrite each other, and the work
lost is work already paid for. Git worktrees give each session or agent its own
checkout, which removes the class of problem rather than managing it.

**Evaluate**: whether parallel work is isolated in worktrees or shares one
tree; whether a worktree is actually usable when created, since it is a fresh
checkout without gitignored files - an `.env` that does not arrive means an
agent that cannot run anything, and dependencies must be installed there too;
whether there is a convention for copying the needed untracked files in;
whether stale worktrees are cleaned up or accumulate.

**Absorbs C4**: this block carries both halves - whether the project notices
concurrent work at all (duplicated effort, silent divergence between two
agents building the same abstraction, a build that never links the halves
together so nothing fails until they meet) and whether the isolation mechanism
is configured to actually work. Budget rises to ~30 lines to cover both.

---

## C15. Choosing an orchestration mode and bounding its cost

- **Status**: Selected
- **Section**: new 22
- **Budget**: ~30 lines

**Leak**: The available modes - one session, subagents, parallel sessions,
coordinated teams, scripted workflows - differ in cost by more than an order of
magnitude. Each teammate or agent is a separate context window. Choosing the
heaviest mode by default, or letting one form silently turn into another, is
the largest single multiplier in this whole audit.

**Evaluate**: whether the project distinguishes the modes and says which fits
which work, rather than reaching for the most powerful one; whether anyone has
set the ceilings the tooling offers - concurrency limits, workflow size
guidelines, team size, which the documentation puts at three to five for most
work; whether a large fan-out is trialled on a slice before being run over the
whole repository; whether the mode in force is knowable, since a setting can
turn ordinary delegation into a team without anyone asking for one.

**Note**: the strongest ROI candidate in this group, and the one that most
needs the audit's own honest-uncertainty rule - the right answer is a judgment
about the work, not a number.

---

## C16. Trust and verification of agent-reported results

- **Status**: Selected
- **Section**: new 22, or 19
- **Budget**: ~30 lines (absorbs C10)

**Leak**: A delegated agent returns a summary, and the summary is all the main
session sees. If it is wrong, nothing downstream can tell. Confirmation bias
makes this worse: an agent handed a hypothesis tends to return it confirmed, so
a fan-out of agents given the same framing produces agreement that looks like
evidence.

**Evaluate**: whether findings that matter are verified against the artifact
rather than accepted from the report; whether verification is done by something
that did not produce the finding; whether agents are briefed with the question
rather than the expected answer; whether output from one agent is treated as
data rather than as instructions when it reaches another, and whether the
project understands that one agent cannot grant another a permission it was
denied.

**Absorbs C10**: the block covers both directions of the same failure - an
agent's unverified claim about its own work (did it distinguish what it ran
from what it believes; does verification output appear in the record) and an
agent's unverified claim about another agent's work (is a delegated finding
checked against the artifact by something that did not produce it, rather than
accepted from the summary). Read together as one rule: don't trust an
unverified claim, whoever made it.

---

## C17. Codifying repeated orchestration

- **Status**: Selected
- **Section**: new 22, or 16 (Governance)
- **Budget**: ~15 lines

**Leak**: An orchestration described in prose each time is re-derived each
time, with drift between runs. Saved as a script or command, it is read once
and rerun, and its cost becomes predictable.

**Evaluate**: whether multi-agent procedures the project repeats - a release
review, a per-file audit, a migration pass - exist as saved, version-controlled
commands or workflow scripts; whether they are committed at project scope so
the team shares them; whether anyone rereads them, since a saved orchestration
that nobody audits is a standing instruction with no owner.

---

## C18. Parallel execution of the audit prompt itself

- **Status**: Processed - written into Save Tokens Audit v2.2.txt,
  AUDIT SEQUENCE preamble, as an option the agent proposes to the user before
  starting (not a default), per the user's explicit instruction
- **Source**: user request, this session
- **Section**: not a numbered section - a change to ROLE & CONSTRAINTS /
  AUDIT SEQUENCE, the preamble that currently mandates "Perform each section
  in order"
- **Budget**: ~25-30 lines in the preamble

**Leak**: The current instruction is strict sequential execution across 21
sections in one context. On a codebase of real size this is the audit's own
largest wall-clock cost, and it is self-inflicted: most sections read
different files and evaluate independent properties (Accessibility and
Internationalisation, for instance, share no real dependency). Serial
execution pays full sequential time for work that does not need it.

**Change proposed**: add explicit permission, near ROLE & CONSTRAINTS or
AUDIT SEQUENCE, to run the audit as a fan-out - one agent per section or per
cluster of related sections, running concurrently - followed by a synthesis
pass that merges and ROI-ranks every worker's findings into the single
required output list. This turns section execution from an implicit
turn-by-turn choice into a named pattern, which is exactly the discipline C15
argues every orchestration decision should get.

**Why this is not simply Selected yet**:
- Some sections have a real dependency and cannot run blind to each other's
  output. The C1 block explicitly points at section 11's Flakiness check;
  C6's baseline-budget measurement is referenced by section 20; section 12
  (Testing) presumes section 11 has already defined the pipeline's levels.
  A fan-out needs to say which sections are safe to parallelize and which
  must run after another, not treat all 21 as independent by default.
- The FINAL OUTPUT FORMAT section requires one ranked list, not 21. Naive
  concatenation would double-count overlapping findings - section 6 (Security)
  and section 19 (AI-Specific Risk) both touch reviewed AI output, for
  example - so the synthesis step needs real deduplication, not just a merge.
- A fan-out of independent workers is exactly the shape C16 already warns
  about: a caller that only sees each worker's summary, with no way to check
  it independently. If this is adopted, the synthesis pass should apply
  C16's rule - verify a finding against the artifact before it is ranked,
  don't accept it from the summary alone.
- Cost: 21 concurrent agents is workflow-scale, not casual subagent-scale.
  Worth bounding with a size guideline (per C15) rather than defaulting to
  one worker per section regardless of project size - a small project does
  not need a 21-agent fan-out to answer a question a single pass would answer
  as fast.

**Note**: this candidate applies C15's own argument - choose an orchestration
mode and bound its cost - to the audit prompt's own execution, and pulls in
C16's verification rule for the same reason. It reads as an addition to the
preamble that changes how the whole prompt runs, not as a new numbered
section that changes what it evaluates.

---

## Agent platform mechanics (C19 - C26)

Source for this group: an agent's exploration of
cloud.google.com/products/gemini-enterprise-agent-platform and its linked
docs (agent registry, agent identity/IAM, agent gateway, memory bank, agent
evaluation, grounding) plus one lifecycle blog post - 12 pages fetched,
2 hops deep. These are distinct from C11-C17: that group is about how one
project orchestrates its own delegated agents; this group is about what a
managed agent-platform deployment needs to get right once agents are treated
as first-class, identity-bearing, network-connected things in production.
Several items below extend existing numbered sections rather than the new
agent section, which is itself informative - agent platforms surface new
instances of old categories (security, cost, testing) more than they invent
wholly new ones.

---

## C19. Agent identity and credential lifecycle hygiene

- **Status**: Selected
- **Section**: 6 (Security), touches 16 (Governance)
- **Source**: Gemini Enterprise Agent Platform docs - agent-identity-overview
  (IAM-specific and platform-specific pages)
- **Budget**: ~20 lines

**Leak**: Per-agent identity is usually checked once, at launch. Deleting an
agent does not revoke the IAM bindings that referenced it - they become
inactive grants that sit there until someone manually purges them - and
redeploying "the same" agent under the same name mints a new principal,
silently orphaning the old bindings. An audit that only checks least-privilege
at time zero misses the pile of stale, unrevoked grants that accumulates
afterward, which is the actual attack surface six months in, plus the
reviewer time spent later working out which of forty bindings are still live.

**Evaluate**: whether there is a documented process, not a manual step someone
remembers, for revoking bindings when an agent is deleted or redeployed;
whether anything periodically diffs principals with active bindings against
agents actually deployed; whether audit logs capture both the agent's and the
acting user's identity when an agent acts on someone's behalf, or only one;
whether any agent still runs on a long-lived key or a shared service account
where a scoped, non-impersonable identity was available instead.

**Note**: distinct from C12 (least-privilege scoping of delegated agents),
which governs what an agent may do within one orchestration session. This is
about identity persisting, and drifting, across deployments in production.

---

## C20. Agent registry and catalog governance

- **Status**: Selected
- **Section**: new agent section, touches 4 (Dependency)
- **Source**: Gemini Enterprise Agent Platform docs - agent-registry,
  agent-gateway-overview (which treats the registry as its directory of
  approved agents, tools, and MCP servers)
- **Budget**: ~18 lines

**Leak**: Without one searchable inventory of agents, tools, and MCP servers,
a team re-implements the same capability more than once - a token cost paid
in design and review - or worse, someone stands up a "shadow" agent that
nobody owns, approved, or security-reviewed. This is a problem that appears
only once more than one person is generating agents with AI help, which on
current trends is most projects within a year.

**Evaluate**: whether one source of truth lists every agent, tool, and MCP
server with an owner recorded against each; whether building something new is
preceded by a required check against that catalog for an existing equivalent;
whether an unregistered agent can reach production data or credentials at
all; whether registry metadata - version, approval status - is checked
automatically before one agent is allowed to call another.

**Note**: distinct from C11 (subagent definitions as versioned assets), which
is about one definition file being versioned. This is about discoverability
and approval gating across many agents at the scale of a team or org.

---

## C21. Network mediation for agent-to-agent and agent-to-tool calls

- **Status**: Selected
- **Section**: 6 (Security)
- **Source**: Gemini Enterprise Agent Platform docs - agent-gateway-overview
  (deny-unless-explicitly-granted policy for all agent traffic, protocol
  translation, prompt/response scanning at the boundary)
- **Budget**: ~20 lines

**Leak**: Most projects let an agent call whatever tool, MCP server, or
endpoint its code references, with nothing mediating the call - a service
mesh with no ingress or egress control. An agent that can be prompt-injected
into calling an arbitrary external endpoint has no gate to stop it, and with
no mediating layer there is also no single place to see that traffic
happened afterward, let alone audit it.

**Evaluate**: whether outbound tool, API, or MCP calls go directly from agent
code or through a mediating layer that enforces an allowlist; whether all
agent network traffic lands in one log, independent of what the agent itself
chooses to report; whether a destination is checked against a registry before
a call is made, or the URL is simply hardcoded; whether inbound traffic to an
agent is held to the same standard as agent-to-agent traffic, or quietly
weaker.

**Note**: distinct from C12 (which tools an agent may call) - this is whether
every call, regardless of which tools are allowed, passes through one
enforcement and logging point rather than going direct.

---

## C22. Long-term agent memory governance

- **Status**: Selected
- **Section**: 9 (Data Lifecycle), touches 20 (Context Continuity)
- **Source**: Gemini Enterprise Agent Platform docs - memory-bank
  (extraction, consolidation, TTL, per-identity scope isolation, regional
  residency; "cross-border memory contamination" as the platform's own term)
- **Budget**: ~18 lines

**Leak**: Persistent, cross-session agent memory - facts about a user or task
auto-injected into future prompts - fails in two distinct ways when
unmanaged: an unbounded store that keeps retrieving and re-injecting stale
context on every call, which is pure recurring token cost; and a genuine
compliance risk, where a memory scoped to the wrong identity leaks across
users or lands in the wrong data-residency region. This differs from
within-session context management precisely because the memory is designed
to persist and be reused automatically, not carried once and discarded.

**Evaluate**: whether stored memories carry a TTL or expiration policy, or
accumulate indefinitely; whether memory retrieval is scoped and isolated per
identity, and whether that isolation has actually been tested rather than
assumed; whether there is a defined policy for what is worth remembering, or
the system persists everything by default; whether memory storage respects
the same data-residency requirements as the underlying data it was built
from.

**Note**: the cross-session analogue of what C8 (tooling friction log) and
section 20's persistent memory check ask within a session or across a task.

---

## C23. Agent trajectory evaluation, not just output evaluation

- **Status**: Selected
- **Section**: 12 (Testing)
- **Source**: Gemini Enterprise Agent Platform docs - agent-evaluation
  (trajectory quality vs. final-response quality, environment simulation with
  mocked tool calls and errors); reinforced by a lifecycle blog post
- **Budget**: ~22 lines

**Leak**: Standard testing checks whether the final answer is correct. An
agentic system can reach a correct answer by a wasteful or fragile path - five
sequential tool calls where one would do - and an eval harness that scores
only the final response is blind to this. A regression that triples a
workflow's token cost and latency can pass every existing test as long as the
last line of output still looks right.

**Evaluate**: whether the test suite scores the sequence and efficiency of
tool calls an agent makes, not only its final output; whether any test
injects a mocked tool failure or unexpected result to check the agent
degrades gracefully rather than looping or hallucinating a recovery; whether
a CI gate can fail a build when a trajectory becomes measurably less
efficient - more calls, more tokens - even though the final answer is
unchanged; whether eval cases are versioned and rerun as regression tests
rather than checked once by hand.

**Note**: distinct from C16 (trust and verification of agent-reported
results), which is about not trusting a single unverified claim mid-session.
This is a systematic, offline evaluation harness with a CI gate.

---

## C24. Deterministic grounding checks versus LLM-judge evaluation cost

- **Status**: Selected
- **Section**: 19 (AI-Specific Risk), touches 15 (Cost)
- **Source**: Gemini Enterprise Agent Platform docs - agent-evaluation
  (reference-based vs. reference-free metrics); lifecycle blog post's
  verbatim citation-matching example
- **Budget**: ~14 lines

**Leak**: Many projects check hallucination and grounding purely with an
LLM-as-judge, which costs a full model call per evaluation and is itself
probabilistic - the judge can be wrong or inconsistent between runs. For any
claim that traces back to structured tool output - an ID, a code, a filename,
a number - a plain string match against the source data is both more
reliable and far cheaper at scale than paying for another model call to
render a verdict.

**Evaluate**: whether claims that reference verifiable structured data are
checked deterministically, in addition to or instead of an LLM judge; whether
judge-based evaluation is reserved for genuinely subjective qualities -
helpfulness, tone - rather than applied to everything by default; whether the
token cost of judge-based evaluation at CI scale (tokens times runs times
frequency) is tracked anywhere at all.

---

## C25. Agent interoperability protocol versioning

- **Status**: Selected
- **Section**: 4 (Dependency), touches 13 (Vendor Resilience)
- **Source**: Gemini Enterprise Agent Platform docs - agent-registry
  (A2A protocol version 1.0, `supportedInterfaces` declaration requirement)
- **Budget**: ~14 lines

**Leak**: Once agents built in different frameworks need to call each other or
a shared MCP server, the project has taken on a dependency surface that
existing dependency audits do not see: the interop protocol version, which
lives in no package manifest. An unpinned or undeclared interface is a silent
cross-agent breakage waiting to happen the moment one side upgrades.

**Evaluate**: whether the A2A or MCP protocol version each agent supports is
declared and checked at registration or deploy time, rather than assumed
compatible; whether a change to one agent's interface triggers a check for
other agents or tools that depend on the old one before it ships; whether a
fallback or error path is defined for a call to an agent that does not
support the expected protocol version.

---

## C26. Agent runtime cost shape

- **Status**: Selected
- **Section**: 15 (Cost)
- **Source**: lifecycle blog post (Agent Runtime scale-to-zero and cold-start
  tradeoff, persistent session/memory state, sandboxed code execution billed
  separately from model inference)
- **Budget**: ~16 lines

**Leak**: A managed agent runtime's cost profile is easy to get backwards.
Scale-to-zero removes idle cost but adds cold-start latency, and the common
fix - a keep-alive ping - quietly reintroduces the always-on cost the team
was trying to avoid in the first place. Separately, persistent cross-session
memory kept "just in case" carries its own storage and retrieval cost even
for an agent that never actually uses continuity. Neither shows up in a
simple "which model, how many tokens" cost review, because both are
infrastructure decisions specific to long-lived agent deployments.

**Evaluate**: whether scale-to-zero is enabled for agents that do not need
low-latency response, with the cold-start cost actually measured against the
idle-compute savings rather than assumed; whether a keep-alive ping's cost has
ever been compared to simply eating the cold start; whether every agent with
persistent memory or session state actually uses cross-session continuity, or
it is enabled by default and unused; whether sandboxed code-execution cost is
tracked separately from model-inference cost so one does not hide inside the
other in a bill review.

---

## Agent architecture and design principles (C27 - C31)

Source for this group: anthropic.com/engineering/building-effective-agents,
fetched directly (one article, not a crawl). Distinct from C19-C26: that group
is platform/production governance (identity, network, registry) for an agent
already built and deployed. This group is design-time architecture - whether
an agentic feature was the right shape to build in the first place, before any
governance question arises. Also distinct from C11-C17, which is about
orchestrating Claude Code's own delegated subagents during development, not
about the architecture of a product the project is building.

---

## C27. Complexity justification: agent vs. workflow vs. single call

- **Status**: Selected
- **Section**: new agent-platform section, touches 3 (Architecture)
- **Source**: building-effective-agents ("optimizing single LLM calls with
  retrieval and in-context examples is usually enough"; "agentic systems
  often trade latency and cost for better task performance"; add complexity
  "only when it demonstrably improves outcomes")
- **Budget**: ~18 lines

**Leak**: An open-ended autonomous agent loop is reached for by default on
tasks a single augmented LLM call or a fixed workflow would solve more
cheaply and more predictably. The cost of agentic autonomy is not just
higher latency and spend per task - it is that errors compound across many
autonomous steps instead of surfacing once, the way a single call's error
would.

**Evaluate**: whether, for each LLM-driven feature, a simpler approach -
a single call with retrieval and examples, or a fixed workflow - was tried
and measured before an autonomous agent loop was built; whether the decision
to use an agent rests on a measured comparison rather than a default; whether
the number of steps the task requires is genuinely unpredictable in advance,
which is the stated condition for needing agent-style autonomy, rather than a
fixed pipeline dressed up as an agent; whether agent behavior was tested in a
sandboxed environment with guardrails before being given production autonomy.

**Note**: sharpens section 3's general "is structural complexity proportional
to scope" question into the specific, citable case of agentic complexity.

---

## C28. Workflow pattern selection before an open-ended agent loop

- **Status**: Selected
- **Section**: new agent-platform section
- **Source**: building-effective-agents (prompt chaining, routing,
  parallelization - sectioning and voting, orchestrator-workers,
  evaluator-optimizer)
- **Budget**: ~20 lines

**Leak**: Many tasks built as a fully autonomous agent actually have a fixed,
known shape that one of five well-documented workflow patterns already
covers, more cheaply and more predictably: prompt chaining with checks
between steps, routing to a specialized path, parallelization by splitting a
task or by running it multiple times for diversity, an orchestrator
delegating to workers, or a generator checked by an evaluator in a loop. An
open-ended agent built for a task with a genuinely fixed shape carries the
compounding-error risk of autonomy without buying any of the flexibility
that autonomy is for.

**Evaluate**: whether each agentic feature was checked against the five
standard patterns before an open-ended loop was chosen; whether a task that
decomposes into fixed steps is implemented as a workflow - deterministic
control flow with LLM calls inside the steps - rather than as an agent
renegotiating the same fixed steps on every run; whether the choice among
patterns is documented, so a later reviewer can tell why an agent rather
than a chain or a router was used, instead of inferring it from the code.

**Note**: complements C27. C27 asks whether the task should be agentic at
all; this asks, if so, which known pattern fits before defaulting to a fully
open loop.

---

## C29. Agent-computer interface (tool and API) design and testing quality

- **Status**: Processed - written into Save Tokens Audit v2.2.txt, section 2
- **Section**: 1 (AI Configuration), touches the new agent-platform section
- **Source**: building-effective-agents (ACI section: tool documentation
  "just as much prompt engineering attention as your overall prompts," the
  poka-yoke absolute-path example, format guidance)
- **Budget**: ~22 lines

**Leak**: A tool or API exposed for an agent to call routinely gets less
design rigor than one built for a human developer - a thin description, an
ambiguous parameter, a format that forces the model into token-expensive
bookkeeping such as maintaining an exact line count or escaping strings by
hand. A tool an agent misuses produces the same retries and wrong actions as
a hallucinated API, except the fix costs a rewrite of the tool's interface,
not a prompt correction.

**Evaluate**: whether each tool exposed to an agent is documented to the
standard of a docstring for a new team member - example usage, edge cases,
explicit input format, clear boundaries from adjacent tools; whether the tool
has actually been tested by running many example agent invocations against
it and revising the interface based on the mistakes observed, not only
unit-tested against a spec written before any agent used it; whether the
tool's argument design makes the common mistake structurally impossible -
requiring an absolute path instead of a relative one, for instance - rather
than merely documenting against it; whether output formats resemble
naturally-occurring text the model has seen at scale, rather than a bespoke
format that costs extra tokens and errors to produce correctly.

---

## C30. Framework abstraction risk in agent implementations

- **Status**: Selected
- **Section**: 2 (Technology Stack), touches 19 (AI-Specific Risk)
- **Source**: building-effective-agents ("start by using LLM APIs directly";
  frameworks "often create extra layers of abstraction that can obscure the
  underlying prompts and responses"; "incorrect assumptions about what's
  under the hood are a common source of...error")
- **Budget**: ~14 lines

**Leak**: An agent framework hides the actual prompts and API calls it
constructs, which is convenient until something misbehaves - then diagnosing
it requires first reverse-engineering what the framework actually sent,
before the real problem can even be located.

**Evaluate**: when an agent misbehaves, can the actual prompt and API call it
sent be inspected directly, or does diagnosis require first understanding a
framework's internal prompt construction; was a framework adopted for a
pattern simple enough to implement directly in a few lines against the raw
API; does anyone on the team actually understand what the framework does
underneath its abstraction, or is its behavior taken on faith.

---

## C31. Explicit agent planning-step transparency

- **Status**: Selected
- **Section**: new agent-platform section, touches 14 (Observability)
- **Source**: building-effective-agents (one of three named core principles:
  "prioritize transparency by explicitly showing the agent's planning steps")
- **Budget**: ~14 lines

**Leak**: An agent that reasons internally and reports only a final action
gives a reviewer nothing to check before the action lands, and nothing to
debug afterward beyond an outcome that was already executed. Anthropic lists
this alongside simplicity and interface design as one of only three core
principles in the piece - not an optional nicety.

**Evaluate**: whether the agent surfaces its plan or reasoning before or
alongside an action with a real-world effect, rather than only the action
itself; whether a human or an automated check can intervene on the plan
before execution, for actions above some risk threshold; whether the
planning trace is available to diagnose a wrong action afterward, or only
the outcome is.

**Note**: distinct from C16 (trust and verification of agent-reported
results), which is a review discipline applied after the fact. This is a
design property - surfacing the plan as the agent forms it, not verifying a
claim once it has already acted.

---

## Agent platform governance, OpenAI sources (C32 - C37)

Source for this group: five OpenAI URLs the user gave (solutions/agents,
practical-guide-to-building-ai-agents, its PDF, workspace-agents, and the
developers.openai.com building-agents track), researched by an agent.
**Fetch reliability caveat**: two of the five pages returned HTTP 403 to
direct fetch and were substituted with WebSearch-aggregated summaries
(moderate confidence, not a direct read); the PDF came back as unreadable
binary and was also substituted. Only developers.openai.com/tracks and one
linked cookbook page (agentic_governance_cookbook, reached within the
research agent's 3-extra-fetch allowance) were read directly. Treat sourcing
on this group as weaker than the Gemini and Anthropic groups above - verify
against the primary pages before drafting final prompt text if these are
selected.

---

## C32. Guardrail-layer precision/recall tuning

- **Status**: Selected
- **Section**: 6 (Security) or 19 (AI-Specific Risk)
- **Source**: OpenAI agentic governance cookbook (guardrail pipeline stages,
  confidence-threshold feedback loops, oscillation-prevention guidance)
- **Budget**: ~15 lines

**Leak**: Each guardrail - a relevance classifier, a safety classifier, a
PII filter - is typically its own model call layered in front of or behind
the main agent call. Deployed once and never re-tuned, an over-aggressive
threshold multiplies cost and latency across all traffic through false
positives, while a too-loose one lets unsafe output through - and neither
failure shows up in ordinary "does the agent work" testing, only when the
guardrails themselves are measured.

**Evaluate**: whether guardrail classifiers are tracked with their own
precision/recall metrics, separate from end-task accuracy; whether a labeled
eval set of known-good and known-bad inputs is used to tune thresholds,
rather than thresholds set once from intuition; whether guardrail-layer
token and latency cost is measured separately from the primary agent call,
so its overhead is visible in cost review; whether there is a documented
process to prevent threshold oscillation when tuning one metric destabilizes
another.

**Note**: distinct from C24 (deterministic grounding checks vs. LLM-judge
cost), which evaluates the agent's final output against source truth. This
evaluates the guardrail classifiers themselves, which run on every call
regardless of whether the main task succeeds - a multiplicative cost tax on
all traffic, not an eval-time cost.

---

## C33. Human-in-the-loop escalation calibration

- **Status**: Selected
- **Section**: 6 (Security) or 16 (Governance)
- **Source**: OpenAI practical guide to building agents (per-tool risk
  ratings, failure-threshold and high-risk triggers for escalation)
- **Budget**: ~14 lines

**Leak**: A project without a deliberate escalation design picks one of two
costly extremes: escalating too much, where a human review queue becomes the
bottleneck and burns reviewer time on trivially safe actions; or escalating
too little, where irreversible tool calls execute unsupervised and failures
surface only after the damage is done. Neither extreme is visible from
reading the code alone - it requires checking whether risk is actually rated
per tool and whether the escalation rate itself is tracked.

**Evaluate**: whether tools or actions carry an explicit risk rating -
read-only, reversible, irreversible - with different approval requirements
per tier; whether a numeric failure-threshold or anomaly trigger drives
escalation, rather than escalation being ad hoc or absent entirely; whether
the human-escalation rate is tracked over time, since a rising rate signals
drifting difficulty or a miscalibrated agent and a rate that falls to zero on
a system with irreversible actions is itself a red flag; whether human
feedback from an escalation is fed back into evaluation data or discarded
after the human acts.

**Note**: related to C12 (least-privilege scoping of delegated agents) but
distinct: C12 is a static allowlist set at agent-definition time; this is a
dynamic, per-call risk gate plus its own throughput calibration against
reviewer capacity.

---

## C34. Governance-as-code packaging across agents

- **Status**: Selected
- **Section**: 16 (Governance)
- **Source**: OpenAI agentic governance cookbook (versioned, installable
  policy packages consumed by every agent)
- **Budget**: ~12 lines

**Leak**: When safety and compliance policy - PII filtering, moderation
rules, jailbreak checks - is hand-rolled inline per agent rather than defined
once as a versioned package every agent consumes, a codebase with several
agents accumulates slightly different copies of "the PII filter." When a
rule needs to change, someone has to find and patch every copy, and the
drift is in safety-critical logic, not a utility function.

**Evaluate**: whether there is one canonical, versioned source for
cross-cutting agent policies, or equivalent logic duplicated per agent;
whether updating a policy requires touching every consuming agent or
propagates from a single version bump; whether there is one place to answer
"which policy version is agent X running" for an audit.

**Note**: adjacent to C20 (agent registry, which solves duplicate-agent
sprawl) and C11 (which versions role/prompt definitions). This versions
shared safety and compliance policy modules specifically - a different
artifact from either.

---

## C35. Trace and telemetry data residency for agent observability

- **Status**: Selected
- **Section**: 14 (Observability)
- **Source**: OpenAI agentic governance cookbook (Zero Data Retention
  compliance, custom trace processors redacting PII before storage)
- **Budget**: ~13 lines

**Leak**: Agent observability naturally wants full spans - every tool call,
prompt, and output - for debugging. That telemetry stream carries the same
PII and compliance exposure as the underlying conversations, and a
vendor-hosted tracing dashboard may violate a retention commitment the
primary data is already held to. A project can end up non-compliant purely
through its debug logs, because telemetry is treated as exempt from scrutiny
by default.

**Evaluate**: where execution traces (prompts, tool arguments and results,
outputs) are stored, and whether that location is covered by the same
data-retention requirements as the primary data; whether PII is redacted
from spans before storage, or only from user-facing output; whether, if a
vendor's hosted tracing dashboard is in use, its retention policy has
actually been checked against the project's compliance obligations.

**Note**: a different data class from C22 (long-term agent memory
governance): that candidate covers the agent's own persistent state;
this covers execution telemetry generated continuously regardless of
whether the agent has memory at all, and often exempted from scrutiny
because it is "just logs."

---

## C36. Provider-managed conversation state lock-in

- **Status**: Selected
- **Section**: 13 (Vendor Resilience), touches 20 (Context Continuity)
- **Source**: OpenAI developers track (Responses API's server-side
  conversation-history statefulness)
- **Budget**: ~14 lines

**Leak**: A provider API that stores and replays conversation history
server-side is convenient, but creates two under-examined costs: opaque
replay economics, since it is not always clear whether replayed history is
billed at full input-token rates on every subsequent turn, so a long-running
stateful session can accumulate cost invisibly; and portability lock-in,
since conversation continuity lives in the provider's storage and does not
travel if the provider is switched or the workload is self-hosted later.

**Evaluate**: for any provider-managed stateful conversation feature in use,
whether it is clear how replayed history is billed on each call; whether
conversation continuity would survive a provider switch, or would need to be
reconstructed from the project's own logs; whether there is a cap or pruning
policy on provider-side stored state, or it grows unbounded for long
sessions.

**Note**: distinct from C30 (framework abstraction risk), which is about not
being able to inspect what a framework sends. This is about a provider
silently owning and billing for state the caller never resends or sees at
all - an economic and lock-in risk, not a debuggability one.

---

## C37. Checkpointing for triggered or scheduled agents on partial failure

- **Status**: Selected
- **Section**: 18 (Deployment & Recovery)
- **Source**: OpenAI workspace-agents framing (trigger + process + connected
  tools, for time-based or event-driven work)
- **Budget**: ~13 lines

**Leak**: A workflow triggered on a schedule or webhook that fails partway
through a multi-step process, and simply reruns from the top on the next
trigger instead of resuming from the failure point, pays the full token cost
of every already-completed step again on every retry. If the failure is
systemic - a broken downstream connector, an expired token - this repeats
indefinitely until someone notices, silently burning budget on a workflow
that was never going to complete.

**Evaluate**: whether a triggered agent's partial failure resumes from the
failure point or reruns the entire workflow from scratch; whether there is
alerting on repeated failures of the same triggered workflow, rather than
silent indefinite retry; whether connector or auth tokens the triggered
agent depends on are monitored for expiry, rather than surfacing only when
something external notices the agent has stopped working.

---

## Anthropic prompting-practice claims, secondhand sources (C38 - C40)

Source for this group: a summary the user pasted, itself aggregated from a
YouTube video ("How Anthropic Engineers ACTUALLY Prompt Claude Code"), a
second YouTube clip, a LinkedIn post, an Instagram reel, and a Substack post
- secondhand characterizations of Anthropic engineers' practice, not a
primary Anthropic document. **Confidence caveat**: treat this group as the
weakest-sourced in the file. Several of its claims restate ground this file
already covers in more detail (skills' three-layer structure duplicates the
existing Skills architecture check; running parallel sessions duplicates
C15); those are not re-added here. Only the genuinely new claims follow.

---

## C38. Deterministic script versus inference for repeatable sub-tasks

- **Status**: Processed - written into Save Tokens Audit v2.2.txt, section 2
- **Section**: 1 (AI Configuration)
- **Source**: pasted summary, "write code instead of tokens: if a
  deterministic task can be handled by a short script, let code handle it
  rather than burning inference tokens"
- **Budget**: ~15 lines

**Leak**: A deterministic sub-task - reformatting a file, computing a value,
renaming across a set of matches - handled by asking the model to reason
through it in natural language costs more tokens, runs slower, and is less
reliable than a short script that does the same thing exactly every time.
Skills and configuration files that describe such a step as something the
agent should "figure out" each run are paying inference cost for a problem
that does not need judgment.

**Evaluate**: whether a skill or configuration rule identifies its
deterministic sub-steps and hands them to a script rather than to model
reasoning; whether a task performed identically more than once in a session
gets converted to a script rather than re-prompted each time; whether the
project's skills contain any step whose correct output could be verified by
a human as "always the same given the same input" and is still being
generated by inference rather than computed.

**Note**: complements C29 (agent-computer interface design) - that candidate
is about tool quality when the model does need to call something; this is
about recognizing when the model should not be doing the work at all.

---

## C39. Embedded self-verification step within skill or workflow procedures

- **Status**: Processed - written into Save Tokens Audit v2.2.txt, section 2
- **Section**: 1 (AI Configuration)
- **Source**: pasted summary, "self-correction loops: program skills to
  include verification steps - have Claude render, inspect, or critique its
  own initial output against provided evidence before showing it to you"
- **Budget**: ~15 lines

**Leak**: A skill that describes only the steps to produce an output, with no
step requiring the agent to check that output against evidence before
presenting it, relies entirely on the human reviewer to catch a wrong result.
A skill that mandates a check-against-evidence step as part of its own
procedure - render a UI and inspect it, run the test it just wrote, diff
generated output against the spec - catches a class of error before it ever
reaches review, at the cost of one extra step baked into the skill itself.

**Evaluate**: whether skills or workflow procedures that produce a
verifiable artifact (rendered UI, generated file, structured output) include
a mandatory self-check step against that evidence, rather than ending at
generation; whether the self-check compares against something concrete -
a test result, a rendered screenshot, a spec - rather than the model's own
unaided judgment of its own output; whether skills lacking this step are
ones whose output is genuinely unverifiable in isolation, or simply ones
where the step was never added.

**Note**: distinct from C16 (trust and verification of agent-reported
results), which is a review discipline for what one agent tells another or
tells the human. This is a design property built into the skill's own
procedure, run by the same agent before it reports anything at all - closer
in spirit to C31 (explicit agent planning-step transparency) than to C16.

---

## C40. Prompt-engineering craft within configuration and skill files

- **Status**: Rejected
- **Section**: 1 (AI Configuration)
- **Source**: pasted summary - few-shot examples in delimiter tags, positive
  over negative framing, structural tags separating context/instructions/
  output
- **Budget**: ~12 lines

**Leak**: The existing Skills architecture check asks whether a skill exists,
is scoped correctly, and loads on demand - not whether the instructions
inside it are well-written as a prompt. A skill or configuration rule phrased
as a list of prohibitions, with no example of the desired output, is a weaker
prompt than the same rule with one concrete example and positive framing,
and the difference shows up as more correction cycles per use, not as a
missing feature.

**Evaluate**: whether a skill that produces a specific output format includes
at least one concrete example of that output, rather than only a
description; whether instructions are phrased as what to do rather than
predominantly as a list of prohibitions; whether distinct blocks - context,
instructions, expected output - are structurally delimited rather than run
together as undifferentiated prose.

**Note**: the thinnest candidate in this group and the most subjective to
evaluate consistently - flag for a lower priority or fold into the existing
Skills architecture check as a closing bullet rather than a standalone block,
if selected.

**Rejection reason**: too subjective to evaluate consistently as a standalone
audit block. The underlying point survives as a closing bullet on the
existing Skills architecture check instead, if that check is revised.

---

## Structural proposal: a dedicated Skills section

Raised by the user, prompted by how much skill-authoring content has
accumulated scattered across this file: the existing Skills architecture
block (Processed, inside section 1), C29 (tool/API design, adjacent), and
C38-C40 (deterministic scripts, embedded self-verification, prompt craft) are
all skill-authoring concerns homed in section 1 mainly for lack of a better
place. The two IBM videos below reinforce this - their organizing frame is
skills as a category in their own right, alongside MCP, RAG, and memory, not
a subtopic of general AI configuration.

**Done**: inserted as section 2 (Agent Skills Audit) in
Save Tokens Audit v2.2.txt, right after section 1. Sections that were 2-21
were renumbered to 3-22. The former Skills architecture block was cut out of
section 1 and moved into section 2 verbatim; two cross-references inside
section 1 that pointed at it were updated to name section 2 explicitly.
Note: this work initially landed in v2.1.txt by mistake, after v2.1 had
already been committed - corrected by moving the content to v2.2.txt and
restoring v2.1.txt to its committed state. See Delta v2.2 from v2.1.md.

---

## Skill-craft candidates from IBM's skills videos (C41 - C42)

Source for this group: two IBM Technology YouTube videos ("5 Best Practices
for Building AI Agent Skills" and "Skills vs MCP vs RAG vs Memory: What AI
Agents Need to Know"), both presented by Martin Keen (and Bri Kopecki for
the first). **Fidelity caveat**: YouTube's transcript panel would not
reliably render through browser automation (virtualized list, stale element
references after repeated attempts) - these candidates are sourced from each
video's official title, description, and chapter markers, plus a small
number of caption fragments incidentally captured while the player was
active, not a full transcript read. Confidence is moderate: real enough to
be worth drafting, not verified against the full spoken content. A third
video in the batch (a 52-second clip from a secondary "AI automation agency"
channel, not Anthropic's own channel) is not represented here - its likely
content overlaps C27, C28, and C39 closely enough, and its length and
provenance are thin enough, that it did not clear the bar for a new
candidate.

---

## C41. Skill trigger-description specificity

- **Status**: Processed - written into Save Tokens Audit v2.2.txt, section 2
- **Section**: proposed new Skills section (see structural proposal above),
  currently section 1
- **Source**: "5 Best Practices for Building AI Agent Skills" (IBM
  Technology), chapter "Write Skills That Trigger"; caught caption: "a
  compliance skill that generates reports might be just a little bit too
  vague"
- **Budget**: ~12 lines

**Leak**: The existing Skills architecture check asks whether a description
is concise and under a length ceiling. A description can satisfy that and
still be too vague to trigger reliably - "generates reports" describes
almost anything a compliance-adjacent skill might do, so the router has
nothing to disambiguate it from a neighboring skill, and either the wrong
skill fires or none does and the agent falls back to reasoning the task out
from scratch at full cost.

**Evaluate**: whether a skill's description names the specific situation
that should trigger it, not only the general category of what it does;
whether two skills in the same project could plausibly both match the same
request, and if so, whether their descriptions were revised to disambiguate;
whether description quality has actually been tested by checking which
skill fires on a handful of realistic requests, not just read for length.

**Note**: narrower than, and a real addition to, the existing Skills
architecture check - length and specificity are different failure modes and
a skill can pass one while failing the other.

---

## C42. Explicit escalation conditions instead of guessing

- **Status**: Processed - written into Save Tokens Audit v2.2.txt, section 2,
  accepted as-is on the reconstructed content's own merits despite the
  sourcing caveat above
- **Section**: proposed new Skills section, currently section 1
- **Source**: "5 Best Practices for Building AI Agent Skills" (IBM
  Technology), chapter title "When Agents Shouldn't Guess." **Lower
  confidence than most entries in this file**: sourced from the chapter
  title and the description's "avoid common pitfalls" line only - the
  explanatory content of this specific chapter could not be read, so the
  evaluate bullets below are a reasonable reconstruction of what the title
  implies, not a paraphrase of stated content. Verify against the source
  before drafting final prompt text.

**Leak**: A skill that describes only the happy path leaves the agent to
guess when an input is ambiguous or a precondition is unmet, and a plausible
wrong guess is more expensive than a stalled task - it produces a confident,
wrong result that consumes downstream tokens before anyone notices, rather
than a cheap, early request for clarification.

**Evaluate**: whether a skill's procedure names the specific conditions under
which the agent must stop and ask rather than proceed on an assumption;
whether "ask for clarification" is phrased as a required step for named
conditions, not a general disclaimer that leaves the judgment call to the
model; whether a skill has actually been exercised with an ambiguous or
malformed input to check it stops rather than guesses.

**Note**: complements C39 (embedded self-verification), which checks output
against evidence after generation. This is about not proceeding past a
precondition failure at all.

---

## C43. Mechanism selection: skill, MCP tool, RAG, or memory

- **Status**: Processed - written into Save Tokens Audit v2.2.txt, section 2,
  placed first, before Skills architecture, as the logically prior question
- **Section**: proposed new Skills section, or new agent-platform section
- **Source**: "Skills vs MCP vs RAG vs Memory: What AI Agents Need to Know"
  (IBM Technology) - description states the video's own thesis: "four core
  techniques... Learn when each approach should be used, how they work
  together, and why they play different roles." No chapters were available
  for this video and the transcript could not be read; this candidate is
  built from the description's explicit framing, not the explanatory detail.
- **Budget**: ~18 lines

**Leak**: Skills, MCP tool connections, retrieval (RAG), and persistent
memory solve different problems - procedural knowledge, live external
capability, large or changing information, and experience across sessions,
respectively - but a project without a clear model of the distinction tends
to default to one mechanism for everything it builds: a memory store used
for what should have been a retrieval index, or a hand-written skill
re-describing knowledge that a retrieval call would fetch fresher and
cheaper. Each mechanism has a different cost and staleness profile, so
picking the wrong one is a recurring tax, not a one-time mistake.

**Evaluate**: whether the project can state, for each piece of agent
capability, which of the four mechanisms it uses and why; whether anything
implemented as a skill is actually static procedural knowledge rather than
information that changes often enough to belong in retrieval instead;
whether anything implemented as persistent memory is genuinely
experience-across-sessions rather than a lookup that retrieval or a direct
tool call would serve more cheaply and more freshly; whether a live external
capability was hand-coded into a skill's instructions instead of exposed as
a tool call.

**Note**: the same proportionality argument as C27/C28 (agent vs. workflow
vs. single call) and C1/C6, applied to a different axis - which knowledge or
capability substrate fits the need, not which control-flow pattern does.

---

## Skills best practices, cross-vendor (C44 - C51)

Source for this group: official documentation read directly, not social
media or search-synthesis - the strongest sourcing of any research batch in
this file after the initial Gemini platform group. **Anthropic**: the
dedicated Skill authoring best-practices page, plus two engineering blog
posts ("Equipping agents for the real world with Agent Skills" and
"Introducing advanced tool use"). **OpenAI**: a genuine, dated Skills feature
compatible with the open `agentskills.io` standard - the Skills API guide
and an Agents SDK case-study blog post. **Google Gemini**: no branded
"Skills" feature exists. The closest analog is Gemini CLI's folder-based
Extensions (`gemini-extension.json` + `GEMINI.md`, bundled MCP servers);
its guidance is thinner and mostly packaging/security-oriented, so it
corroborates C51 below rather than standing on its own. Candidates 44, 45,
46, 49, and 50 are Anthropic-only, drawn from verbatim examples on the
best-practices page. C47 is cross-vendor with hard numbers from both
Anthropic and OpenAI. C51 is corroborated by all three.

---

## C44. Concise-is-key / assume-competence pruning

- **Status**: Processed - written into Save Tokens Audit v2.2.txt, section 2
- **Section**: proposed new Skills section
- **Source**: Anthropic Skill authoring best practices, "Core principles ->
  Concise is key" - a verbatim before/after example: the same instruction at
  ~150 tokens (explaining what a PDF is, why a library is recommended) vs.
  ~50 tokens (just the import and one code block)
- **Budget**: ~14 lines

**Leak**: A skill that explains concepts the model already knows from
training - what a PDF is, why a well-known library is a reasonable choice -
pays a token cost on every trigger for information that adds nothing. This
is distinct from the existing "reference knowledge belongs in linked docs"
check, which is about where content lives; this is about content that should
not have been written at all, in any location.

**Evaluate**: whether the skill body explains concepts the model already
knows rather than only the project-specific procedure; whether a sampled
paragraph can be deleted without changing the agent's behavior, which is the
test for whether it earned its token cost; whether sentences justify why a
tool or library was chosen when a bare recommendation would do the same job.

---

## C45. Freedom-calibration to task fragility

- **Status**: Processed - written into Save Tokens Audit v2.2.txt, section 2
- **Section**: proposed new Skills section
- **Source**: Anthropic Skill authoring best practices, "Set appropriate
  degrees of freedom" - three instruction styles (high-freedom heuristic
  prose, medium parameterized pseudocode, low-freedom exact scripts) with
  the stated analogy "narrow bridge vs. open field"
- **Budget**: ~15 lines

**Leak**: A skill's freedom level can be wrong in either direction even when
the skill is otherwise correctly scoped. Over-specifying an open-ended
judgment task (a code review, a research question) as a rigid script
forecloses valid approaches and wastes the model's actual capability.
Under-specifying a fragile, irreversible operation (a database migration, a
destructive edit) as loose prose invites a plausible-looking deviation that
causes real damage.

**Evaluate**: whether skills governing fragile or irreversible operations
are written as exact, low-freedom scripts rather than general prose;
whether skills for open-ended judgment tasks avoid over-specifying a rigid
procedure that closes off valid approaches; whether the freedom level
actually matches what the skill's own title or description implies.

---

## C46. Reference-file navigability: link depth and table-of-contents discipline

- **Status**: Processed - written into Save Tokens Audit v2.2.txt, section 2
- **Section**: proposed new Skills section
- **Source**: Anthropic Skill authoring best practices, "Avoid deeply nested
  references" and "Structure longer reference files with a table of
  contents" - direct quote: nested reference links can cause the agent to
  use commands like `head -100` to preview rather than read a file fully,
  "resulting in incomplete information"
- **Budget**: ~13 lines

**Leak**: A reference file that links to another reference file, two or more
hops from the skill's entry point, invites a partial read that looks
successful but silently drops context - the agent previews the file instead
of reading it in full, and nothing signals that the preview was incomplete.

**Evaluate**: whether any reference file links onward to a further reference
file rather than staying one hop from the skill's entry point; whether a
reference file over roughly 100 lines carries a table of contents at the
top, so a partial or preview read still reveals its full scope; whether
session transcripts show the agent previewing a long reference file with a
command like `head` or `sed` instead of reading it whole.

---

## C47. Tool and skill count budget with deferred, search-based discovery

- **Status**: Processed - written into Save Tokens Audit v2.2.txt, section 2
- **Section**: proposed new Skills section
- **Source**: cross-vendor with hard numbers. OpenAI's function-calling
  guide: "aim for fewer than 20 functions available at the start of a
  turn," since each definition is billed as input tokens on every turn.
  Anthropic's advanced tool use post: eager loading of 50+ MCP tools cost
  about 72,000 tokens versus about 8,700 tokens with search-based deferred
  loading (roughly an 85 percent reduction), and MCP-eval accuracy rose from
  49 to 74 percent on one model purely from switching to deferred loading
- **Budget**: ~18 lines

**Leak**: Every eagerly-loaded tool or skill definition is billed on every
turn regardless of whether that turn uses it. Past a modest count this stops
being a rounding error: Anthropic's own measurement shows a nearly
order-of-magnitude token difference, and a real accuracy difference, between
loading everything upfront and loading definitions on demand through search.
This generalizes directly to skill sprawl, not only to MCP tool counts.

**Evaluate**: how many tools or skills are eagerly loaded into context at
the start of a conversation, independent of how many are actually used;
whether a search or deferred-loading mechanism exists once that count passes
roughly 15 to 20; whether the small set of tools or skills used on nearly
every turn stay eagerly loaded while the long tail is deferred, rather than
an all-or-nothing choice.

**Note**: complements C6 (per-session baseline budget) with a specific,
quantified mechanism for the tool/skill-count dimension of that budget.

---

## C48. Programmatic tool orchestration to prevent context pollution

- **Status**: Processed - written into Save Tokens Audit v2.2.txt, section 2
- **Section**: proposed new Skills section
- **Source**: Anthropic advanced tool use post, "Programmatic Tool Calling" -
  measured reduction from 43,588 to 27,297 tokens (37 percent) on a
  multi-step workflow, elimination of 19 or more separate inference passes
  for a 20-call chain, and an accuracy gain on one benchmark from 46.5 to
  51.2 percent
- **Budget**: ~16 lines

**Leak**: A workflow chaining several dependent tool calls that routes every
intermediate result - a raw API payload, a multi-thousand-row list - back
through the model between steps pays for the model to read data it will
immediately hand to the next tool unchanged. Writing that chain as code that
calls multiple tools and returns only the final synthesized result cuts both
the token cost and the number of inference passes, measured in the tens of
percent on a representative workflow.

**Evaluate**: whether a workflow chaining three or more dependent tool or
skill calls routes each intermediate result back through the model between
steps, rather than through a code layer that only returns the final result;
whether an orchestration or code-execution layer is available for this
purpose where the harness supports it; whether anyone has actually measured
the token cost of a representative multi-step workflow with and without
this pattern.

**Note**: a chaining-architecture pattern, distinct from C38 (deterministic
script vs. inference for one repeatable step) - this is about how several
tool calls compose, not whether any single step should be scripted.

---

## C49. Evaluation-first skill development

- **Status**: Processed - written into Save Tokens Audit v2.2.txt, section 2
- **Section**: proposed new Skills section
- **Source**: Anthropic Skill authoring best practices, "Build evaluations
  first" - create evaluations before writing extensive documentation, a
  minimum of three scenarios, an explicit baseline run without the skill,
  then minimal instructions written just to pass
- **Budget**: ~15 lines

**Leak**: Writing a skill's documentation before establishing what gap it
actually closes invites speculative guidance for failure modes nobody has
observed, which bloats the skill body with instructions that never earn
their token cost. Recording a baseline - what the agent does without the
skill - and a small set of concrete scenarios first, then writing only
enough instruction to pass them, keeps the skill's content tied to a real,
demonstrated gap.

**Evaluate**: whether a skill has a recorded baseline showing what the agent
did before the skill existed, documenting the actual gap being closed;
whether at least a handful of concrete evaluation scenarios - a query and
the expected behavior - are checked in alongside the skill; whether any
section of the skill addresses a failure mode nobody has actually observed
happening.

**Note**: distinct from C39 (embedded self-verification within a skill's own
runtime procedure) - this is an authoring-time gate on what goes into the
skill in the first place, not a runtime check the skill performs on its own
output.

---

## C50. Script robustness: no deferred error handling, no unjustified constants

- **Status**: Processed - written into Save Tokens Audit v2.2.txt, section 2
- **Section**: proposed new Skills section
- **Source**: Anthropic Skill authoring best practices, "Solve, don't defer"
  and the "voodoo constants" subsection (citing Ousterhout's law on
  undocumented magic numbers)
- **Budget**: ~16 lines

**Leak**: A bundled script that lets a common error propagate back to the
agent instead of handling it defeats the point of scripting the step at
all - every unhandled error re-triggers a full model reasoning pass on
something the script should have resolved deterministically. Separately, an
undocumented magic number in a script forces the agent to guess whether the
value is safe to reuse or change, a guess a one-line rationale comment would
have made unnecessary.

**Evaluate**: whether bundled scripts catch and handle their own common
failure modes - a missing file, a permission error - rather than letting
the exception reach the agent; whether numeric or configuration constants in
scripts carry a one-line rationale rather than appearing as bare magic
numbers; whether a script's failure message tells the agent specifically
what to fix, such as the valid values for a field, rather than only that it
failed.

**Note**: distinct from C38 (whether to script a step at all) - this is
about whether a script, once written, is actually reliable to depend on.

---

## C51. Skill supply-chain trust and injection/exfiltration review gate

- **Status**: Processed - written into Save Tokens Audit v2.2.txt, section 2
- **Section**: proposed new Skills section, touches 6 (Security)
- **Source**: triple-corroborated. Anthropic's Agent Skills blog post,
  "Security considerations" - audit an externally-sourced skill's bundled
  code and resources, especially instructions directing the agent to
  contact untrusted network destinations. OpenAI's Skills guide - skills as
  "privileged code and instructions" carrying "prompt injection-driven data
  exfiltration" risk, requiring developer inspection before use and gating
  write/high-impact actions behind explicit approval, never exposing raw
  skills to end users. Gemini CLI's extension best practices - least
  privilege and an explicit tool-denylist for dangerous shell patterns
- **Budget**: ~20 lines

**Leak**: A skill or extension is privileged code and instructions, not
inert documentation - one sourced externally and enabled without a full
read is an injection and exfiltration surface distinct from ordinary code
review, since its content can direct the agent to call out to an
unrecognized destination or perform a high-impact action the reviewer never
saw described anywhere else.

**Evaluate**: whether an externally-sourced skill or extension has actually
been read in full, including any bundled scripts, before being enabled;
whether any skill contains instructions that cause outbound network calls,
and whether the destination is one the team recognizes and approved; whether
write or otherwise high-impact actions reachable by a skill are gated behind
explicit confirmation rather than invocable autonomously; whether end users
can enable arbitrary skills directly, or only a bounded set a developer has
already curated.

**Note**: a quality/security-risk item rather than a pure token-waste one,
matching this audit's own stated secondary objective. Corroborated
independently by all three vendors researched, the strongest cross-vendor
agreement of any candidate in this file.

---

## Notes for triage

C1 and C2 come straight from the open issues and should probably anchor the
next version.
C3 is the other issue and is cheap to write. C4, C5 and C6 are the largest
genuine gaps I can find against the current 21 sections - nothing in v2.1
mentions parallel sessions, connected tool servers, or a measured baseline.
C7 through C9 are narrower. C10 overlaps with existing material in section 19
and may be better as two added bullets than as its own block.

**Triage of C1-C17 complete (see status field on each entry above).** Of those:
6 Processed (C1, C2, C3, C6, C7, C8 - written into Save Tokens Audit
v2.1.txt), 7 Selected but not yet integrated (C11-C17), 4 Rejected (C4, C5,
C10 merged away; C9 dropped outright).

C18, C42, and C43 are now Processed (see their entries above) - approved as-is
and written into Save Tokens Audit v2.2.txt.

Selected, as 13 distinct blocks to draft:

- **Existing sections**: C1 (12), C2 (11), C3 (16 or new), C6 absorbing C5
  (1, ~30 lines), C7 (1 or 16, harness-neutral per its drafting constraint),
  C8 (20 or 16).
- **New section 22 (agents)**: C11, C12, C13, C14 absorbing C4 (~30 lines),
  C15, C16 absorbing C10 (~30 lines), C17.

Thirteen blocks is still far more than one version should absorb; v2.1 added
one. The agent group (7 blocks, all Selected) is the more coherent unit to
integrate together, since it's a genuine gap - the prompt currently mentions
neither parallel sessions nor MCP servers - and it directly answers issue #2.
C1-C3 answer issue #1 and the other half of issue #2 and are cheap. C6-C8 are
general-configuration items with no issue behind them.

Per the integration gate above, the next step (which blocks go into v2.1 or a
new v2.2, in what order) is started by the maintainer, not decided here.

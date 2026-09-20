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
exactly one block (50 lines, section 1) over v2.0.

Text is deliberately plain ASCII. Working file: Save Tokens Audit v2.1.txt
(961 lines, 21 sections).

---

## C1. Test suite parallelization and wall-clock budget

- **Status**: Selected
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

- **Status**: Selected
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

- **Status**: Selected
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

- **Status**: Selected
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

- **Status**: Selected
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

- **Status**: Selected
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

## Notes for triage

C1 and C2 come straight from the open issues and should probably anchor the
next version.
C3 is the other issue and is cheap to write. C4, C5 and C6 are the largest
genuine gaps I can find against the current 21 sections - nothing in v2.1
mentions parallel sessions, connected tool servers, or a measured baseline.
C7 through C9 are narrower. C10 overlaps with existing material in section 19
and may be better as two added bullets than as its own block.

**Triage complete (see status field on each entry above).** Final tally: 13
Selected, 4 Rejected (C4, C5, C10 merged away; C9 dropped outright). Zero
Undecided or To investigate remain.

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

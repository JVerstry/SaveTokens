# Delta: v2.2 ← v2.1

Net: +229 lines (1222 → 1451). One new numbered section (Agent Skills Audit,
inserted as section 2; every section that was 2-21 shifted to 3-22), one new
preamble subsection (parallel execution option), and one relocated block
(Skills architecture, moved out of section 1 into the new section 2, verbatim
plus two cross-reference fixes). No existing check was removed or reworded
outside of those two cross-reference fixes.

## AUDIT SEQUENCE (preamble)

- **Parallel execution option** *(new)*: before starting, assess whether the
  audit is a good candidate for parallel execution, since most sections read
  different files and evaluate independent properties. If the project is
  large enough and the environment supports it, **propose** to the user —
  once, before starting, not partway through — running the audit as a
  fan-out of concurrent agents per section or per cluster, followed by a
  synthesis pass. Framed explicitly as an option to offer, not a default to
  adopt. If accepted, three rules apply to the fan-out itself:
  1. Map dependencies before splitting work (some sections reference another
     section's findings; a dependent section runs after the one it depends
     on, not concurrently with it).
  2. Deduplicate at the synthesis step rather than just merging — sections
     that overlap in subject matter will independently surface the same
     finding.
  3. Verify before ranking — a worker's finding is a claim until checked
     against the artifact, the same rule this prompt already applies to
     hallucinated repository facts.

## Section 1 — AI Configuration Audit

- **Skills architecture and extraction opportunity** *(moved, not changed)*:
  relocated verbatim to the new section 2. Two cross-references inside
  section 1 that used to point at it ("the skills architecture check above")
  were rewritten to name section 2 explicitly, since it is no longer above —
  in the Per-session baseline budget and Tool/MCP-server-review bullets.

## Section 2 — Agent Skills Audit *(new section)*

Evaluates any on-demand-loaded, folder-based capability package the
project's AI configuration defines — skills, in Claude Code's terminology,
the OpenAI Agents SDK's, or an equivalent extension elsewhere. Thirteen
checks, in this order:

1. **Mechanism selection — skill, tool connection, retrieval, or memory**
   *(new)*: whether the project can state, for each piece of agent
   capability, which of the four mechanisms it uses and why, since each has
   a different cost and staleness profile. Placed first, ahead of the
   architecture check, as the logically prior question.
2. **Skills architecture and extraction opportunity** *(moved from section
   1, unchanged)*: the original seven-check block — partitioning universal
   rules from task-specific skills, frontmatter description length,
   single-responsibility, reference knowledge in linked docs, cross-layer
   duplication, and the non-interactive flag for implicit guardrails.
3. **Skill trigger-description specificity** *(new)*: a description can pass
   the length and single-responsibility checks and still be too vague to
   disambiguate from a sibling skill.
4. **Concise is key** *(new)*: whether the skill body explains concepts the
   model already knows from training, rather than only the project-specific
   procedure — cites a roughly threefold token difference from a worked
   example.
5. **Freedom calibration to task fragility** *(new)*: whether fragile or
   irreversible operations get exact, low-freedom scripts and open-ended
   judgment tasks avoid over-specification.
6. **Reference-file navigability** *(new)*: link depth (no more than one hop
   from the skill's entry point) and a table of contents for files over
   roughly 100 lines.
7. **Evaluation-first skill development** *(new)*: a recorded baseline and a
   handful of concrete evaluation scenarios before extensive documentation
   is written.
8. **Embedded self-verification** *(new)*: a mandatory check-against-evidence
   step before reporting completion, for any skill producing a verifiable
   artifact.
9. **Explicit escalation conditions instead of guessing** *(new)*: named
   stop-and-ask conditions rather than proceeding on an unstated assumption.
   **Provenance caveat**: sourced from a video chapter title only ("When
   Agents Shouldn't Guess", IBM Technology) — the explanatory content could
   not be read (transcript unavailable), so the check's wording is a
   reconstruction of what the title implies, not a paraphrase of stated
   content. Lowest-confidence item introduced in this version. Verify
   against the source, or against independent practice, before treating it
   as settled guidance in a future revision.
10. **Script robustness** *(new)*: bundled scripts handling their own common
    failure modes and documenting constants, rather than deferring errors
    back to the agent or leaving magic numbers unexplained.
11. **Deterministic logic versus inference** *(new)*: deterministic
    sub-steps handed to a script rather than re-prompted as model reasoning.
12. **Tool and skill count budget** *(new)*: how many tools/skills are
    eagerly loaded at conversation start, and whether a search/deferred-
    loading mechanism exists past roughly fifteen to twenty — cites a
    roughly order-of-magnitude token difference from one measured example.
13. **Programmatic tool orchestration** *(new)*: whether a multi-step tool
    chain routes intermediate results through the model or through a code
    layer that returns only the final result.
14. **Agent-computer interface design and testing** *(new)*: docstring-
    quality tool documentation, testing via example agent invocations, and
    poka-yoke argument design.
15. **Skill supply-chain trust** *(new)*: whether an externally-sourced
    skill has actually been read in full before being enabled, and whether
    write/high-impact actions it can reach are gated behind confirmation.

(Numbered here for reference; the prompt itself uses labelled subsections,
not a numbered list, matching the style of every other section.)

## Sections 3-22

Unchanged in content. Renumbered from what was 2-21 in v2.1, since section 2
is new. No wording changed as part of the renumbering beyond the section
header numbers themselves.

# SaveTokens

A living community document: the "Vibe Coding Resource Optimization Audit
Prompt", plus the working notes used to grow it. This file exists because a
project whose subject is good AI-configuration practice had none of its
own — the gap was found and closed via a self-audit (see
`work-in-progress/TopicCandidates.md`, "AI Configuration Audit" verdict:
MISSING, before this file existed).

## What's here

- `Save Tokens Audit v<latest>.txt` — the current working version of the
  prompt, at the repository root. There is exactly one active version at
  any time.
- `archive/` — every superseded version, plus a `Delta vX.Y from vX.Z.md`
  for each transition, describing what actually changed (not just line
  counts). Once a version is archived, it is closed: never edit it again.
- `work-in-progress/TopicCandidates.md` — the triage log for every
  candidate topic considered for the prompt: its rationale, evaluation
  bullets, status, and (once integrated) which version and section it
  landed in.
- `scripts/new-version.sh` — clones the current version into a new one and
  bumps its header. See "Starting a new version" below.

## Style for the audit prompt itself

Match the existing voice exactly when adding to `Save Tokens Audit vX.Y.txt`:

- Dense paragraph-plus-bullets, wrapped at roughly 79 columns.
- A short subsection label ending in a colon, then `- ` bullets phrased as
  questions ("Does the project...? Is there a...?").
- Real em dashes (`—`) for asides, not double hyphens.
- No meta-commentary about sourcing, confidence, or where a check came from
  inside the prompt text itself — that belongs in TopicCandidates.md and the
  version's delta doc, not in text an audit-running agent will read as
  instructions to evaluate a project.
- Cross-reference other sections by name ("the Testing Audit"), not by
  number. Section numbers shift on every version that adds or removes a
  section; names don't.

## TopicCandidates.md workflow

Status vocabulary, in order: **Undecided** → **To investigate** → **Selected**
→ **Processed** (or **Rejected**, from any state). The file's own header
documents each precisely — read it before adding a candidate.

**Integration gate**: a candidate may be written into the audit prompt only
once it is Selected, and only when the maintainer starts that step — never
on this agent's own initiative, even if a candidate looks obviously good.
Proposing, researching, and drafting candidate entries is unrestricted;
editing the prompt file itself is not.

**Before summarizing candidate counts or statuses to the user** (e.g. "how
many are Processed", "what's still open"), grep or read the actual file —
do not recite from memory or from an earlier turn's count. This file has
been given an incorrect status summary at least once in this project's
history from exactly that shortcut.

## Starting a new version

Run `scripts/new-version.sh <from> <to>` from the repo root rather than
cloning by hand. It checks that the source file is the current, committed
working file before cloning (the manual version of this step went wrong
once: a version was edited in place after being committed, instead of being
cloned forward, and needed a multi-file correction to fix). Follow the
script's printed next steps for archiving the predecessor and updating
TopicCandidates.md's `Processed` citations.

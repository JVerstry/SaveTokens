#!/usr/bin/env bash
# Clone the current audit prompt into a new version.
#
# This exists because the manual clone-bump-header procedure was done ad hoc
# at least twice by hand and once went wrong: a post-commit version was
# edited in place instead of being cloned forward, requiring a multi-file
# correction (restoring the committed file from git, moving the drifted
# content into the right version, rewriting a delta doc, and fixing ~20
# stale cross-references in work-in-progress/TopicCandidates.md).
#
# Usage: scripts/new-version.sh <from-version> <to-version>
# Example: scripts/new-version.sh 3.0 3.1
#
# Run this from the repository root.

set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: $0 <from-version> <to-version>" >&2
  echo "Example: $0 3.0 3.1" >&2
  exit 1
fi

FROM="$1"
TO="$2"
FROM_FILE="Save Tokens Audit v${FROM}.txt"
TO_FILE="Save Tokens Audit v${TO}.txt"

if [ ! -f "$FROM_FILE" ]; then
  echo "Error: '$FROM_FILE' not found at repo root." >&2
  echo "It may already be archived (check archive/) or the version number" >&2
  echo "may be wrong. Only the current working-file version can be cloned" >&2
  echo "from — that is the whole point of this check." >&2
  exit 1
fi

if [ -f "$TO_FILE" ]; then
  echo "Error: '$TO_FILE' already exists. Refusing to overwrite." >&2
  exit 1
fi

# If the source file has uncommitted changes, cloning now would silently
# carry undocumented work into the new version with no record of what it
# was. Commit or stash first so the eventual delta doc is accurate.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if ! git diff --quiet -- "$FROM_FILE" 2>/dev/null || \
     ! git diff --cached --quiet -- "$FROM_FILE" 2>/dev/null; then
    echo "Error: '$FROM_FILE' has uncommitted changes." >&2
    echo "Commit or stash them first, so the delta between v${FROM} and" >&2
    echo "v${TO} can be recorded accurately." >&2
    exit 1
  fi
fi

cp "$FROM_FILE" "$TO_FILE"
# The version header is always line 3: "Version X.Y"
sed -i "3s/.*/Version ${TO}/" "$TO_FILE"

echo "Created '$TO_FILE' (Version ${TO}), cloned from '$FROM_FILE'."
echo
echo "Next steps:"
echo "  1. Make ALL further edits in '$TO_FILE'. Do not edit '$FROM_FILE'"
echo "     again — once cloned from, it is closed."
echo "  2. When '$TO_FILE' is ready to ship, archive the predecessor:"
echo "       git mv \"$FROM_FILE\" archive/"
echo "  3. Write 'archive/Delta v${TO} from v${FROM}.md' describing what"
echo "     changed (see the existing delta docs in archive/ for the format)."
echo "  4. In work-in-progress/TopicCandidates.md, update any 'Processed'"
echo "     entries that cite '$FROM_FILE' by section number if that content"
echo "     moved or was renumbered in v${TO}."

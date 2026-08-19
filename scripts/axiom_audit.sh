#!/usr/bin/env bash
# Declared-axiom audit.
#
# QLF's contract is not merely "zero sorry". A theorem proved from definitions and a
# theorem proved from six opaque bridge assumptions are epistemically different things,
# so the bridge assumptions are enumerated here and pinned. Any `axiom` added to lean/
# that is not on the list fails CI — an assumption must be a deliberate, reviewed act,
# never something that arrives with a proof.
#
# `opaque` declarations (bdMeanOnConstant, continuumProperTime, reconstructedProperTime)
# are deliberately not listed: an opaque def is abstract *data* with a hidden body, not an
# assumption — it adds no axiom to the kernel. Only propositions asserted without proof do.
#
# The complementary audit is the *dependency* footprint (which axioms a given theorem
# actually rests on): that is lean/QLF_AxiomAudit.lean, reported by `#print axioms` in
# the build log.
#
# To add or remove a boundary: change lean/, regenerate with `scripts/axiom_audit.sh
# --write`, update the Axiom inventory in CLAUDE.md and Open_Problems.md, and commit
# all three together.

set -euo pipefail
cd "$(dirname "$0")/.."

EXPECTED="lean/axioms.expected"

# Column-0 `axiom` declarations only — indented occurrences are prose inside doc
# comments. The name is the second whitespace-separated token.
current() {
  grep -rn '^axiom ' lean/ --include='*.lean' \
    | sed -E 's|^lean/([^:]+):[0-9]+:axiom[[:space:]]+([^[:space:]:({]+).*|\1 \2|' \
    | sort
}

if [[ "${1:-}" == "--write" ]]; then
  current > "$EXPECTED"
  echo "wrote $EXPECTED ($(wc -l < "$EXPECTED") axioms)"
  exit 0
fi

if diff -u "$EXPECTED" <(current); then
  echo "axiom audit: OK — $(wc -l < "$EXPECTED") declared axioms, all expected."
else
  echo
  echo "axiom audit: FAILED — the declared axioms differ from $EXPECTED."
  echo "A '-' line is an axiom that was discharged; a '+' line is one that was added."
  echo "If the change is intended, run 'scripts/axiom_audit.sh --write' and update the"
  echo "Axiom inventory in CLAUDE.md and Open_Problems.md in the same commit."
  exit 1
fi

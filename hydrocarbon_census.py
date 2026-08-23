#!/usr/bin/env python3
"""
hydrocarbon_census.py — "degree of unsaturation" is the closure count of a molecule.

[`Chemistry.md`](Chemistry.md) gets molecules from one rule — a bond is a shared closure — and
then admits a gap: it gets stoichiometry and formulas right "but not double bonds." This script
closes that one, and the closing is a counting argument rather than a new rule.

Organic chemistry teaches a formula to memorise,

    DoU = (2C + 2 + N - H - X) / 2

with a rider that oxygen and sulphur are left out and no reason given. Read the molecule as a
graph whose vertex degrees are the valences. The handshake lemma gives 2E = sum(v_i), so the
cycle rank of a connected molecular graph is

    b1 = E - V + 1 = sum(v_i - 2)/2 + 1

which is that formula, with each element's coefficient revealed as (valence - 2)/2: carbon +1,
nitrogen +1/2, hydrogen and halogen -1/2, and **oxygen 0 -- which is why it was missing**. A
divalent atom adds one vertex and one edge, so it cannot change a cycle rank.

What that buys is the identification, not the arithmetic:

  * b1 counts INDEPENDENT CLOSURES. A cycle in the molecular graph is a loop that returns -- the
    same object as a contact loop in lean/QLF_Folding.lean and as any ZFA-closed twist history.
    "Unsaturation" is closure count; "saturated" means zero closures, i.e. a tree.
  * A DOUBLE BOND AND A RING ARE THE SAME THING. Both contribute exactly 1. Chemistry files them
    in different chapters; on the substrate there is one phenomenon, and C6H12 is ONE census
    class holding cyclohexane and every hexene together.
  * VALENCE 2 IS THE NEUTRAL ELEMENT of closure counting, which is why a divalent monomer
    polymerises into a chain: the backbone carries no closure of its own, so every closure a
    polymer has is a contact -- exactly what protein_census.py assumes.

Lean anchor: lean/QLF_Unsaturation.lean (no axioms). This script is its check: it enumerates the
skeletons the valence rule admits, verifies the closure count on every one, and compares the
isomer counts against the published series.

Usage:
    python3 hydrocarbon_census.py            # full run
    python3 hydrocarbon_census.py --quick    # cheap re-run + assert every invariant (CI)
"""

from __future__ import annotations

import argparse
import sys
import time
from itertools import combinations, permutations

# Chemistry.md valences.
VALENCE = {'H': 1, 'C': 4, 'N': 3, 'O': 2, 'S': 2, 'F': 1, 'Cl': 1, 'Br': 1, 'I': 1}


# =============================================================================
# THE IDENTITY: DoU = cycle rank = closure count
# =============================================================================
def textbook_dou(counts):
    """(2C + 2 + N - H - X)/2, exactly as it is taught -- oxygen and sulphur omitted."""
    C = counts.get('C', 0)
    N = counts.get('N', 0)
    H = counts.get('H', 0)
    X = sum(counts.get(x, 0) for x in ('F', 'Cl', 'Br', 'I'))
    return (2 * C + 2 + N - H - X) / 2


def closure_count(counts):
    """b1 = E - V + 1 for a connected graph whose vertex degrees are the valences.

    This is `doubledClosures / 2` of lean/QLF_Unsaturation.lean, and the whole content of
    that module is that it equals `textbook_dou` for every molecule."""
    V = sum(counts.values())
    E = sum(VALENCE[a] * k for a, k in counts.items()) / 2
    return E - V + 1


def per_atom_contribution():
    """Each element's coefficient in the DoU formula IS (valence - 2)/2."""
    return {a: (v - 2) / 2 for a, v in VALENCE.items()}


MOLECULES = [
    ("methane",      {'C': 1, 'H': 4}),
    ("ethane",       {'C': 2, 'H': 6}),
    ("ethene",       {'C': 2, 'H': 4}),
    ("ethyne",       {'C': 2, 'H': 2}),
    ("cyclohexane",  {'C': 6, 'H': 12}),
    ("benzene",      {'C': 6, 'H': 6}),
    ("naphthalene",  {'C': 10, 'H': 8}),
    ("water",        {'O': 1, 'H': 2}),
    ("ethanol",      {'C': 2, 'H': 6, 'O': 1}),
    ("acetone",      {'C': 3, 'H': 6, 'O': 1}),
    ("glycine",      {'C': 2, 'H': 5, 'N': 1, 'O': 2}),
    ("tryptophan",   {'C': 11, 'H': 12, 'N': 2, 'O': 2}),
    ("caffeine",     {'C': 8, 'H': 10, 'N': 4, 'O': 2}),
    ("cholesterol",  {'C': 27, 'H': 46, 'O': 1}),
    ("chloroform",   {'C': 1, 'H': 1, 'Cl': 3}),
    ("cysteine",     {'C': 3, 'H': 7, 'N': 1, 'O': 2, 'S': 1}),
    ("glucose",      {'C': 6, 'H': 12, 'O': 6}),
]


# =============================================================================
# ALKANES: the carbon skeleton is a free tree with max degree 4
# =============================================================================
def _canon_rooted(adj, v, parent):
    return "(" + "".join(sorted(_canon_rooted(adj, u, v) for u in adj[v] if u != parent)) + ")"


def _canon_tree(adj, n):
    """AHU canonical form of a free tree, rooted at its centre(s)."""
    deg = {v: len(adj[v]) for v in range(n)}
    left = set(range(n))
    leaves = [v for v in left if deg[v] <= 1]
    while len(left) > 2:
        nxt = []
        for v in leaves:
            left.discard(v)
            for u in adj[v]:
                if u in left:
                    deg[u] -= 1
                    if deg[u] == 1:
                        nxt.append(u)
        leaves = nxt
    return min(_canon_rooted(adj, c, -1) for c in left)


def alkane_skeletons(nmax):
    """Grow trees a leaf at a time. Max degree 4 is the ONLY rule applied."""
    counts = {1: 1}
    shapes = [{0: []}]
    for n in range(2, nmax + 1):
        seen, keep = set(), []
        for adj in shapes:
            for v in range(n - 1):
                if len(adj[v]) >= 4:
                    continue
                new = {k: list(x) for k, x in adj.items()}
                new[n - 1] = [v]
                new[v].append(n - 1)
                c = _canon_tree(new, n)
                if c not in seen:
                    seen.add(c)
                    keep.append(new)
        shapes = keep
        counts[n] = len(keep)
    return counts, shapes


# The published constitutional-isomer counts of the alkanes (OEIS A000602) — an external
# check that the valence rule is chemistry's own generator, not a QLF claim.
ALKANE_SERIES = {1: 1, 2: 1, 3: 1, 4: 2, 5: 3, 6: 5, 7: 9, 8: 18, 9: 35,
                 10: 75, 11: 159, 12: 355, 13: 802, 14: 1858}


# =============================================================================
# ONE CLOSURE CLASS: every C_nH_m isomer, ring and double bond alike
# =============================================================================
def isomers(n, m, maxmult=3):
    """Constitutional isomers of C_nH_m as multigraphs on n carbons.

    Edge multiplicity IS bond order, so a ring and a double bond are enumerated by the same
    machine and land in the same class -- which is the point. Hydrogens are forced once the
    skeleton is fixed, so counting skeletons counts constitutional isomers."""
    E2 = 4 * n - m
    if E2 < 0 or E2 % 2:
        return None, None
    E = E2 // 2
    pairs = list(combinations(range(n), 2))
    npairs = len(pairs)
    pidx = {p: i for i, p in enumerate(pairs)}
    maps = [tuple(pidx[(min(p[a], p[b]), max(p[a], p[b]))] for (a, b) in pairs)
            for p in permutations(range(n))]
    raw = set()
    cur = [0] * npairs
    deg = [0] * n

    def connected():
        seen, stack = {0}, [0]
        while stack:
            v = stack.pop()
            for i, (a, b) in enumerate(pairs):
                if not cur[i]:
                    continue
                u = b if a == v else (a if b == v else None)
                if u is not None and u not in seen:
                    seen.add(u)
                    stack.append(u)
        return len(seen) == n

    def rec(i, left):
        if left == 0:
            if all(deg) and connected():
                raw.add(tuple(cur))
            return
        if i == npairs or left > maxmult * (npairs - i):
            return
        a, b = pairs[i]
        for k in range(min(maxmult, left, 4 - deg[a], 4 - deg[b]), -1, -1):
            cur[i] = k
            deg[a] += k
            deg[b] += k
            rec(i + 1, left - k)
            deg[a] -= k
            deg[b] -= k
            cur[i] = 0

    rec(0, E)
    canon = {min(tuple(g[mp[j]] for j in range(npairs)) for mp in maps) for g in raw}
    return len(canon), E - n + 1


# Textbook constitutional-isomer counts. Each b1 >= 1 entry is the merged class: the alkenes
# and the cycloalkanes of that formula, counted together because they carry the same closure.
ISOMER_CASES = [
    ("C4H10", 4, 10, 2),   ("C4H8", 4, 8, 5),
    ("C5H12", 5, 12, 3),   ("C5H10", 5, 10, 10),
    ("C6H14", 6, 14, 5),   ("C6H12", 6, 12, 25),
]


# =============================================================================
# INVARIANTS — each a theorem of lean/QLF_Unsaturation.lean, asserted against fresh data
# =============================================================================
INVARIANTS = [
    "the textbook DoU equals the cycle rank, for every molecule (dou_chno)",
    "each element's DoU coefficient is (valence - 2)/2 (doubledClosures_cons)",
    "a divalent atom cannot change the closure count (divalent_neutral)",
    "a chain of divalent units is closure-neutral (divalent_chain_neutral)",
    "saturated means zero closures, and C_nH_(2n+2) follows (saturated_iff_alkane)",
    "every alkane skeleton the valence rule admits is a tree (b1 = 0)",
    "alkane isomer counts match the published series (external check)",
    "isomer counts of a merged closure class match the textbook total (external check)",
]


def check(alkane_max=10, isomer_cases=None):
    fails = []

    for name, counts in MOLECULES:                                   # J1
        d, b = textbook_dou(counts), closure_count(counts)
        if abs(d - b) > 1e-9:
            fails.append("J1 %s: DoU %r != cycle rank %r" % (name, d, b))
        if d < 0 or d != int(d):
            fails.append("J1 %s: closure count %r is not a non-negative integer" % (name, d))

    contrib = per_atom_contribution()                                # J2
    for name, counts in MOLECULES:
        predicted = sum(contrib[a] * k for a, k in counts.items()) + 1
        if abs(predicted - closure_count(counts)) > 1e-9:
            fails.append("J2 %s: sum of (valence-2)/2 + 1 != cycle rank" % name)

    for name, counts in MOLECULES:                                   # J3/J4
        for divalent in ('O', 'S'):
            bumped = dict(counts)
            bumped[divalent] = bumped.get(divalent, 0) + 3
            if abs(closure_count(bumped) - closure_count(counts)) > 1e-9:
                fails.append("J3 %s: adding %s changed the closure count" % (name, divalent))
            if abs(textbook_dou(bumped) - textbook_dou(counts)) > 1e-9:
                fails.append("J3 %s: adding %s changed the textbook DoU" % (name, divalent))

    for n in range(1, 12):                                           # J5
        if closure_count({'C': n, 'H': 2 * n + 2}) != 0:
            fails.append("J5: C%dH%d is not closure-free" % (n, 2 * n + 2))
        if closure_count({'C': n, 'H': 2 * n}) != 1:
            fails.append("J5: C%dH%d does not carry exactly one closure" % (n, 2 * n))

    counts, shapes = alkane_skeletons(alkane_max)                    # J6/J7
    for n in range(1, alkane_max + 1):
        if counts[n] != ALKANE_SERIES[n]:
            fails.append("J7: %d alkane skeletons at n=%d, published series says %d"
                         % (counts[n], n, ALKANE_SERIES[n]))
    for adj in shapes:
        V = len(adj)
        E = sum(len(x) for x in adj.values()) // 2
        if E - V + 1 != 0:
            fails.append("J6: an alkane skeleton is not a tree (b1 = %d)" % (E - V + 1))

    for name, n, m, want in (isomer_cases or []):                    # J8
        got, b1 = isomers(n, m)
        if got != want:
            fails.append("J8 %s: %d isomers, textbook says %d" % (name, got, want))
        if b1 != closure_count({'C': n, 'H': m}):
            fails.append("J8 %s: enumerated b1 %r != formula closure count" % (name, b1))
    return fails


def report():
    print("== the degree of unsaturation IS the cycle rank ==")
    print("%-14s %-22s %8s %8s" % ("molecule", "formula", "DoU", "b1"))
    for name, counts in MOLECULES:
        formula = "".join("%s%s" % (a, k if k > 1 else "")
                          for a in ('C', 'H', 'N', 'O', 'S', 'F', 'Cl', 'Br', 'I')
                          if (k := counts.get(a, 0)))
        print("%-14s %-22s %8.1f %8.1f" % (name, formula, textbook_dou(counts),
                                           closure_count(counts)))

    print("\n== and each coefficient is (valence - 2)/2 ==")
    contrib = per_atom_contribution()
    print("   " + "   ".join("%s(v=%d): %+.1f" % (a, VALENCE[a], contrib[a])
                             for a in ('C', 'N', 'O', 'S', 'H', 'Cl')))
    print("   oxygen and sulphur are absent from the textbook formula because their"
          " coefficient is ZERO")

    print("\n== alkanes: the valence rule alone, against the published series ==")
    counts, _ = alkane_skeletons(14)
    print("   n        " + "".join("%6d" % n for n in range(1, 15)))
    print("   counted  " + "".join("%6d" % counts[n] for n in range(1, 15)))
    print("   series   " + "".join("%6d" % ALKANE_SERIES[n] for n in range(1, 15)))

    print("\n== one closure class: rings and double bonds counted together ==")
    print("%-8s %4s %9s %10s" % ("formula", "b1", "isomers", "textbook"))
    for name, n, m, want in ISOMER_CASES:
        t = time.time()
        got, b1 = isomers(n, m)
        print("%-8s %4d %9d %10d   (%.1fs)" % (name, b1, got, want, time.time() - t))


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--quick", action="store_true",
                    help="cheap re-run and assert every invariant (what CI runs)")
    args = ap.parse_args()

    if args.quick:
        fails = check(alkane_max=10, isomer_cases=ISOMER_CASES[:4])
        if fails:
            print("FAILED:")
            for f in fails:
                print("  -", f)
            return 1
        print("hydrocarbon census OK -- %d invariants asserted against fresh data"
              % len(INVARIANTS))
        return 0

    fails = check(alkane_max=12, isomer_cases=ISOMER_CASES)
    if fails:
        print("FAILED:")
        for f in fails:
            print("  -", f)
        return 1
    report()
    print("\nall %d invariants hold." % len(INVARIANTS))
    return 0


if __name__ == "__main__":
    sys.exit(main())

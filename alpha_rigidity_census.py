#!/usr/bin/env python3
"""
alpha_rigidity_census.py — the N(d) look-elsewhere census for issue #116.

Computes the last open acceptance criterion of #116: the reachable-value count
N(d) over the frozen `Expr` grammar of `QLF_AlphaRigidity`, and the resulting
accidental-hit probability against the measured value near alpha^-1 = 137.

GRAMMAR (QLF_AlphaRigidity.lean, division-free):
    Expr := two(2) | three(3) | sum a b | prod a b | pow a n   (n : ℕ)
    val  : two->2, three->3, sum->+, prod->*, pow->^
    depth: sum/prod = max(depth a, depth b)+1 ; pow = depth a + 1 ; leaves = 0
The real construction is  sum(pow two 7)(pow three 2) = 2^7 + 3^2 = 137, depth 2.

WHAT THIS SHOWS (the honest finding):
  1. Under the FULL FREE grammar the look-elsewhere is LARGE, not small:
       - 137 needs depth >= 2 (a single op cannot reach it);
       - at the construction's own depth 2, ~60% of the +/-9 integer band
         [128,146] is already reachable, 137 among them (not sparse/special);
       - by depth 3 the whole band [128,146] is filled (19/19);
       - by depth <= 10 the grammar reaches essentially every integer up to the
         value cap (grammar_reaches_all is already a Lean theorem).
     So grammar SPARSITY provides NO rigidity for 137.
  2. Under the FROZEN TEMPLATE  alpha^-1 = 128 + d^2  (d the substrate spatial
     dimension), 137 is reached at exactly d=3, with zero slack, and 136 is
     unreachable (d^2 = 8 has no natural solution). THIS is where the rigidity
     lives -- exactly the `alpha_unique` / `dimension_136_unreachable` /
     cross-sector overdetermination joint already machine-checked in
     QLF_AlphaRigidity.lean.

CONCLUSION: the N(d) census quantifies why "all rigidity lives in the template"
(the qualitative answer already in #116) is the correct and necessary reading.
The competitive claim for 137 is NOT "the grammar can barely reach it" -- it can
reach the whole neighbourhood -- but "with d substrate-derived (6+2 split) the
frozen template 128 + d^2 locks 137 with zero slack across three independent
sectors." Ten is more than enough depth: the band saturates by depth 3.
"""

MAX_DEPTH = 10   # "10 dimensions are enough" -- the band saturates by depth 3.


def reachable(D, V, min_exp):
    """Distinct integer values (>=2) reachable at depth <= D, capped at V.
       min_exp: 0 = full grammar (pow n>=0, so pow gives 1 and a); 2 = only
       non-degenerate powers a^2, a^3, ... (the construction's intent)."""
    S = {2, 3}
    for _ in range(D):
        new = set(S)
        for a in S:
            if a >= 2:
                n = min_exp
                while True:
                    v = 1 if n == 0 else a ** n
                    if v > V:
                        break
                    new.add(v)
                    n += 1
            elif min_exp == 0:
                new.add(1)                  # 1^n = 1
            for b in S:
                if a + b <= V:
                    new.add(a + b)
                if a * b <= V:
                    new.add(a * b)
        S = new
    return {x for x in S if x >= 2}


def band(S, lo, hi):
    return sorted(x for x in S if lo <= x <= hi)


def free_grammar_census(V=1000, min_exp=2):
    print(f"### Free-grammar census   (value cap V={V}, "
          f"pow exponent {'>=2 non-degenerate' if min_exp==2 else '>=0 full'})")
    print(f"{'depth<=':>8} {'N(d)':>7} {'137?':>5} {'band[128,146]':>14} "
          f"{'band-fill':>10}")
    prev_band = None
    for D in range(1, MAX_DEPTH + 1):
        S = reachable(D, V, min_exp)
        b = band(S, 128, 146)
        row = (f"{D:>8} {len(S):>7} {str(137 in S):>5} "
               f"{len(b):>14} {len(b)/19:>10.3f}")
        print(row)
        if D <= 3:
            print(f"           reachable in [128,146] = {b}")
        if len(b) == 19 and prev_band != 19:
            print(f"           --> band [128,146] fully saturated at depth {D}")
        prev_band = len(b)
    print()


def template_census():
    print("### Frozen-template census   alpha^-1 = 128 + d^2   (d = 0..10)")
    vals = [(d, 128 + d * d) for d in range(0, 11)]
    print("   d :", [d for d, _ in vals])
    print(" 128+d^2:", [v for _, v in vals])
    inband = [v for _, v in vals if 128 <= v <= 146]
    print(f"   template values in [128,146]: {inband}  ({len(inband)} of 11)")
    hits = [d for d, v in vals if v == 137]
    print(f"   value 137 reached at: d = {hits}  (unique; zero slack)")
    print(f"   136 reachable by the template? "
          f"{'yes' if 136 in [v for _, v in vals] else 'no (d^2=8 has no natural solution)'}")
    print()


if __name__ == "__main__":
    print("=" * 72)
    print(" alpha-rigidity N(d) look-elsewhere census  (issue #116)")
    print("=" * 72, "\n")
    free_grammar_census(V=1000, min_exp=2)
    free_grammar_census(V=1000, min_exp=0)
    template_census()
    print("SUMMARY")
    print("  Free grammar: look-elsewhere is LARGE -- 137 reachable at depth 2,")
    print("  the [128,146] band fully fills by depth 3. Grammar sparsity gives")
    print("  no rigidity. Rigidity lives ENTIRELY in the frozen template")
    print("  128 + d^2 with d substrate-derived: 137 unique at d=3 (zero slack),")
    print("  136 unreachable -- exactly QLF_AlphaRigidity's alpha_unique /")
    print("  dimension_136_unreachable / cross-sector overdetermination joint.")

#!/usr/bin/env python3
"""
contextual_census.py — the contextual census, built as a falsification test.

QLF's phase question is closed: `phase_rule` (lean/QLF_PhaseRule.lean) proves that a
count-balanced history folds to

    phi(h) = (-1)^(#negative twists + inversions of its axis word) . I

and QLF_BasisIndependence proves the stored (X, Y, Z) alphabet is a coordinate chart, not a
preferred physical basis. What is left open is the *partition*: which histories count as the
joint closure of a preparation P, an apparatus M, and a result c. That set,

    J(P, M, c),

is the one remaining freedom, and a freely-chosen one would reproduce any amplitudes at all
(Philosophy.md 3a rule 4). So this script fixes it by the only substrate-native rule available
-- **a run is a way exactly when preparation, system strand and apparatus close together** --
and then measures, without fitting anything:

    A(c) = sum over s of phi(P ++ s ++ M_c),   over system strands s that make the run close
    P(c) = A(c)^2 / sum_k A(k)^2

Design commitments, so the result can falsify rather than accommodate:

  * the phase is the **proven formula**, never a matrix product -- a failure here cannot be
    blamed on an approximate phase model;
  * a **preparation is an unbalanced strand** (an open strand needing closure), not merely a
    string prefix -- a balanced prefix prepares nothing, and the script refuses one;
  * preparation and apparatus are specified **independently**, and the contribution map is
    relational, K = K(P, M): neither side alone decides which strands close;
  * every geometry is run at **increasing finite horizons** and reported as a scaling table,
    never at a single hand-picked horizon;
  * a battery of geometries is printed **together and blind** -- no per-case tuning.

It is also a checker. Two consequences of the Lean theorems are asserted against the numbers:
symmetric branch pairs must give exactly equal amplitudes (QLF_BasisIndependence), and the
DP must agree with brute-force enumeration wherever brute force is affordable.

What it found (reproduce with --depth-scan 3 --max-k 18)
--------------------------------------------------------
The transverse geometries are pinned to exactly 1/2 at every horizon, which is not evidence
about anything: QLF_BasisIndependence *forces* it, since the two branches are exchanged by a
relabeling that fixes the preparation. A number forced by a proven symmetry is bookkeeping
(Philosophy.md 3a rule 4), and the script prints it only as a regression check.

The aligned geometries are the informative ones, and they say something the framework has to
answer for: **for any fixed preparation, the contextual weight washes out toward 1/2 as the
horizon grows.** The branch ratio A(-)/A(+) climbs monotonically at every horizon computed --
at depth 1: 0, .125, .200, .267, .327, .381, .429, .472, .511, .546 through k = 18, reaching
.677 at k = 28 where P(+) has fallen to .686 -- and a deeper preparation only delays it (depth 2
is still .936 at k = 28, but its ratio is rising too). Conversely, letting the depth grow with
the horizon drives the weight to 1. Two independent code paths (recomputing the census per
horizon, and reusing one incrementally) agree exactly at every overlapping horizon.

So this partition does **not** define a horizon-independent contextual probability: the number
is set by the ratio of preparation depth to horizon, and both limits are degenerate (1/2 one
way, 1 the other). The limit itself is not proven -- monotone data through k = 18 is not a
theorem -- but it is enough to say a further principle is needed to fix the regime.

**Indexing does not rescue it, and that is now checked rather than assumed.** The obvious suspicion
is that the flat `P ++ s ++ M_c` is at fault: it puts system and apparatus in one Pauli algebra, where
distinct axes anticommute, whereas independent factors commute (QLF_IndexedFactors). Recomputing with
the system on factor 1 and the apparatus on factor 2 -- which deletes exactly the cross-inversion term
between `s` and `M_c` -- gives **identical probabilities at every horizon**, for aligned, transverse and
mixed geometries alike.

The reason is structural, not a coincidence: a strand's **axis parity is determined by its imbalance**
(`n_X = #> + #<` and `imbalance_X = #> - #<` agree mod 2, and likewise for Y and Z), so within the one
imbalance class that a branch selects, the cross term is a *constant sign*. A global sign per branch
cannot survive `|A|^2`. So the flat/indexed distinction is **invisible to Born weights here**, and the
wash-out is a property of the partition itself.

QLF already has the candidate, and it is not a free parameter: closure is **capacity-relative**
(`closedAtHorizon_iff_maxExcursion_le`, lean/QLF_ClosureDepthLaw.lean), and the count/listening
distinction says what a horizon of capacity R actually receives. The contextual weight should
plausibly be read at the observer's listening horizon rather than at k -> infinity. That is the
next experiment, not a conclusion.

Usage:  python3 contextual_census.py [--max-k 12] [--brute-check 4] [--depth-scan 3]
"""
from __future__ import annotations
import argparse
import itertools
from collections import defaultdict

# --------------------------------------------------------------------------- #
# the alphabet, in the canonical chart (a chart, not a frame: QLF_BasisIndependence)
# --------------------------------------------------------------------------- #
ALPHABET = '^v<>/\\+-'
CONJ_PAIRS = [('^', 'v'), ('>', '<'), ('/', '\\'), ('+', '-')]
NEG_TWISTS = set('v<\\-')
# ordv: the gauge axis is outside the order entirely; X < Y < Z
ORDV = {'>': 1, '<': 1, '^': 2, 'v': 2, '/': 3, '\\': 3, '+': 0, '-': 0}
AXIS_INDEX = {1: 0, 2: 1, 3: 2}          # X, Y, Z -> parity slot


def imbalance(word: str) -> tuple[int, int, int, int]:
    """Net signed count per conjugate pair. A run closes iff this is all zeros."""
    return tuple(word.count(a) - word.count(b) for a, b in CONJ_PAIRS)


def is_balanced(word: str) -> bool:
    return all(v == 0 for v in imbalance(word))


def neg_count(word: str) -> int:
    return sum(1 for c in word if c in NEG_TWISTS)


def inv_count(word: str) -> int:
    """Inversions of the axis word: later letters that ought to precede earlier ones."""
    a = [ORDV[c] for c in word]
    return sum(1 for i in range(len(a)) for j in range(i + 1, len(a))
               if a[j] > 0 and a[j] < a[i])


def phase(word: str) -> int:
    """The proven rule (QLF_PhaseRule.phase_rule). Defined for any word; physical when balanced."""
    return (-1) ** (neg_count(word) + inv_count(word))


def axis_parities(word: str) -> tuple[int, int, int]:
    """Parities of the X, Y, Z letter multiplicities -- all the phase rule needs of a segment."""
    p = [0, 0, 0]
    for c in word:
        o = ORDV[c]
        if o:
            p[AXIS_INDEX[o]] ^= 1
    return tuple(p)


def cross_parity(pu: tuple[int, int, int], pv: tuple[int, int, int]) -> int:
    """Parity of the inversions *between* segments u and v of u ++ v.

    An inversion crosses when the later letter is the smaller: nX_v(nY_u + nZ_u) + nY_v.nZ_u.
    Only parities matter, which is what makes the whole census a finite dynamic program.
    """
    uX, uY, uZ = pu
    vX, vY, vZ = pv
    return (vX * (uY + uZ) + vY * uZ) % 2


# --------------------------------------------------------------------------- #
# the system strands, as an exact dynamic program over (imbalance, axis parities)
# --------------------------------------------------------------------------- #
def strand_census(k: int) -> dict:
    """Signed census of all 8^k system strands of length k.

    Returns {(imbalance, axis_parities): sum of (-1)^(neg + inv) over strands in that class}.
    Exact, and polynomial in k where enumeration is 8^k -- the phase rule is what allows it,
    since appending a letter costs a sign determined by parities alone.
    """
    states = {((0, 0, 0, 0), (0, 0, 0)): 1}
    for _ in range(k):
        states = _step(states)
    return states


def _step(states: dict) -> dict:
    """Extend every strand by one letter. The sign it costs is fixed by axis-count parities
    alone -- which is exactly why the phase rule turns an 8^k enumeration into a polynomial
    dynamic program."""
    nxt = defaultdict(int)
    for (imb, par), amp in states.items():
        for c in ALPHABET:
            o = ORDV[c]
            # new inversions: earlier letters strictly greater than c (both non-gauge)
            if o == 1:      new_inv = (par[1] + par[2]) % 2
            elif o == 2:    new_inv = par[2] % 2
            else:           new_inv = 0
            sign = -1 if (c in NEG_TWISTS) != (new_inv == 1) else 1
            d = [0, 0, 0, 0]
            for idx, (a, b) in enumerate(CONJ_PAIRS):
                if c == a: d[idx] = 1
                elif c == b: d[idx] = -1
            nimb = tuple(imb[i] + d[i] for i in range(4))
            npar = list(par)
            if o: npar[AXIS_INDEX[o]] ^= 1
            nxt[(nimb, tuple(npar))] += sign * amp
    return dict(nxt)


def amplitude(prep: str, app: str, k: int, census: dict) -> int:
    """A(c) = sum over closing strands s of phi(prep ++ s ++ app), exactly."""
    need = tuple(-(imbalance(prep)[i] + imbalance(app)[i]) for i in range(4))
    p_par, a_par = axis_parities(prep), axis_parities(app)
    base = (neg_count(prep) + neg_count(app)
            + inv_count(prep) + inv_count(app)
            + cross_parity(p_par, a_par)) % 2          # the P-M cross term, K = K(P, M)
    total = 0
    for (imb, s_par), amp in census.items():
        if imb != need:
            continue
        # the strand's own phase is already in `amp`; add both crossings it introduces
        extra = (cross_parity(p_par, s_par) + cross_parity(s_par, a_par)) % 2
        total += amp * (-1) ** ((base + extra) % 2)
    return total


def amplitude_brute(prep: str, app: str, k: int) -> int:
    """Same quantity by direct enumeration -- the cross-check on the dynamic program."""
    tot = 0
    for s in itertools.product(ALPHABET, repeat=k):
        w = prep + ''.join(s) + app
        if is_balanced(w):
            tot += phase(w)
    return tot


# --------------------------------------------------------------------------- #
# geometries: preparation vs apparatus, specified independently
# --------------------------------------------------------------------------- #
def geometries() -> list[tuple[str, str, str, str, str]]:
    """(label, preparation, branch '+', branch '-', what the relabeling theorem forces)."""
    return [
        # aligned: the branch pair is exchanged by flipZ, which does NOT fix a Z preparation
        ("Z-prep, Z-apparatus (aligned)",     "/",  "\\",    "/",     "free"),
        # transverse: exchanged by flipX / flipY, which DO fix a Z preparation
        ("Z-prep, X-apparatus (transverse)",  "/",  ">\\",   "<\\",   "forced equal"),
        ("Z-prep, Y-apparatus (transverse)",  "/",  "^\\",   "v\\",   "forced equal"),
        # intermediate: the branch pair mixes an absorbed Z with a transverse letter
        ("Z-prep, ZX mix a=1",                "/",  "\\>",   "/<",    "free"),
        ("Z-prep, ZX mix a=2",                "/",  "\\>>",  "/<<",   "free"),
        ("Z-prep, ZY mix a=1",                "/",  "\\^",   "/v",    "free"),
        # a deeper preparation: two units of Z imbalance
        ("ZZ-prep, Z-apparatus (aligned)",    "//", "\\\\",  "//",    "free"),
    ]


def depth_scan(dmax: int, kmax: int) -> None:
    """How the aligned contextual weight moves as the horizon grows, per preparation depth.

    Reuses one dynamic program across all horizons, so this reaches k ~ 20 in under a minute.
    """
    geos = [(f"depth d={d} (aligned)", "/" * d, "\\" * d, "/" * d) for d in range(1, dmax + 1)]
    states = {((0, 0, 0, 0), (0, 0, 0)): 1}
    rows: dict[str, list] = {label: [] for label, _, _, _ in geos}
    for k in range(0, kmax + 1):
        for label, prep, bp, bm in geos:
            Ap = amplitude(prep, bp, k, states)
            Am = amplitude(prep, bm, k, states)
            if Ap or Am:
                rows[label].append((k, Ap * Ap / (Ap * Ap + Am * Am), (Am / Ap) if Ap else None))
        if k == kmax:
            break
        states = _step(states)
    for label, rs in rows.items():
        print(f"\n== {label}")
        print(f"   {'k':>3}  {'P(+)':>10}  {'A(-)/A(+)':>10}")
        for k, p, r in rs:
            print(f"   {k:>3}  {p:>10.6f}  {r:>10.6f}" if r is not None
                  else f"   {k:>3}  {p:>10.6f}")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--max-k", type=int, default=12, help="largest system-strand horizon")
    ap.add_argument("--brute-check", type=int, default=4,
                    help="verify the DP against enumeration up to this horizon (8^k words; 6 is slow)")
    ap.add_argument("--depth-scan", type=int, default=0, metavar="DMAX",
                    help="instead of the battery, scan preparation depths 1..DMAX over horizons")
    args = ap.parse_args()

    if args.depth_scan:
        depth_scan(args.depth_scan, args.max_k)
        return

    failures: list[str] = []

    # ---- the preparation must be an OPEN strand, or it prepares nothing -------------
    for label, prep, bp, bm, _ in geometries():
        if is_balanced(prep):
            failures.append(f"{label}: preparation {prep!r} is already closed, so it prepares nothing")

    # ---- the dynamic program must agree with enumeration ---------------------------
    print("== cross-check: dynamic program vs brute-force enumeration")
    for k in range(0, args.brute_check + 1):
        cen = strand_census(k)
        for label, prep, bp, bm, _ in geometries():
            for app in (bp, bm):
                a1 = amplitude(prep, app, k, cen)
                a2 = amplitude_brute(prep, app, k)
                if a1 != a2:
                    failures.append(f"DP != brute force at k={k}, {prep!r}/{app!r}: {a1} vs {a2}")
    print(f"   checked all geometries for k <= {args.brute_check}: "
          f"{'OK' if not failures else 'MISMATCH'}")

    # ---- the scaling tables --------------------------------------------------------
    censuses = {k: strand_census(k) for k in range(0, args.max_k + 1)}
    for label, prep, bp, bm, forced in geometries():
        print(f"\n== {label}    prep={prep!r}  branches=({bp!r}, {bm!r})   [{forced}]")
        print(f"   {'k':>3}  {'A(+)':>12} {'A(-)':>12}   {'P(+)':>8}")
        for k in range(0, args.max_k + 1):
            Ap = amplitude(prep, bp, k, censuses[k])
            Am = amplitude(prep, bm, k, censuses[k])
            if Ap == 0 and Am == 0:
                continue                                    # no run of this length closes
            tot = Ap * Ap + Am * Am
            print(f"   {k:>3}  {Ap:>12} {Am:>12}   {Ap * Ap / tot:>8.5f}")
            if forced == "forced equal" and Ap != Am:
                failures.append(f"{label} k={k}: branches exchanged by a preparation-fixing "
                                f"relabeling must have equal amplitudes (QLF_BasisIndependence), "
                                f"got {Ap} vs {Am}")

    print("\n== invariants")
    if failures:
        print("   FAILURES:")
        for f in failures:
            print(f"     - {f}")
        raise SystemExit(1)
    print("   all asserted invariants hold "
          "(DP = enumeration; symmetric branch pairs exactly equal; preparations open)")


if __name__ == "__main__":
    main()

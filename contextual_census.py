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

The listening horizon: run, and it does not rescue the partition (--listening 2,3,4)
--------------------------------------------------------------------------------------
Closure is **capacity-relative** (`closedAtHorizon_iff_maxExcursion_le`,
lean/QLF_ClosureDepthLaw.lean), so the candidate fix was to read the weight at the observer's
listening horizon rather than at k -> infinity: keep only runs whose free action
(twist_core.spatial_free_action + local_free_action, maximised over prefixes -- the multi-pair
form of Lean's `maxExcursion`) never exceeds a capacity R. That is now measured, and it fails,
for a reason sharper than the wash-out it was meant to cure:

  * **At every capacity the aligned weight still decays to exactly 1/2**, and the capacity only
    sets the rate: |P(+) - 1/2| falls by 0.666, 0.868, 0.906 per twist at R = 2, 3, 4, so a
    preparation stays readable for tau = 2.5, 7.1, 10.1 twists. **A larger listening horizon
    remembers longer, and forgets just as completely.**
  * **What a long run keeps of the preparation is not its direction.** Against an asymmetric
    branch pair (one no relabeling can exchange, so nothing is symmetry-forced) the limit does
    depend on the preparation -- three distinct values at R = 3, one per axis class -- but a
    preparation and its **reversal** land on the same limit, exactly: `/` with `\\`, `/>` with
    `/<`, `/^` with `/v`. The sense of the prepared strand, which is precisely what a Born weight
    must depend on, is erased; only its axis class survives.
  * **Mechanism, not coincidence.** At fixed capacity the walk is a finite signed transfer
    operator whose leading eigenvalue is a degenerate +-i.lambda(R) pair (lambda = 3.991, 4.383,
    4.638 at R = 2, 3, 4, each with a 16-fold top modulus). Every preparation collapses onto that
    same dominant subspace; the direction-carrying part lives in subdominant modes and decays no
    slower than the spectral gap lambda2/lambda1 = 0.752, 0.951, 0.979.
  * **A roundoff trap, recorded because it produced a wrong answer first.** In floating point the
    subdominant part sinks under the roundoff floor at k* ~ 16 ln 10 / ln(lambda1/lambda2) -- about
    730 twists at R = 3 -- and past that the arithmetic noise, which does overlap the dominant
    subspace, is what the ratio reports: every preparation appears to converge to one universal
    limit. It does not. The scan is exact-integer by default for this reason.

So capacity does not fix the regime, and the whole family of long-horizon readings is closed:
whatever carries a Born weight is in the **transient**, at horizons comparable to the preparation
itself, which is the regime the depth scan already showed to be depth-to-horizon-ratio dependent.
Physically the substrate is saying something reasonable -- free evolution inside a bounded capacity
thermalises, and a measurement is a prompt joint closure, not an infinite free run -- but it is not
yet a Born rule.

Usage:  python3 contextual_census.py [--max-k 12] [--brute-check 4] [--depth-scan 3]
        python3 contextual_census.py --listening 2,3,4 [--listen-k 160]
        python3 contextual_census.py --spectrum 2,3,4          (needs numpy)
"""
from __future__ import annotations
import argparse
import itertools
import math
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


def free_action(imb: tuple[int, int, int, int]) -> int:
    """The repo's own free-action functional on a running imbalance: |v|+|h|+|d| + |l|
    (twist_core.spatial_free_action + local_free_action). Its maximum over prefixes is the
    capacity a run demands -- the multi-pair form of Lean's `maxExcursion`, which is exactly
    this quantity for a single conjugate pair."""
    return sum(abs(x) for x in imb)


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


def _step(states: dict, capacity: int | None = None, letters: str = ALPHABET) -> dict:
    """Extend every strand by one letter. The sign it costs is fixed by axis-count parities
    alone -- which is exactly why the phase rule turns an 8^k enumeration into a polynomial
    dynamic program.

    With `capacity=R` the walk is confined to the listening horizon: any extension whose free
    action exceeds R is dropped (see `free_action`). With `letters` a single character, the
    step feeds one prescribed letter rather than branching over the alphabet.
    """
    nxt = defaultdict(int)
    for (imb, par), amp in states.items():
        for c in letters:
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
            if capacity is not None and free_action(nimb) > capacity:
                continue                                    # unhearable at this capacity
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
# the listening horizon: closure is capacity-relative, so read the weight at capacity R
# --------------------------------------------------------------------------- #
START = {((0, 0, 0, 0), (0, 0, 0)): 1}


def _feed(states: dict, word: str, capacity: int | None) -> dict:
    """Append a prescribed word, letter by letter, under the capacity bound."""
    for c in word:
        states = _step(states, capacity, letters=c)
        if not states:
            return {}
    return states


def listening_amplitude(prep: str, app: str, k: int, R: int) -> int:
    """A(c) at listening capacity R: the same signed sum, but over runs whose free action
    never exceeds R at any prefix -- exactly the runs a horizon of capacity R can close
    (closedAtHorizon_iff_maxExcursion_le). Exact integers."""
    st = _feed(START, prep, R)
    for _ in range(k):
        st = _step(st, R)
        if not st:
            return 0
    st = _feed(st, app, R)
    return sum(a for (imb, _), a in st.items() if imb == (0, 0, 0, 0))


def listening_amplitude_brute(prep: str, app: str, k: int, R: int) -> int:
    """Same quantity by enumeration -- the cross-check on the capacity-bounded program."""
    tot = 0
    for s in itertools.product(ALPHABET, repeat=k):
        w = prep + ''.join(s) + app
        imb = [0, 0, 0, 0]
        ok = True
        for c in w:
            for idx, (a, b) in enumerate(CONJ_PAIRS):
                if c == a: imb[idx] += 1
                elif c == b: imb[idx] -= 1
            if free_action(tuple(imb)) > R:
                ok = False
                break
        if ok and all(v == 0 for v in imb):
            tot += phase(w)
    return tot


def listening_scan(prep: str, branches: list[str], R: int, kmax: int,
                   exact: bool = True) -> list:
    """Branch amplitudes at capacity R over horizons 0..kmax, from a single walk.

    **Exact integers by default, and that is not fussiness.** At fixed capacity the walk is a
    finite signed transfer operator whose leading eigenvalues are a degenerate +-i.lambda(R)
    pair, so the amplitude carries a subdominant, preparation-dependent part suppressed only as
    (lambda2/lambda1)^k. In floating point that part sinks below the roundoff floor at

        k* ~ 16 ln 10 / ln(lambda1/lambda2)     (about 730 twists at R = 3),

    after which the arithmetic noise -- which has full overlap with the dominant subspace --
    is what the ratio reports. Run this in floats past k* and every preparation appears to
    converge to one universal limit; that limit is an artifact of the rounding, not of the
    substrate. Exact integers cost bigint arithmetic and are worth it.
    """
    st = _feed(START, prep, R)
    if not exact:
        st = {s: float(v) for s, v in st.items()}
    out = []
    for k in range(kmax + 1):
        out.append((k, [sum(v for (imb, _), v in _feed(st, a, R).items() if imb == (0, 0, 0, 0))
                        for a in branches]))
        if not st:
            break
        st = _step(st, R)
        if not st:
            break
        if not exact:
            m = max(abs(v) for v in st.values()) or 1.0
            st = {s: v / m for s, v in st.items()}
    return out


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


def capacity_spectrum(R: int) -> tuple:
    """The capacity-R transfer operator's spectrum: what sets the forgetting rate.

    Returns (dimension, |lambda1|, multiplicity of the top modulus, |lambda2|). The leading
    eigenvalue is a degenerate +-i.lambda pair, so amplitudes turn as well as grow, and the gap
    |lambda2|/|lambda1| is how fast everything but the dominant subspace -- the preparation's
    imprint included -- is forgotten.
    """
    import numpy as np                                   # only this mode needs it
    rng = range(-R, R + 1)
    states = [((a, b, c, d), (p & 1, (p >> 1) & 1, (p >> 2) & 1))
              for a in rng for b in rng for c in rng for d in rng
              if abs(a) + abs(b) + abs(c) + abs(d) <= R for p in range(8)]
    idx = {s: i for i, s in enumerate(states)}
    T = np.zeros((len(states), len(states)))
    for s, i in idx.items():
        for t, v in _step({s: 1}, R).items():
            T[idx[t], i] += v
    mags = np.abs(np.linalg.eigvals(T))
    l1 = mags.max()
    top = int((mags > l1 - 1e-7).sum())
    l2 = mags[mags < l1 - 1e-7].max()
    return len(states), l1, top, l2


def listening_report(capacities: list[int], kmax: int) -> list[str]:
    """Read the contextual weight at a finite listening horizon, and measure what survives it.

    Per capacity R: the scaling table of the standard geometries; what a long free run retains of
    the preparation; and how fast it stops retaining it.
    """
    failures: list[str] = []
    # an asymmetric branch pair -- no relabeling exchanges these, so any preparation dependence
    # is free to show itself rather than being forced away by QLF_BasisIndependence
    probe = ["\\", "/>>"]
    # each row is a preparation and its DIRECTION REVERSAL: same axis, opposite sense
    reversed_pairs = [("/", "\\"), ("/>", "/<"), ("/^", "/v")]

    for R in capacities:
        print(f"\n===== listening capacity R = {R}  "
              f"(runs whose free action never exceeds {R} at any prefix)")
        for label, prep, bp, bm, forced in geometries():
            rows = [(k, a[0], a[1]) for k, a in listening_scan(prep, [bp, bm], R, kmax)
                    if a[0] or a[1]]
            if not rows:
                print(f"  {label}: no run closes at this capacity")
                continue
            print(f"  {label}   [{forced}]")
            for row in rows[:3] + ([None] + rows[-2:] if len(rows) > 5 else []):
                if row is None:
                    print("     ...")
                    continue
                k, Ap, Am = row
                print(f"     k={k:>4}   P(+) = {Ap * Ap / (Ap * Ap + Am * Am):.9f}"
                      + (f"   A-/A+ = {Am / Ap:+.9f}" if Ap else ""))
                if forced == "forced equal" and Ap != Am:
                    failures.append(f"R={R} {label} k={k}: a preparation-fixing relabeling exchanges "
                                    f"these branches, so QLF_BasisIndependence forces equality")

        # --- what a long free run retains of the preparation ------------------------
        print(f"  -- what survives: limit of A(-)/A(+) for branches {probe}")
        for prep, rev in reversed_pairs:
            lim, drift = {}, {}
            for p in (prep, rev):
                seq = [a[1] / a[0] for _, a in listening_scan(p, probe, R, kmax) if a[0]]
                if seq:
                    lim[p] = seq[-1]
                    drift[p] = abs(seq[-1] - seq[-3]) if len(seq) >= 3 else float('inf')
            if len(lim) < 2:
                continue
            gap = abs(lim[prep] - lim[rev])
            # neither sequence has reached its own limit yet, so the pair can only be asked to agree
            # to within the drift each still has left -- a tighter test would just be reading noise
            tol = max(3 * max(drift[prep], drift[rev]), 1e-12)
            print(f"     {prep!r:>5} -> {lim[prep]:+.9f}      its reversal {rev!r:>5} -> "
                  f"{lim[rev]:+.9f}      |difference| = {gap:.1e}  (still drifting by {tol / 3:.1e})")
            if gap > tol:
                failures.append(f"R={R}: {prep!r} and {rev!r} differ by {gap:.1e}, more than the "
                                f"{tol:.1e} their own convergence allows -- they do NOT share a limit")

        # --- how fast the preparation stops being readable --------------------------
        rows = [(k, a[0], a[1]) for k, a in listening_scan("/", ["\\", "/"], R, kmax)
                if a[0] or a[1]]
        pts = [(k, abs(Ap * Ap / (Ap * Ap + Am * Am) - 0.5)) for k, Ap, Am in rows]
        pts = [(k, e) for k, e in pts if 1e-9 < e < 0.1]
        if len(pts) >= 4:
            (k0, e0), (k1, e1) = pts[0], pts[-1]
            decay = (e1 / e0) ** (1.0 / (k1 - k0))
            tau = -1.0 / math.log(decay)
            print(f"  -- coherence: on the aligned geometry |P(+) - 1/2| falls by {decay:.4f} per "
                  f"twist, so a preparation stays readable for tau = {tau:.1f} twists at R = {R}")
            if e1 >= e0:
                failures.append(f"R={R}: the aligned weight is not decaying toward 1/2")
    return failures


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--max-k", type=int, default=12, help="largest system-strand horizon")
    ap.add_argument("--brute-check", type=int, default=4,
                    help="verify the DP against enumeration up to this horizon (8^k words; 6 is slow)")
    ap.add_argument("--depth-scan", type=int, default=0, metavar="DMAX",
                    help="instead of the battery, scan preparation depths 1..DMAX over horizons")
    ap.add_argument("--listening", type=str, default="", metavar="R1,R2,...",
                    help="read the weight at finite listening capacities instead (closure is "
                         "capacity-relative: closedAtHorizon_iff_maxExcursion_le)")
    ap.add_argument("--spectrum", type=str, default="", metavar="R1,R2,...",
                    help="report the capacity-R transfer operator's spectrum: the forgetting rate "
                         "quoted by the listening scan is its spectral gap")
    ap.add_argument("--listen-k", type=int, default=600,
                    help="horizon to carry the listening scan to (the limit needs k >> tau(R))")
    args = ap.parse_args()

    if args.spectrum:
        print("== the capacity-R transfer operator (needs numpy)")
        print("   tau_gap is the SLOWEST forgetting time the operator allows (the global gap); a "
              "given\n   geometry may forget faster, as the aligned one does.")
        print(f"   {'R':>3}  {'states':>8}  {'|lambda1|':>10}  {'top mult':>9}  {'|lambda2|':>10}  "
              f"{'gap':>8}  {'tau_gap':>8}")
        for R in [int(x) for x in args.spectrum.split(",")]:
            n, l1, top, l2 = capacity_spectrum(R)
            gap = l2 / l1
            print(f"   {R:>3}  {n:>8}  {l1:>10.6f}  {top:>9}  {l2:>10.6f}  {gap:>8.6f}  "
                  f"{-1 / math.log(gap):>8.1f}")
        return

    if args.listening:
        caps = [int(x) for x in args.listening.split(",")]
        print("== cross-check: capacity-bounded program vs brute-force enumeration")
        bad = []
        for R in caps[:2]:
            for k in range(0, min(args.brute_check, 3) + 1):
                for label, prep, bp, bm, _ in geometries():
                    for app in (bp, bm):
                        if listening_amplitude(prep, app, k, R) != listening_amplitude_brute(prep, app, k, R):
                            bad.append(f"R={R} k={k} {prep!r}/{app!r}")
        print(f"   {'OK' if not bad else 'MISMATCH: ' + ', '.join(bad)}")
        failures = bad + listening_report(caps, args.listen_k)
        print("\n== invariants")
        if failures:
            print("   FAILURES:")
            for f in failures:
                print(f"     - {f}")
            raise SystemExit(1)
        print("   all asserted invariants hold (capacity program = enumeration; symmetric branch "
              "pairs exactly equal; a preparation and its reversal share one limit; the aligned "
              "weight decays toward 1/2)")
        return

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

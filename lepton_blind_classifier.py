#!/usr/bin/env python3
"""
lepton_blind_classifier.py (version 3) — rooted causal lepton-ladder attack on QLF #140.

This version performs two separate audits:

A. BLIND TOPOLOGY SELECTION (no measured masses)
   1. spatial twists only
   2. no immediate Hermitian reversal
   3. first-return ZFA (final closure; no proper causal prefix already closes)
   4. rooted baryon winding B = 0
   5. final Pauli fold = -I (electron-like half-spin)
   6. quotient signed spatial-axis permutations + antiparticle
   7. frequency = number of ways selects the L=6 class
   8. parent-child continuation selects the rooted L=8 class
   CAVEAT (see part G3): step 8 filters to 3-axis classes BEFORE applying the
   parent rule, and that filter is LOAD-BEARING -- without it 9 of the 12 L=8
   classes have a mu parent, not 1.  No measured mass enters, so the blind-test
   discipline holds, but "3 axes for tau" is an imposed assumption, not an
   output.  Part F shows the rule also goes ambiguous at L=10.

B. KOIDE PHASE AUDIT (only after topology selection)
   Reproduce the exact-Q=2/3 phase implied by the repo's m_e and m_mu inputs,
   then compare it with the existing 2/9 candidate -- including the provenance
   of the stale 0.22227 (a single-channel tau extraction) and the fact that
   2/9's residual is the same ~1e-5 order as Q's own deviation from 2/3.
   2/9 is a CANDIDATE Koide-phase hypothesis throughout, never a derivation.

C. THE PHASE, PROPERLY POSED
   Why 2/9 is the wrong object to derive (delta is a Z3 gauge parameter, so
   only Delta = 3*delta is physical), the free 3-parameter fit with propagated
   experimental errors, the noise floor that forbids chasing the 7th digit,
   and what a derivation would still need.

D. THE RESIDUAL
   Which defect is statistically real (one: +9.83 ppm on m_mu/m_e), and the
   much larger radiative puzzle behind it -- why Koide survives at all.

E. IS Delta = Q A RELATION?
   No.  Conditioned on Q = 2/3 the phase Delta is essentially free, so the
   proposed reduction is REFUTED: Q = 2/3 and Delta = 2/3 are two independent
   facts, and only the first is derived.

F. WHAT Delta = 2/3 IS, AND WHERE THE LADDER STOPS
   Delta = 2/3 is m_mu/m_e = 206.77 in other coordinates (not derived), and
   the ladder's selection rule -- unique parented continuation -- goes
   AMBIGUOUS at L=10, so part A is not an independent argument for exactly
   three generations.

G. THE (R, axis) -> MASS-RATIO MAP (issue #140's original ask)
   Shape theorem: the census integers are all 5-smooth but the mass ratios are
   not, so no direct map exists; it must factor as census -> Delta -> masses,
   and Delta = 2/3 IS 5-smooth.  Also flags that part A's 3-axis filter is
   load-bearing, so the census 'axes = 2,2,3' cannot evidence the 2/3.

H. THE UNIT AUDIT (corrects G2)
   'Delta = 2/3 is 5-smooth, precisely what a census CAN yield' holds in
   RADIANS alone -- as a fraction of a turn the phase is 1/(3 pi).  So any
   circle-division census is excluded (the smallest turn-fraction fitting the
   measured Delta is 33/311), only an arc-over-radius reading survives, and
   the invariant the masses are actually built from, e3 = -1/2 + cos(Delta)
   /sqrt2, is no more 5-smooth (0.27% off) than the mass ratios of G1.

No QLF imports are required.
"""

from __future__ import annotations

import itertools
import math
import random
from collections import Counter, defaultdict

SPATIAL = "^v<>/\\"

TWIST = {
    ">": (0, +1), "<": (0, -1),
    "^": (1, +1), "v": (1, -1),
    "/": (2, +1), "\\": (2, -1),
}
FROM = {v: k for k, v in TWIST.items()}
CONJ = {t: FROM[(a, -s)] for t, (a, s) in TWIST.items()}
AXNAME = "XYZ"
ORDER = {c: i for i, c in enumerate(SPATIAL)}

_EVEN = {("X", "Y", "Z"), ("Y", "Z", "X"), ("Z", "X", "Y")}
_ODD  = {("X", "Z", "Y"), ("Z", "Y", "X"), ("Y", "X", "Z")}


def axes_engaged(h: str) -> str:
    return "".join(sorted({AXNAME[TWIST[t][0]] for t in h}))


def balanced(h: str) -> bool:
    c = Counter(h)
    return c["^"] == c["v"] and c[">"] == c["<"] and c["/"] == c["\\"]


def admissible(h: str) -> bool:
    return all(h[i + 1] != CONJ[h[i]] for i in range(len(h) - 1))


def first_return_zfa(h: str) -> bool:
    if not balanced(h):
        return False
    return all(not balanced(h[:k]) for k in range(2, len(h)))


def sign_triple(a: str, b: str, c: str) -> int:
    t = (a, b, c)
    return 1 if t in _EVEN else -1 if t in _ODD else 0


def baryon_number(h: str) -> int:
    ax = [AXNAME[TWIST[t][0]] for t in h]
    return sum(
        sign_triple(ax[i], ax[i + 1], ax[i + 2])
        for i in range(len(ax) - 2)
    )


# ---------- exact 2x2 Pauli fold, pure Python ----------

I = (1+0j, 0j, 0j, 1+0j)
X = (0j, 1+0j, 1+0j, 0j)
Y = (0j, -1j, 1j, 0j)
Z = (1+0j, 0j, 0j, -1+0j)


def smul(s, m):
    return tuple(s*x for x in m)


PMAP = {
    ">": X, "<": smul(-1, X),
    "^": Y, "v": smul(-1, Y),
    "/": Z, "\\": smul(-1, Z),
}


def mmul(m1, m2):
    a, b, c, d = m1
    e, f, g, h = m2
    return (a*e+b*g, a*f+b*h, c*e+d*g, c*f+d*h)


def fold_phase(h: str) -> str:
    m = I
    for t in h:
        m = mmul(m, PMAP[t])
    for s, name in ((1, "+I"), (-1, "-I"), (1j, "+iI"), (-1j, "-iI")):
        if all(abs(m[i] - s*I[i]) < 1e-9 for i in range(4)):
            return name
    return "open"


# ---------- symmetry quotient ----------

def antiparticle(h: str) -> str:
    return "".join(CONJ[t] for t in reversed(h))


def signed_axis_transforms():
    for perm in itertools.permutations(range(3)):
        for flips in itertools.product((+1, -1), repeat=3):
            def tr(h: str, perm=perm, flips=flips) -> str:
                out = []
                for t in h:
                    a, s = TWIST[t]
                    out.append(FROM[(perm[a], s*flips[a])])
                return "".join(out)
            yield tr


TRANSFORMS = list(signed_axis_transforms())


def key(h: str):
    return tuple(ORDER[c] for c in h)


def orbit(h: str) -> set[str]:
    out = set()
    for tr in TRANSFORMS:
        q = tr(h)
        out.add(q)
        out.add(antiparticle(q))
    return out


def canonical(h: str) -> str:
    return min(orbit(h), key=key)


def generate_first_return(length: int) -> list[str]:
    out = []

    def rec(pref: str):
        if len(pref) == length:
            if first_return_zfa(pref):
                out.append(pref)
            return
        for t in SPATIAL:
            if pref and t == CONJ[pref[-1]]:
                continue
            rec(pref + t)

    rec("")
    return out


def half_spin_free(length: int) -> list[str]:
    return [
        h for h in generate_first_return(length)
        if baryon_number(h) == 0 and fold_phase(h) == "-I"
    ]


def classes(words: list[str]) -> dict[str, list[str]]:
    d = defaultdict(list)
    for h in words:
        d[canonical(h)].append(h)
    return d


# ---------- causal parent relation ----------

def conjugate_pair_deletions(h: str):
    """
    Delete one same-axis opposite-sign pair, preserving the causal order of
    everything else.
    """
    for i in range(len(h)):
        for j in range(i + 1, len(h)):
            if h[j] == CONJ[h[i]]:
                yield (i, j, h[i] + h[j], h[:i] + h[i+1:j] + h[j+1:])


def parent_edges(child_orbit: set[str], parent_orbit: set[str]) -> int:
    total = 0
    for h in child_orbit:
        for _, _, _, q in conjugate_pair_deletions(h):
            if q in parent_orbit:
                total += 1
    return total


def child_parent_degree(child_orbit: set[str], parent_orbit: set[str]) -> Counter:
    deg = Counter()
    for h in child_orbit:
        n = sum(1 for _, _, _, q in conjugate_pair_deletions(h) if q in parent_orbit)
        deg[n] += 1
    return deg


def select_topologies():
    print("=== A. BLIND ROOTED TOPOLOGY SELECTION ===\n")

    c4 = classes(half_spin_free(4))
    c6 = classes(half_spin_free(6))
    c8 = classes(half_spin_free(8))

    e = next(iter(c4))  # unique
    mu = max(c6.items(), key=lambda kv: len(kv[1]))[0]  # frequency=ways

    tau3 = {
        rep: members for rep, members in c8.items()
        if len(axes_engaged(rep)) == 3
    }

    print("L=4 free half-spin classes:")
    for rep, mem in c4.items():
        print(f"  {rep:10} ways={len(mem):3d} axes={axes_engaged(rep)}")
    print()

    print("L=6 free half-spin classes:")
    for rep, mem in sorted(c6.items(), key=lambda kv: key(kv[0])):
        print(f"  {rep:10} ways={len(mem):3d} axes={axes_engaged(rep)}")
    print(f"  -> number-of-ways selection: mu = {mu}\n")

    print("L=8 three-axis free half-spin classes:")
    omu = orbit(mu)
    parentful = []
    for rep, mem in sorted(tau3.items(), key=lambda kv: key(kv[0])):
        o = orbit(rep)
        edges = parent_edges(o, omu)
        deg = child_parent_degree(o, omu)
        print(
            f"  {rep:10} ways={len(mem):3d} "
            f"mu-parent-edges={edges:3d} degree={dict(deg)}"
        )
        if edges:
            parentful.append(rep)

    if len(parentful) != 1:
        raise RuntimeError(f"Expected unique rooted tau continuation, got {parentful}")
    tau = parentful[0]
    print(f"  -> causal-parent selection: tau = {tau}\n")

    oe, om, ot = orbit(e), orbit(mu), orbit(tau)
    print("Selected causal ladder:")
    for n, h in (("e", e), ("mu", mu), ("tau", tau)):
        print(
            f"  {n:3} = {h:10} L={len(h)} axes={axes_engaged(h)} "
            f"B={baryon_number(h):+d} fold={fold_phase(h)} orbit={len(orbit(h))}"
        )

    print("\nParent-edge audit:")
    print(f"  mu -> e deletion edges across orbit  = {parent_edges(om, oe)}")
    print(f"  per-mu rooted history                = {dict(child_parent_degree(om, oe))}")
    print(f"  tau -> mu deletion edges across orbit= {parent_edges(ot, om)}")
    print(f"  per-tau rooted history               = {dict(child_parent_degree(ot, om))}")

    old = "^v<>/\\"
    print("\nEarlier L=6 tau proposal:")
    print(
        f"  {old}: balanced={balanced(old)}, first-return={first_return_zfa(old)}, "
        f"B={baryon_number(old)}, fold={fold_phase(old)}"
    )
    print("  -> reject as elementary: (^v)(<>)(/\\) are already separate closures.")

    return e, mu, tau


# ---------- Koide audit ----------

ME = 0.51099895000
MMU = 105.6583755
MTAU = 1776.86

# PDG / CODATA 1-sigma uncertainties (MeV)
D_ME = 0.00000000015
D_MMU = 0.0000023
D_MTAU = 0.12


def koide_weights(delta: float):
    # k=(0,1,2) = (tau,e,mu)
    return [
        (1 + math.sqrt(2)*math.cos(delta + 2*math.pi*k/3))**2
        for k in range(3)
    ]


def mu_e_ratio(delta: float) -> float:
    w = koide_weights(delta)
    return w[2] / w[1]


def solve_delta_from_e_mu() -> float:
    target = MMU / ME
    lo, hi = 0.21, 0.23
    flo = mu_e_ratio(lo) - target
    fhi = mu_e_ratio(hi) - target
    if flo * fhi > 0:
        raise RuntimeError("Root not bracketed")
    for _ in range(100):
        mid = (lo + hi) / 2
        fm = mu_e_ratio(mid) - target
        if flo * fm <= 0:
            hi, fhi = mid, fm
        else:
            lo, flo = mid, fm
    return (lo + hi) / 2


def koide_tau_from_e_mu():
    a = math.sqrt(ME) + math.sqrt(MMU)
    b = ME + MMU
    s_tau = 2*a + math.sqrt(6*a*a - 3*b)
    return s_tau*s_tau


def koide_Q() -> float:
    s = math.sqrt(ME) + math.sqrt(MMU) + math.sqrt(MTAU)
    return (ME + MMU + MTAU) / (s*s)


def single_channel_deltas() -> dict[str, float]:
    """
    Extract delta from ONE mass at a time, with M pinned by all three measured
    masses (M = sum(sqrt m)/3).  Because the measured Q is not exactly 2/3 the
    three extractions disagree in the 5th decimal -- this is the provenance of
    the stale 0.22227 that Weak_Force.md used to quote as "the phase m_e, m_mu
    demand".  It is the tau-channel value, not a two-input solve.
    """
    M = (math.sqrt(ME) + math.sqrt(MMU) + math.sqrt(MTAU)) / 3.0
    out = {}
    for name, m, k in (("tau", MTAU, 0), ("e", ME, 1), ("mu", MMU, 2)):
        c = (math.sqrt(m)/M - 1) / math.sqrt(2)
        c = max(-1.0, min(1.0, c))
        # the branch near delta ~ 0.222 rad
        cands = [(sg*math.acos(c) - 2*math.pi*k/3) % (2*math.pi) for sg in (1, -1)]
        out[name] = min(cands, key=lambda d: abs(d - 2/9))
    return out


def delta_sigma_from_experiment(delta: float) -> float:
    """1-sigma spread in delta induced by the experimental m_mu/m_e error."""
    rel = math.hypot(D_MMU/MMU, D_ME/ME)
    h = 1e-9
    dr = (mu_e_ratio(delta + h) - mu_e_ratio(delta - h)) / (2*h)
    return (MMU/ME) * rel / abs(dr)


def koide_audit():
    print("\n=== B. KOIDE PHASE AUDIT (AFTER BLIND SELECTION) ===\n")

    delta_exactQ = solve_delta_from_e_mu()
    delta_29 = 2/9

    print("Repo inputs (koide_tau_demo.py):")
    print(f"  m_e   = {ME:.11f} MeV")
    print(f"  m_mu  = {MMU:.7f} MeV")
    print(f"  m_tau = {MTAU:.2f} MeV\n")

    print("B1. The well-posed determination (exact Q=2/3; m_e, m_mu the two inputs):")
    print(f"  delta_required = {delta_exactQ:.15f} rad")
    print(f"  2/9            = {delta_29:.15f} rad")
    print(f"  difference     = {delta_29-delta_exactQ:+.3e} rad")
    print(f"  relative delta gap = {(delta_29/delta_exactQ-1)*100:+.8f}%\n")

    print("B2. Provenance of the stale 0.22227 (single-channel extractions,")
    print("    M pinned by all three MEASURED masses):")
    sc = single_channel_deltas()
    for name in ("tau", "mu", "e"):
        print(f"  delta from {name:3} channel alone = {sc[name]:.9f} rad")
    print("  -> they disagree in the 5th decimal because measured Q != 2/3.")
    print("     0.22227 is the TAU-channel value; it is not what m_e,m_mu demand.\n")

    obs_mu_e = MMU / ME
    pred_mu_e = mu_e_ratio(delta_29)
    w = koide_weights(delta_29)
    tau_from_e = ME * (w[0] / w[1])

    print("B3. Exact delta=2/9 as a zero-parameter mass-RATIO prediction")
    print("    (m_e supplies only the overall scale):")
    print(f"  observed  m_mu/m_e = {obs_mu_e:.12f}")
    print(f"  predicted m_mu/m_e = {pred_mu_e:.12f}")
    print(f"  relative error     = {(pred_mu_e/obs_mu_e-1)*100:+.8f}%  "
          f"({(pred_mu_e/obs_mu_e-1)*1e6:+.1f} ppm)")
    print(f"  m_tau from e scale = {tau_from_e:.6f} MeV")
    print(f"  relative error     = {(tau_from_e/MTAU-1)*100:+.6f}%  "
          f"= {(tau_from_e-MTAU)/D_MTAU:+.2f} sigma\n")

    mt_koide = koide_tau_from_e_mu()
    print("B4. For comparison, exact Q=2/3 with measured e,mu gives:")
    print(f"  m_tau = {mt_koide:.6f} MeV  "
          f"({(mt_koide/MTAU-1)*100:+.6f}% = {(mt_koide-MTAU)/D_MTAU:+.2f} sigma)\n")

    print("B5. How 2/9 fails, and how Koide's own 2/3 fails -- same order:")
    sig = delta_sigma_from_experiment(delta_exactQ)
    Q = koide_Q()
    print(f"  sigma(delta) from the m_mu/m_e error = {sig:.3e} rad")
    print(f"  (2/9 - delta_required)               = {(delta_29-delta_exactQ)/sig:+.0f} sigma")
    print(f"  measured Q                           = {Q:.9f}")
    print(f"  (2/3 - Q)/Q                          = {(2/3)/Q-1:+.3e}")
    print(f"  2/9 residual on m_mu/m_e             = {pred_mu_e/obs_mu_e-1:+.3e}")
    print("  -> both deviations are ~1e-5.  2/9 fails exactly where Q=2/3 fails.\n")

    print("VERDICT")
    print("  * delta = 0.222222047 rad is the well-posed two-input value (B1).")
    print("    The older 0.22227 was the tau-channel extraction (B2), not a solve")
    print("    from m_e, m_mu -- Weak_Force.md sec 5c now states this correctly.")
    print("  * 2/9 is NOT excluded by m_tau: 1.04 sigma, as good as exact Q=2/3")
    print("    at 0.91 sigma (B3/B4).  Both sit inside the PDG error bar.")
    print("  * 2/9 IS excluded by m_mu/m_e at ~9.8 ppm -- but only CONDITIONAL on")
    print("    Q being exactly 2/3, which the data does not support at that")
    print("    precision: Q itself is off by 9.2e-6 -- nearly the same number (B5).")
    print("  * So 2/9 stays a flagged CANDIDATE Koide-phase hypothesis, pointing")
    print("    at one common ~1e-5 correction rather than two coincidences.")
    print("  * The missing physics is not arithmetic: QLF still needs a reason why")
    print("    the Koide cosine phase should equal the count ratio 2/9 at all.")
    print("    Until that exists this is numerology, however sharp.")
    print("  * See part C: 2/9 is in fact the WRONG object to derive.")


# ---------- C. the phase, properly posed ----------

def fit_three_phase(me: float, mmu: float, mtau: float):
    """
    EXACT 3-parameter fit of  sqrt(m_k) = M(1 + A cos(delta + 2pi k/3)),
    k = 0,1,2 -> tau,e,mu.  Nothing is assumed: three masses determine
    (M, A, delta) with no residual, via the first three power sums.

        sum cos      = 0     ->  M     = (sum sqrt m)/3
        sum cos^2    = 3/2   ->  A     = sqrt(2/3 sum u^2),  u_k = sqrt(m_k)/M - 1
        sum cos^3    = (3/4) cos(3 delta)
                             ->  delta = arccos(4 sum u^3 / 3A^3)/3

    Note the third power sum is the FIRST one that sees delta, and it sees it
    only through cos(3 delta).  That is not an accident -- see z3_redundancy().
    """
    s = [math.sqrt(mtau), math.sqrt(me), math.sqrt(mmu)]
    M = sum(s) / 3.0
    u = [x / M - 1.0 for x in s]
    A = math.sqrt(2 * sum(x * x for x in u) / 3.0)
    c3 = max(-1.0, min(1.0, 4 * sum(x**3 for x in u) / (3 * A**3)))
    return M, A, math.acos(c3) / 3.0


def z3_redundancy() -> bool:
    """
    delta -> delta + 2pi/3 permutes the three phases, hence relabels the three
    generations, hence leaves the SPECTRUM identical.  So delta is a Z3 gauge
    parameter: it is defined only mod 2pi/3, and every physical invariant is a
    function of Delta = 3*delta.  Returns True if verified numerically.
    """
    M, A = 17.715561710, math.sqrt(2)
    def spec(d):
        return sorted((M*(1 + A*math.cos(d + 2*math.pi*k/3)))**2 for k in range(3))
    base = spec(2/9)
    return all(
        all(abs(x - y) < 1e-9 for x, y in zip(base, spec(2/9 + n*2*math.pi/3)))
        for n in (1, 2)
    )


def mc_phase_errors(trials: int = 60000, seed: int = 1):
    """Propagate the experimental mass errors into the fitted (A^2, delta)."""
    rng = random.Random(seed)
    a2s, ds = [], []
    for _ in range(trials):
        _, a, d = fit_three_phase(rng.gauss(ME, D_ME),
                                  rng.gauss(MMU, D_MMU),
                                  rng.gauss(MTAU, D_MTAU))
        a2s.append(a*a); ds.append(d)
    def stat(v):
        m = sum(v)/len(v)
        return m, math.sqrt(sum((x-m)**2 for x in v)/(len(v)-1))
    return stat(a2s), stat(ds)


def phase_audit():
    print("\n=== C. THE PHASE, PROPERLY POSED ===\n")

    print("C1. delta is a Z3 GAUGE PARAMETER, so 2/9 is the wrong target.")
    print(f"  delta -> delta + 2pi/3 leaves the spectrum identical: "
          f"{'VERIFIED' if z3_redundancy() else 'FAILED'}")
    print("  Only Delta = 3*delta is physical.  Consequently:")
    print("    - the object to derive is  Delta = 2/3,  not  delta = 2/9;")
    print("    - the 9 in 2/9 is NOT one count.  It factorises as")
    print("        9 = 3 (generations, from Q) x 3 (the Z3 quotient),")
    print("      so reading it as '3^2 directional couplings, the same 9 as")
    print("      alpha' matches the right number to the wrong decomposition.")
    print("  This also explains why the phase is a pure number rather than a")
    print("  multiple of pi: Delta is a ratio of invariants; the 1/3 is the")
    print("  quotient, not an angle.\n")

    print("C2. Free 3-parameter fit (NOTHING assumed -- not even Q=2/3):")
    M, A, d = fit_three_phase(ME, MMU, MTAU)
    (a2m, a2s), (dm, ds) = mc_phase_errors()
    print(f"  M       = {M:.6f} MeV^1/2")
    print(f"  A^2     = {a2m:.9f} +- {a2s:.9f}   (predicted 2)")
    print(f"  delta   = {dm:.9f} +- {ds:.9f}   (candidate 2/9)")
    print(f"  Delta   = {3*dm:.9f} +- {3*ds:.9f}   (candidate 2/3)")
    print(f"  -> A^2 = 2   at {(a2m-2)/a2s:+.2f} sigma")
    print(f"  -> Delta=2/3 at {(3*dm-2/3)/(3*ds):+.2f} sigma")
    print("  Errors are dominated by m_tau (+-0.12 MeV).  NEITHER is excluded.\n")

    print("C3. Delta = Q is NOT an identity -- it is a second relation.")
    rng = random.Random(11)
    worst = 0.0
    for _ in range(20000):
        a = 10**rng.uniform(-1, 0.5); b = 10**rng.uniform(1, 2.5)
        c = 10**rng.uniform(2.5, 4)
        _, _, dd = fit_three_phase(a, b, c)
        q = (a+b+c)/(math.sqrt(a)+math.sqrt(b)+math.sqrt(c))**2
        worst = max(worst, abs(3*dd - q))
    Q = koide_Q()
    print(f"  random mass triples: |Delta - Q| reaches {worst:.3f}  (O(1) generic)")
    print(f"  charged leptons    : |Delta - Q| = {abs(3*d-Q):.2e}")
    print("  The leptons do satisfy it -- but this does NOT make it a relation.")
    print("  See part E: conditioned on Q = 2/3, Delta is essentially free, so")
    print("  'Delta = Q' has no content beyond two separate facts.  REFUTED.\n")

    print("C4. NOISE FLOOR -- why the 1e-7 'agreement' is not evidence.")
    delta_condQ = solve_delta_from_e_mu()
    syst = abs(d - delta_condQ) / delta_condQ
    agree = abs(2/9 - delta_condQ) / (2/9)
    print(f"  delta from the free fit           = {d:.10f}")
    print(f"  delta conditional on Q=2/3 exactly= {delta_condQ:.10f}")
    print(f"  systematic between the two        = {syst:.2e}")
    print(f"  |2/9 - (conditional value)|       = {agree:.2e}")
    print(f"  -> the celebrated agreement is {syst/agree:.0f}x SMALLER than the")
    print("     choice of extraction.  It is below the model's own noise floor,")
    print(f"     which the Q defect sets at {(2/3)/Q-1:.1e}.")
    print("  HONEST PRECISION:  delta = 2/9 holds at 1e-5, and no better.")
    print("  Chasing the 7th digit is chasing an artefact of assuming Q=2/3.\n")

    print("C5. WHAT A DERIVATION STILL NEEDS (and what cannot supply it).")
    print("  The Pauli fold CANNOT supply the phase.  The fold group is mu_4 =")
    print("  {+-I, +-iI}; the half-spin signature is one bit (-I vs +I); the")
    print("  free-energy quantum is one bit (dF = -log 2).  A FINITE group has")
    print("  no continuous parameter, so no amount of fold structure yields a")
    print("  real angle.  One-bit precision does do one useful thing: it sets")
    print("  the resolution floor, which is what rules the 1e-7 chase out (C4).")
    print("  A derivation must therefore produce  Delta = 2/3  as a ratio of")
    print("  CENSUS COUNTS, with the Z3 quotient already built in -- and must")
    print("  also produce the common ~1e-5 correction that Q and Delta share.")
    print("  Until then: not derived.  Consistent, reduced, and open.")


# ---------- D. the residual, and the radiative puzzle behind it ----------

ALPHA = 1 / 137.035999177


def q_running(mu: float) -> float:
    """
    Koide Q built from one-loop QED running masses at common scale mu:
        mbar_k(mu) = M_k / (1 + (alpha/pi)[1 + (3/2) ln(mu/M_k)])
    """
    m = [M / (1 + (ALPHA/math.pi)*(1 + 1.5*math.log(mu/M)))
         for M in (ME, MMU, MTAU)]
    return sum(m) / (sum(math.sqrt(x) for x in m))**2


def residual_audit():
    print("\n=== D. THE RESIDUAL, AND THE LARGER PUZZLE BEHIND IT ===\n")

    print("D1. There is no 'common 1e-5 correction to Q and Delta'.")
    (a2m, a2s), (dm, ds) = mc_phase_errors()
    w = koide_weights(2/9)
    pred, obs = w[2]/w[1], MMU/ME
    ru = math.hypot(D_MMU/MMU, D_ME/ME)
    rows = [("A^2 - 2", a2m-2, a2s), ("Delta - 2/3", 3*dm-2/3, 3*ds),
            ("m_mu/m_e (rel)", pred/obs-1, ru)]
    print(f"  {'quantity':>16} {'defect':>12} {'+- unc':>12} {'sigma':>10}")
    for n, d, s in rows:
        print(f"  {n:>16} {d:+12.3e} {s:12.1e} {d/s:+10.1f}"
              f"   {'SIGNIFICANT' if abs(d/s) > 3 else 'noise'}")
    print("\n  The Q and Delta defects are m_tau noise.  EXACTLY ONE number is")
    print(f"  significant: m_mu/m_e is overpredicted by {(pred/obs-1)*1e6:+.2f} ppm.")
    print("  Its locus -- the e-mu sector -- is where the blind ladder carries")
    print("  its one asymmetry: e and mu share axes {x,y}, only tau engages z.\n")

    print("D2. Q is blind to universal shifts, so only log(m_k) terms can move it.")
    c = 1.7
    Qc = ((c*ME + c*MMU + c*MTAU)
          / (math.sqrt(c*ME)+math.sqrt(c*MMU)+math.sqrt(c*MTAU))**2)
    print(f"  m_k -> {c}*m_k :  Q = {koide_Q():.12f} -> {Qc:.12f}  (exactly equal)")
    print(f"  flavour-dependent scale (alpha/pi)*ln(m_mu/m_e) = "
          f"{(ALPHA/math.pi)*math.log(MMU/ME):.2e}\n")

    print("D3. Radiative corrections are 100x LARGER than the residual,")
    print("    and no scale rescues them:")
    print(f"  {'mu (MeV)':>12} {'Q(running)':>14} {'Q - 2/3':>12}")
    for mu in (1.0, 1e3, MTAU, 1e6, 1e12):
        print(f"  {mu:12.3g} {q_running(mu):14.9f} {q_running(mu)-2/3:+12.2e}")
    print(f"  {'POLE':>12} {koide_Q():14.9f} {koide_Q()-2/3:+12.2e}")
    print(f"\n  running is {abs(q_running(1e4)-2/3)/abs(koide_Q()-2/3):.0f}x worse, and")
    print("  essentially SCALE-INDEPENDENT (the ln mu is universal, so it cancels")
    print("  in Q).  Koide is a POLE-MASS relation, full stop.")
    print("  => the real question is not 'where does 9.8 ppm come from' but")
    print("     'why is the 1.1e-3 absent' -- a discrepancy 115x larger.\n")

    print("D4. QLF answers THAT one, and was committed to the answer already.")
    print("  Weak_Force.md sec 5d: only observables carry physical mass; the")
    print("  quoted quark masses are scheme-dependent running parameters, never")
    print("  measured -- which is why quark-Koide is PREDICTED to fail.  The pole")
    print("  mass is the on-shell, gauge-invariant, IR-complete observable, which")
    print("  is exactly what a ZFA closure is; a running mass is bookkeeping.")
    print("  So the substrate relation must hold for POLE masses -- and the 183x")
    print("  preference for pole over running is that prediction confirmed.")
    print("  One principle, two consequences (5d and this), neither fitted.\n")

    print("D5. The 9.83 ppm itself: NOT derived, and not being fitted.")
    resid = pred/obs - 1
    for name, val in (("1/(24*48*96)  [orbit sizes]", 1/(24*48*96)),
                      ("2*(alpha/pi)^2", 2*(ALPHA/math.pi)**2),
                      ("alpha^2/(2pi)", ALPHA**2/(2*math.pi))):
        print(f"  {name:28} = {val:.4e}  off by {abs(val/resid-1)*100:.0f}%  REJECTED")
    print(f"  {'residual':28} = {resid:.4e}")
    print("  An exact census count must come out EXACT: an 8% miss is a failure,")
    print("  not a near-miss.  With alpha, pi and small rationals any single")
    print("  number matches to a few percent, so none of these are candidates.")
    print("  Status: open.")


# ---------- E. is Delta = Q a relation?  (no) ----------

def fit_any(ms):
    """(A, Delta) for an arbitrary triple of positive masses, heaviest -> k=0."""
    s = sorted((math.sqrt(m) for m in ms), reverse=True)
    s = [s[0], s[2], s[1]]
    M = sum(s) / 3.0
    u = [x / M - 1.0 for x in s]
    A = math.sqrt(2 * sum(x*x for x in u) / 3.0)
    c3 = max(-1.0, min(1.0, 4 * sum(x**3 for x in u) / (3 * A**3)))
    return A, math.acos(c3)


def q_any(ms):
    return sum(ms) / sum(math.sqrt(m) for m in ms)**2


def delta_equals_q_test():
    print("\n=== E. IS  Delta = Q  A RELATION?  (REFUTED) ===\n")

    print("E1. Conditioned on Q = 2/3, is Delta pinned near 2/3?")
    rng = random.Random(3)
    ds = []
    while len(ds) < 4000:
        ms = [10**rng.uniform(-2, 0), 10**rng.uniform(0, 3), 10**rng.uniform(2, 5)]
        if abs(q_any(ms) - 2/3) < 0.001:
            ds.append(fit_any(ms)[1])
    ds.sort()
    near = sum(1 for x in ds if abs(x - 2/3) < 0.01) / len(ds)
    print(f"  {len(ds)} random triples with Q = 2/3 +- 0.001")
    print(f"  Delta range          : {ds[0]:.4f} .. {ds[-1]:.4f}")
    print(f"  Delta median         : {ds[len(ds)//2]:.4f}")
    print(f"  5th / 95th percentile: {ds[len(ds)//20]:.4f} / {ds[-len(ds)//20]:.4f}")
    print(f"  within 0.01 of 2/3   : {near*100:.1f}%")
    print("  -> Q = 2/3 carries essentially NO information about Delta.\n")

    print("E2. The sharpest counterexample, from real numbers:")
    cbt = [1270.0, 4180.0, 172690.0]          # (c, b, t)
    _, D = fit_any(cbt); q = q_any(cbt)
    print(f"  (c,b,t):  Q = {q:.6f}  -- within {abs(q-2/3)/(2/3)*100:.1f}% of 2/3")
    print(f"            Delta = {D:.6f}  -- a factor {(2/3)/D:.2f} away from 2/3")
    print("  A triple with Koide's invariant AT 2/3 whose phase is nowhere near.")
    print("  (Quark masses are scheme-dependent parameters, not observables, so")
    print("   they cannot test a physical law -- but that objection does not")
    print("   apply here: the question is the MATHEMATICAL one, whether Q fixes")
    print("   Delta as functions of a triple of positive reals.  E1 settles it")
    print("   with random triples and no physics at all.)\n")

    print("E3. VERDICT")
    print("  'Delta = Q' is REFUTED as a relation.  Delta and Q are independent")
    print("  functions on mass-triple space; the leptons satisfying both is two")
    print("  separate facts wearing one costume, not a reduction.")
    print("    Q = 2/3      -- DERIVED (N=3 axes, A^2=2 transverse; sec 5b)")
    print("    Delta = 2/3  -- INDEPENDENT, NOT derived, NOT implied by Q")
    print("  The honest residue is weaker: the substrate's transverse fraction")
    print("  2/3 appears twice -- once in the amplitude sector, once in the")
    print("  phase sector -- a structural coherence, not a derivation.")


# ---------- F. what Delta = 2/3 actually is, and where the ladder stops ----------

def first_return_pruned(length: int) -> list[str]:
    """
    Same set as generate_first_return, but with the balance-reachability and
    first-return prunes applied during construction, so L=10 is tractable.
    """
    out: list[str] = []
    c = [0, 0, 0]
    pref: list[str] = []

    def rec():
        n = len(pref)
        if n == length:
            out.append("".join(pref))
            return
        r = length - n
        s = abs(c[0]) + abs(c[1]) + abs(c[2])
        if s > r or (r - s) % 2:
            return
        for t in SPATIAL:
            if pref and t == CONJ[pref[-1]]:
                continue
            a, sg = TWIST[t]
            c[a] += sg
            pref.append(t)
            n2 = n + 1
            balanced_now = (c == [0, 0, 0])
            # a PROPER prefix may not close; the final word must
            if not (2 <= n2 < length and balanced_now) and \
               not (n2 == length and not balanced_now):
                rec()
            c[a] -= sg
            pref.pop()

    rec()
    return out


def delta_two_thirds_audit():
    print("\n=== F. WHAT Delta = 2/3 IS, AND WHERE THE LADDER STOPS ===\n")

    print("F1. Delta = 2/3 IS the muon-to-electron mass ratio.")
    print("  With A^2 = 2 derived, the form has parameters (M, Delta).  M is the")
    print("  overall scale, so Delta is the ONLY remaining ratio freedom:")
    print(f"  {'Delta':>10} {'m_mu/m_e':>14} {'m_tau/m_e':>14}")
    for D in (0.60, 0.64, 2/3, 0.69, 0.72):
        w = koide_weights(D/3)
        print(f"  {D:10.4f} {w[2]/w[1]:14.4f} {w[0]/w[1]:14.2f}")
    print(f"  {'measured':>10} {MMU/ME:14.4f} {MTAU/ME:14.2f}")
    print("  -> 'derive Delta = 2/3' and 'derive m_mu/m_e = 206.77' are the SAME")
    print("     statement in different coordinates.  That is the difficulty")
    print("     class: a number nobody has derived.  NOT DERIVED here either.\n")

    print("F2. Does the blind ladder stop at three generations?")
    otau, omu, oe = orbit(TAU_REP), orbit(MU_REP), orbit(E_REP)
    print("  signature of the rungs that WERE selected:")
    for nm, h, po in (("mu", MU_REP, oe), ("tau", TAU_REP, omu)):
        print(f"    {nm:4} parent-degree = {dict(child_parent_degree(orbit(h), po))}")
    print("    tau's signature: every rooted history has EXACTLY ONE parent.\n")

    free = [h for h in first_return_pruned(10)
            if baryon_number(h) == 0 and fold_phase(h) == "-I"]
    cls: dict[str, list[str]] = defaultdict(list)
    for h in free:
        cls[canonical(h)].append(h)
    cand = [r for r in cls if len(axes_engaged(r)) == 3]
    rows = []
    for r in cand:
        o = orbit(r)
        e = parent_edges(o, otau)
        if e:
            rows.append((r, len(cls[r]), e, dict(child_parent_degree(o, otau))))
    strict = [r for r, _, _, d in rows if set(d) == {1}]

    print(f"  L=10: {len(cls)} classes, {len(cand)} three-axis,")
    print(f"        {len(rows)} with a causal parent in the tau orbit,")
    print(f"        {len(strict)} matching tau's exact degree signature.")
    for r, w, e, d in sorted(rows, key=lambda x: key(x[0])):
        mark = "  <-- tau signature" if set(d) == {1} else ""
        print(f"    {r:12} ways={w:3d} edges={e:4d} degree={d}{mark}")

    print("\n  VERDICT: the rule that produced e -> mu -> tau is AMBIGUOUS at L=10.")
    print("  L=8 gave 1 of 2 candidates; L=10 gives 12 of 105 (4 under the strict")
    print("  signature).  It yields neither 0 -- which would confirm the ladder")
    print("  terminates at three generations -- nor 1, a fourth generation.")
    print("  So the L=8 uniqueness looks like a small-numbers accident, and this")
    print("  ladder is NOT an independent derivation of 'exactly three'.")
    print("  QLF's three-generation claim rests on QLF_Generations (generation")
    print("  count = spatial dimension = 3), which is untouched by this; what")
    print("  fails is this combinatorial route as a second, independent argument.")


E_REP, MU_REP, TAU_REP = "^<v>", "^^<vv>", "^^</>vv\\"


# ---------- G. the (R, axis) -> mass-ratio map: a shape theorem ----------

def five_smooth_best(target: float, amax=12, bmax=6, cmax=4):
    """Closest 2^a 3^b 5^c to target with small exponents."""
    best = None
    for a in range(-amax, amax+1):
        for b in range(-bmax, bmax+1):
            for c in range(-cmax, cmax+1):
                v = 2.0**a * 3.0**b * 5.0**c
                e = abs(v/target - 1)
                if best is None or e < best[0]:
                    best = (e, a, b, c, v)
    return best


def mass_ratio_map_audit():
    print("\n=== G. THE (R, axis) -> MASS-RATIO MAP: A SHAPE THEOREM ===\n")

    print("G1. Every census integer at the three rungs is 5-SMOOTH.")
    print("  L = 4,6,8;  orbit = ways = 24,48,96;  axes = 2,2,3;")
    print("  conj-pairs = 2,5,6;  parent-edges = 192,96.")
    print("  All are of the form 2^a 3^b 5^c, so ANY product or ratio of them")
    print("  is 5-smooth too.  Can the mass ratios be 5-smooth?\n")
    print(f"  {'quantity':>16} {'value':>13}   closest 2^a 3^b 5^c      error")
    for nm, t in (("m_mu/m_e", MMU/ME), ("m_tau/m_e", MTAU/ME),
                  ("m_tau/m_mu", MTAU/MMU), ("Delta = 2/3", 2/3)):
        e, a, b, c, v = five_smooth_best(t)
        print(f"  {nm:>16} {t:13.6f}   2^{a:<3d}3^{b:<3d}5^{c:<3d} = {v:11.6f}"
              f"  {e*100:7.3f}%")
    print("\n  The MASS RATIOS ARE NOT 5-SMOOTH: the closest small-exponent form")
    print("  misses by 0.14-0.61%, orders of magnitude outside the 1e-5 at which")
    print("  the three-phase picture holds.  A 64000-expression brute search over")
    print("  a^p b^q c^r from the census pool does no better (best 0.286% off).")
    print("  => the DIRECT census -> mass-ratio map does not exist in any simple")
    print("     form.  This is a real negative, not a failed fit.\n")

    print("G2. So the map must FACTOR:   census -> Delta -> masses.")
    print("  sqrt(m_k)/M = 1 + sqrt2 cos(Delta/3 + 2pi k/3): the mass ratios are")
    print("  COSINE VALUES at an O(1) phase, transcendental in Delta.  A census")
    print("  produces integers; it cannot produce those directly.  It can only")
    print("  produce the PHASE, and the cosine does the rest.  Independently:")
    print("  Q = 2/3 is derived and holds to 1e-5, so any correct map must")
    print("  reproduce it -- which a map onto (M, Delta) does automatically and")
    print("  a map onto three independent masses would have to hit by accident.")
    print("  And Delta = 2/3 IS exactly 5-smooth (2 * 3^-1) -- precisely the kind")
    print("  of object a census CAN yield.  The issue's ask is thereby reshaped")
    print("  from 'three masses' to ONE SMALL RATIONAL.  That is well posed.\n")

    print("G3. WARNING -- the obvious census route to 2/3 is CIRCULAR.")
    print("  The axis counts (e,mu,tau) = (2,2,3) look like the transverse")
    print("  fraction 2/3.  Provenance of each:")
    print("    e  (L=4): 3 axes need >=6 twists to balance  -> FORCED")
    c6 = classes(half_spin_free(6))
    n3 = sum(1 for r in c6 if len(axes_engaged(r)) == 3)
    print(f"    mu (L=6): 3-axis free half-spin classes = {n3}  -> OUTPUT")
    c8 = classes(half_spin_free(8))
    omu = orbit(MU_REP)
    parented = [r for r in c8 if parent_edges(orbit(r), omu)]
    three = [r for r in parented if len(axes_engaged(r)) == 3]
    print(f"    tau(L=8): part A filters to 3-axis BEFORE the parent rule.")
    print(f"              Drop the filter: {len(parented)} of {len(c8)} classes have a mu")
    print(f"              parent ({len(three)} of them 3-axis) -- NOT unique.")
    print("  => the 3-axis criterion is LOAD-BEARING in part A's tau selection.")
    print("     'axes = 2,2,3' is therefore partly IMPOSED, and cannot be cited")
    print("     as census evidence for Delta = 2/3.  Recorded so it is not.")


# ---------- H. the unit audit: is 'Delta = 2/3 is 5-smooth' unit-luck? ----------

def cf_convergents(x, n=12):
    """Continued-fraction convergents p/q of x."""
    a, v = [], x
    for _ in range(n):
        i = int(v)
        a.append(i)
        if abs(v - i) < 1e-15:
            break
        v = 1.0 / (v - i)
    out, p0, q0, p1, q1 = [], 1, 0, a[0], 1
    for i in a[1:]:
        p0, q0, p1, q1 = p1, q1, i * p1 + p0, i * q1 + q0
        out.append((p1, q1))
    return out


def unit_audit():
    """Part G2 claimed Delta = 2/3 is 5-smooth, 'precisely what a census can
    yield'.  That is true of the RADIAN measure only.  This part asks what
    justifies radians, and audits every other reading."""
    print("\n=== H. THE UNIT AUDIT: WHICH ANGULAR UNIT IS THE CENSUS UNIT? ===\n")
    D = 2.0 / 3.0

    print("H1. Delta = 2/3 is 5-smooth IN RADIANS.  In every other unit it is not.\n")
    print(f"  {'unit':>22}   Delta in that unit")
    for nm, u in (("turn (2pi)", 2 * math.pi),
                  ("Z3 cell (2pi/3)", 2 * math.pi / 3),
                  ("pi", math.pi),
                  ("right angle (pi/2)", math.pi / 2),
                  ("degree", math.pi / 180)):
        print(f"  {nm:>22} = {D / u:.9f}")
    print(f"\n  As a fraction of a TURN the phase is exactly 1/(3 pi) = "
          f"{1/(3*math.pi):.9f}")
    print("  -- transcendental.  A census cannot yield that.  So the 5-smoothness")
    print("  of 2/3 is a fact about the radian, not about the phase: it survives")
    print("  exactly one choice of unit and is destroyed by every other.\n")

    print("H2. Consequence -- the CIRCLE-DIVISION route is EXCLUDED.")
    print("  If a census fixes the phase by dividing a turn into q equal parts")
    print("  and stepping p of them, then Delta = 2pi p/q.  Convergents of")
    print(f"  Delta/2pi = {D/(2*math.pi):.9f} :\n")
    print(f"    {'p/q':>14}   2pi p/q        rel err vs 2/3")
    for p, q in cf_convergents(D / (2 * math.pi))[:8]:
        v = 2 * math.pi * p / q
        print(f"    {p:>6d}/{q:<7d} {v:.9f}   {abs(v/D - 1):.3e}")
    # tested against the DATA, not against the hypothesis
    DM, SD = 0.666689, 0.000025          # free 3-parameter fit, part C
    lo, hi = DM - 2 * SD, DM + 2 * SD
    hits = []
    for q in range(1, 401):
        for p in range(1, q):
            if math.gcd(p, q) == 1 and lo <= 2 * math.pi * p / q <= hi:
                hits.append((q, p))
                break
    print(f"\n  Against the DATA (free-fit Delta = {DM} +- {SD}, 2 sigma band")
    print(f"  [{lo:.6f}, {hi:.6f}]), the turn-fractions that fit are")
    print("    " + ", ".join(f"{p}/{q}" for q, p in hits[:4]))
    print(f"  smallest denominator q = {hits[0][0]}.  A census that cuts a circle")
    print("  into 311 parts and takes 33 of them is not a census; it is a fit.")
    print("  Single divisions are nowhere near: 2pi/9 misses by 4.7%.")
    print("  => NO circle-division census can produce this phase.\n")

    print("H3. What SURVIVES: arc-over-radius.  A rational RADIAN measure is")
    print("  what you get from n unit arc-steps at integer radius R: Delta = n/R.")
    print("  Delta = 2/3 then reads '2 steps at radius 3' -- a CURVATURE ratio,")
    print("  not a division of the circle.  This is the only surviving shape, and")
    print("  it is what actually explains (part C) why the phase is a pure number")
    print("  rather than a multiple of pi: turn-fractions carry pi, arc/radius")
    print("  ratios do not.  NOTE: this fixes the FORM, not the counts, and G3's")
    print("  trap still forbids supplying them from the (2,2,3) axis census.\n")

    print("H4. And the physics never sees Delta -- it sees cos(Delta).")
    s = [math.sqrt(m) for m in (ME, MMU, MTAU)]
    M3 = sum(s) / 3
    e3_meas = s[0] * s[1] * s[2] / M3**3
    cosD = math.cos(D)
    e3 = -0.5 + cosD / math.sqrt(2)
    print("  With A^2 = 2 the normalized sqrt-mass triple has e1 = 3, e2 = 3/2")
    print("  fixed, so exactly ONE symmetric function carries the phase:")
    print("    e3 = 27 prod(sqrt m) / (sum sqrt m)^3 = -1/2 + cos(Delta)/sqrt2")
    print(f"       model (Delta = 2/3) : {e3:.9f}")
    print(f"       measured            : {e3_meas:.9f}   ({e3_meas/e3-1:+.2e})")
    print("  Is THAT quantity census-shaped?\n")
    print(f"  {'quantity':>12} {'value':>13}   closest 2^a 3^b 5^c      error")
    for nm, t in (("cos Delta", cosD), ("e3", e3),
                  ("e3^(1/3)", e3 ** (1 / 3)), ("Delta", D)):
        e, a, b, c, v = five_smooth_best(t)
        print(f"  {nm:>12} {t:13.9f}   2^{a:<3d}3^{b:<3d}5^{c:<3d} = {v:11.9f}"
              f"  {e*100:7.4f}%")
    print("\n  Only Delta itself is 5-smooth.  cos(Delta) misses by 0.54%, e3 by")
    print("  0.27% -- the same 0.1-0.6% band as the mass ratios in G1, i.e. the")
    print("  SAME negative.  Passing through the phase did not make the target")
    print("  census-shaped; it moved the non-smoothness into the cosine.\n")
    print("  => G2's 'Delta = 2/3 IS 5-smooth, precisely what a census CAN yield'")
    print("     is CORRECTED: it holds in radians alone, and the invariant the")
    print("     masses are built from is no more census-shaped than they are.")
    print("     The reshaping to one small rational stands; the claim that the")
    print("     rational is thereby within census reach does NOT.")


def main():
    select_topologies()
    koide_audit()
    phase_audit()
    residual_audit()
    delta_equals_q_test()
    delta_two_thirds_audit()
    mass_ratio_map_audit()
    unit_audit()


if __name__ == "__main__":
    main()

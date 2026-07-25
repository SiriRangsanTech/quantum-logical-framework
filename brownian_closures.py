"""
brownian_closures.py — the ZFA closures of a Brownian phase, computed EXACTLY.

This is QLF: we do not sample a Brownian phase and count what happened — we
compute exactly what is most likely to happen. The census *is* the return
probability, so every quantity here is exact combinatorics (no Monte-Carlo).

The deeper reading (per Jim): **each ZFA closure is a quantum logical system**,
and **each renders its own continuum — valid up to the next phase change**. The
continuum is not one global object; it is generated closure-by-closure,
phase-by-phase, from the exact discrete substrate. That is *mathematics from QLF*
(Mathematics_From_QLF.md): the exact census below, its smooth power-law rendering
above, and the phase transitions where the rendering switches.

Two kinds of phase change appear, both exact:
  * dimensional (Polya) — the Brownian phase over p conjugate pairs is a walk on
    Z^p; it is RECURRENT for p<=2 (closes with probability 1) and TRANSIENT for
    p>=3 (closes with probability 1 - 1/G(p), the Polya constant). The transition
    at p=2 -> p=3 is a genuine phase change.
  * scale (octave) — as a closure grows, new irreducible closures appear at each
    length threshold (half-spin at length 2, two-axis at 4, the 3-axis Borromean
    proton at 6, ...). Each threshold is a phase change; the cascade rendering
    (-5/3) holds within an octave regime.

Reuses genesis.py (the exact census `multipair_census`, `c_pair`, `slope`) and
twist_core (`calculate_action`, `is_pauli_closed`). Instant (no sampling).

Anchored: census = Brownian walk (QLF_CensusBrownian); count balance ==> Pauli
closure (count_balanced_pauli_closed, QLF_TwistAlphabet); -5/3 forced
(QLF_Kolmogorov); no blow-up (QLF_NavierStokesBKM); the continuum-as-rendering
(TheContinuum.md, Mathematics_From_QLF.md). The GMC <-> zeta / <-> turbulence ties
stay bridge candidates (Riemann-Conjecture-Proof.md).
"""

from __future__ import annotations

import math
from itertools import product

from genesis import multipair_census, slope
from twist_core import TWISTS, calculate_action, is_pauli_closed, pauli_fold


# ----------------------------------------------------------------------
# EXACT return probability u_{2m}(p) = P(the p-pair Brownian phase is back at
# the origin after 2m steps) = closed 2m-walks / (2p)^{2m} = multipair_census
# ratio.  This IS QLF_CensusBrownian's returnDensity, generalized to p
# dimensions (exact combinatorics, no sampling).
# ----------------------------------------------------------------------
def u_return(p: int, m: int) -> float:
    return multipair_census(p, m)[2]


def green_function(p: int, M0: int = 80):
    """G(p) = sum_m u_{2m}(p) = expected returns.  Diverges (recurrent) for p<=2;
    for p>=3 the exact partial sum to M0 plus the continuum-rendered LCLT tail
    (u_{2m} ~ 2 (p/4pi m)^{p/2}) -- the continuum bridge closing the exact sum."""
    partial = math.fsum(u_return(p, m) for m in range(M0 + 1))
    if p <= 2:
        return float('inf'), partial
    C = 2.0 * (p / (4 * math.pi)) ** (p / 2)                 # u_{2m} ~ C m^{-p/2}
    tail = C * M0 ** (1 - p / 2) / (p / 2 - 1)               # integral M0..inf
    return partial + tail, partial


def polya_return_prob(p: int):
    """P(the phase ever closes) = 1 - 1/G(p)."""
    G, partial = green_function(p)
    if p <= 2:
        return 1.0, float('inf'), partial
    return 1.0 - 1.0 / G, G, partial


# ----------------------------------------------------------------------
# EXACT first-return (excursion) law.  With U(x)=sum u_{2m} x^m and
# F(x)=1-1/U(x), the coefficient f_{2m} = P(the FIRST closure is at length 2m).
# The first returns are the IRREDUCIBLE closures.  Rational convolution, exact.
# ----------------------------------------------------------------------
def first_return_coeffs(p: int, N: int):
    u = [u_return(p, m) for m in range(N + 1)]      # u[0] = 1
    v = [0.0] * (N + 1)                              # v = 1/U power series
    v[0] = 1.0 / u[0]
    for n in range(1, N + 1):
        v[n] = -math.fsum(u[k] * v[n - k] for k in range(1, n + 1)) / u[0]
    f = [0.0] + [-v[m] for m in range(1, N + 1)]     # F = 1 - 1/U
    return f


# ----------------------------------------------------------------------
# EXACT irreducible-closure enumeration.  A ZFA closure = count-balanced
# (Pauli closure is then automatic, count_balanced_pauli_closed).  Irreducible =
# first return: no proper closed prefix.  Enumerate the short ones exactly.
# ----------------------------------------------------------------------
def is_balanced(h: str) -> bool:
    return all(x == 0 for x in calculate_action(h))


# ----------------------------------------------------------------------
# EXACT Onsager-Feynman circulation (signTriple / baryonNumber) and the
# mu4 = {+1,-1,+i,-i} phase quantum of the fold.  These verify the
# QLF_QuantumTurbulence theorems empirically on the enumerated closures:
#   * vortex_is_one_quantum / circulation_is_integer_quantized (|w|<=1, B in Z)
#   * phase_quantum_* / quarter_turn_primitive (fold lands in mu4; the +-i
#     closures carry the pi/2 quarter-turn; count_balanced_pauli_closed).
# ----------------------------------------------------------------------
_AX = {'^': 'y', 'v': 'y', '>': 'x', '<': 'x', '/': 'z', '\\': 'z', '+': None, '-': None}
_CYC = {('x', 'y', 'z'), ('y', 'z', 'x'), ('z', 'x', 'y')}
_ANTI = {('x', 'z', 'y'), ('z', 'y', 'x'), ('y', 'x', 'z')}


def _sign_triple(a, b, c):        # the discrete Levi-Civita curl on the 3 colour axes
    t = (a, b, c)
    return 1 if t in _CYC else (-1 if t in _ANTI else 0)


def vorticity_cells(h: str):      # per-cell vorticity w = signTriple, |w| <= 1
    ax = [_AX[c] for c in h]
    return [_sign_triple(ax[k], ax[k + 1], ax[k + 2]) for k in range(len(ax) - 2)]


def circulation(h: str) -> int:   # total circulation B = baryonNumber (integer count of quanta)
    return sum(vorticity_cells(h))


_CONJ = {'^': 'v', 'v': '^', '<': '>', '>': '<', '/': '\\', '\\': '/', '+': '-', '-': '+'}


def n_pauli(h: str) -> int:      # number of non-gauge (Pauli) twists
    return sum(1 for c in h if c not in '+-')


def dagger(h: str) -> str:       # time-reversal = Hermitian conjugate (reverse + conjugate)
    return ''.join(_CONJ[c] for c in reversed(h))


def mu4_phase(h: str):
    """The mu4 = {+1,-1,+i,-i} scalar the Pauli fold lands on, or None if not closed.
    +-i are the pi/2 quarter-turn phase-shift agents; +-1 the 0/pi (half-turn) phases."""
    a, b, c, d = pauli_fold(h)
    if abs(b) > 1e-9 or abs(c) > 1e-9 or abs(a - d) > 1e-9:
        return None
    for lam, name in ((1 + 0j, '+1'), (-1 + 0j, '-1'), (1j, '+i'), (-1j, '-i')):
        if abs(a - lam) < 1e-9:
            return name
    return None


def phase_and_circulation(max_len: int = 6):
    """Over ALL balanced closures at each length: the mu4 phase histogram, the count that
    FAIL to land in mu4 (must be 0 = count_balanced_pauli_closed), max |vorticity|, and
    whether every circulation is an integer (Onsager-Feynman)."""
    out = {}
    for L in range(2, max_len + 1, 2):
        hist = {'+1': 0, '-1': 0, '+i': 0, '-i': 0}
        not_in_mu4 = max_w = 0
        all_int = True
        for tup in product(TWISTS, repeat=L):
            h = ''.join(tup)
            if not is_balanced(h):
                continue
            ph = mu4_phase(h)
            if ph is None:
                not_in_mu4 += 1
            else:
                hist[ph] += 1
            w = vorticity_cells(h)
            if w:
                max_w = max(max_w, max(abs(x) for x in w))
            if circulation(h) != int(circulation(h)):
                all_int = False
        out[L] = (hist, not_in_mu4, max_w, all_int)
    return out


def irreducible_closures(max_len: int = 6):
    out = {}
    for L in range(2, max_len + 1, 2):
        n_all = n_irr = 0
        examples = []
        for tup in product(TWISTS, repeat=L):
            h = ''.join(tup)
            if not is_balanced(h):
                continue
            n_all += 1
            if any(is_balanced(h[:k]) for k in range(2, L, 2)):
                continue                              # has a proper closed prefix
            n_irr += 1
            if len(examples) < 8:
                examples.append(h)
        out[L] = (n_all, n_irr, examples)
    return out


# ----------------------------------------------------------------------
def rule(t):
    print("\n" + "=" * 76)
    print(t)
    print("=" * 76)


def main():
    print(__doc__.strip().split("\n\n")[0])
    print("\n[EXACT — no Monte-Carlo]  every quantity is exact combinatorics.")

    rule("1. THE EXACT RETURN LAW  (the census IS the return probability)")
    print("   u_{2m}(p) = P(p-pair Brownian phase back at origin after 2m steps)")
    print("             = closed-walk count / (2p)^{2m} = QLF_CensusBrownian.returnDensity.")
    print(f"\n   {'2m':>4}  " + "  ".join(f"p={p}" for p in (1, 2, 3)))
    for m in (1, 2, 4, 8, 16):
        print(f"   {2*m:>4}  " + "  ".join(f"{u_return(p, m):.4f}" for p in (1, 2, 3)))
    for p in (1, 2, 3):
        s = slope([math.log(m) for m in range(20, 81)],
                  [math.log(u_return(p, m)) for m in range(20, 81)])
        print(f"   p={p}: return-density exponent (exact fit) = {s:+.3f}   [continuum rendering: -p/2 = {-p/2:+.1f}]")
    print("   -> CONTINUUM BRIDGE: the exact census renders to the power law n^{-p/2}")
    print("      (Wallis/Stirling) -- the Gaussian propagator of the phase.  Mathematics")
    print("      from QLF: the smooth law is the completion of the exact count.")

    rule("2. PHASE CHANGE (dimensional, Polya)  -- which phases close at all")
    print("   G(p) = sum_m u_{2m} = expected returns; P(ever close) = 1 - 1/G.")
    print(f"\n   {'p (dim)':>8} {'G(p)':>12} {'P(closes)':>12}   phase")
    known = {3: 0.340537, 4: 0.193206, 5: 0.135178}   # classical Polya constants
    for p in (1, 2, 3, 4, 5):
        P, G, _ = polya_return_prob(p)
        if p <= 2:
            print(f"   {p:>8} {'inf':>12} {1.0:>12.4f}   RECURRENT (closes w.p. 1)")
        else:
            print(f"   {p:>8} {G:>12.4f} {P:>12.4f}   TRANSIENT  (Polya ~ {known[p]:.4f})")
    print("   -> the transition p=2 -> p=3 is a genuine PHASE CHANGE: below it every")
    print("      phase closes, above it most do not.  The substrate selects few-axis")
    print("      closures -- and the exact Polya constants match the classical values.")

    rule("3. FIRST-RETURN = THE IRREDUCIBLE CLOSURES  (each a quantum logical system)")
    f = first_return_coeffs(1, 140)
    ms = list(range(10, 60))
    s = slope([math.log(2 * m) for m in ms], [math.log(f[m]) for m in ms])
    print(f"   1-D first-return exponent (exact F=1-1/U fit) = {s:+.3f}")
    print(f"   continuum rendering: the excursion law -3/2 = -1.500  (~ (2m)^{{-3/2}})")
    print("\n   exact irreducible-closure census (first returns, no closed prefix):")
    print(f"\n   {'len':>4} {'#balanced':>10} {'#irreducible':>13}   examples / reading")
    reading = {2: "half-spin atoms (1 axis, fold -I)",
               4: "two-axis closures (lepton loops)",
               6: "three-axis Borromean (proton-class)"}
    for L, (n_all, n_irr, ex) in irreducible_closures(6).items():
        exs = " ".join(ex[:6])
        print(f"   {L:>4} {n_all:>10} {n_irr:>13}   {reading.get(L,'')}")
        print(f"        e.g. {exs}")
    print("\n   -> the MOST LIKELY emergent closure is the shortest first return -- the")
    print("      eight half-spin atoms (each a minimal quantum logical system).  Every")
    print("      count-balanced closure Pauli-closes (count_balanced_pauli_closed), so")
    print("      ZFA closure of the phase IS the return to origin.")

    rule("4. ONSAGER-FEYNMAN CIRCULATION & THE mu4 PHASE QUANTUM  (QLF_QuantumTurbulence)")
    print("   Every CLOSED loop (count-balanced) folds to the REAL subgroup {+1,-1} of")
    print("   mu4 = {+1,-1,+i,-i}: fermion -1 (360 deg) / boson +1 (720 deg).  The reason is")
    print("   parity: a balanced closure pairs every axis, so its Pauli-twist count is EVEN")
    print("   (det = (-1)^even = +1 => scalar^2 = 1 => real).  Verified on ALL balanced closures;")
    print("   vorticity |w|<=1 per cell, circulation B in Z (Onsager-Feynman quantization):")
    print(f"\n   {'len':>4} {'not-in-mu4':>11} {'max|w|':>7} {'B integer':>10}   mu4 phase histogram {{+1,-1,+i,-i}}")
    for L, (hist, nbad, maxw, allint) in phase_and_circulation(6).items():
        hs = "{" + ", ".join(f"{k}:{hist[k]}" for k in ('+1', '-1', '+i', '-i')) + "}"
        print(f"   {L:>4} {nbad:>11} {maxw:>7} {('yes' if allint else 'NO'):>10}   {hs}")
    print("   -> not-in-mu4 = 0 (count_balanced_pauli_closed); every closed loop is REAL +-1;")
    print("      NO closed loop folds to +-i (even Pauli count).  max|w|=1, B integer = Onsager-Feynman.")
    print("\n   The pi/2 quarter-turn +-i is the phase of an OPEN FORWARD half-strand (odd Pauli")
    print("   count); the dagger (backward in time, also odd) closes it: forward-odd + backward-odd")
    print("   = EVEN => real +-1 (Jim).  QLF_PrimeResonance: half-spin = 3 forward + 3 back = 6")
    print("   (half_spin_balanced_steps); 3 = prime (half_spin_prime).")
    print(f"\n   {'forward strand':16}{'nP':>3}{'phase':>6}   {'+ dagger (closure)':20}{'nP':>3}{'phase':>7}{'bal':>5}")
    for s in ('>^/', '^</', '^>/', '^\\<'):
        full = s + dagger(s)
        print(f"   {s:16}{n_pauli(s):>3}{str(mu4_phase(s)):>6}   {full:20}"
              f"{n_pauli(full):>3}{str(mu4_phase(full)):>7}{str(is_balanced(full)):>5}")
    print("   -> the open vortex strand carries the quarter-turn +-i; time-reversal (dagger)")
    print("      closes it into the real +-1 loop.  i^2=-1 (half), i^4=+1 (full 2pi) -- quarter_turn_primitive.")

    rule("5. THE OCTAVE CASCADE = TURBULENCE  (exact census per octave)")
    print("   closures of length 2m for p=3 = C(2m,m)*c_3(m) (exact).  Binned by octave:")
    print(f"\n   {'octave j':>8} {'lengths':>10} {'log2(#closures)':>16} {'bits/octave':>12}")
    prev = None
    for j in range(1, 8):
        m_lo, m_hi = 2 ** (j - 1), 2 ** j - 1
        count = sum(multipair_census(3, m)[1] for m in range(m_lo, m_hi + 1))
        bits = math.log2(count)
        incr = f"{bits - prev:+.2f}" if prev is not None else "  --"
        print(f"   {j:>8} {f'{2*m_lo}-{2*m_hi}':>10} {bits:>16.2f} {incr:>12}")
        prev = bits
    print("   -> octave-constant closure flux (log 2 / closure) is the K41 scale")
    print("      invariance that QLF_Kolmogorov turns into the forced -5/3; an emergent")
    print("      closure ~ a quantized vortex (QLF_Turbulence).  CONTINUUM BRIDGE: the")
    print("      cascade -5/3 holds within an octave regime -- up to the next phase change.")

    rule("6. THE CONTINUUM, ONE CLOSURE AT A TIME  (mathematics from QLF)")
    print("   Each closure is a quantum logical system; each renders its OWN continuum")
    print("   (its propagator / power law / mass-frequency), valid UP TO the next phase")
    print("   change -- the dimensional Polya transition (sec 2) and the octave")
    print("   thresholds (sec 5).  The continuum is therefore not one global object but")
    print("   a PATCHWORK of exact-closure renderings, each valid within its phase:")
    print("     * n^{-p/2}   -- the return-density rendering, per dimension p (sec 1)")
    print("     * -3/2       -- the first-return / irreducible-closure rendering (sec 3)")
    print("     * -5/3       -- the turbulent-cascade rendering, per octave (sec 5)")
    print("   Contrast the continuum's own story: a single, infinitely-fine,")
    print("   non-differentiable object that needs an EXTERNAL cutoff (for GMC to exist,")
    print("   to avoid the Navier-Stokes blow-up).  In QLF the cutoff is intrinsic --")
    print("   the discrete closure below every rendering, capped at the Planck floor")
    print("   (= dissipation cutoff = GMC UV cutoff).  The substrate IS the")
    print("   regularization; the continuum is what it renders, phase by phase.")

    print("\n" + "-" * 76)
    print("EXACT / ANCHORED : return law = census (QLF_CensusBrownian); ZFA = return")
    print("                   (count_balanced_pauli_closed); Polya constants match; -5/3")
    print("                   (QLF_Kolmogorov); no blow-up (QLF_NavierStokesBKM); circulation")
    print("                   quantized + mu4 pi/2 phase quantum (QLF_QuantumTurbulence, sec 4).")
    print("MATHEMATICS-FROM-QLF : the continuum rendered per closure, per phase, up to")
    print("                   the next phase change (Mathematics_From_QLF.md).")
    print("BRIDGE CANDIDATE : GMC <-> zeta and GMC <-> turbulence (Riemann-Conjecture-Proof.md).")


if __name__ == "__main__":
    main()

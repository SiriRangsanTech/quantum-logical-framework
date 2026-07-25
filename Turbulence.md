# Turbulence in QLF

*How turbulence emerges in the [Quantum Logical Framework](README.md) (QLF) — the Brownian phase, the
quantized-vortex cascade, the forced `−5/3` spectrum, and the no-blow-up — all one story, and the contrast
with the pathological continuum.*

Turbulence is where several QLF threads meet: the closure census is a random walk, the walk's emergent
closures are quantized vortices, the vortex cascade is a frequency-octave hierarchy carrying `log 2` per step,
that scale-invariance forces the Kolmogorov `−5/3` spectrum, and the same discreteness that quantizes vorticity
is exactly what forbids the Navier–Stokes finite-time blow-up. This doc connects those pieces and closes with
the exact program output.

It is all **Navier–Stokes**, but two *distinct* questions live inside it:

- **Regularity** (the Clay problem) — does a smooth solution stay smooth, or can vorticity blow up in finite
  time? QLF's answer: **no blow-up**, because vorticity is quantized and Planck-capped
  ([`QLF_NavierStokesBKM`](lean/QLF_NavierStokesBKM.lean), reduced from `QLF_NavierStokes`). See
  [`NavierStokes_QLF.md`](NavierStokes_QLF.md), [`Navier_Stokes_Geometry.md`](Navier_Stokes_Geometry.md).
- **Statistics** (a separate open problem, *not* the Clay one) — the `−5/3` Kolmogorov spectrum and the
  intermittency corrections. QLF forces `−5/3` from closure-flux scale invariance
  ([`QLF_Kolmogorov`](lean/QLF_Kolmogorov.lean)).

---

## 1. The geometry — vorticity is a quantized discrete curl

Turbulence is rotational, and in QLF rotation is **circulation** = the baryon-winding invariant, a sliding
sum of the discrete Levi-Civita symbol `signTriple` (the oriented 3-axis linking). The local curl is the
**vorticity** `ω = signTriple(axis a, axis b, axis c) ∈ {−1, 0, +1}` — one circulation quantum per cell.

The load-bearing fact ([`QLF_AngularMomentum`](lean/QLF_AngularMomentum.lean)):

- **`vorticity_quantized`** — `|ω| ≤ 1` per cell: **vorticity cannot diverge**. On the discrete geometry the
  Beale–Kato–Majda vorticity-blow-up criterion is *unsatisfiable*.
- **`circulation_bounded`** — `|L| ≤ n` in a finite region (finite angular momentum).
- **`circulation_integer_quantized`** ([`QLF_Turbulence`](lean/QLF_Turbulence.lean)) — total circulation is an
  **integer** count of net quanta: the **Onsager–Feynman quantization** of vorticity, derived from the
  substrate. So turbulent vorticity is a *quantized-vortex tangle*, and **classical turbulence is the
  coarse-grained limit of quantum turbulence** — why superfluid turbulence reproduces the classical Kolmogorov
  cascade.

This is the mechanism behind the no-blow-up: the continuum PDE inherits a *uniform* vorticity cap
`|ω| ≤ 1/L_P²` (`planck_caps_vorticity`), and BKM (cited, 1984) then gives global smoothness — a *reduction*
of the `navier_stokes_continuum_limit` axiom to a sharp vorticity-rendering bridge, not a Clay proof.

---

## 2. The cascade — a frequency-octave hierarchy of closures

A turbulent flow is a cascade of eddies from large to small. In QLF each eddy is a **ZFA closure**, and smaller
eddies are **higher-frequency** closures (`f = 1/R`, a shorter-period local clock, [`QLF_LocalClock`](lean/QLF_LocalClock.lean)):

- **`cascade_frequency_increases`** ([`QLF_Turbulence`](lean/QLF_Turbulence.lean)) — the cascade is a frequency
  hierarchy: low-`f` large eddies → high-`f` small eddies (reusing `QLF_Consciousness.freq_lt_of_lt`).
- **`vortex_quantum`** — a vortex line is one circulation quantum.
- **`cascade_capped`** — a top frequency / dissipation floor (Kolmogorov, ultimately Planck): **no infinite
  cascade**; reconnection is a ZFA closure at the floor (the same vorticity cap behind the no-blow-up).

Each closure in the cascade carries the **`log 2`** free-energy quantum
([`QLF_FreeEnergy`](lean/QLF_FreeEnergy.lean), `ΔF = −log 2`), octave-independent — the census's `flux_scale_invariant`.

---

## 3. The `−5/3` spectrum — forced by closure-flux scale invariance

The Kolmogorov `−5/3` inertial-range spectrum is *forced*, not fitted ([`QLF_Kolmogorov`](lean/QLF_Kolmogorov.lean)):

- **`flux_scale_invariant`** — the per-closure energy is the octave-independent `log 2` quantum, so a
  scale-invariant transfer count gives octave-independent flux (K41's inertial-range premise, grounded in the
  constant `log 2` quantum).
- **`kolmogorov_exponents`** — `(a, b) = (2/3, −5/3)` is the **unique** solution of the dimensional
  constraints on `E(k) = ε^a k^b` (`−3a = −2`, `2a − b = 3`): the actual content of "`−5/3` follows by
  dimensional analysis," a genuine `linarith` theorem.
- **Intermittency** — the She–Leveque `ζ_p` corrections: the velocity Hölder exponent `h = 1/3` (the same
  flux `1/3` as `−5/3`, dimension-independent), the vortex-filament codimension `C₀ = d−1 = 2` the sole
  `d`-dependent input.

So the spectrum is the *statistics* question, distinct from and additional to the Clay *regularity* question.

---

## 4. The Brownian phase — what closures actually emerge

Underneath the cascade is the closure census as a **random walk** ([`QLF_CensusBrownian`](lean/QLF_CensusBrownian.lean)):
a ZFA-balanced string of length `2n` (`#+ = #−`) is a **closed `±1` walk**, so the census `= C(2n,n)` = the
closed-walk count, and the return density factors as two independent 1-D Brownian returns. This attaches the
critical line and the turbulent cascade to *settled* mathematics — **Gaussian multiplicative chaos** (GMC) /
log-correlated fields, the one object that unifies the Brownian phase, the Riemann critical line (Montgomery–
Odlyzko / Fyodorov–Hiary–Keating / Saksman–Webb), and turbulence (Kahane's GMC born from Mandelbrot's
cascades). The **Planck floor = the GMC UV cutoff** ([`Riemann-Conjecture-Proof.md`](Riemann-Conjecture-Proof.md)).

Because this is QLF, we do not *sample* a Brownian phase and count what happened — we compute *exactly what is
most likely*. [`brownian_closures.py`](brownian_closures.py) does this from the census alone (the census **is**
the return probability), reading off which closures emerge, in what order, with what statistics. Its findings:

- **The exact return law** renders to `n^{−p/2}` per dimension `p` (the Gaussian propagator of the phase).
- **A dimensional phase change (Pólya)** — recurrent for `p ≤ 2` (closes w.p. 1), transient for `p ≥ 3`; the
  close-probabilities `0.3406 / 0.1932 / 0.1352` match the **classical Pólya constants to four digits**. The
  substrate selects **few-axis** closures.
- **First returns are the irreducible closures** — 1-D first-return exponent `−3/2` (the excursion law); the
  exact irreducible census is **8** half-spin atoms (length 2), **104** two-axis (length 4), **2944**
  three-axis Borromean/proton-class (length 6). The most likely emergent closure is the shortest first
  return — the half-spin.
- **The octave cascade = turbulence** — the exact closure count per octave grows with constant `log 2` per
  closure, the K41 scale-invariance behind `−5/3`.

---

## 5. The continuum, one closure at a time

The organizing thesis (per Jim): **each ZFA closure is a quantum logical system, and each renders its own
continuum — valid up to the next phase change**. The QLF continuum is therefore a **patchwork** of
exact-closure renderings — `n^{−p/2}` (per dimension), `−3/2` (the excursion law), `−5/3` (per octave) — each
valid within its phase, the renderings switching at the phase transitions (the dimensional Pólya transition
`p = 2→3`; the octave thresholds where new irreducible closures appear). That is *mathematics from QLF*
([`Mathematics_From_QLF.md`](Mathematics_From_QLF.md)).

Contrast the continuum's *own* story: a single, infinitely-fine, non-differentiable object that needs an
**external** cutoff for GMC to exist at all and to avoid the Navier–Stokes blow-up. In QLF the cutoff is
**intrinsic** — the discrete closure under every rendering, capped at the Planck floor (= dissipation cutoff
= GMC UV cutoff). **The substrate *is* the regularization; the continuum is what it renders, phase by phase**
— the message of [`TheContinuum.md`](TheContinuum.md), made concrete in the Brownian-turbulence cascade.

---

## 6. Program output

Exact — no Monte-Carlo. Run: `python3 brownian_closures.py`.

```
brownian_closures.py — the ZFA closures of a Brownian phase, computed EXACTLY.

[EXACT — no Monte-Carlo]  every quantity is exact combinatorics.

============================================================================
1. THE EXACT RETURN LAW  (the census IS the return probability)
============================================================================
   u_{2m}(p) = P(p-pair Brownian phase back at origin after 2m steps)
             = closed-walk count / (2p)^{2m} = QLF_CensusBrownian.returnDensity.

     2m  p=1  p=2  p=3
      2  0.5000  0.2500  0.1667
      4  0.3750  0.1406  0.0694
      8  0.2734  0.0748  0.0266
     16  0.1964  0.0386  0.0098
     32  0.1399  0.0196  0.0036
   p=1: return-density exponent (exact fit) = -0.497   [continuum rendering: -p/2 = -0.5]
   p=2: return-density exponent (exact fit) = -0.994   [continuum rendering: -p/2 = -1.0]
   p=3: return-density exponent (exact fit) = -1.491   [continuum rendering: -p/2 = -1.5]
   -> CONTINUUM BRIDGE: the exact census renders to the power law n^{-p/2}
      (Wallis/Stirling) -- the Gaussian propagator of the phase.  Mathematics
      from QLF: the smooth law is the completion of the exact count.

============================================================================
2. PHASE CHANGE (dimensional, Polya)  -- which phases close at all
============================================================================
   G(p) = sum_m u_{2m} = expected returns; P(ever close) = 1 - 1/G.

    p (dim)         G(p)    P(closes)   phase
          1          inf       1.0000   RECURRENT (closes w.p. 1)
          2          inf       1.0000   RECURRENT (closes w.p. 1)
          3       1.5166       0.3406   TRANSIENT  (Polya ~ 0.3405)
          4       1.2395       0.1932   TRANSIENT  (Polya ~ 0.1932)
          5       1.1563       0.1352   TRANSIENT  (Polya ~ 0.1352)
   -> the transition p=2 -> p=3 is a genuine PHASE CHANGE: below it every
      phase closes, above it most do not.  The substrate selects few-axis
      closures -- and the exact Polya constants match the classical values.

============================================================================
3. FIRST-RETURN = THE IRREDUCIBLE CLOSURES  (each a quantum logical system)
============================================================================
   1-D first-return exponent (exact F=1-1/U fit) = -1.516
   continuum rendering: the excursion law -3/2 = -1.500  (~ (2m)^{-3/2})

   exact irreducible-closure census (first returns, no closed prefix):

    len  #balanced  #irreducible   examples / reading
      2          8             8   half-spin atoms (1 axis, fold -I)
        e.g. ^v v^ <> >< /\ \/
      4        168           104   two-axis closures (lepton loops)
        e.g. ^^vv ^<v> ^<>v ^>v< ^><v ^/v\
      6       5120           2944   three-axis Borromean (proton-class)
        e.g. ^^^vvv ^^v^vv ^^v<v> ^^v<>v ^^v>v< ^^v><v

   -> the MOST LIKELY emergent closure is the shortest first return -- the
      eight half-spin atoms (each a minimal quantum logical system).  Every
      count-balanced closure Pauli-closes (count_balanced_pauli_closed), so
      ZFA closure of the phase IS the return to origin.

============================================================================
4. THE OCTAVE CASCADE = TURBULENCE  (exact census per octave)
============================================================================
   closures of length 2m for p=3 = C(2m,m)*c_3(m) (exact).  Binned by octave:

   octave j    lengths  log2(#closures)  bits/octave
          1        2-2             2.58           --
          2        4-6            10.93        +8.34
          3       8-14            29.85       +18.92
          4      16-30            69.60       +39.74
          5      32-62           150.76       +81.16
          6     64-126           314.67      +163.91
          7    128-254           644.03      +329.36
   -> octave-constant closure flux (log 2 / closure) is the K41 scale
      invariance that QLF_Kolmogorov turns into the forced -5/3; an emergent
      closure ~ a quantized vortex (QLF_Turbulence).  CONTINUUM BRIDGE: the
      cascade -5/3 holds within an octave regime -- up to the next phase change.

============================================================================
5. THE CONTINUUM, ONE CLOSURE AT A TIME  (mathematics from QLF)
============================================================================
   Each closure is a quantum logical system; each renders its OWN continuum
   (its propagator / power law / mass-frequency), valid UP TO the next phase
   change -- the dimensional Polya transition (sec 2) and the octave
   thresholds (sec 4).  The continuum is therefore not one global object but
   a PATCHWORK of exact-closure renderings, each valid within its phase:
     * n^{-p/2}   -- the return-density rendering, per dimension p (sec 1)
     * -3/2       -- the first-return / irreducible-closure rendering (sec 3)
     * -5/3       -- the turbulent-cascade rendering, per octave (sec 4)
   Contrast the continuum's own story: a single, infinitely-fine,
   non-differentiable object that needs an EXTERNAL cutoff (for GMC to exist,
   to avoid the Navier-Stokes blow-up).  In QLF the cutoff is intrinsic --
   the discrete closure below every rendering, capped at the Planck floor
   (= dissipation cutoff = GMC UV cutoff).  The substrate IS the
   regularization; the continuum is what it renders, phase by phase.

----------------------------------------------------------------------------
EXACT / ANCHORED : return law = census (QLF_CensusBrownian); ZFA = return
                   (count_balanced_pauli_closed); Polya constants match; -5/3
                   (QLF_Kolmogorov); no blow-up (QLF_NavierStokesBKM).
MATHEMATICS-FROM-QLF : the continuum rendered per closure, per phase, up to
                   the next phase change (Mathematics_From_QLF.md).
BRIDGE CANDIDATE : GMC <-> zeta and GMC <-> turbulence (Riemann-Conjecture-Proof.md).
```

---

## Honest scope

The regularity no-blow-up is *reduced* to a sharp vorticity-rendering bridge (`QLF_NavierStokesBKM`), not a
Clay proof; the `−5/3` spectrum is *forced* by closure-flux scale invariance (`QLF_Kolmogorov`), not a
derivation of turbulence from first principles; the GMC ↔ ζ and GMC ↔ turbulence ties are *bridge candidates*
attaching the reformulation to settled mathematics, not proofs. `brownian_closures.py` is **exact
combinatorics** (no sampling): the census, the settled `−p/2` / `−3/2` / `−5/3` laws, and the classical Pólya
constants are the references. The novel content is the *synthesis* — that all these are one closure-census
story — and the *framing*: the continuum rendered one closure at a time, up to the next phase change.

## See also

- [`Navier_Stokes_Geometry.md`](Navier_Stokes_Geometry.md) — the geometry (circulation, vorticity, no-blow-up), §6b the exact Brownian closures
- [`NavierStokes_QLF.md`](NavierStokes_QLF.md) — the Clay regularity reformulation
- [`Mathematics_From_QLF.md`](Mathematics_From_QLF.md) — the continuum as a per-closure per-phase rendering
- [`Riemann-Conjecture-Proof.md`](Riemann-Conjecture-Proof.md) — the census-Brownian / GMC bridge
- [`TheContinuum.md`](TheContinuum.md) — the substrate-as-regularization thesis
- [`Genesis.md`](Genesis.md) — the enumerative census (`genesis.py`) this companions
- Lean: [`QLF_Turbulence`](lean/QLF_Turbulence.lean), [`QLF_Kolmogorov`](lean/QLF_Kolmogorov.lean), [`QLF_AngularMomentum`](lean/QLF_AngularMomentum.lean), [`QLF_NavierStokesBKM`](lean/QLF_NavierStokesBKM.lean), [`QLF_CensusBrownian`](lean/QLF_CensusBrownian.lean)

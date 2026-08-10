# CLAUDE.md — Quantum Logical Framework

Project context for Claude Code sessions. Read this before making any changes.

---

## Project overview

**Quantum Logical Framework (QLF)** is a formal proof system machine-verified in Lean 4 across **184 modules with zero `sorry` blocks**. It encodes quantum mechanics and spacetime dynamics using phase-string combinatorics (ZFA — Zero-phase Flux Algebra).

Core claim: *ZFA balance is the selection principle for physical reality.* Every terminating computation is a ZFA string; every ZFA string is symmetric (lies on the critical line). The Church-Turing universe filtered to ZFA-balanced strings is our physical universe.

**Lean is NOT installed locally.** CI (GitHub Actions) is the only way to verify Lean changes. Push to GitHub and wait for CI before reporting success.

---

## 184 active modules

In `lean/`, registered in `lakefile.lean` roots array (in build order). For fuller per-module descriptions + the complete key-theorem lists, see [`lean/README.md`](lean/README.md).

| Module | What it proves |
|---|---|
| `QLF_Axioms` | Types, counting, pruning, ZFA definition |
| `QLF_Combinatorics` | Phase-string generation helpers |
| `QLF_QuCalc` | Phase-generation engine |
| `QLF_Universality` | Every terminating computation IS a ZFA string (Church-Turing) |
| `QLF_Critical_Line` | ZFA → symmetry bridge |
| `QLF_Spectral` | Hermitian spectral projectors |
| `QLF_Riemann` | Riemann hypothesis program |
| `SpacetimeDynamics` | Pauli-basis 2×2 Hermitian matrices |
| `RhoQuCalc` | ρ-process algebra |
| `ZFAEventDynamics` | ZFA event dynamics |
| `AgeOfUniverse` | Cosmological age from ZFA event rate |
| `ER_EPR_QLF` | ER=EPR from the substrate core — zero axioms |
| `PauliExclusion` | Fermionic statistics via matrix commutator |
| `StringTheoryQLF` | String modes |
| `MTheoryQLF` | M-theory |
| `BraKetRhoQuCalc` | Bra-ket ↔ RhoQuCalc correspondence |
| `QLF_FreeEnergy` | Per-event ΔF = -log 2 at half-spin ZFA closure |
| `QLF_Pauli` | 4-element Pauli scalar group {±I, ±iI} |
| `QLF_TwistAlphabet` | 8-twist alphabet with σ-matrix mapping |
| `QLF_VacuumAlignment` | Vacuum-alignment TOE-completing principle (KL saturation ≡ ZFA closure, per-event + trajectory) |
| `QLF_RhoProcessBridge` | Every constructible RhoProcess's event trajectory saturates the cumulative info bound |
| `QLF_LocalClock` | A depth-`R` Markov blanket IS a local clock (Kitada local time) |
| `QLF_EinsteinGeometricFactor` | Einstein `8π = 4π·2` (boundary solid angle × Hermitian-pair degeneracy) |
| `QLF_SubstrateLightSpeed` | `c = L_Planck/τ_Planck` via ρ-cancellation → local Lorentz invariance |
| `QLF_FineStructureSubstrate` | α = 1/137 from substrate combinatorics, zero free params |
| `QLF_LenzMassRatio` | `m_p/m_e = 6π⁵ = \|S₃\|·π⁵`, 0.002% |
| `QLF_PionMassRatio` | Charged-pion/electron ratio `m_π±/m_e = \|S₂\|/α = 2/α = 274` (`pion_electron_ratio_eq`), vs measured 273.1 (0.3%) |
| `QLF_QuantumBlackHole` | Every hadron (meson + baryon) is a Markov-blanket quantum black hole |
| `QLF_DarkMatter` | Dark matter = denser logic near masses |
| `QLF_HorizonTemperature` | Unruh/Hawking/de Sitter from one substrate relation |
| `QLF_Casimir` | The Casimir effect — finite census, `1/a⁴` scaling, accelerated-boundary Unruh tie |
| `QLF_MondScale` | The `2π` in `a₀ = cH₀/(2π)` derived — the ZFA closure-loop period |
| `QLF_MondNu` | The MOND interpolation function `ν` is the unique closure-balance form |
| `QLF_RarBalance` | The closure-balance conjunction derived |
| `QLF_AlgebraEmergence` | A group emerges from the substrate as a genuine Mathlib structure |
| `QLF_BorromeanAngles` | The 5-angle count `5 = 3 + 2` (Jacobi internal + chirality-mixing) |
| `QLF_EulerMascheroni` | γ as the harmonic excess `H_N − ln N` of the ZFA ensemble |
| `QLF_RiemannZeta` | Substrate ↔ ζ bridge: `γ_QLF` = ζ's Laurent constant at `s=1` |
| `QLF_RiemannMRE` | MRE bridge — — a constructive scaffold for the Riemann boundary |
| `QLF_DiracCorrection` | Hydrogen fine structure (α² kinematic/spin-orbit/Darwin) |
| `QLF_LambShift` | Lamb-shift prefactor `4/(3πn³) = 4·(2/3)·(1/2π)·(1/n³)` |
| `QLF_GMinusTwo` | Electron `g−2`: `a_e = α/2π` (Schwinger), 0.2% |
| `QLF_GravityFromDelay` | Newton's law + `G = L_P²c³/ℏ` from holographic delay |
| `QLF_HolographicDensity` | Naming η and quantifying the Bekenstein–Hawking residual exactly |
| `QLF_GravitationalCoupling` | The strength of gravity `α_G = exp(−28π)` from the `14π` hierarchy |
| `QLF_PlanckScale` | The Planck length is the closure floor by construction, not a posited input |
| `QLF_LoopQuantumGravity` | QLF's substrate is a spin network of half-spin (j=½) ZFA closures |
| `QLF_MercuryPerihelion` | Perihelion advance 42.99″/century (0.03%) |
| `QLF_CosmologicalConstant` | `Ω_Λ = log 2` (1.2%), closing the 10¹²² vacuum catastrophe |
| `QLF_PrimordialMarkovBlanket` | Markov blankets as Fuller geodesic spheres |
| `QLF_Koide` | Koide `Q = 2/3` follows by construction from `N=3 ∧ A²=2` ⇒ `m_τ` to 0.006% |
| `QLF_Generations` | Three fermion generations = the 3 spatial axes |
| `QLF_WeinbergAngle` | Weak mixing angle `sin²θ_W = 3/8` at the unification scale |
| `QLF_RunningCouplings` | One-loop RG structure + substrate UV-finiteness |
| `QLF_GravitationalWaves` | GWs + the linearized wave equation. — Massless transverse ripple ⇒ speed `c` |
| `QLF_FlavorMixing` | CKM/PMNS parameter count + Kobayashi–Maskawa |
| `QLF_CondensedMatter` | Quantum Hall resistance from α + Cooper pairs as bosons |
| `QLF_CosmicInflation` | Inflation (past) + gravity (present) as one event duality |
| `QLF_StrongCP` | `θ̄ = 0` without an axion. — The strong-CP θ-term is a CP-odd topological winding |
| `QLF_Baryogenesis` | The three Sakharov conditions are met ⟹ matter excess is generic |
| `QLF_Nucleosynthesis` | Primordial helium fraction. — Every surviving neutron → deepest light closure ⁴He, so `Y_p = 2r/ |
| `QLF_MassSpectrum` | The absolute spectrum is one scale, exponentially generated |
| `QLF_BetaFunction` | QCD `b₀ = 7` from the substrate. — The one-loop β-coefficient `b₀ = 11N_c/3 − 2n_f/3` with `N_c = color_count = substrate_spatial_dimension = 3` |
| `QLF_Anyons` | Fractional statistics from a 2D braiding phase |
| `QLF_MuonG2` | Placing the muon `g−2` honestly. — Leading `a_μ = α/2π = a_e` |
| `QLF_AlphaS` | The hierarchy from one integer. — Closes `QLF_MassSpectrum`'s last input: posit `α_s |
| `QLF_EinsteinEquations` | The Einstein equations as the substrate's equation of state (Jacobson 1995) |
| `QLF_Fusion` | The β⁺ keystone — joining two Markov blankets needs distinguishability |
| `QLF_NoFreeDuplication` | The substrate forbids free Banach–Tarski duplication |
| `QLF_InfoSynthesis` | Information synthesis as disjunctive (OR) closure |
| `QLF_MuonCatalysis` | Lepton-catalyzed fusion is QLF cold fusion (rate, not necessity) |
| `QLF_LoopClosure` | The closure machine vs the `2π` rendering |
| `QLF_ReachableEvent` | Closure-reachability as a pre-geometric Lean object |
| `QLF_SU5` | The `5̄⊕10` generation as the antisymmetric content of QLF's `3⊕2` |
| `QLF_CausalInterval` | Number↔volume — the curvature side of the Einstein equations begins |
| `QLF_CausalDimension` | Dimension from combining histories (number↔volume reads the dimension) |
| `QLF_CausalContinuum` | The statistical continuum limit of the BD curvature operator — Einstein curvature side in the Millennium pattern |
| `QLF_OrderMetric` | The order → metric reconstruction — *Order + Number = Geometry |
| `QLF_HorizonClosure` | Closure is horizon-relative; observation is bounded closure |
| `QLF_MaxwellCurl` | The Maxwell curl laws as flux-conservation closure over the event sequence |
| `QLF_Consciousness` | The frequency-hierarchy of resonant closures — a QLF model of consciousness |
| `QLF_PrimeResonance` | Prime frequencies are the irreducible modes; the half-spin prime-3 keystone |
| `QLF_AtomicStructure` | What the substrate geometry says about atomic structure |
| `QLF_AngularMomentum` | Angular momentum as circulation; the Navier–Stokes geometry and no-blow-up |
| `QLF_NavierStokesBKM` | Reducing `navier_stokes_continuum_limit` via the Planck vorticity cap + Beale–Kato–Majda |
| `QLF_Turbulence` | Turbulence as a quantized-vortex tangle; the cascade as a frequency hierarchy |
| `QLF_Kolmogorov` | The flux-invariance lemma + the forced `−5/3` exponent |
| `QLF_QuantumTurbulence` | The superfluid/quantum-turbulence dynamical picture, proven |
| `QLF_HiggsTurbulence` | The Higgs as the radial mode of a quantum-turbulent gauge-fold vacuum |
| `QLF_TopYukawaRunning` | The top-Yukawa running sector of the Higgs quartic |
| `QLF_ClosureBinding` | How closures bind — the structure of the substrate four-fermion interaction |
| `QLF_CondensateGap` | The interacting closure-binding condenses — an NJL gap equation with the census as the loop |
| `QLF_PrimeCascadeDecay` | Turbulence forces decay — the prime phase-slip + the cascade dump |
| `QLF_NeutrinoOscillation` | Flavor oscillation as a norm-preserving closure precession |
| `QLF_LogicalBang` | The logical bang + nested phases (drawn from the inside) |
| `QLF_PiRational` | The substrate π-approximant is rational; the interface is `Real`-free |
| `QLF_ShannonOverfit` | The reals over-parameterize physics — non-identifiability, a Shannon proof |
| `QLF_FQHE` | The fractional-quantum-Hall stability ordering, made rigorous |
| `QLF_ContradictionReceipt` | A contradiction receives no receipt |
| `QLF_EntropyUniqueness` | The closure measure is forced, not chosen |
| `QLF_Identifiability` | Capacity bounds distinguishability; the unconstrained tail |
| `QLF_CensusShannon` | Information composes as counts multiply |
| `QLF_BornProbability` | Count-ratio Born probabilities satisfy the probability axioms |
| `QLF_AlphaRigidity` | The elementarity spine of α-rigidity |
| `QLF_Reconstruction` | The reconstruction theorem's entropy-uniqueness wing (finite lattice) |
| `QLF_EmergenceChain` | The emergence forcing chain, assembled (reuse-only) |
| `QLF_PostulateReduction` | The five reconstruction postulates collapse into one-and-a-half |
| `QLF_ProperInvolution` | The substrate dagger is a proper involution — the (a1) rung of the orthomodular reduction |
| `QLF_QuantumLogic` | The substrate realizes the minimal quantum logic `MO2` — orthomodular, non-distributive, no bridge axiom |
| `QLF_StabilizerZi` | Stabilizer / Clifford evolution never leaves ℤ[i] |
| `QLF_CensusWalk` | Lean-anchors genesis.py §2 (the `−p/2` spectral exponent) at low orders |
| `QLF_HarmonicClosure` | Reality & constructable truth as the closing spectrum of frequency-component closures |
| `QLF_DynamicalDarkEnergy` | `ρ_Λ ∝ H²` ⟹ QLF's dark energy is dynamical, not a constant Λ |
| `QLF_CurvatureLie` | Curvature from one-bit orthogonality IS the su(2) Lie bracket |
| `QLF_KnotInvariant` | Embedded ZFA closures are knots/links — the Kauffman-lineage reading |
| `QLF_ReidemeisterLinking` | The crossing-sign Levi-Civita algebra + the Reidemeister invariances of the linking number |
| `QLF_LinkDiagram` | A Gauss-code link diagram + full R1/R2/R3 invariance of the linking number |
| `QLF_KauffmanBracket` | The Kauffman bracket as a firebreak state-sum — the bridge's discrete side, built |
| `QLF_TorusBracket` | A concrete planar loop-count — `bracket` computes named knots |
| `QLF_PlanarBracket` | The general planar loop-tracer — `bracket` computes any knot from its arc code |
| `QLF_Firebreak` | ZFA closure as the firebreak on path-integral possibility-space |
| `QLF_GaugeUnification` | One force, three projections — EM is the abelian limit |
| `QLF_GaugeHolonomy` | The gauge *force* is the holonomy of the closure connection |
| `QLF_WeakChirality` | The weak force is chiral; only the left-handed neutrino enters the blanket |
| `QLF_Confinement` | Color confinement = the singlet-closure obstruction |
| `QLF_HiggsMechanism` | Mass is the gauge-fold delay (the constructive Higgs) |
| `QLF_CKM` | Flavor mixing is unitary = closure. — Strengthens `QLF_FlavorMixing`'s count with the dynamical constraint: the CKM matrix is **unitary**, and… |
| `QLF_QuarkMass` | Quark masses are not closure observables; hadron masses are |
| `QLF_QuarkStructure` | The Borromean three-colour necessity, proven |
| `QLF_NeutrinoMass` | The neutrino mass is Majorana; only the self-conjugate fermion can be |
| `QLF_PMNS` | Lepton mixing is unitary, with extra Majorana phases |
| `QLF_Supersymmetry` | The supercharge is the half-spin shift; `{Q,Q†}=2P` is two half-spins closing an event |
| `QLF_CensusBrownian` | The closure census is a random walk — the Riemann GMC bridge, discrete side |
| `QLF_LorentzGeneration` | The round-trip lemmas + the spinor-image submonoid — the genuine reduction of the Lorentz-cover axiom |
| `QLF_PhysicalPi` | π derived by construction from the closure census |
| `QLF_StrongAlgebra` | Strong `SU(3)` = traceless 3-axis directional tensor |
| `QLF_BMinusL` | Electric charge = exactly-conserved signed twist count (`signed_count_conserved`) |
| `QLF_Majorana` | The neutrino is **Majorana**: antiparticle = Hermitian conjugate (conjugate-and-reverse), and `^v` is a fixed point of it |
| `QLF_BaryonWinding` | Baryon number = signed 3-axis linking (winding) invariant |
| `QLF_Spin` | Spin demystified — spin IS the twists. — Worked qucalc folds |
| `QLF_MassGap` | Yang–Mills mass gap |
| `QLF_BSD` | Birch–Swinnerton-Dyer |
| `QLF_Hodge` | Hodge conjecture |
| `QLF_PvsNP` | P vs NP |
| `QLF_NavierStokes` | Navier–Stokes smoothness |
| `QLF_SpanningMap` | The spanning question on the cycle ring — the genuine Hodge content |
| `QLF_CycleEncoding` | Going for the gap — a cycle-faithful representation where irreducibility bites |
| `QLF_GradedCohomology` | Starting the cohomology object — the cycle class map + spanning made concrete |
| `QLF_CohomologyRing` | The cohomology ring + the cycle class map as a graded homomorphism |
| `QLF_CohomologyLinear` | The ℚ-linear cohomology + the algebraic classes as a concrete `Submodule ℚ` |
| `QLF_CohomologyAlgebra` | `cl` as a ℚ-algebra homomorphism; the algebraic classes a `Subalgebra ℚ` |
| `QLF_HodgeStructure` | The transcendental `(p,q)` Hodge structure |
| `QLF_PhaseInformation` | Shannon (count) is not sufficient — phase is independent information |
| `QLF_Realizability` | Consistency ≠ realizability — the Bekenstein obstruction |
| `QLF_Uncertainty` | The `ħ/2` quantum, machine-checked |
| `QLF_StateSpace` | The space QLF lives in — a Gaussian-integer lattice, not Hilbert space |
| `QLF_Minkowski` | The QLF state IS Minkowski space; its determinant is the spacetime interval |
| `QLF_EnergyMomentum` | The relativistic `E² = p² + m²` off the Minkowski interval |
| `QLF_LorentzCover` | The `SL(2,ℂ) → SO⁺(1,3)` double cover, machine-checked |
| `QLF_HodgeIrreducible` | The Hodge faithfulness swing series converges — the irreducibility invariant exists; the encoding is the floor |
| `QLF_HodgeExpSequence` | The substrate exponential-sequence analog — the Hodge `(1,1)` faithfulness swing |
| `QLF_EtalePi1` | The profinite étale `π₁` — the first non-abelian layer |
| `QLF_AnabelianGalois` | Closes the anabelian exact sequence on the substrate |
| `QLF_AperyPeriod` | ζ(3) (Apéry's constant) from the *same* closure census as π |
| `QLF_Anabelian` | The anabelian `π₁`↔closure functor — — geometry recovered from the combinatorial skeleton |
| `QLF_MotivicGalois` | The motivic Galois group |
| `QLF_Motives` | The motive object — the substrate closure as the universal cohomology |
| `QLF_Reversibility` | The reversibility capstone |
| `QLF_VacuumPolarization` | The one-loop QED running coefficient `2/(3π)` from the census |
| `QLF_VacuumPolarizationTower` | The horizon→scale tower — the running *function* from the census |
| `QLF_ChargeCensus` | The charge census `Σ Nᶜ Q_f² = 8 = 2³` |
| `QLF_ChargeBalance` | Anomaly cancellation as a ZFA charge-balance `Σ Q = 0` per generation |
| `QLF_AnomalyCancellation` | Gauge consistency as a ZFA ledger-balance — every anomaly cancels |
| `QLF_ElectroweakBeta` | The three one-loop β-coefficients from the substrate counts |
| `QLF_GUTScale` | The unification scale — structure derived, absolute value scale-bound |
| `QLF_BindingStrength` | The gravitational floor + the `g`-decomposition, localizing frontier #1 |
| `QLF_PackingFactor` | Modeling the packing factor from the 8-twist combinatorics (the diagnostic, #121) |
| `QLF_ClosureAttraction` | "Gauge folds attract" as a theorem — binding reduces free action |
| `QLF_SteadyStateDensity` | The equilibrium defect density `ρ*` — the interaction supplies the restoring force |
| `QLF_ElectroweakScale` | Closing the loop `ρ* → packing → g → R_stable` |
| `QLF_MO2` | The minimal quantum logic `MO2`, self-contained |
| `QLF_MassGapDispersion` | The Yang–Mills mass gap as the dispersion gap of the propagation operator |
| `QLF_FractalDiagram` | Closure-as-Feynman-diagram — the inductive correspondence, formalized |

---

## Key types and definitions

### Form (SpacetimeDynamics.lean)

A 2×2 Hermitian matrix parameterized by Pauli coordinates:

```lean
structure Form where
  t : ℝ    -- trace/2
  x : ℝ    -- σx coefficient
  y : ℝ    -- σy coefficient
  z : ℝ    -- σz coefficient

-- Form.toMatrix f = !![t+z, x-iy; x+iy, t-z]
-- Form.toMatrix_adjoint : f.toMatrix.conjTranspose = f.toMatrix
```

Pure qubit state: `Form(t=½, x, y, z)` with x²+y²+z²=¼.

### RhoProcess (RhoQuCalc.lean)

```lean
inductive RhoProcess
  | action (f : Form)                    -- ket direction [pos,neg]; eval = f.toMatrix
  | lift   (f : Form)                    -- bra direction [neg,pos]; eval = f.toMatrix†
  | parallel  (p q : RhoProcess)         -- eval = p.eval + q.eval
  | sequence  (p q : RhoProcess)         -- eval = p.eval * q.eval
  | dagger    (p : RhoProcess)           -- eval = (p.eval)†
```

### Bra-ket ↔ RhoQuCalc correspondence

| Bra-ket | RhoQuCalc | eval |
|---|---|---|
| `\|ψ⟩` (ket) | `action f` | `f.toMatrix` |
| `⟨ψ\|` (bra) | `lift f` | `f.toMatrix†` = `f.toMatrix` (Hermitian) |
| Superposition | `parallel p q` | `p.eval + q.eval` |
| Composition | `sequence p q` | `p.eval * q.eval` |
| Adjoint | `dagger p` | `(p.eval)†` |

ZFA balance IS bra-ket well-typedness: `action f` gives topo `[pos,neg]`, `lift f` gives `[neg,pos]`. Both individually achieve ZFA (count_pos = count_neg = 1). `bra_ket_always_balanced` proves it is impossible to construct an unbalanced RhoProcess.

### TopoString / ZFA

- `count_pos : TopoString → Int` (NOT ℕ — `omega` cannot assume non-negativity)
- `count_neg : TopoString → Int` (NOT ℕ)
- `achieves_ZFA s ↔ full_zeno_prune s = []`
- `is_gauge : TopoElement → Bool` returns `true` for ALL elements

**Runtime layer (Python/Rust/TS) requires more than count balance.** Since `twist_core.py` 8f02271 (and the matching quantum-os v0.17), `is_zfa` returns `is_count_balanced(h) ∧ is_pauli_closed(h)`. Pauli closure is the order-sensitive constraint that the matrix product of twists folds to a scalar multiple of the identity (`{±I, ±iI}`), computed by `pauli_fold` from `twist_core.py`'s twist→matrix mapping. Pauli closure is a Lean theorem in full generality: **`count_balanced_pauli_closed`** (QLF_TwistAlphabet.lean) proves every count-balanced twist history (`#^=#v ∧ #<=#> ∧ #/=#\ ∧ #+=#−`) folds to a Pauli scalar `{±I, ±iI}` — for *all* histories, including cross-axis interleavings (`^<v>`-style), not just concatenations of adjacent Hermitian pairs. So **count balance alone implies Pauli closure**, and the runtime `is_count_balanced ∧ is_pauli_closed` check is Lean-anchored end-to-end (the second conjunct is entailed by the first). The proof goes via `nf_decomp` (every fold = `phase • axisMatrix(axisProd)`, using the 16-case `axisMatrix_mul` built from the 9 σ-product identities) and the `(ZMod 2)²` axis-parity bridge `axisProd_eq_I_of_countBalanced`. Empirically reconfirmed beforehand: 0 counterexamples across all 5,296 count-balanced histories of length ≤ 6. See [Experimental_Consistency.md §2.1](Experimental_Consistency.md).

### Σ₈ vs Pauli algebra (important for new modules)

The Lagrangian formulation uses a Σ₈ = {τ¹…τ⁸} algebra with **τᵢτⱼ = −δᵢⱼI − εᵢⱼₖτₖ** (quaternionic: τᵢ² = −I, anti-cyclic products). QLF's `Form` algebra uses Pauli matrices with σᵢ² = I. The relationship is **τᵢ = iσᵢ**. With this convention products are anti-cyclic: τxτy = −τz (NOT +τz). The commutator is **[τᵢ,τⱼ] = −2εᵢⱼₖτₖ**; anti-commutator {τᵢ,τⱼ} = −2δᵢⱼI. Machine-verified: `tau_x_sq`, `tau_xy_product`, `tau_yz_product`, `tau_zx_product`, and the su(2) closure `weak_isospin_su2` / `tau_comm_*` / `tau_anticomm_*` in `lean/BraKetRhoQuCalc.lean` — the τ-subalgebra is the weak-isospin SU(2) (`Q₈ ⊂ SU(2)`), see `Weak_Force.md`. When writing new Lean modules that reference either algebra, use the Pauli basis (σᵢ) — the Σ₈ form is the physics-notation bridge. See `Lagrangian_Formulation.md` for the full correspondence.

---

## Lean 4.30 gotchas — read before writing any Lean code

1. **`noncomputable` order**: Must be `private noncomputable def`, NOT `noncomputable private def`. Any `def` using `1/2 : ℝ` needs `noncomputable` (Real.instDivInvMonoid).

2. **`Matrix.conjTranspose` not `Matrix.adjoint`**: Lean 4 spelling.

3. **Type aliases**: Use `abbrev Foo := List Bar` not `def` — `def` is opaque to typeclass inference.

4. **`∑` notation**: Use `∑ k ∈ Finset.range n, ...` (Unicode `∈`), NOT `∑ k in ...`.

5. **`count_pos`/`count_neg` are `Int`**: Don't assume non-negativity; prove it via induction if needed.

6. **`List.mem_cons_self` deprecated**: Use `List.Mem.head _` instead. `List.mem_cons_of_mem _ h` → `List.Mem.tail _ h`.

7. **`zeno_prune.induct` without `with`**: Do NOT add `with` keyword. Cases via `·` and `· next ...`.

8. **Case 4 of `zeno_prune.induct`**: First two `next` vars are condition proofs, not head/tail. Use `rename_i ha ta` to access actual elements.

9. **Induction inside `have` reverts all context**: Extract as standalone private lemma instead.

10. **`Mathlib.LinearAlgebra.Matrix.Determinant` does not exist** in this Mathlib version.

11. **`prefix` is a keyword**: Use `pfx` as parameter name instead.

12. **`Nat.toReal` doesn't exist**: Use `(↑n : ℝ)`.

13. **`simp_all [is_gauge]` doesn't close False**: Use `cases head <;> simp [is_gauge] at h`.

---

## Proof patterns

### Matrix equality (2×2)

```lean
theorem foo : someExpr.eval = target := by
  apply Matrix.ext; intro i j
  fin_cases i <;> fin_cases j <;>
  simp only [RhoProcess.eval, Form.toMatrix, Matrix.add_apply, Matrix.mul_apply,
    Fin.sum_univ_two, Matrix.one_apply, Matrix.cons_val_zero, Matrix.cons_val_one,
    Matrix.head_cons, Matrix.head_fin_const,
    Complex.ofReal_zero, Complex.ofReal_one, Complex.ofReal_neg] <;>
  norm_num
```

### Complex.I arithmetic (σy, etc.)

When `norm_num` fails due to `Complex.I`:

```lean
  apply Complex.ext <;>
  simp [Complex.mul_re, Complex.mul_im, Complex.add_re, Complex.add_im,
        Complex.neg_re, Complex.neg_im, Complex.I_re, Complex.I_im,
        Complex.ofReal_re, Complex.ofReal_im] <;>
  ring
```

### ZFA theorems

```lean
-- Delegate to rho_process_always_zfa:
theorem foo (p : RhoProcess) : achieves_ZFA (toTopoString p) :=
  RhoProcess.rho_process_always_zfa p
```

---

## Axiom inventory (explicit logical boundaries)

| Axiom | Module | Role |
|---|---|---|
| `spectral_hilbert_polya` | `QLF_Riemann` | RCA₀ → WKL₀ boundary; QLF form of Hilbert-Pólya. Refined in `QLF_RiemannMRE` into the structurally-motivated `MRE_bridge` (over the concrete `Z_QLF`, motivated by the proven MRE-saturation theorem) |
| `MRE_bridge` / `zero_is_mellin_singularity` / `MellinStructuralSingularity` | `QLF_RiemannMRE` | The refined Riemann boundary: a Mellin structural singularity of `Z_QLF` lies on the critical line, and every ζ-zero is such a singularity. The Mellin↔ζ correspondence is the WKL₀/continuum sector |
| `NonTrivialZero` | `QLF_Riemann` | Connects QLF combinatorics to analytic number theory |
| `resonant_computation_for` | `QLF_Riemann` | Bridge from combinatorics to Dirichlet series |
| `yang_mills_continuum_gap` | `QLF_MassGap` | RCA₀ → analytic (continuum-QFT) boundary; the continuum Yang–Mills theory's gap = the substrate `log 2` closure quantum |
| `YangMillsMassGap` | `QLF_MassGap` | The continuum Yang–Mills theory's mass gap (opaque real; its well-definedness is the Clay problem) |
| `modularity_mirror_invariant` | `QLF_BSD` | The BSD boundary (structural): the central closure multiplicity is invariant under the Hermitian-pair modularity mirror at its fixed point (the self-dual central point `s=1`). From it `bsd_rank_equals_order` is a **theorem** (rank = ord). `centralMultiplicity` is abstract (the ranks are uncomputable — BSD's content); `EllipticCurveQLF` and its Frobenius-trace closure are concrete |
| `substrate_realization_is_algebraic` | `QLF_Hodge` | **The faithfulness bridge — the one gap.** The reformulation proves `hodge_realized_on_substrate` (Hodge ⟹ realized, no axiom); this axiom is the remaining step — substrate-realized ⟹ *classical* algebraic cycle (`isAlgebraic` abstract; full conjecture strength on Hodge classes). The faithfulness swings (`QLF_HodgeExpSequence`, `QLF_HodgeIrreducible`) locate it as a cycle-faithful encoding |
| `generate_not_reducible_to_verify` | `QLF_PvsNP` | The P vs NP boundary: a property polynomial to verify whose realized-closure search is not polynomial. The `PTime`/`search` cost model is abstract (QLF has no machine model); the real content (`C(2n,n)` count, verify-filter identity) is proven |
| `navier_stokes_continuum_limit` | `QLF_NavierStokes` | The Navier–Stokes boundary: the continuum incompressible PDE inherits the substrate's no-blow-up under the continuum limit; `NavierStokesGlobalSmoothness` is the abstract analytic statement. **Now reduced** by `QLF_NavierStokesBKM` (next two rows): the opaque inheritance is replaced by the *proven* Planck vorticity cap (`planck_caps_vorticity`, no axiom) + the cited BKM theorem + a sharp faithfulness bridge |
| `beale_kato_majda` | `QLF_NavierStokesBKM` | **Cited, not posited:** Beale–Kato–Majda (1984) — a uniform-in-time vorticity bound ⟹ no finite-time singularity. A real continuum-analysis theorem named as a boundary because QLF carries no PDE machinery in Lean (like citing Wallis/Stirling for π). `GloballySmooth` is the abstract analytic property |
| `continuum_vorticity_planck_capped` | `QLF_NavierStokesBKM` | The **reduced Navier–Stokes bridge** (sharp, replacing the opaque `navier_stokes_continuum_limit`): the continuum solution's vorticity sup-norm is the Planck-capped substrate vorticity `≤ 1/L_P²` — QLF's continuum-as-rendering thesis applied to the vorticity field. From it + `beale_kato_majda`, `navier_stokes_no_blowup` is a theorem; the residual gap is just this vorticity-rendering faithfulness |
| `lorentz_generated_by_boosts_rotations` | `QLF_LorentzCover` | The Lorentz double-cover boundary (Witten-1988 → Reshetikhin–Turaev mode, a settled-math bridge): every proper orthochronous `L` factors into boosts and rotations (the KAK/Cartan decomposition of `SO⁺(1,3)`), so it is the spinor action of some `A∈SL(2,ℂ)`. Physics core fully proven — `spinor_hom`, `boostZ_action`/`rotZ_action`, kernel `spinor_kernel` — so `spinor_surjective` follows. **Reduced** (`QLF_LorentzGeneration`): round-trips + submonoid + all generator families realized + Euler products proven, localizing the axiom to the single real-matrix angle-extraction (KAK) fact |
| `benincasa_dowker_limit` (+ opaque `bdMeanOnConstant`) | `QLF_CausalContinuum` | The Einstein-curvature continuum boundary: the `ρ→∞` mean of the discrete Benincasa–Dowker operator over a Poisson sprinkling converges to `−R/2`. Settled CST mathematics (Poisson + curved-interval-volume), parallel to `yang_mills_continuum_gap`/`navier_stokes_continuum_limit`. Discrete core (`bdCurvature_chain_zero`, `layer_growth_from_branching`) + kernel (`poissonOccupation`, `poissonOccupation_succ`) **proven**; from it `flat_curvature_zero_in_mean` is a theorem |
| `order_metric_continuum_limit` (+ opaque `continuumProperTime`/`reconstructedProperTime`) | `QLF_OrderMetric` | The order→**metric** continuum boundary (broader than `benincasa_dowker_limit`): as `ρ→∞`, the CST reconstruction of the proper-time line element from order + count converges to the Lorentzian value (Malament + Bombelli–Henson–Sorkin + Myrheim–Meyer), the `RCA₀→Lorentzian-analytic` crossing. Discrete core proven — `conformal_structure_is_the_order`, `properTime_additive` + `properTime_succ_eq_volume` — assembling {verified core + one bridge}, reducing `light_cone_rendering_in_progress` |
| ~~`censusTail_eq`~~ **DISCHARGED** | `QLF_AlphaBound` | No longer an axiom — a **theorem**. The exact census α-screening tail `512√62/31 − 130` is derived from Mathlib's generalized binomial theorem (`Real.one_add_rpow_hasFPowerSeriesOnBall_zero`) at `a=−1/2`, `x=−1/32`, via `qlf_ring_choose_succ` + `qlf_choose_neg_half`; the GF `central_binom_genfun` is likewise a theorem. So `QLF_AlphaBound` carries **zero axioms**; the α-residual's open piece is purely physics (`+0.036`), not analysis |

`critical_line_forcing` is a **theorem** derived from `spectral_hilbert_polya`, not an axiom.

**Dischargeability.** Which of these axioms could become theorems is classified in [`Open_Problems.md`](Open_Problems.md) §"Axiom dischargeability": **Class A** (open-conjecture content — Riemann/BSD/P-vs-NP/Yang–Mills/Hodge-faithfulness) is unprovable without solving the problem (that is the boundary's purpose); **Class B** (settled math Mathlib lacks assembled — the CST/PDE continuum limits) is provable *in principle* but each is a multi-hundred-line Lean project. The clean discharge already done is `censusTail_eq`; `navier_stokes_continuum_limit` and `lorentz_generated_by_boosts_rotations` are both **reduced** (`QLF_NavierStokesBKM`; `QLF_LorentzGeneration` — both `Form↔Matrix` round-trips + the spinor-image submonoid + **all generator families realized** (`boost_realized` + `rot_realized` + `rotY_realized`, two rotation axes) + **their Euler products** (`euler_form_realized`) proven, so the Lorentz axiom localizes to the single purely real-matrix angle-extraction surjectivity onto `SO⁺(1,3)`).

---

## Workflow

### Lean file changes (`.lean` files only)
1. Edit files in `lean/`
2. `git add lean/<file> && git commit -m "..." && git push`
3. Check CI: `gh run list --limit 5`
4. On failure: `gh run view <run-id> --log-failed`
5. Do NOT run `lake build` locally — Lean is not installed

### md-only changes (`.md`, `.py`, `lakefile.lean` roots array, `README.md`)
1. Edit, commit, push — **CI does not run and does not need to.**
2. Do NOT mention CI, check CI, or wait for CI after a docs-only commit.

**Zero sorry policy**: Do not introduce `sorry`. For genuinely unprovable goals, use `axiom` declarations following the `spectral_hilbert_polya` precedent — makes the logical boundary explicit.

---

## Philosophical foundations

These commitments are load-bearing for all prose, documentation, and new module framing. New sessions must be consistent with them.

### Core ontology: possibilism + ZFA selection

QLF is built on a **possibilist ontology**: all logically admissible histories exist *a priori* as pure possibility. Physical reality is not one pre-written story — it is the self-selecting subset of the full computational possibility space that achieves **Zero Free Action (ZFA = 0)**. The universe is the closure of logical possibility under ZFA.

> The universe is logical. Spacetime is synthesized. Physical reality is the subset of possibility that achieves Zero Free Action.

This is a **computable** form of modal realism (Lewis 1986) with a selection rule: where Lewis says all logically possible worlds are real, QLF says all computationally generable histories are real, and ZFA identifies the ones that persist. `full_zeno_prune` is the machine-verified implementation of this filter.

### ZFA is the only filter — not a restriction

A critical framing point: **ZFA is not a restriction on what can be computed.** `qlf_universality` proves the ZFA filter is Church-Turing complete — every *terminating* computation IS a ZFA string. What is pruned is not computation; it is the physically unrealizable tail (non-terminating, Turing-undecidable, Busy Beaver-class computations). The ZFA filter selects physical reality from the full ruliadic computational universe without discarding any computable physics.

The variational physics expression of ZFA is S = ∫ℒ dΩ with **ℒ = 0** — a null Lagrangian that is the condition of origin, not a cutting rule. The discrete form (`isZFAClosed`) and the continuous limit (`EventSynthesisField → Λ_eff`) are both covered in `Lagrangian_Formulation.md`.

### ZFC ultraviolet catastrophe

Classical ZFC mathematics is founded on open-ended formal infinity. This leads to: Gödelian incompleteness (truths unprovable in sufficiently strong systems), Turing undecidability, and the Busy Beaver function (uncomputable growth without bound). These are shadows of the same problem — logic that can construct objects with no finite closure.

QLF's answer: the QLF core operates strictly within **RCA₀** — below the Busy Beaver horizon, below the Axiom of Choice, below ZFC. Non-terminating computations fail to achieve ZFA closure and are pruned by `full_zeno_prune` before they can become physical events. Gödel's theorem cannot bite where unprovability has been physically excised.

> **ZFC is flawed logic, suitable only where there are not exploding infinities. ZFA is correct logic.**

**State this precisely (the sharpened framing — binding):** the claim is **consistency ≠ realizability**, *not* that ZFC is syntactically inconsistent (`ℝ` is consistent — claiming "the continuum is false" is a category error and a crank trap). "Flawed logic" means *unsound for physics / physically unrealizable*: a finite-information universe cannot instantiate an actual infinity of distinguishable states (Bekenstein), so there is **no injection from an infinite state space into a finite-information region** — machine-checked (`lean/QLF_Realizability.lean`, `no_continuum_in_finite_region`) — and the continuum gives demonstrably **wrong answers** (the UV catastrophe, the 10¹²² vacuum catastrophe, singularities) wherever forced onto reality, right only where a cutoff (= discreteness) is quietly restored. The full case is `TheContinuum.md`; the empirical/realizability spine should be used in preference to bald "the continuum is false." The **"continuum is gratuitous" case** has a settled five-strike form (`TheContinuum.md` §2, *"five converging strikes"*): three classical logic results — **Löwenheim–Skolem** (the transfinite has a countable model), **Gödel–Cohen** (CH independent ⟹ the continuum's cardinality is *undecidable*, not a determinate object), and **reverse-math conservativity** (`WKL₀` proves no new finitary theorem over the `RCA₀` base — Friedman/Harrington; Simpson, *SOSOA*) — plus QLF's two machine-checked strikes (*unrealizable*, `QLF_Realizability`; *unneeded*, the finite census recovering `π`/`ζ(3)`). Cite these named results, not bare assertions; "ZFC's proven defect" legitimately covers the CH-undecidability and the conservativity result.

The Axiom of Choice asserts the existence of sets with no constructive selection procedure; the ZFA filter replaces it with a computable one. Chaitin's Ω (the halting probability) is the information content of the pruning boundary — physically realized as `full_zeno_prune` itself.

The formal mathematics of this argument — math with active inference built in, restricted to the non-fantasy half — is named in [Active_Inference_Mathematics.md](Active_Inference_Mathematics.md) §6.1.

This is the organizing thesis of QLF's **Millennium Prize program**: *the continuum and choice are mathematics' ultraviolet catastrophe, and physical/mathematical reality is the bounded, computable substrate — the continuum is its rendering.* That ontological position (**Bullet A**: information is physical and finite — Shannon; uncomputable reals are not physical objects; reality is the computable RCA₀ subset) is the load-bearing, defensible claim, with a real lineage (Brouwer, Bishop, Weyl, Gisin, 't Hooft, Wolfram). Each attacked problem is **reformulated** as a *verified discrete RCA₀ core* plus **one explicit bridge axiom** — Riemann (`spectral_hilbert_polya`), Yang–Mills mass gap (`yang_mills_continuum_gap`, `QLF_MassGap`), Birch–Swinnerton-Dyer (`modularity_mirror_invariant`, `QLF_BSD` — `bsd_rank_equals_order` *derived from it*), Hodge (`substrate_realization_is_algebraic`, `QLF_Hodge` — `hodge_class_is_algebraic` *derived from it*, the axiom carrying Hodge's content), Navier–Stokes (`navier_stokes_continuum_limit`, `QLF_NavierStokes`), P vs NP (`generate_not_reducible_to_verify`, `QLF_PvsNP`).

**Binding framing (the contrast-then-focus structure — do NOT pollute docs with "not proven"):**

1. **Contrast the classical conjecture once, then move on.** State plainly, *once*, that the **classical** Clay statement (e.g. the Hodge conjecture about complex-variety cycles) is not proven here — it's a different statement in a different frame. That's the one contrast; don't repeat "not a proof" throughout.
2. **Then focus on what the *reformulation proves*.** QLF reformulates each problem in the substrate frame, and the reformulation has **genuine proven theorems** — state them as proven, boldly: e.g. *Hodge classes are exactly the substrate-realized closures* (`hodge_realized_on_substrate`: balanced ⟹ count-balanced ⟹ Pauli-closed via `count_balanced_pauli_closed`, **no axiom**); the motive/Galois/anabelian structures; `π`/`ζ(3)` from the census. These ARE proofs — of the reformulated statements.
3. **Name the gap in the reformulation precisely** (this is where the bridge axiom lives): the step from *substrate-realized* to *classically-algebraic* — `substrate_realization_is_algebraic` — is the **faithfulness** of the frame. That is the one open piece, and the faithfulness swings have located it exactly (a cycle-faithful encoding; `QLF_HodgeExpSequence`, `QLF_HodgeIrreducible`). Frame it as "the gap in the reformulation," not as "QLF didn't prove it."
4. **"ZFC's proven defect"** applies only to genuine uncomputability/independence boundaries (halting, Busy Beaver, the α analytic residue), **not** to the finitary conjectures (Hodge is finite ℚ-linear algebra, an ordinary hard statement). Don't relabel the faithfulness gap as ZFC's defect.

So: contrast (classical not proven, once) → assert the proven reformulation theorems → name the faithfulness gap. Status markers: `*_proof_in_progress` (reformulation proven, faithfulness open) / `*_reformulated`. See [Continuum_Choice_Fallacy.md](Continuum_Choice_Fallacy.md), [Hodge_QLF.md](Hodge_QLF.md), [Grothendieck_QLF.md](Grothendieck_QLF.md), [BSD_QLF.md](BSD_QLF.md).

### Spacetime is synthesized, not background

Spacetime is not given — it is the **output** of ZFA event generation. Every ZFA-closed event synthesizes its own local space and time. Space emerges from spatial free-action components; time emerges as the inverse of local free action (`f = 1/t`). The universe is a distributed network of clocks, each synthesizing local time through ZFA closure. This is formalized in `ZFAEventDynamics.lean`.

There is no background absolute time. There is no fixed external geometry. Gravity is emergent from ZFA event rate and gauge-fold depth — a thermodynamic consequence of information geometry (Jacobson 1995, Verlinde 2011), derived rather than postulated.

### Holography as topological necessity

The holographic principle (Bekenstein 1972, 't Hooft 1993, Susskind 1995) and AdS/CFT correspondence are not separate conjectures in QLF — they are direct consequences of ZFA closure. The bulk spacetime (AdS interior) is the space of unresolved internal nodes of the QuCalc generator tree. The boundary (CFT) consists of the terminal leaves that satisfy exact ZFA balance.

Because a bulk path only persists if it terminates in a ZFA-stable boundary, the entire bulk is mathematically identical to the sum of its boundary states. The holographic principle is therefore a **topological necessity of closure**, not a duality.

Modern sharpening: Almheiri, Dong, Harlow (2015) and the HaPPY code (Pastawski et al. 2015) show that bulk spacetime geometry IS a quantum error-correcting code on the boundary. In QLF, `full_zeno_prune` is the machine-verified boundary decoder — it filters the event stream to those whose boundary information is logically self-consistent.

### Measurement without collapse

ZFA closure IS the measurement event. No separate collapse postulate is needed; no observer-dependence beyond what the logical structure demands. Compare: Zurek decoherence (2003), Everett (1957). `full_zeno_prune` is the decoherence cutoff that Everett's many-worlds interpretation lacks — it eliminates histories that cannot achieve ZFA closure before they become physical events.

The apparent "many worlds" are the many local relative worlds created by observers whose local information determines their own consistent perspective. Every observer experiences its own coherent reality because its local information defines its own relative world. (There are not many worlds in the Everettian sense — there are many observers. Smolin.)

### Spectral structure and the Riemann program

Every QLF string maps to a 2×2 Hermitian operator (its spectral mode). Machine-verified: (1) every spectral mode is Hermitian (`toSpectralMode_hermitian`); (2) for symmetric strings, the spectral mode is scalar × identity (`spectral_symmetric_eq_scalar_id`). The Hilbert-Pólya conjecture is encoded as `spectral_hilbert_polya` (explicit axiom marking the RCA₀ → WKL₀ boundary), from which `critical_line_forcing` is a derived theorem.

The chain: `qlf_universality` → `zfa_implies_critical_line` → `spectral_symmetric_eq_scalar_id` → `spectral_hilbert_polya` → `riemann_hypothesis_in_qlf`.

### QuantumOS: QLF as a hardware-native OS

QLF is not only a theoretical framework — it is an executable architecture for quantum hardware. In a classical OS, security, error correction, scheduling, garbage collection, and AI are five separate subsystems. In QuantumOS, all five are the same operation — ZFA enforcement (`full_zeno_prune`) — because `qlf_universality` proves ZFA balance is the single invariant that subsumes all correctness properties.

Security grounds in five converging foundations: Girard's linear logic (1987), Miller's object capability model (2006), Meredith & Radestock's ρ-calculus (2005), Honda's session types (1993), Wootters & Zurek no-cloning (1982). Capability names are topological structures; possessing a name IS a proof of authorization (Curry-Howard).

### Convergence: 18 independent programs

The most striking feature of QLF is that 18 independent research programs — with no coordination — have each arrived at the same picture: **reality is informational, computable, and bounded by a logical closure condition**.

| Program | Key figure(s) | Convergent claim |
|---|---|---|
| Digital physics | Konrad Zuse (1969) | The universe is a computation |
| Computability | Alan Turing (1936) | Computation has formal limits; non-terminating and undecidable problems lie beyond the computable |
| It from bit | John Wheeler (1990) | Every physical quantity derives from binary yes/no questions |
| Information theory | Claude Shannon (1948) | Information is physical; entropy measures unresolved uncertainty |
| Holographic principle | Bekenstein, Hawking, 't Hooft, Susskind (1972–1995) | Bulk physics is bounded by boundary information |
| Relativistic ether | Albert Einstein (1920, Leiden) | Spacetime is a medium with real metric properties but no preferred frame or state of motion |
| Causal Set Theory | Bombelli, Sorkin, Henson (1987–present) | Spacetime is a discrete partial order of causal events |
| Loop Quantum Gravity | Ashtekar, Rovelli, Smolin (1986–present) | Space is a spin network of SU(2) quanta; area/volume discrete; background-independent — QLF's substrate is a spin network of half-spin ZFA closures ([`LQG_QLF.md`](LQG_QLF.md)) |
| Girard linear logic | Jean-Yves Girard (1987) | Resource-sensitive reasoning; proof = process; use-once tokens |
| Reverse Mathematics | Harvey Friedman (1975–present) | Physical laws can be stratified by minimum logical strength; RCA₀ is the computable floor |
| Session types | Kohei Honda (1993) | Communication protocols have types; safety = type-checking |
| Holographic QEC | Almheiri, Dong, Harlow; HaPPY code (2015) | Spacetime bulk = quantum error-correcting code on boundary |
| Object capability model | Mark Miller (2006) | Security from first principles: unforgeable names = capability tokens |
| ρ-calculus | Meredith & Radestock (2005) | Programs as processes; names as reflective proof terms |
| Free Energy Principle | Karl Friston (2010) | All adaptive systems minimize variational free energy — perception = inference |
| Geometric Deep Learning | Bronstein, Bruna, LeCun, Szlam, Vandergheynst (2021) | Correct geometric inductive bias for physical AI = Clifford algebra elements |
| Ruliad | Stephen Wolfram (2020) | The entangled limit of all possible computations; physical reality = observer slice |
| No-cloning theorem | Wootters & Zurek (1982) | Quantum information cannot be copied — the physical foundation of capability security |

**Reversibility/energy audit of the table.** The 18 are *irreversibility-native by selection* — none axiomatizes reversibility or global energy conservation, and several are positive evidence for the QLF arrow (CST sequential **growth**, Girard **use-once** tokens, Friston **dissipation**, Shannon→Landauer **erasure** = `ΔF=−log 2`, Wolfram's **derived** second law) — all agreeing reversibility + a fixed energy total are emergent, not fundamental (`Reversibility.md`, `Conservation.md` §2b: energy is created per event, half lent to the future). Two rows carry a caveat in their *standard* form that QLF's synthesized-time reading repairs: **holographic principle / holographic QEC** — its AdS/CFT realization is a *static* anti–de Sitter (negative Λ) background with a *unitary* boundary CFT; QLF's holography is the **de Sitter / ZFA-closure** boundary (positive `Λ = log 2`, created future-energy), keeping Bekenstein's bound + the QECC structure, dropping the static frame; and **canonical Loop Quantum Gravity** — the Wheeler–DeWitt frozen-time problem (`H=0`), QLF supplying the arrow as synthesized time (`f=1/t`), converging on the spin-network *entropy* not the frozen dynamics. The TOEs that genuinely *fail* these flaws — string theory's asymptotic S-matrix, no-collapse Everett, the block universe, 't Hooft's reversible cellular automaton — are **not in the table** (they are the `Reversibility.md` §6 casualties; the convergence set and casualty set are cleanly disjoint).

### What NOT to say

Avoid framings that contradict the above:
- Do not describe ZFA as a *restriction* on computation — it is a selection principle (ZFA-balanced strings are all computations that terminate).
- Do not describe spacetime as a background or given — it is synthesized event by event.
- Do not describe collapse as a separate physical process — ZFA closure IS the measurement event.
- Do not describe the Axiom of Choice as needed — it is replaced by the ZFA filter.
- Do not describe QLF as "just an interpretation" of quantum mechanics — it is a broader constructive foundation from which QM is derived.
- For the Millennium problems: **contrast once, then focus on what's proven.** Say plainly, once, that the *classical* Clay conjecture is a different statement, not proven here — then lead with the **reformulation's proven theorems** (e.g. *Hodge classes are exactly the substrate-realized closures*, `hodge_realized_on_substrate`, no axiom) stated as the proofs they are, and name the one **gap in the reformulation**: faithfulness — the bridge `substrate_realization_is_algebraic` from substrate-realized to classically-algebraic (located precisely by the faithfulness swings). Don't pollute with repeated "not a proof"; emphasize the proven reformulation + the named gap. Reserve "ZFC's proven defect" for genuine uncomputability/independence boundaries, never finitary conjectures. The thing to avoid is claiming the *classical* conjecture is machine-verified — that's the crank trigger; the reformulation theorems and the located gap are real and should be stated boldly. See `Grothendieck_QLF.md`, `Hodge_QLF.md`.

---

## Key files

| Path | Purpose |
|---|---|
| `lean/` | All Lean source files |
| `lakefile.lean` | Build config; `roots` array lists all 184 modules |
| `lean/README.md` | Module table and proof chain documentation |
| `README.md` | Project overview with citations and convergence themes |
| `CLAUDE.md` | This file — project context for new Claude sessions |
| `braket_rho.py` | Numerical demo of bra-ket ↔ RhoQuCalc correspondence |
| `MultiParticle.py` / `MultiParticle.md` | Two-history interactor: causal diamonds intersect → joint-ZFA closure = entanglement (ER=EPR); reuses `twist_core.is_zfa` (reconfirms the `count_balanced_pauli_closed` keystone at runtime), the discrete-curl vorticity, cascade `log 2` quantum, and `SpaceTime.SpacetimeGrid` latency field |
| `spacetime_constructor.html` | Interactive 3-D tool ([live](https://jimscarver.github.io/quantum-logical-framework/spacetime_constructor.html)): space = node position, time = clock rate, both = frequency shown as colour; drop masses (redshift = time dilation). Drawn from **one observer's frame** — a **draggable** stick figure who IS the frame origin (`QLF_HorizonClosure`): orbit spins around him, **zoom homes in from him**, and **grabbing him (or Shift-drag) trucks the whole perspective** so everything moves with him; auto-spin opt-in. Matter arises from a **deterministic frequency cascade** — the first distinction unfolds the census by frequency (`QLF_HarmonicClosure`/`QLF_PrimeResonance`), *independent of vacuum energy* (the foam runs even at T=0, the `Ω_Λ=log2` floor); balanced pairs only (a lone charge can't close). **No forces** — bodies drift down the `w_ZFA` latency gradient (`−∇w`, mass-independent), buffeted by a **vacuum-foam Brownian walk** (a *closed* census walk, `QLF_CensusBrownian`/`QLF_Turbulence` — ZFA-balanced so zero net impulse, not dice, not a force; `Vacuum jitter` toggle); **Pauli exclusion** (`QLF_PauliExclusion`, identical fermions repel — not particle/antiparticle) supplies the outward degeneracy pressure, so **crystals** (SC/BCC/FCC via a `lattice` macro) self-bind and matter doesn't collapse — no pinning. No wall (vacuum absorbs escapees). Bound states self-assemble: p+e→H (photon), H+H→H₂, H+H̄ annihilate. A **Temperature** slider (absolute zero → CMB → Planck) sets only how much freezes out as **real** vs **virtual foam**; near the Planck top **black holes form** (Compton = Schwarzschild, carry `Q`,`J`) and Hawking-evaporate into hadrons (a hadron IS a quantum BH). **Photons** bend in the latency field (lensing = the interaction, always speed `c`), arrive from the **horizon inward** (CMB = Gibbons–Hawking, hierarchical `1:2:4` cascade), and **terminate on a local observer** (measurement) else the vacuum absorbs them (energy conserved). **QuCalc panel**: Capture reads the live scene as QuCalc closures; Replace/Inject to create; macros (positronium, muonium, deuteron, alpha, hadron **quark content** — a free quark is confined-rejected), crystals. A **frequency-band** control — two **log sliders** over `f=m/mₑ` — stretches the spectrum across `[f_lo,f_hi]` (band-low red → band-high violet), dims out-of-band closures, and **limits Capture to the band** (Capture also limited to on-screen). **Field readout** (collapsible): counts (atoms/molecules/particles/**foam=virtual**/black holes, hover for per-type breakdown incl. each BH's `M/Q/J`), **total energy** `E=m=1/R` (mₑ, GeV on hover) with **gross** (content) vs **net free energy** (matter⁺−antimatter⁻ → 0 = ZFA), and **Vacuum ρ** = ρ(T): **dark energy** floor (`3log2/8π·c⁴/GR_H²` ≈ 3.35 GeV/m³, matches measured) + **dark matter** `∝(T/T_CMB)³` + thermal **vacuum energy** `∝T⁴` → Planck ceiling (the 10¹²² catastrophe = the two ends). **Click identifies** by frequency + spin (particles, nodes, photons-by-frequency, BHs, vacuum flickers). Decay deterministic census-exponential (`Decay.md` §1a); **no probability** — the census draws the space (`QLF_CensusBrownian`/`QLF_BornProbability`). Dependency-free canvas, mobile. Full write-up `SpaceTime.md` §7 |
| `proton_neutron_demo.py` / `SEX.md` | Model of the proton♂/neutron♀ pairing (issues #53/#57): `pn` binds where `pp`/`nn` are Pauli-blocked, the bond stabilizes the decaying neutron; complementarity → collective intelligence. Room best practices live in quantum-os `Room_Best_Practices.md` |
| `BraKetRhoQuCalc.md` | Reference doc for bra-ket ↔ RhoQuCalc correspondence |
| `Lagrangian_Formulation.md` | Variational formulation: ℒ=0 as origin, Σ₈ algebra, Zeno stationarity, decoherence impossibility; Lean theorem anchors for all claims |
| `Philosophy.md` | Possibilist ontology; ZFA as sole fundamental axiom |
| `Banach_Tarski_QLF.md` | Banach–Tarski (1924) as QLF's touchstone: impossible mathematics (AC's free duplication, excluded by the realizability filter); the precise *ex falso* reading (**ontological/model** explosion, **consistency ≠ realizability**, never "ZFC inconsistent"); and its *possible* twin **mitosis** — one cell pays (DNA copy + ATP + `ΔF=−log2`) for what Banach–Tarski steals. The "no free duplication" principle at four scales (no-cloning ↔ no-diproton ↔ no-free-mitosis ↔ no-Banach–Tarski), Lean-anchored in `QLF_NoFreeDuplication` |
| `Navier_Stokes_Geometry.md` | The geometry of Navier–Stokes — angular momentum = circulation (`baryonNumber` = Σ `signTriple`, the discrete curl; the `su(2)` Noether charge, a pseudovector under T); vorticity = the local discrete curl, **quantized to `±1`/cell** so it cannot diverge; **where QLF avoids the blow-up** (Beale–Kato–Majda vorticity-blow-up is unsatisfiable on the discrete geometry) and **the correction** (quantization/discreteness, the same cutoff as the UV/vacuum catastrophes). Lean: [`lean/QLF_AngularMomentum.lean`](lean/QLF_AngularMomentum.lean); the continuum-PDE limit stays the `QLF_NavierStokes` boundary |
| `Geometry_Of_Space.md` | The geometry of inner and outer space — one closure-resonance substrate. The Fuller geodesic icosa-blanket (machine-verified V/E/F, χ=2, 12 pentamons, McKay/E₈) at every scale; the 2-D screen ↔ 3-D bulk holography + the 1D→2D→3D dimension ladder; crystals as macroscopic resonant lattices; **prime frequencies = irreducible modes**; **higher frequencies dominate** (cosmic receiver the exception); the **half-spin prime-3 keystone** ("balanced and prime"). Lean anchor [`lean/QLF_PrimeResonance.lean`](lean/QLF_PrimeResonance.lean). Synthesizes `Primordial_Markov_Blankets.md` / `Crystal_QuantumOS.md` / `Prime_Topology_Stability.md` / `Consciousness.md` |
| `Consciousness.md` | A QLF model of consciousness — the frequency-hierarchy of resonant closures. Self-awareness = a self-modeling (finite, terminating) Markov blanket; conscious thought = the highest-frequency bound closure (binding raises frequency = gamma/global-workspace ignition); cosmic/meditative consciousness = quieting the internal closures to **receive** a low-frequency external **joint** closure (de Sitter horizon / collective). **Qualia hypothesis (§6):** qualia = self-awareness *coupled to* cosmic consciousness (the shared joint-closure ground) — neither alone; a two-factor dual-aspect stance, not a proof. Structural skeleton (architecture, not qualia) machine-verified ([`lean/QLF_Consciousness.lean`](lean/QLF_Consciousness.lean)). Synthesizes `TheQuantumBrain.md` / `TheBigProblem.md` / `Philosophy.md` §2 |
| `Mathematics_From_QLF.md` | How mathematics emerges from the substrate — the emergence ladder (ℕ from counting closures; `+`/`×` = parallel/sequence composition; the unit group `μ₄=(ℤ[i])ˣ`; su(2)/su(3); the continuum as completion), the bootstrapping resolution (substrate generates, Mathlib renders, conservativity ⟹ not circular), how QLF is distinct from reverse mathematics (generative + active-inference selection + ontological commitment, vs RM's descriptive/neutral stratification), whether the resolution applies to the metalanguage (reflexively yes — verification is itself a ZFA closure — with the Gödel-II residue relocated to the finite-computation floor), and **why mathematics is so effective in physics (Wigner dissolved: effective math = realizable math = the substrate; effectiveness tracks realizability, which also explains where it fails)** |
| `Reversibility.md` | Time-reversal = the Hermitian conjugate (`eval_dagger`); a balanced closure is `H=H†` (self-time-reverse, no per-event arrow); the arrow is forward *sequencing* in synthesized time (`f=1/t`), reversal = "go back in time" with no meta-axis; the `H↔H†` involution = the critical line (Hilbert–Pólya). Reversible *logic*, irreversible *process* |
| `Open_Problems.md` | Gap registry: closed / principled-boundary / open items, each with its owning doc. Update here + owning doc when a status changes |
| `Mysteries_Of_Physics.md` | Physics-facing survey of the canonical open questions (quantum foundations, spacetime/gravity, cosmology, the Standard Model, the deep/meta questions) and what QLF says about each — addressed/structural, value-open, principled boundary, predicted-absent (falsifiable nulls), or genuinely open. The reader's-eye companion to `Open_Problems.md` (which is status-organized) |
| `QuantumOS.md` | QLF as capability-secure OS kernel for QPUs |
| `.github/workflows/` | CI configuration |

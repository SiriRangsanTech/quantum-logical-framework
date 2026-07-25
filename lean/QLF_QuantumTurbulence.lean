import QLF_Turbulence
import QLF_StateSpace
import QLF_PrimeResonance
import QLF_TwistAlphabet
import Mathlib

set_option linter.unusedVariables false

/-!
# QLF_QuantumTurbulence — the superfluid-turbulence dynamical picture, proven

This anchors the §5/§8 claims of [`Turbulence.md`](../Turbulence.md) (issue #120) — the sharpened
superfluid / quantum-turbulence reading — as Lean theorems, in the reuse-only synthesis style
(`QLF_HarmonicClosure` / `QLF_CurvatureLie` pattern; **no new axioms**). The dynamical picture is:

* **Onsager–Feynman circulation is quantized** — a vortex line is one circulation quantum
  (`vortex_quantum`, `|ω| ≤ 1`), and total circulation is an **integer** count of net quanta
  (`circulation_integer_quantized`). Derived from the substrate ([`QLF_Turbulence`](lean/QLF_Turbulence.lean)),
  so classical turbulence is the coarse-grained limit of quantum turbulence.
* **The phase alphabet is `μ₄`; a CLOSED loop realizes its REAL subgroup `{±1}`, the `±i` quarter-turn
  is the OPEN forward half-strand.** The fold group is `μ₄ = {±1, ±i} = (ℤ[i])ˣ`
  ([`QLF_StateSpace`](lean/QLF_StateSpace.lean)), the generator `i` a `π/2` quarter-turn closing after four
  (`phase_quantum_closes_after_four` `p⁴=1`, `phase_quantum_is_quarter_turn` `i` order 4,
  `quarter_turn_primitive` `I⁴=1` but `I²≠1` — a *primitive* 4th root, exactly `π/2`). But a **count-balanced
  closure** (a closed ZFA loop) folds to the **real** subgroup `{±I}` — fermion `−1` (360°) / boson `+1`
  (720°) — **never `±i`**: `balanced_closure_folds_real` (now a full theorem), because a closure pairs
  every axis so its Pauli (non-gauge) twist count is **even** (`balanced_pauli_count_even`) ⟹ `det = (−1)^even
  = +1` (`det_twistMatrixFold`) ⟹ `λ² = 1 ⟹ λ = ±1`. Exhaustively reconfirmed in `brownian_closures.py`
  (0 balanced closures fold to `±i`).
  The `±i` quarter-turn belongs to an **open forward strand** with an *odd* Pauli count (e.g. the prime-3
  proton strand `>^/`), and **time-reversal** (the Hermitian-conjugate dagger, also odd) closes it — forward
  odd `+` backward odd `=` even `⟹` real `±1` (Jim). This is the Onsager–Feynman circulation quantum in the
  8-twist algebra: an open vortex line carries the quarter-turn, closing to the real loop.
* **The cascade resolves highest-frequency-first, down to a floor.** Smaller eddies are higher-frequency
  closures (`highest_frequency_resolves_first`, reusing `cascade_frequency_increases`), and the frequency
  is bounded above by the dissipation floor (`cascade_has_floor`, reusing `cascade_capped`) — no infinite
  cascade; reconnection is a ZFA closure at the floor, the same vorticity cap that removes the
  Navier–Stokes blow-up.
* **Prime closures are the irreducible phase-shift agents.** A prime-period closure cannot decompose into
  a repeat of a shorter closure (`prime_closure_irreducible`, reusing `prime_freq_irreducible`); the
  half-spin (prime `3`) is the minimal such lock (`half_spin_is_prime_agent`, reusing `half_spin_prime` /
  `half_spin_irreducible`). Its forward strand of `3` (odd, prime) carries the `±i` quarter-turn, and the
  closure `3 + 3 = 6` (`half_spin_balanced_steps`, forward `+` dagger) is even ⟹ the real fermion `−1`.

**Honest scope:** this proves the *structural core* — circulation integer-quantized, the `μ₄` quarter-turn
phase alphabet, the closed-loop **`balanced_closure_folds_real`** (a full theorem: even Pauli count ⟹ fold
`∈ {±I}`, never `±i`) with Jim's `dagger_doubles_pauli_count`, the cascade frequency-ordered with a floor,
prime closures irreducible.
It does **not** prove the `−5/3` spectrum (that is `QLF_Kolmogorov`, the *statistics* question), the
Kelvin-wave small-scale exponent (model-dependent), or the Vinen/Kolmogorov regime dynamics — those stay
the structural reading of `Turbulence.md` §2/§5. The Navier–Stokes no-blow-up is reduced in
`QLF_NavierStokesBKM`; the Riemann/GMC tie is a bridge candidate. Reuses `QLF_Turbulence` +
`QLF_StateSpace` + `QLF_PrimeResonance`; no new axioms. See `Turbulence.md`.
-/

namespace QLF.QuantumTurbulence

open QLF QLF.StateSpace QLF.Turbulence QLF.PrimeResonance QLF.Consciousness QLF.AngularMomentum

/-! ## Onsager–Feynman: circulation is quantized (reuse) -/

/-- **A vortex line is one circulation quantum** (`|ω| ≤ 1` per cell) — Onsager–Feynman, derived. -/
theorem vortex_is_one_quantum (a b c : Twist) : (vorticity a b c).natAbs ≤ 1 :=
  vortex_quantum a b c

/-- **Total circulation is an integer count of vortex quanta**, bounded by the cells threaded — the
    quantized-vortex tangle, not a continuous field. -/
theorem circulation_is_integer_quantized (ts : List Twist) :
    (circulation ts).natAbs ≤ ts.length :=
  circulation_integer_quantized ts

/-! ## The order-parameter phase quantum is a primitive quarter-turn (π/2) -/

/-- **The order-parameter phase closes after four quarter-turns.** Every closure folds to a phase
    `p ∈ μ₄`, and `p⁴ = 1`: four `π/2` quarter-turns make one full `2π` winding — the `q = 1`
    Onsager–Feynman vortex loop, expressed in the 8-twist algebra. -/
theorem phase_quantum_closes_after_four (p : PauliScalar) : p * p * p * p = 1 :=
  pauliScalar_pow_four_eq_one p

/-- **The phase quantum is a genuine quarter-turn — `i` has order exactly 4.** None of `i, i², i³` is
    the identity, so the phase increment cannot close in fewer than four steps: the winding is quantized
    in units of `π/2`, not `π` or `2π`. -/
theorem phase_quantum_is_quarter_turn :
    PauliScalar.i ≠ 1 ∧
    PauliScalar.i * PauliScalar.i ≠ 1 ∧
    PauliScalar.i * PauliScalar.i * PauliScalar.i ≠ 1 :=
  pauliScalar_i_order_four

/-- **The phase increment is a *primitive* 4th root of unity — exactly `π/2`.** In `ℂ` the generator
    `i` satisfies `i⁴ = 1` (closes after a full turn) but `i² ≠ 1` (a half-turn does *not* close): the
    order-parameter phase `e^{iS}` advances by a genuine quarter-turn per prime closure. This is the
    Onsager–Feynman quantization at the continuum-rendered level (`toComplex : μ₄ ↪ ℂˣ`). -/
theorem quarter_turn_primitive :
    Complex.I ^ 4 = 1 ∧ Complex.I ^ 2 ≠ 1 := by
  refine ⟨?_, ?_⟩
  · rw [show (4 : ℕ) = 2 + 2 by norm_num, pow_add, Complex.I_sq]; norm_num
  · rw [Complex.I_sq]
    intro h
    have hre : (-1 : ℂ).re = (1 : ℂ).re := by rw [h]
    norm_num at hre

/-- The phase group embeds into `ℂ` on the 4th roots of unity — the order parameter's phase is `μ₄`,
    not a continuous `U(1)`. -/
theorem phase_embeds_on_fourth_roots (p : PauliScalar) : (toComplex p) ^ 4 = 1 :=
  toComplex_pow_four p

/-! ## Closed loop folds real; the `±i` quarter-turn is the open forward half-strand -/

/-- **A count-balanced closure has an EVEN number of non-gauge (Pauli) twists** — the parity behind
    "a closed ZFA loop folds real, never `±i`" (issue #120, Jim's forward-odd `+` backward-odd `=` even).
    Each colour axis is paired (`#^=#v`, `#<=#>`, `#/=#\`), so the Pauli-twist count is `2·(#^+#<+#/)`.
    Since each Pauli twist contributes matrix `det = −1` and each gauge twist `det = +1`, the fold
    determinant is `(−1)^even = +1`, forcing the closure scalar `λ` (from `count_balanced_pauli_closed`)
    to satisfy `λ² = 1 ⟹ λ ∈ {+1, −1}` — the REAL subgroup (fermion `−1` / boson `+1`), **never** the
    quarter-turn `±i`. The `±i` (a genuine `μ₄` element) is the phase of an OPEN forward strand of *odd*
    Pauli count (e.g. the prime-3 proton strand `>^/`); the dagger (time-reversal, also odd) closes it —
    forward-odd `+` backward-odd `=` even (the half-spin `3 + 3 = 6`, `half_spin_balanced_steps`, with `3`
    prime, `half_spin_prime`). This parity is the crux of the full theorem `balanced_closure_folds_real`
    below; exhaustively reconfirmed in `brownian_closures.py` (0 balanced closures fold to `±i`). -/
theorem balanced_pauli_count_even {ts : List Twist} (h : countBalanced ts) :
    Even (ts.count Twist.up + ts.count Twist.down + ts.count Twist.left
          + ts.count Twist.right + ts.count Twist.slash + ts.count Twist.backslash) := by
  obtain ⟨hu, hl, hs, _⟩ := h
  exact ⟨ts.count Twist.up + ts.count Twist.left + ts.count Twist.slash, by
    rw [← hu, ← hl, ← hs]; ring⟩

/-- Non-gauge (Pauli) twists — the ones carrying `det = −1`. -/
def isPauli : Twist → Bool
  | Twist.plus  => false
  | Twist.minus => false
  | _           => true

/-- The determinant sign of each twist's matrix: `+1` for the gauge pair `±I`, `−1` for the six Pauli
    twists (`det σ = −1`, `det(−σ) = −1`). -/
noncomputable def detSign : Twist → ℂ
  | Twist.plus  => 1
  | Twist.minus => 1
  | _           => -1

/-- **The determinant of each twist matrix is its `detSign`.** `det σ = −1` (traceless involutory Pauli),
    `det(−σ) = (−1)²·det σ = −1`, `det(±I) = 1`. -/
theorem det_twistMatrix (t : Twist) : (Twist.toMatrix t).det = detSign t := by
  have hx : σx.det = -1 := by simp only [σx, Matrix.det_fin_two_of]; norm_num
  have hz : σz.det = -1 := by simp only [σz, Matrix.det_fin_two_of]; norm_num
  have hy : σy.det = -1 := by
    simp only [σy, Matrix.det_fin_two_of]
    rw [neg_mul, Complex.I_mul_I]; norm_num
  cases t
  · simpa [Twist.toMatrix, detSign] using hy
  · simp only [Twist.toMatrix, detSign]
    rw [show (-σy) = (-1 : ℂ) • σy by rw [neg_one_smul], Matrix.det_smul, Fintype.card_fin, hy]; norm_num
  · simp only [Twist.toMatrix, detSign]
    rw [show (-σx) = (-1 : ℂ) • σx by rw [neg_one_smul], Matrix.det_smul, Fintype.card_fin, hx]; norm_num
  · simpa [Twist.toMatrix, detSign] using hx
  · simpa [Twist.toMatrix, detSign] using hz
  · simp only [Twist.toMatrix, detSign]
    rw [show (-σz) = (-1 : ℂ) • σz by rw [neg_one_smul], Matrix.det_smul, Fintype.card_fin, hz]; norm_num
  · simp [Twist.toMatrix, detSign, Matrix.det_one]
  · simp only [Twist.toMatrix, detSign]
    rw [show (-1 : M) = (-1 : ℂ) • (1 : M) by rw [neg_one_smul], Matrix.det_smul, Fintype.card_fin,
       Matrix.det_one]; norm_num

/-- **The fold determinant is `(−1)` to the Pauli-twist count.** `det` is multiplicative over the ordered
    fold, and each twist contributes `detSign` (`−1` per Pauli, `+1` per gauge). -/
theorem det_twistMatrixFold (ts : List Twist) :
    (twistMatrixFold ts).det = (-1 : ℂ) ^ (ts.countP isPauli) := by
  induction ts with
  | nil => simp [twistMatrixFold, Matrix.det_one]
  | cons t rest ih =>
    have h1 : twistMatrixFold (t :: rest) = t.toMatrix * twistMatrixFold rest := by
      simp [twistMatrixFold]
    rw [h1, Matrix.det_mul, ih, det_twistMatrix, List.countP_cons, pow_add]
    cases t <;> simp [detSign, isPauli, pow_one, pow_zero]

/-- The Pauli-twist count equals the sum of the six non-gauge twist counts. -/
theorem countP_isPauli_eq (ts : List Twist) :
    ts.countP isPauli = ts.count Twist.up + ts.count Twist.down + ts.count Twist.left
      + ts.count Twist.right + ts.count Twist.slash + ts.count Twist.backslash := by
  induction ts with
  | nil => rfl
  | cons t rest ih =>
    cases t <;>
      simp [List.countP_cons, List.count_cons, isPauli, ih] <;>
      omega

/-- **A closed ZFA loop folds to the REAL subgroup `{±I}`, never the quarter-turn `±iI`** — the full
    determinant statement, now a theorem (previously the cited bridge). A count-balanced closure has an
    even Pauli-twist count (`balanced_pauli_count_even`, via `countP_isPauli_eq`), so its fold determinant
    is `(−1)^even = 1` (`det_twistMatrixFold`); with `fold = coePS p • I` (`count_balanced_pauli_closed`),
    `det = (coePS p)² = 1`, which excludes `p ∈ {i, negI}` (whose squares are `−1`). Hence the fold is
    `+I` (boson, 720°) or `−I` (fermion, 360°) — the `±i` open-strand quarter-turn cannot survive closure. -/
theorem balanced_closure_folds_real {ts : List Twist} (h : countBalanced ts) :
    twistMatrixFold ts = 1 ∨ twistMatrixFold ts = -1 := by
  obtain ⟨p, hp⟩ := count_balanced_pauli_closed h
  have hdet1 : (twistMatrixFold ts).det = 1 := by
    rw [det_twistMatrixFold]
    have he : Even (ts.countP isPauli) := by
      rw [countP_isPauli_eq]; exact balanced_pauli_count_even h
    exact he.neg_one_pow
  have hp2 : (coePS p) ^ 2 = 1 := by
    rw [hp, pauliScalarToMatrix_eq, Matrix.det_smul, Fintype.card_fin, Matrix.det_one, mul_one] at hdet1
    exact hdet1
  rw [hp]
  cases p with
  | one => left; rfl
  | negOne => right; rfl
  | i => exfalso; simp only [coePS] at hp2; rw [Complex.I_sq] at hp2; norm_num at hp2
  | negI => exfalso; simp only [coePS] at hp2; rw [neg_sq, Complex.I_sq] at hp2; norm_num at hp2

/-! ## Forward-odd `+` backward-odd `=` even (Jim's parity) -/

/-- The Hermitian-conjugate map preserves gauge-vs-Pauli, so the dagger of a strand has the same
    Pauli-twist count. -/
theorem conj_preserves_isPauli (t : Twist) : isPauli (Twist.conj t) = isPauli t := by
  cases t <;> rfl

theorem countP_map_conj (ts : List Twist) :
    (ts.map Twist.conj).countP isPauli = ts.countP isPauli := by
  induction ts with
  | nil => rfl
  | cons t rest ih =>
    simp only [List.map_cons, List.countP_cons, ih, conj_preserves_isPauli]

/-- Time-reversal (the Hermitian-conjugate dagger): reverse the history and conjugate each twist. -/
def dagger (ts : List Twist) : List Twist := (ts.map Twist.conj).reverse

/-- **Forward-odd `+` backward-odd `=` even (Jim).** A strand concatenated with its dagger has twice the
    strand's Pauli count — always even. So an open *odd*-Pauli forward strand (carrying the quarter-turn
    `±i`) closes with its odd time-reverse into an even loop, which folds to the real `±1`
    (`balanced_closure_folds_real` when count-balanced). The half-spin `3 + 3 = 6` is the archetype. -/
theorem dagger_doubles_pauli_count (ts : List Twist) :
    Even ((ts ++ dagger ts).countP isPauli) := by
  refine ⟨ts.countP isPauli, ?_⟩
  rw [List.countP_append, dagger, List.countP_reverse, countP_map_conj]

/-! ## The cascade: highest-frequency-first, down to a floor (reuse) -/

/-- **Highest frequency resolves first.** A smaller eddy (shorter period `R_small < R_large`) is a
    *higher*-frequency closure (`freq R_large < freq R_small`): the cascade is the frequency-ordered
    resolution of the coexisting closures, smallest/highest-`f` first. -/
theorem highest_frequency_resolves_first {R_small R_large : ℕ}
    (h0 : 0 < R_small) (h : R_small < R_large) :
    freq R_large < freq R_small :=
  cascade_frequency_increases h0 h

/-- **The cascade has a floor.** Every eddy has period `R ≥ R_min` (the Kolmogorov / healing-length /
    Planck scale), so its frequency `≤ freq R_min`: no infinite cascade, reconnection at the floor. -/
theorem cascade_has_floor {R_min R : ℕ} (h0 : 0 < R_min) (h : R_min ≤ R) :
    freq R ≤ freq R_min :=
  cascade_capped h0 h

/-! ## Prime closures are the irreducible phase-shift agents (reuse) -/

/-- **A prime-period closure is irreducible** — its only divisors are `1` and itself, so the vacuum
    cannot factor it into a repeat of a shorter closure. The prime closures' odd forward strands carry
    the `±i` quarter-turn; ordinary closures decompose into them. -/
theorem prime_closure_irreducible {R : ℕ} (h : R.Prime) :
    ∀ d, d ∣ R → d = 1 ∨ d = R :=
  prime_freq_irreducible h

/-- **The half-spin is the minimal irreducible phase agent** — period `3` (prime), the same lock as the
    proton, so its `μ₄` phase shift cannot be decomposed. -/
theorem half_spin_is_prime_agent :
    Nat.Prime halfSpinSteps ∧ (∀ d, d ∣ halfSpinSteps → d = 1 ∨ d = halfSpinSteps) :=
  ⟨half_spin_prime, half_spin_irreducible⟩

/-- **Established (the superfluid-turbulence dynamical picture, §5/§8 of `Turbulence.md`).**
    Onsager–Feynman circulation is integer-quantized (`vortex_is_one_quantum`,
    `circulation_is_integer_quantized`); the phase alphabet is `μ₄` with a *primitive* quarter-turn `π/2`
    generator (`quarter_turn_primitive`, `phase_quantum_is_quarter_turn`, `phase_quantum_closes_after_four`),
    but a **closed** ZFA loop folds to the **real** subgroup `{±1}` (fermion `−1` / boson `+1`) —
    `balanced_closure_folds_real`, never `±i`, because its Pauli-twist count is even
    (`balanced_pauli_count_even`); the `±i` quarter-turn is the OPEN forward half-strand, closed by its odd
    time-reverse dagger (forward-odd `+` backward-odd `=` even, `dagger_doubles_pauli_count`); the cascade
    resolves highest-frequency-first (`highest_frequency_resolves_first`) down to a dissipation floor
    (`cascade_has_floor`); and prime closures are the irreducible agents (`prime_closure_irreducible`,
    `half_spin_is_prime_agent`). Together: turbulence is a frequency-ordered resolution of coexisting
    quantized-vortex closures, prime closures' open strands driving the discrete `μ₄` quarter-turn phase
    shifts that close into real `±1` loops. **Honest scope:** the structural core + the proven
    `balanced_closure_folds_real` (even Pauli count ⟹ fold real, never `±i`) + `dagger_doubles_pauli_count`;
    *not* the `−5/3` spectrum (`QLF_Kolmogorov`), the Kelvin-wave exponent, or the regime dynamics. No new
    axioms. See `Turbulence.md`. -/
theorem quantum_turbulence_summary : True := trivial

end QLF.QuantumTurbulence

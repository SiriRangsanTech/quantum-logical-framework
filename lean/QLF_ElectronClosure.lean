-- QLF_ElectronClosure.lean
-- The electron as a closed periodic mode, and charge as the residue of non-closure.
--
-- Three questions this module settles, each of which `Electron.md` previously
-- stated in prose and in one case stated inconsistently:
--
-- 1. **Is the electron open or closed?**  Both, at two different levels, and the
--    levels are different *axes* of the alphabet. The internal spin cycle `^<v>`
--    is count-balanced and folds to `−I` — a completed half-spin closure. The
--    charge is an unmatched **gauge** twist, and it is exactly what has *not*
--    closed. So "an open Hermitian deficit" and "ZFA closed: True" were both
--    right about different things.
--
-- 2. **Is Hermiticity the same as closure?**  No. The prefix `^<v` folds to
--    `−σx`, which is Hermitian, yet the history is unbalanced (`<` unmatched).
--    `hermitian_not_implies_zfa` records the counterexample. A mode is manifest
--    at a completed cycle, not at a Hermitian intermediate.
--
-- 3. **Is there charge "between" electrons of different energy or spin?**  No —
--    and this is a theorem, not a stance. `twistCharge` vanishes on every one of
--    the six spatial twists (`twistCharge_eq_zero_of_spatial`), so charge is a
--    function of the gauge counts alone (`chiralCharge_determined_by_gauge`).
--    Spin and energy are spatial content. Hence two electron modes differing
--    only in spatial content — any spin, any harmonic — carry **exactly zero**
--    charge difference (`no_charge_between_spatial_modes`). The electromagnetic
--    coupling is blind to spin and energy because charge does not live on those
--    axes. What is left over is the common gauge deficit, which is why an
--    electron still needs a partner to close.
--
-- Two further results support the "manifest only at full cycles" reading:
-- distinct full-cycle harmonics have zero coherent overlap (`harmonics_orthogonal`
-- — Kronecker delta from Kraft-free geometry: a geometric sum of a root of unity)
-- and the two spin channels are orthogonal projectors (`spin_projectors_orthogonal`).
-- Together: `Γ[(m,s),(n,s')] = δ_mn δ_ss'` (`channelKernel_diagonal`).
--
-- Scale: no length parameter occurs anywhere in the closure predicate — that is
-- the honest form of "the electron has no hard radius", an *absence*, not a
-- theorem. What the closure does fix is a period, and `rest_period_times_c` /
-- `compton_full_cycle` relate it to the Compton and reduced Compton lengths.
--
-- Zero axioms.

import QLF_Spin
import Mathlib

namespace QLF

-- `twistCharge` / `chiralCharge` live in `QLF.Spin`.
open QLF.Spin

-- ==========================================
-- 1. Two closures: the cycle closes, the charge does not
-- ==========================================

/-- The electron's internal cycle `^<v>` — the canonical completed half-spin mode. -/
def electronCycle : List Twist := [Twist.up, Twist.left, Twist.down, Twist.right]

/-- An intermediate prefix `^<v`: a legitimate state, but not a completed cycle. -/
def electronPrefix : List Twist := [Twist.up, Twist.left, Twist.down]

/-- **The electron cycle is ZFA-closed.** `#^ = #v`, `#< = #>`, no gauge content. -/
theorem electronCycle_countBalanced : countBalanced electronCycle := by
  unfold countBalanced electronCycle
  decide

/-- **The electron cycle folds to `−I`** — the half-spin fermion sign, needing
    `720°` to return. Reuse of the cross-axis interleaving theorem. -/
theorem electronCycle_folds_negI :
    twistMatrixFold electronCycle = pauliScalarToMatrix PauliScalar.negOne :=
  interleaved_xlvr_folds_to_negI

/-- **The prefix is not closed.** One `<` is unmatched: free action `F = 1`. -/
theorem electronPrefix_not_countBalanced : ¬ countBalanced electronPrefix := by
  unfold countBalanced electronPrefix
  decide

/-- The prefix folds to `−σx`. -/
theorem electronPrefix_fold : twistMatrixFold electronPrefix = -σx := by
  simp only [electronPrefix, twistMatrixFold, List.foldr_cons, List.foldr_nil,
    Matrix.mul_one]
  apply Matrix.ext; intro i j
  fin_cases i <;> fin_cases j <;>
    simp only [Twist.toMatrix, σx, σy, σz,
      Matrix.mul_apply, Fin.sum_univ_two, Matrix.neg_apply, Matrix.one_apply,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
      Matrix.head_fin_const] <;>
    apply Complex.ext <;>
    simp [Complex.mul_re, Complex.mul_im, Complex.add_re, Complex.add_im,
          Complex.neg_re, Complex.neg_im, Complex.I_re, Complex.I_im,
          Complex.ofReal_re, Complex.ofReal_im] <;>
    ring

/-- `−σx` is Hermitian. -/
theorem neg_sigmax_hermitian : (-σx : M).conjTranspose = -σx := by
  apply Matrix.ext; intro i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.conjTranspose_apply, Matrix.neg_apply, σx]

/-- **Hermitian does not imply ZFA-closed.** The prefix `^<v` folds to the
    Hermitian `−σx` while carrying non-zero free action. Self-adjointness is a
    property of the *operator*; closure is a property of the *history*. So an
    electron is not manifest merely because its intermediate is self-adjoint —
    it is manifest at the completed cycle. -/
theorem hermitian_not_implies_zfa :
    (twistMatrixFold electronPrefix).conjTranspose = twistMatrixFold electronPrefix ∧
      ¬ countBalanced electronPrefix := by
  refine ⟨?_, electronPrefix_not_countBalanced⟩
  rw [electronPrefix_fold]
  exact neg_sigmax_hermitian

-- ==========================================
-- 2. Charge is the unmatched gauge count
-- ==========================================

/-- Charge is the signed gauge count, and nothing else. -/
theorem chiralCharge_eq_gauge_counts (ts : List Twist) :
    chiralCharge ts = (ts.count Twist.plus : Int) - (ts.count Twist.minus : Int) := by
  induction ts with
  | nil => rfl
  | cons a rest ih =>
    have hc : chiralCharge (a :: rest) = twistCharge a + chiralCharge rest := by
      simp [chiralCharge]
    rw [hc, ih]
    cases a <;> simp [twistCharge, List.count_cons] <;> push_cast <;> ring

/-- **A ZFA-closed history is electrically neutral.** Charge is precisely the
    residue of non-closure: what is left unmatched on the gauge axis. This is
    the exact sense in which charge is *emergent* rather than fundamental — it
    is a count of what has not yet closed, carried by no field and by no point. -/
theorem zfa_closure_is_neutral {ts : List Twist} (h : countBalanced ts) :
    chiralCharge ts = 0 := by
  rw [chiralCharge_eq_gauge_counts, h.2.2.2, sub_self]

/-- Every spatial twist is charge-neutral. -/
theorem twistCharge_eq_zero_of_spatial {t : Twist}
    (h1 : t ≠ Twist.plus) (h2 : t ≠ Twist.minus) : twistCharge t = 0 := by
  cases t <;> simp_all [twistCharge]

theorem chiralCharge_append (l₁ l₂ : List Twist) :
    chiralCharge (l₁ ++ l₂) = chiralCharge l₁ + chiralCharge l₂ := by
  simp [chiralCharge, List.map_append, List.sum_append]

/-- A history built only from charge-neutral twists carries no charge. -/
theorem chiralCharge_eq_zero_of_all_zero {l : List Twist}
    (h : ∀ t ∈ l, twistCharge t = 0) : chiralCharge l = 0 := by
  induction l with
  | nil => rfl
  | cons a rest ih =>
    have ha : twistCharge a = 0 := h a (List.mem_cons_self a rest)
    have hr : chiralCharge rest = 0 := ih fun t ht => h t (List.mem_cons_of_mem a ht)
    have hc : chiralCharge (a :: rest) = twistCharge a + chiralCharge rest := by
      simp [chiralCharge]
    rw [hc, ha, hr, add_zero]

/-- **Charge is determined by the gauge counts alone.** -/
theorem chiralCharge_determined_by_gauge (ts us : List Twist)
    (hp : ts.count Twist.plus = us.count Twist.plus)
    (hm : ts.count Twist.minus = us.count Twist.minus) :
    chiralCharge ts = chiralCharge us := by
  rw [chiralCharge_eq_gauge_counts, chiralCharge_eq_gauge_counts, hp, hm]

/-- **No charge between electron modes of different energy or spin.**
    Spin and energy are *spatial* content — the axis word and its depth — while
    charge lives on the gauge axis, where `twistCharge` is the only non-zero
    weight. So two modes carrying the same gauge deficit and *any* spatial
    content whatever — different harmonics, opposite spins — have **exactly
    zero** charge difference. There is no charge *between* them: the
    electromagnetic weight cannot see a spin or an energy.

    Scope, stated sharply: this says the charge *difference* is zero, so no
    Coulomb channel is opened or closed by a difference of spin or energy. It
    does not say the shared gauge deficit vanishes — that residue is the common
    charge, and it is exactly why an electron must still find a partner. -/
theorem no_charge_between_spatial_modes (gauge sp₁ sp₂ : List Twist)
    (h₁ : ∀ t ∈ sp₁, twistCharge t = 0) (h₂ : ∀ t ∈ sp₂, twistCharge t = 0) :
    chiralCharge (sp₁ ++ gauge) = chiralCharge (sp₂ ++ gauge) := by
  rw [chiralCharge_append, chiralCharge_append,
    chiralCharge_eq_zero_of_all_zero h₁, chiralCharge_eq_zero_of_all_zero h₂]

/-- The spatial alphabet, as the hypothesis `no_charge_between_spatial_modes` needs. -/
theorem electronCycle_all_neutral : ∀ t ∈ electronCycle, twistCharge t = 0 := by
  intro t ht
  cases t
  case up => rfl
  case down => rfl
  case left => rfl
  case right => rfl
  case slash => rfl
  case backslash => rfl
  case plus => simp [electronCycle] at ht
  case minus => simp [electronCycle] at ht

-- ==========================================
-- 3. The charged electron, and the manifest joint event
-- ==========================================

/-- The electron *with* its gauge deficit: the closed cycle plus one unmatched `+`. -/
def electronCharged : List Twist := electronCycle ++ [Twist.plus]

/-- The positron's cycle — the electron's, read from behind. -/
def positronCycle : List Twist := [Twist.down, Twist.right, Twist.up, Twist.left]

/-- Positronium: two cycles and a matched gauge pair. -/
def positronium : List Twist :=
  electronCycle ++ [Twist.plus] ++ positronCycle ++ [Twist.minus]

/-- **The charge is the deficit**: the charged electron carries `+1`. -/
theorem electronCharged_charge : chiralCharge electronCharged = 1 := by
  unfold chiralCharge electronCharged electronCycle
  decide

/-- …and is therefore *not* ZFA-closed. The cycle closed; the charge did not. -/
theorem electronCharged_not_countBalanced : ¬ countBalanced electronCharged := by
  unfold countBalanced electronCharged electronCycle
  decide

/-- **The manifest event is the joint closure** — and it is neutral. -/
theorem positronium_countBalanced : countBalanced positronium := by
  unfold countBalanced positronium electronCycle positronCycle
  decide

theorem positronium_neutral : chiralCharge positronium = 0 :=
  zfa_closure_is_neutral positronium_countBalanced

-- ==========================================
-- 4. A joint closure does not need matching components
-- ==========================================

/-- A deep (high-excursion) open half. -/
def openDeep : List Twist := [Twist.up, Twist.up, Twist.left, Twist.right]

/-- A shallow open half, of a different length. -/
def openShallow : List Twist := [Twist.down, Twist.down]

/-- **Unequal components, one closed event.** Neither half is balanced, they are
    not even the same length, and their joint history closes. So a joint closure
    places no constraint on the individual modes — only on the total. Electrons
    of different energies *can* enter one closed event; what cannot happen is a
    completed event with unmatched conserved distinctions. -/
theorem joint_closure_allows_unequal_components :
    ¬ countBalanced openDeep ∧ ¬ countBalanced openShallow ∧
      countBalanced (openDeep ++ openShallow) ∧
      openDeep.length ≠ openShallow.length := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · unfold countBalanced openDeep; decide
  · unfold countBalanced openShallow; decide
  · unfold countBalanced openDeep openShallow; decide
  · unfold openDeep openShallow; decide

-- ==========================================
-- 5. Manifest at full cycles: harmonic orthogonality
-- ==========================================

/-- The coherent overlap of two full-cycle harmonics over one period of `N`
    steps, with `ζ` the ratio of their phase steps. -/
noncomputable def cycleOverlap (N : ℕ) (ζ : ℂ) : ℂ :=
  (N : ℂ)⁻¹ * ∑ k ∈ Finset.range N, ζ ^ k

/-- A mode overlaps itself completely. -/
theorem cycleOverlap_same (N : ℕ) (hN : N ≠ 0) : cycleOverlap N 1 = 1 := by
  have hN' : (N : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hN
  simp [cycleOverlap, Finset.card_range, hN']

/-- **Distinct full-cycle harmonics have zero coherent overlap.** A root of unity
    other than `1` sums to zero over a full period — the geometric series
    telescopes because the cycle *closes*. This is why a quantity is invariant
    only at a completed cycle: over anything less, the cross terms survive. -/
theorem cycleOverlap_distinct {ζ : ℂ} (N : ℕ) (hpow : ζ ^ N = 1) (hne : ζ ≠ 1) :
    cycleOverlap N ζ = 0 := by
  unfold cycleOverlap
  rw [geom_sum_eq hne N, hpow, sub_self, zero_div, mul_zero]

/-- The Kronecker delta on harmonics, in the form the census supplies it. -/
theorem harmonics_orthogonal {ζ : ℂ} {N : ℕ} (hζ : IsPrimitiveRoot ζ N)
    {m n : ℕ} (hn : n < N) (hmn : m < n) :
    cycleOverlap N (ζ ^ (n - m)) = 0 := by
  have hd0 : n - m ≠ 0 := Nat.sub_ne_zero_of_lt hmn
  have hdN : n - m < N := lt_of_le_of_lt (Nat.sub_le n m) hn
  have hne : ζ ^ (n - m) ≠ 1 := hζ.pow_ne_one_of_pos_of_lt hd0 hdN
  have hpow : (ζ ^ (n - m)) ^ N = 1 := by
    rw [← pow_mul, mul_comm, pow_mul, hζ.pow_eq_one, one_pow]
  exact cycleOverlap_distinct N hpow hne

-- ==========================================
-- 6. The two spin channels are orthogonal
-- ==========================================

/-- The spin-up channel projector. -/
noncomputable def projUp : M := !![1, 0; 0, 0]

/-- The spin-down channel projector. -/
noncomputable def projDown : M := !![0, 0; 0, 1]

/-- These are the spectral projectors of `σ_z`: `P↑ = ½(1 + σ_z)`. -/
theorem projUp_eq_half : projUp = (2 : ℂ)⁻¹ • ((1 : M) + σz) := by
  apply Matrix.ext; intro i j
  fin_cases i <;> fin_cases j <;>
    simp [projUp, σz, Matrix.smul_apply, Matrix.add_apply, Matrix.one_apply] <;>
    norm_num

/-- …and `P↓ = ½(1 − σ_z)`. -/
theorem projDown_eq_half : projDown = (2 : ℂ)⁻¹ • ((1 : M) - σz) := by
  apply Matrix.ext; intro i j
  fin_cases i <;> fin_cases j <;>
    simp [projDown, σz, Matrix.smul_apply, Matrix.sub_apply, Matrix.one_apply] <;>
    norm_num

/-- **The two spin channels are orthogonal.** -/
theorem spin_projectors_orthogonal : projUp * projDown = 0 := by
  apply Matrix.ext; intro i j
  fin_cases i <;> fin_cases j <;>
    simp [projUp, projDown, Matrix.mul_apply, Fin.sum_univ_two]

theorem projUp_idem : projUp * projUp = projUp := by
  apply Matrix.ext; intro i j
  fin_cases i <;> fin_cases j <;>
    simp [projUp, Matrix.mul_apply, Fin.sum_univ_two]

/-- The overlap of two spin channels. -/
noncomputable def spinOverlap (P Q : M) : ℂ := (P * Q).trace

theorem spinOverlap_opposite : spinOverlap projUp projDown = 0 := by
  unfold spinOverlap
  rw [spin_projectors_orthogonal, Matrix.trace_zero]

theorem spinOverlap_same : spinOverlap projUp projUp = 1 := by
  unfold spinOverlap
  rw [projUp_idem, Matrix.trace_fin_two]
  simp [projUp]

-- ==========================================
-- 7. The channel kernel is diagonal
-- ==========================================

/-- The coherent channel kernel between two electron modes: harmonic overlap
    times spin overlap. -/
noncomputable def channelKernel (N : ℕ) (ζ : ℂ) (P Q : M) : ℂ :=
  cycleOverlap N ζ * spinOverlap P Q

/-- **`Γ[(m,s),(n,s')] = δ_mn δ_ss'`.** Different harmonics, or opposite spins,
    carry no coherent cross term at all — the two ways of being a different mode
    each kill the kernel on their own. -/
theorem channelKernel_diagonal (N : ℕ) (ζ : ℂ) :
    channelKernel N ζ projUp projDown = 0 ∧
      (ζ ^ N = 1 → ζ ≠ 1 → channelKernel N ζ projUp projUp = 0) ∧
      (N ≠ 0 → channelKernel N 1 projUp projUp = 1) := by
  unfold channelKernel
  refine ⟨?_, ?_, ?_⟩
  · rw [spinOverlap_opposite, mul_zero]
  · intro hpow hne
    rw [cycleOverlap_distinct N hpow hne, zero_mul]
  · intro hN
    rw [cycleOverlap_same N hN, spinOverlap_same, mul_one]

-- ==========================================
-- 8. The scale a closure fixes is a period, not a radius
-- ==========================================

/-- The closure period of a mode of energy `E`: `T = h/E`. -/
noncomputable def closurePeriod (planckH E : ℝ) : ℝ := planckH / E

/-- The spatial period of a mode of momentum `p`: `λ = h/p` (de Broglie). -/
noncomputable def closureWavelength (planckH p : ℝ) : ℝ := planckH / p

/-- **The rest closure period, carried at `c`, is the Compton wavelength.**
    `c · (h / mc²) = h / mc`. The electron's intrinsic scale is the length its
    own closure takes to complete — not a radius it occupies. -/
theorem rest_period_times_c (planckH m c : ℝ) (hm : m ≠ 0) (hc : c ≠ 0) :
    c * closurePeriod planckH (m * c ^ 2) = closureWavelength planckH (m * c) := by
  unfold closurePeriod closureWavelength
  field_simp <;> ring

/-- **A full cycle is `2π` radians.** The Compton wavelength is `2π` times the
    reduced length `ħ/(mc)`, which is the one-*radian* length. The full cycle is
    the manifest one, which is why `λ_C`, not `ƛ_C`, is the electron's scale. -/
theorem compton_full_cycle (hbar m c : ℝ) (hm : m ≠ 0) (hc : c ≠ 0) :
    closureWavelength (2 * Real.pi * hbar) (m * c) = 2 * Real.pi * (hbar / (m * c)) := by
  unfold closureWavelength
  field_simp <;> ring

end QLF

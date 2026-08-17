import QLF_TwistAlphabet
import Mathlib

set_option linter.unusedVariables false

/-!
# QLF_BalancedPhaseReal — balance forces a **real** phase: closures fold to `±I`, never `±iI`

`count_balanced_pauli_closed` ([`QLF_TwistAlphabet`](QLF_TwistAlphabet.lean)) proves a count-balanced
history folds to a Pauli scalar in `μ₄ = {±1, ±i}`. Empirically the `±i` cases never occurred —
exhaustively over all 5,296 balanced histories of length ≤ 6, and in 80,000 samples at length 8–14
([`QLF_PhaseAssignment`](QLF_PhaseAssignment.lean)). This module proves they cannot:

> **`balanced_phase_is_real`** — a count-balanced history folds to `+I` or `−I`. The phase group on
> closures is `μ₂`, not `μ₄`.

## The proof — one line of physics, and it is order-blind

Take determinants. Each axis twist maps to `±σ`, and every `σ` has `det = −1`; each gauge twist maps to
`±I`, with `det = +1` (in `2×2`, negation does not change the determinant). Determinant is
multiplicative, so

```
det (fold h) = (−1) ^ (number of axis twists in h)
```

Count balance makes that exponent **even** — `#^ = #v`, `#< = #>`, `#/ = #\` give
`2(#^ + #> + #/)` axis letters — so `det (fold h) = 1`. And if the fold is the scalar `c·I`, then
`det = c²`. Hence `c² = 1`, so `c = ±1`: the `±i` scalars are excluded because they have `det = −1`.

**Why it works for every ordering at once.** The determinant does not see order. Anticommutation moves
signs around inside the product, but no rearrangement changes `det`, so a single computation settles
every interleaving simultaneously — no case analysis over orderings, and no appeal to the normal form.

**This is *a* proof, not *the* proof.** The same fact may well fall out of the `nf_decomp` phase
bookkeeping or a parity argument on the symplectic form over `𝔽₂`; nothing here claims the determinant
route is the only one ([`Law_Of_Exceptions.md`](../Law_Of_Exceptions.md) §7: construction proves
possibility, not uniqueness).

## What it changes

Branch amplitudes over the balanced census are **integers**, not Gaussian integers: each way contributes
`±1`, so a branch's amplitude is a signed count and its weight a perfect square. That is a real
narrowing of the Born picture built in [`QLF_Degeneracy`](QLF_Degeneracy.lean) — the `μ₄` freedom it
allowed is not exercised on closures — and it matches the measured census (at length 6: `1 488` ways at
`+1`, `3 632` at `−1`, amplitude `−2 144`).

No axioms.
-/

namespace QLF.BalancedPhaseReal

open QLF

/-- The six axis twists (as opposed to the two gauge twists `+`, `−`). -/
def isAxis : Twist → Bool
  | Twist.plus  => false
  | Twist.minus => false
  | _           => true

/-- How many axis twists a history contains. -/
def axisLen : List Twist → ℕ
  | [] => 0
  | t :: rest => (if isAxis t then 1 else 0) + axisLen rest

/-- **Each twist's determinant**: `−1` for an axis twist (every Pauli matrix has `det = −1`, and in
    `2×2` negation leaves the determinant alone), `+1` for a gauge twist. -/
theorem det_toMatrix (t : Twist) :
    (t.toMatrix).det = if isAxis t then (-1 : ℂ) else 1 := by
  cases t <;>
    simp [Twist.toMatrix, isAxis, σx, σy, σz, Matrix.det_fin_two_of, Matrix.det_neg,
      Matrix.det_one] <;>
    norm_num [Complex.I_mul_I]

/-- **The determinant of a fold counts its axis twists** — multiplicativity of `det`, and nothing
    else. Note this is insensitive to the order of the history. -/
theorem det_fold (ts : List Twist) :
    (twistMatrixFold ts).det = (-1 : ℂ) ^ (axisLen ts) := by
  induction ts with
  | nil => simp [twistMatrixFold, axisLen]
  | cons t rest ih =>
      have hfold : twistMatrixFold (t :: rest) = t.toMatrix * twistMatrixFold rest := by
        simp [twistMatrixFold]
      rw [hfold, Matrix.det_mul, ih, det_toMatrix]
      cases h : isAxis t <;> simp [axisLen, h] <;> ring

/-- The axis length is the total count of the six axis twists. -/
theorem axisLen_eq_counts (ts : List Twist) :
    axisLen ts = ts.count Twist.up + ts.count Twist.down + ts.count Twist.left
      + ts.count Twist.right + ts.count Twist.slash + ts.count Twist.backslash := by
  induction ts with
  | nil => simp [axisLen]
  | cons t rest ih =>
      cases t <;> simp +decide [axisLen, isAxis, List.count_cons, ih] <;> omega

/-- **Count balance makes the axis length even** — the three axis pairs contribute
    `2(#^ + #> + #/)`. -/
theorem axisLen_even_of_balanced {ts : List Twist} (h : countBalanced ts) :
    Even (axisLen ts) := by
  obtain ⟨h1, h2, h3, h4⟩ := h
  rw [axisLen_eq_counts]
  refine ⟨ts.count Twist.up + ts.count Twist.right + ts.count Twist.slash, ?_⟩
  omega

/-- **The fold of a balanced history has determinant `1`.** -/
theorem det_fold_balanced {ts : List Twist} (h : countBalanced ts) :
    (twistMatrixFold ts).det = 1 := by
  rw [det_fold]
  exact (axisLen_even_of_balanced h).neg_one_pow

/-- The `±i` scalars are exactly the ones with determinant `−1`. -/
theorem det_pauliScalar (p : PauliScalar) :
    (pauliScalarToMatrix p).det = if p = PauliScalar.one ∨ p = PauliScalar.negOne then 1 else -1 := by
  cases p <;>
    simp [pauliScalarToMatrix, Matrix.det_one, Matrix.det_neg, Matrix.det_smul] <;>
    norm_num [Complex.I_mul_I]

/-- **Balance forces a real phase.** A count-balanced history folds to `+I` or `−I` — never `±iI`. The
    phase group on closures is `μ₂`, not `μ₄`, so a way contributes `±1` and a branch amplitude is a
    signed **integer** count. -/
theorem balanced_phase_is_real {ts : List Twist} (h : countBalanced ts) :
    twistMatrixFold ts = 1 ∨ twistMatrixFold ts = -1 := by
  obtain ⟨p, hp⟩ := count_balanced_pauli_closed h
  have hdet : (pauliScalarToMatrix p).det = 1 := by rw [← hp]; exact det_fold_balanced h
  rw [det_pauliScalar] at hdet
  by_cases hc : p = PauliScalar.one ∨ p = PauliScalar.negOne
  · rcases hc with hc | hc
    · left; rw [hp, hc]; simp [pauliScalarToMatrix]
    · right; rw [hp, hc]; simp [pauliScalarToMatrix]
  · rw [if_neg hc] at hdet
    exact absurd hdet (by norm_num)

/-! ### And there is an exception — exactly where the hypothesis fails

The restriction is genuinely a restriction *by balance*. Drop it and `μ₄` is fully exercised: the
unbalanced history `^ > /` (one twist on each axis) folds to `−iI`, because `σx σz = −iσy` and
`σy · (−iσy) = −i·I`. So the hypothesis is load-bearing, not decoration — and the Law of Exceptions
holds of this law too, its exception living precisely outside the balanced sector (48 such histories at
length 3 alone). -/

/-- **The unbalanced sector does reach `±i`.** `^ > /` folds to `−iI`. -/
theorem unbalanced_can_be_imaginary :
    twistMatrixFold [Twist.up, Twist.right, Twist.slash] = -(Complex.I • (1 : M)) := by
  show Twist.up.toMatrix * (Twist.right.toMatrix * (Twist.slash.toMatrix * 1)) = _
  simp only [Twist.toMatrix, mul_one]
  rw [sigma_xz, mul_neg, mul_smul_comm, sigma_y_sq]

/-- And that witness is indeed **not** count-balanced — so it is an exception to the law's *scope*,
    not a counterexample to the law. -/
theorem unbalanced_witness_not_balanced :
    ¬ countBalanced [Twist.up, Twist.right, Twist.slash] := by
  simp [countBalanced]

/-- **Established constructively, no axioms.** A count-balanced history folds to `±I`, never `±iI`
    (`balanced_phase_is_real`), so the phase group on closures is `μ₂` rather than the `μ₄` that
    `count_balanced_pauli_closed` allows. The proof is one determinant computation:
    every Pauli matrix has `det = −1` and every gauge matrix `det = +1` (`det_toMatrix`), `det` is
    multiplicative (`det_fold`), balance makes the number of axis twists even
    (`axisLen_even_of_balanced`), so `det (fold) = 1` (`det_fold_balanced`) — while `±iI` have
    `det = −1` (`det_pauliScalar`). **It settles every ordering at once because `det` cannot see
    order**, which is why no case analysis over interleavings is needed. *A* proof, not *the* proof —
    a parity argument on the symplectic form, or the `nf_decomp` phase bookkeeping, would likely serve
    too. **Consequence:** branch amplitudes over the balanced census are signed **integers**, not
    Gaussian integers, so the `μ₄` freedom assumed in `QLF_Degeneracy` is never exercised on closures
    and every branch weight is a perfect square. **And the law has its exception**, exactly outside its
    hypothesis: the unbalanced `^ > /` folds to `−iI` (`unbalanced_can_be_imaginary`,
    `unbalanced_witness_not_balanced`), so balance is load-bearing rather than decorative and `μ₄` is
    genuinely reached once it is dropped. -/
theorem balanced_phase_real_summary : True := trivial

end QLF.BalancedPhaseReal

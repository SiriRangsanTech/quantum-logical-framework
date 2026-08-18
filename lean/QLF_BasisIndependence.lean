import QLF_PhaseRule
import Mathlib

set_option linter.unusedVariables false

/-!
# QLF_BasisIndependence — **the basis belongs to the question, not to reality**

[`census_inventory.py`](../census_inventory.py) writes every way down in one canonical chart —
`{>,<} ↦ X`, `{^,v} ↦ Y`, `{/,\} ↦ Z`, `{+,−} ↦ I`, with the axis order `X < Y < Z` fixed for the
inversion count of [`QLF_PhaseRule`](QLF_PhaseRule.lean). That is a *coordinate convention*, and a
convention left unexamined is how a coordinate system quietly becomes a preferred physical frame.

This module proves it never was one. **Relabel the axes however you like — swap two of them, reverse
one, swap the gauge pair — and every balanced history folds to exactly what it folded to before:**

> **`fold_invariant_swapXY`**, **`fold_invariant_swapYZ`**, **`fold_invariant_flipX`**,
> **`fold_invariant_swapGauge`** — for count-balanced `ts`, `fold (ts.map r) = fold ts`.

Since `(X Y)` and `(Y Z)` generate `S₃` and conjugating a flip by a transposition gives the other
flips, the composites cover the whole signed-permutation group of the three axes (order 48) together
with the gauge swap — `fold_invariant_swapXZ` and `fold_invariant_flipY` are worked composites.

## Why it holds, and why balance is the hypothesis that earns it

The phase rule makes the question combinatorial. Relabeling moves two things:

* **the sign count**, when a relabeling reverses an axis (`< ↔ >` turns negatives into positives), by
  the number of twists on that axis;
* **the inversion count**, when a relabeling permutes the axis order, by the number of pairs of
  distinct letters whose order it flips — `n_X·n_Y` for the transposition `(X Y)`, `n_Y·n_Z` for
  `(Y Z)` (`invCount_map_swapAxXY`, `invCount_map_swapAxYZ`, proven for *all* words).

Both corrections are **products or sums of axis multiplicities**, and count balance makes every axis
multiplicity even. So each correction is even and `(−1)^{even} = 1`. Balance is doing the work — it is
the same hypothesis that turned `μ₄` into `μ₂` in [`QLF_BalancedPhaseReal`](QLF_BalancedPhaseReal.lean),
and outside it the corrections are real: an unbalanced word genuinely changes phase under relabeling.

## What this forecloses — the reason it was worth proving

A relabeling is a **bijection of the balanced census onto itself** (`map_swapXY_involutive`) that
preserves the phase of each way. So it permutes the ways *without mixing them*: for any outcome class,
the signed amplitude `A = N₊ − N₋` of its relabeled image equals `A` of the original.

That kills an attractive shortcut. One might hope the quantum basis change `Z → X` is the substrate
relabeling `Z ↔ X`, and would therefore deliver the Hadamard mixing `(A₊, A₋) ↦ (A₊ + A₋, A₊ − A₋)`.
**It does not, and cannot:** relabeling acts by permutation, and a permutation of ways can never sum
two amplitude classes into one. Whatever produces the mixing is therefore *not* a symmetry of the
substrate alphabet — it belongs entirely to how a context partitions the ways.

That is the precise content of *the basis belongs to the question*: the census is chart-independent
(proved here), so all contextual structure lives in the map from histories to outcomes, and that map
has to be **derived** — in QLF, from joint closure with the apparatus history
([`ER_EPR_QLF`](ER_EPR_QLF.lean)'s `SharedClosure`, the two-history interactor of
[`MultiParticle.md`](../MultiParticle.md)) — not chosen to fit. A freely-chosen contribution kernel
would reproduce any amplitudes at all, which by [`Philosophy.md`](../Philosophy.md) §3a rule 4 is
bookkeeping rather than physics.

No axioms.
-/

namespace QLF.BasisIndependence

open QLF QLF.PhaseRule

/-- `(−1)^{2k} = 1` — the one arithmetic fact the whole module leans on. -/
private theorem neg_one_pow_two_mul (k : ℕ) : (-1 : ℂ) ^ (2 * k) = 1 := by
  rw [pow_mul]; norm_num

theorem negCount_cons (t : Twist) (ts : List Twist) :
    negCount (t :: ts) = negCount ts + (if isNegTwist t then 1 else 0) := by
  simp [negCount, List.countP_cons]

-- ==========================================
-- The relabelings: two axis transpositions, an axis reversal, the gauge swap
-- ==========================================

/-- Transpose the `X` and `Y` axes. -/
def swapAxXY : Axis → Axis
  | Axis.I => Axis.I
  | Axis.X => Axis.Y
  | Axis.Y => Axis.X
  | Axis.Z => Axis.Z

/-- Transpose the `Y` and `Z` axes. -/
def swapAxYZ : Axis → Axis
  | Axis.I => Axis.I
  | Axis.X => Axis.X
  | Axis.Y => Axis.Z
  | Axis.Z => Axis.Y

/-- Transpose the `X` and `Y` axes on twists, matching signs: `> ↔ ^`, `< ↔ v`. -/
def swapXY : Twist → Twist
  | Twist.up        => Twist.right
  | Twist.right     => Twist.up
  | Twist.down      => Twist.left
  | Twist.left      => Twist.down
  | Twist.slash     => Twist.slash
  | Twist.backslash => Twist.backslash
  | Twist.plus      => Twist.plus
  | Twist.minus     => Twist.minus

/-- Transpose the `Y` and `Z` axes on twists, matching signs: `^ ↔ /`, `v ↔ \`. -/
def swapYZ : Twist → Twist
  | Twist.up        => Twist.slash
  | Twist.slash     => Twist.up
  | Twist.down      => Twist.backslash
  | Twist.backslash => Twist.down
  | Twist.left      => Twist.left
  | Twist.right     => Twist.right
  | Twist.plus      => Twist.plus
  | Twist.minus     => Twist.minus

/-- Reverse the `X` axis: `< ↔ >`. Same axis, opposite sign. -/
def flipX : Twist → Twist
  | Twist.left      => Twist.right
  | Twist.right     => Twist.left
  | Twist.up        => Twist.up
  | Twist.down      => Twist.down
  | Twist.slash     => Twist.slash
  | Twist.backslash => Twist.backslash
  | Twist.plus      => Twist.plus
  | Twist.minus     => Twist.minus

/-- Swap the gauge pair: `+ ↔ −`. -/
def swapGauge : Twist → Twist
  | Twist.plus      => Twist.minus
  | Twist.minus     => Twist.plus
  | Twist.up        => Twist.up
  | Twist.down      => Twist.down
  | Twist.left      => Twist.left
  | Twist.right     => Twist.right
  | Twist.slash     => Twist.slash
  | Twist.backslash => Twist.backslash

theorem swapXY_involutive (t : Twist) : swapXY (swapXY t) = t := by cases t <;> rfl
theorem swapYZ_involutive (t : Twist) : swapYZ (swapYZ t) = t := by cases t <;> rfl
theorem flipX_involutive (t : Twist) : flipX (flipX t) = t := by cases t <;> rfl
theorem swapGauge_involutive (t : Twist) : swapGauge (swapGauge t) = t := by cases t <;> rfl

/-- Relabeling a history twice returns it: the relabelings act on the census by **permutation**. -/
theorem map_swapXY_involutive (ts : List Twist) : (ts.map swapXY).map swapXY = ts := by
  induction ts with
  | nil => rfl
  | cons t ts ih =>
      show swapXY (swapXY t) :: (ts.map swapXY).map swapXY = t :: ts
      rw [swapXY_involutive, ih]

-- ==========================================
-- Counts under relabeling
-- ==========================================

theorem count_map_swapXY (t : Twist) (ts : List Twist) :
    (ts.map swapXY).count t = ts.count (swapXY t) := by
  induction ts with
  | nil => rfl
  | cons a ts ih =>
      show (swapXY a :: ts.map swapXY).count t = (a :: ts).count (swapXY t)
      rw [List.count_cons, List.count_cons, ih]
      cases a <;> cases t <;> simp +decide [swapXY]

theorem count_map_swapYZ (t : Twist) (ts : List Twist) :
    (ts.map swapYZ).count t = ts.count (swapYZ t) := by
  induction ts with
  | nil => rfl
  | cons a ts ih =>
      show (swapYZ a :: ts.map swapYZ).count t = (a :: ts).count (swapYZ t)
      rw [List.count_cons, List.count_cons, ih]
      cases a <;> cases t <;> simp +decide [swapYZ]

theorem count_map_flipX (t : Twist) (ts : List Twist) :
    (ts.map flipX).count t = ts.count (flipX t) := by
  induction ts with
  | nil => rfl
  | cons a ts ih =>
      show (flipX a :: ts.map flipX).count t = (a :: ts).count (flipX t)
      rw [List.count_cons, List.count_cons, ih]
      cases a <;> cases t <;> simp +decide [flipX]

theorem count_map_swapGauge (t : Twist) (ts : List Twist) :
    (ts.map swapGauge).count t = ts.count (swapGauge t) := by
  induction ts with
  | nil => rfl
  | cons a ts ih =>
      show (swapGauge a :: ts.map swapGauge).count t = (a :: ts).count (swapGauge t)
      rw [List.count_cons, List.count_cons, ih]
      cases a <;> cases t <;> simp +decide [swapGauge]

/-- Balance is a relabeling-invariant property: the conjugate pairs are permuted among themselves. -/
theorem countBalanced_map_swapXY {ts : List Twist} (h : countBalanced ts) :
    countBalanced (ts.map swapXY) := by
  obtain ⟨hUD, hLR, hSB, hPM⟩ := h
  refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [count_map_swapXY, count_map_swapXY]
  · exact hLR.symm
  · exact hUD.symm
  · exact hSB
  · exact hPM

theorem countBalanced_map_swapYZ {ts : List Twist} (h : countBalanced ts) :
    countBalanced (ts.map swapYZ) := by
  obtain ⟨hUD, hLR, hSB, hPM⟩ := h
  refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [count_map_swapYZ, count_map_swapYZ]
  · exact hSB
  · exact hLR
  · exact hUD
  · exact hPM

theorem countBalanced_map_flipX {ts : List Twist} (h : countBalanced ts) :
    countBalanced (ts.map flipX) := by
  obtain ⟨hUD, hLR, hSB, hPM⟩ := h
  refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [count_map_flipX, count_map_flipX]
  · exact hUD
  · exact hLR.symm
  · exact hSB
  · exact hPM

theorem countBalanced_map_swapGauge {ts : List Twist} (h : countBalanced ts) :
    countBalanced (ts.map swapGauge) := by
  obtain ⟨hUD, hLR, hSB, hPM⟩ := h
  refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [count_map_swapGauge, count_map_swapGauge]
  · exact hUD
  · exact hLR
  · exact hSB
  · exact hPM.symm

-- ==========================================
-- Axis words under relabeling
-- ==========================================

theorem axisOf_swapXY (t : Twist) : axisOf (swapXY t) = swapAxXY (axisOf t) := by
  cases t <;> rfl

theorem axisOf_swapYZ (t : Twist) : axisOf (swapYZ t) = swapAxYZ (axisOf t) := by
  cases t <;> rfl

theorem axisWord_map_swapXY (ts : List Twist) :
    axisWord (ts.map swapXY) = (axisWord ts).map swapAxXY := by
  induction ts with
  | nil => rfl
  | cons t ts ih =>
      show axisOf (swapXY t) :: axisWord (ts.map swapXY)
          = swapAxXY (axisOf t) :: (axisWord ts).map swapAxXY
      rw [ih, axisOf_swapXY]

theorem axisWord_map_swapYZ (ts : List Twist) :
    axisWord (ts.map swapYZ) = (axisWord ts).map swapAxYZ := by
  induction ts with
  | nil => rfl
  | cons t ts ih =>
      show axisOf (swapYZ t) :: axisWord (ts.map swapYZ)
          = swapAxYZ (axisOf t) :: (axisWord ts).map swapAxYZ
      rw [ih, axisOf_swapYZ]

/-- An axis reversal does not touch the axis word at all — both twists of a pair share an axis. -/
theorem axisWord_map_flipX (ts : List Twist) : axisWord (ts.map flipX) = axisWord ts := by
  induction ts with
  | nil => rfl
  | cons t ts ih =>
      show axisOf (flipX t) :: axisWord (ts.map flipX) = axisOf t :: axisWord ts
      rw [ih]
      cases t <;> rfl

theorem axisWord_map_swapGauge (ts : List Twist) : axisWord (ts.map swapGauge) = axisWord ts := by
  induction ts with
  | nil => rfl
  | cons t ts ih =>
      show axisOf (swapGauge t) :: axisWord (ts.map swapGauge) = axisOf t :: axisWord ts
      rw [ih]
      cases t <;> rfl

-- ==========================================
-- Letter multiplicities under an axis transposition
-- ==========================================

theorem count_map_swapAxXY_X (w : List Axis) :
    (w.map swapAxXY).count Axis.X = w.count Axis.Y := by
  induction w with
  | nil => rfl
  | cons a w ih =>
      show (swapAxXY a :: w.map swapAxXY).count Axis.X = (a :: w).count Axis.Y
      cases a <;> simp +decide [swapAxXY, List.count_cons, ih]

theorem count_map_swapAxXY_Y (w : List Axis) :
    (w.map swapAxXY).count Axis.Y = w.count Axis.X := by
  induction w with
  | nil => rfl
  | cons a w ih =>
      show (swapAxXY a :: w.map swapAxXY).count Axis.Y = (a :: w).count Axis.X
      cases a <;> simp +decide [swapAxXY, List.count_cons, ih]

theorem count_map_swapAxYZ_X (w : List Axis) :
    (w.map swapAxYZ).count Axis.X = w.count Axis.X := by
  induction w with
  | nil => rfl
  | cons a w ih =>
      show (swapAxYZ a :: w.map swapAxYZ).count Axis.X = (a :: w).count Axis.X
      cases a <;> simp +decide [swapAxYZ, List.count_cons, ih]

theorem count_map_swapAxYZ_Y (w : List Axis) :
    (w.map swapAxYZ).count Axis.Y = w.count Axis.Z := by
  induction w with
  | nil => rfl
  | cons a w ih =>
      show (swapAxYZ a :: w.map swapAxYZ).count Axis.Y = (a :: w).count Axis.Z
      cases a <;> simp +decide [swapAxYZ, List.count_cons, ih]

-- ==========================================
-- The inversion count under an axis transposition — the heart of the module
-- ==========================================

/-- **Transposing `X` and `Y` changes the inversion count by `n_X · n_Y`** — one flip for each pair of
    distinct letters whose order the transposition reverses, and no other pair is touched. Proved for
    *every* word; balance enters only later, to make the correction even. -/
theorem invCount_map_swapAxXY (w : List Axis) :
    (-1 : ℂ) ^ (invCount (w.map swapAxXY))
      = (-1 : ℂ) ^ (invCount w + w.count Axis.X * w.count Axis.Y) := by
  induction w with
  | nil => simp [invCount]
  | cons a w ih =>
      cases a
      · -- I: nothing moves
        have hL : invCount ((Axis.I :: w).map swapAxXY) = invCount (w.map swapAxXY) := by
          show invCount (Axis.I :: w.map swapAxXY) = _
          rw [invCount_cons, countP_invPair_I, Nat.zero_add]
        have hR : invCount (Axis.I :: w) = invCount w := by
          rw [invCount_cons, countP_invPair_I, Nat.zero_add]
        have hcX : (Axis.I :: w).count Axis.X = w.count Axis.X := by
          simp +decide [List.count_cons]
        have hcY : (Axis.I :: w).count Axis.Y = w.count Axis.Y := by
          simp +decide [List.count_cons]
        rw [hL, hR, hcX, hcY, ih]
      · -- X ↦ Y: gains one inversion against every later Y of the original
        have hL : invCount ((Axis.X :: w).map swapAxXY)
            = w.count Axis.Y + invCount (w.map swapAxXY) := by
          show invCount (Axis.Y :: w.map swapAxXY) = _
          rw [invCount_cons, countP_invPair_Y, count_map_swapAxXY_X]
        have hR : invCount (Axis.X :: w) = invCount w := by
          rw [invCount_cons, countP_invPair_X, Nat.zero_add]
        have hcX : (Axis.X :: w).count Axis.X = w.count Axis.X + 1 := by
          simp +decide [List.count_cons]
        have hcY : (Axis.X :: w).count Axis.Y = w.count Axis.Y := by
          simp +decide [List.count_cons]
        have hexp : w.count Axis.Y + (invCount w + w.count Axis.X * w.count Axis.Y)
            = invCount w + (w.count Axis.X + 1) * w.count Axis.Y := by ring
        rw [hL, hR, hcX, hcY,
          pow_add (-1 : ℂ) (w.count Axis.Y) (invCount (w.map swapAxXY)), ih, ← pow_add, hexp]
      · -- Y ↦ X: loses them, which differs from gaining them by an even number
        have hL : invCount ((Axis.Y :: w).map swapAxXY) = invCount (w.map swapAxXY) := by
          show invCount (Axis.X :: w.map swapAxXY) = _
          rw [invCount_cons, countP_invPair_X, Nat.zero_add]
        have hR : invCount (Axis.Y :: w) = w.count Axis.X + invCount w := by
          rw [invCount_cons, countP_invPair_Y]
        have hcX : (Axis.Y :: w).count Axis.X = w.count Axis.X := by
          simp +decide [List.count_cons]
        have hcY : (Axis.Y :: w).count Axis.Y = w.count Axis.Y + 1 := by
          simp +decide [List.count_cons]
        have hexp : w.count Axis.X + invCount w + w.count Axis.X * (w.count Axis.Y + 1)
            = (invCount w + w.count Axis.X * w.count Axis.Y) + 2 * w.count Axis.X := by ring
        rw [hL, hR, hcX, hcY, ih, hexp,
          pow_add (-1 : ℂ) (invCount w + w.count Axis.X * w.count Axis.Y) (2 * w.count Axis.X),
          neg_one_pow_two_mul, mul_one]
      · -- Z: sees both blocks, and the two counts merely trade places
        have hL : invCount ((Axis.Z :: w).map swapAxXY)
            = (w.count Axis.X + w.count Axis.Y) + invCount (w.map swapAxXY) := by
          show invCount (Axis.Z :: w.map swapAxXY) = _
          rw [invCount_cons, countP_invPair_Z, count_map_swapAxXY_X, count_map_swapAxXY_Y,
            Nat.add_comm (w.count Axis.Y) (w.count Axis.X)]
        have hR : invCount (Axis.Z :: w) = (w.count Axis.X + w.count Axis.Y) + invCount w := by
          rw [invCount_cons, countP_invPair_Z]
        have hcX : (Axis.Z :: w).count Axis.X = w.count Axis.X := by
          simp +decide [List.count_cons]
        have hcY : (Axis.Z :: w).count Axis.Y = w.count Axis.Y := by
          simp +decide [List.count_cons]
        have hexp : (w.count Axis.X + w.count Axis.Y)
              + (invCount w + w.count Axis.X * w.count Axis.Y)
            = (w.count Axis.X + w.count Axis.Y) + invCount w
              + w.count Axis.X * w.count Axis.Y := by ring
        rw [hL, hR, hcX, hcY,
          pow_add (-1 : ℂ) (w.count Axis.X + w.count Axis.Y) (invCount (w.map swapAxXY)), ih,
          ← pow_add, hexp]

/-- **Transposing `Y` and `Z` changes the inversion count by `n_Y · n_Z`.** -/
theorem invCount_map_swapAxYZ (w : List Axis) :
    (-1 : ℂ) ^ (invCount (w.map swapAxYZ))
      = (-1 : ℂ) ^ (invCount w + w.count Axis.Y * w.count Axis.Z) := by
  induction w with
  | nil => simp [invCount]
  | cons a w ih =>
      cases a
      · -- I
        have hL : invCount ((Axis.I :: w).map swapAxYZ) = invCount (w.map swapAxYZ) := by
          show invCount (Axis.I :: w.map swapAxYZ) = _
          rw [invCount_cons, countP_invPair_I, Nat.zero_add]
        have hR : invCount (Axis.I :: w) = invCount w := by
          rw [invCount_cons, countP_invPair_I, Nat.zero_add]
        have hcY : (Axis.I :: w).count Axis.Y = w.count Axis.Y := by
          simp +decide [List.count_cons]
        have hcZ : (Axis.I :: w).count Axis.Z = w.count Axis.Z := by
          simp +decide [List.count_cons]
        rw [hL, hR, hcY, hcZ, ih]
      · -- X is fixed and least, so it creates no inversions either way
        have hL : invCount ((Axis.X :: w).map swapAxYZ) = invCount (w.map swapAxYZ) := by
          show invCount (Axis.X :: w.map swapAxYZ) = _
          rw [invCount_cons, countP_invPair_X, Nat.zero_add]
        have hR : invCount (Axis.X :: w) = invCount w := by
          rw [invCount_cons, countP_invPair_X, Nat.zero_add]
        have hcY : (Axis.X :: w).count Axis.Y = w.count Axis.Y := by
          simp +decide [List.count_cons]
        have hcZ : (Axis.X :: w).count Axis.Z = w.count Axis.Z := by
          simp +decide [List.count_cons]
        rw [hL, hR, hcY, hcZ, ih]
      · -- Y ↦ Z
        have hL : invCount ((Axis.Y :: w).map swapAxYZ)
            = (w.count Axis.X + w.count Axis.Z) + invCount (w.map swapAxYZ) := by
          show invCount (Axis.Z :: w.map swapAxYZ) = _
          rw [invCount_cons, countP_invPair_Z, count_map_swapAxYZ_X, count_map_swapAxYZ_Y]
        have hR : invCount (Axis.Y :: w) = w.count Axis.X + invCount w := by
          rw [invCount_cons, countP_invPair_Y]
        have hcY : (Axis.Y :: w).count Axis.Y = w.count Axis.Y + 1 := by
          simp +decide [List.count_cons]
        have hcZ : (Axis.Y :: w).count Axis.Z = w.count Axis.Z := by
          simp +decide [List.count_cons]
        have hexp : (w.count Axis.X + w.count Axis.Z)
              + (invCount w + w.count Axis.Y * w.count Axis.Z)
            = w.count Axis.X + invCount w + (w.count Axis.Y + 1) * w.count Axis.Z := by ring
        rw [hL, hR, hcY, hcZ,
          pow_add (-1 : ℂ) (w.count Axis.X + w.count Axis.Z) (invCount (w.map swapAxYZ)), ih,
          ← pow_add, hexp]
      · -- Z ↦ Y
        have hL : invCount ((Axis.Z :: w).map swapAxYZ)
            = w.count Axis.X + invCount (w.map swapAxYZ) := by
          show invCount (Axis.Y :: w.map swapAxYZ) = _
          rw [invCount_cons, countP_invPair_Y, count_map_swapAxYZ_X]
        have hR : invCount (Axis.Z :: w) = (w.count Axis.X + w.count Axis.Y) + invCount w := by
          rw [invCount_cons, countP_invPair_Z]
        have hcY : (Axis.Z :: w).count Axis.Y = w.count Axis.Y := by
          simp +decide [List.count_cons]
        have hcZ : (Axis.Z :: w).count Axis.Z = w.count Axis.Z + 1 := by
          simp +decide [List.count_cons]
        have hexp : (w.count Axis.X + w.count Axis.Y) + invCount w
              + w.count Axis.Y * (w.count Axis.Z + 1)
            = (w.count Axis.X + (invCount w + w.count Axis.Y * w.count Axis.Z))
              + 2 * w.count Axis.Y := by ring
        rw [hL, hR, hcY, hcZ,
          pow_add (-1 : ℂ) (w.count Axis.X) (invCount (w.map swapAxYZ)), ih, hexp,
          pow_add (-1 : ℂ) (w.count Axis.X + (invCount w + w.count Axis.Y * w.count Axis.Z))
            (2 * w.count Axis.Y),
          neg_one_pow_two_mul, mul_one,
          pow_add (-1 : ℂ) (w.count Axis.X) (invCount w + w.count Axis.Y * w.count Axis.Z)]

-- ==========================================
-- Sign counts under an axis reversal / the gauge swap
-- ==========================================

/-- Reversing the `X` axis trades `<` for `>`, so the sign count changes by their two multiplicities.
    Stated additively to stay inside `ℕ`. -/
theorem negCount_map_flipX (ts : List Twist) :
    negCount (ts.map flipX) + ts.count Twist.left = negCount ts + ts.count Twist.right := by
  induction ts with
  | nil => rfl
  | cons t ts ih =>
      show negCount (flipX t :: ts.map flipX) + (t :: ts).count Twist.left
          = negCount (t :: ts) + (t :: ts).count Twist.right
      rw [negCount_cons, negCount_cons, List.count_cons, List.count_cons]
      cases t <;> simp +decide [flipX, isNegTwist] <;> omega

theorem negCount_map_swapGauge (ts : List Twist) :
    negCount (ts.map swapGauge) + ts.count Twist.minus = negCount ts + ts.count Twist.plus := by
  induction ts with
  | nil => rfl
  | cons t ts ih =>
      show negCount (swapGauge t :: ts.map swapGauge) + (t :: ts).count Twist.minus
          = negCount (t :: ts) + (t :: ts).count Twist.plus
      rw [negCount_cons, negCount_cons, List.count_cons, List.count_cons]
      cases t <;> simp +decide [swapGauge, isNegTwist] <;> omega

/-- A transposition preserves the sign count exactly: it maps negative twists to negative twists. -/
theorem negCount_map_swapXY (ts : List Twist) : negCount (ts.map swapXY) = negCount ts := by
  induction ts with
  | nil => rfl
  | cons t ts ih =>
      show negCount (swapXY t :: ts.map swapXY) = negCount (t :: ts)
      rw [negCount_cons, negCount_cons, ih]
      cases t <;> simp +decide [swapXY, isNegTwist]

theorem negCount_map_swapYZ (ts : List Twist) : negCount (ts.map swapYZ) = negCount ts := by
  induction ts with
  | nil => rfl
  | cons t ts ih =>
      show negCount (swapYZ t :: ts.map swapYZ) = negCount (t :: ts)
      rw [negCount_cons, negCount_cons, ih]
      cases t <;> simp +decide [swapYZ, isNegTwist]

-- ==========================================
-- Balance makes every axis multiplicity even
-- ==========================================

theorem axisWord_count_X_even {ts : List Twist} (h : countBalanced ts) :
    (axisWord ts).count Axis.X = 2 * ts.count Twist.right := by
  rw [count_axisWord_X, h.2.1]; ring

theorem axisWord_count_Y_even {ts : List Twist} (h : countBalanced ts) :
    (axisWord ts).count Axis.Y = 2 * ts.count Twist.down := by
  rw [count_axisWord_Y, h.1]; ring

theorem axisWord_count_Z_even {ts : List Twist} (h : countBalanced ts) :
    (axisWord ts).count Axis.Z = 2 * ts.count Twist.backslash := by
  rw [count_axisWord_Z, h.2.2.1]; ring

-- ==========================================
-- The invariance theorems
-- ==========================================

/-- **Swapping the `X` and `Y` axes leaves every balanced history's fold untouched.** The inversion
    count moves by `n_X · n_Y`, and balance makes both factors even. -/
theorem fold_invariant_swapXY {ts : List Twist} (h : countBalanced ts) :
    twistMatrixFold (ts.map swapXY) = twistMatrixFold ts := by
  have hcorr : (-1 : ℂ) ^ ((axisWord ts).count Axis.X * (axisWord ts).count Axis.Y) = 1 := by
    rw [axisWord_count_X_even h, axisWord_count_Y_even h,
      show 2 * ts.count Twist.right * (2 * ts.count Twist.down)
        = 2 * (2 * (ts.count Twist.right * ts.count Twist.down)) from by ring]
    exact neg_one_pow_two_mul _
  have hsc : (-1 : ℂ) ^ (negCount (ts.map swapXY) + invCount (axisWord (ts.map swapXY)))
      = (-1 : ℂ) ^ (negCount ts + invCount (axisWord ts)) := by
    rw [negCount_map_swapXY, axisWord_map_swapXY, pow_add, pow_add, invCount_map_swapAxXY,
      pow_add, hcorr, mul_one]
  rw [phase_rule (countBalanced_map_swapXY h), phase_rule h, hsc]

/-- **Swapping the `Y` and `Z` axes leaves every balanced history's fold untouched.** -/
theorem fold_invariant_swapYZ {ts : List Twist} (h : countBalanced ts) :
    twistMatrixFold (ts.map swapYZ) = twistMatrixFold ts := by
  have hcorr : (-1 : ℂ) ^ ((axisWord ts).count Axis.Y * (axisWord ts).count Axis.Z) = 1 := by
    rw [axisWord_count_Y_even h, axisWord_count_Z_even h,
      show 2 * ts.count Twist.down * (2 * ts.count Twist.backslash)
        = 2 * (2 * (ts.count Twist.down * ts.count Twist.backslash)) from by ring]
    exact neg_one_pow_two_mul _
  have hsc : (-1 : ℂ) ^ (negCount (ts.map swapYZ) + invCount (axisWord (ts.map swapYZ)))
      = (-1 : ℂ) ^ (negCount ts + invCount (axisWord ts)) := by
    rw [negCount_map_swapYZ, axisWord_map_swapYZ, pow_add, pow_add, invCount_map_swapAxYZ,
      pow_add, hcorr, mul_one]
  rw [phase_rule (countBalanced_map_swapYZ h), phase_rule h, hsc]

/-- **Reversing the `X` axis leaves every balanced history's fold untouched.** The axis word does not
    move at all; only the sign count does, by `#< + #>`, which balance makes even. -/
theorem fold_invariant_flipX {ts : List Twist} (h : countBalanced ts) :
    twistMatrixFold (ts.map flipX) = twistMatrixFold ts := by
  have hneg : negCount (ts.map flipX) = negCount ts := by
    have h1 := negCount_map_flipX ts
    have h2 := h.2.1
    omega
  have hsc : (-1 : ℂ) ^ (negCount (ts.map flipX) + invCount (axisWord (ts.map flipX)))
      = (-1 : ℂ) ^ (negCount ts + invCount (axisWord ts)) := by
    rw [hneg, axisWord_map_flipX]
  rw [phase_rule (countBalanced_map_flipX h), phase_rule h, hsc]

/-- **Swapping the gauge pair leaves every balanced history's fold untouched.** -/
theorem fold_invariant_swapGauge {ts : List Twist} (h : countBalanced ts) :
    twistMatrixFold (ts.map swapGauge) = twistMatrixFold ts := by
  have hneg : negCount (ts.map swapGauge) = negCount ts := by
    have h1 := negCount_map_swapGauge ts
    have h2 := h.2.2.2
    omega
  have hsc : (-1 : ℂ) ^ (negCount (ts.map swapGauge) + invCount (axisWord (ts.map swapGauge)))
      = (-1 : ℂ) ^ (negCount ts + invCount (axisWord ts)) := by
    rw [hneg, axisWord_map_swapGauge]
  rw [phase_rule (countBalanced_map_swapGauge h), phase_rule h, hsc]

-- ==========================================
-- Composites: the whole relabeling group, from the generators
-- ==========================================

/-- **The `X ↔ Z` relabeling**, as the composite `(X Y)(Y Z)(X Y)`. Together with the generators
    above this covers all of `S₃` on the three axes. -/
theorem fold_invariant_swapXZ {ts : List Twist} (h : countBalanced ts) :
    twistMatrixFold (((ts.map swapXY).map swapYZ).map swapXY) = twistMatrixFold ts := by
  have h1 := countBalanced_map_swapXY h
  have h2 := countBalanced_map_swapYZ h1
  rw [fold_invariant_swapXY h2, fold_invariant_swapYZ h1, fold_invariant_swapXY h]

/-- **Reversing the `Y` axis**, as the conjugate `(X Y) ∘ flipX ∘ (X Y)` — so every axis reversal is
    covered, not only the `X` one proved directly. -/
theorem fold_invariant_flipY {ts : List Twist} (h : countBalanced ts) :
    twistMatrixFold (((ts.map swapXY).map flipX).map swapXY) = twistMatrixFold ts := by
  have h1 := countBalanced_map_swapXY h
  have h2 := countBalanced_map_flipX h1
  rw [fold_invariant_swapXY h2, fold_invariant_flipX h1, fold_invariant_swapXY h]

/-- **Established constructively, no axioms.** The canonical `{>,<}↦X`, `{^,v}↦Y`, `{/,\}↦Z` chart of
    [`census_inventory.py`](../census_inventory.py) is a coordinate convention and nothing more: every
    balanced history folds to the same Pauli scalar after any transposition of the axes
    (`fold_invariant_swapXY`, `fold_invariant_swapYZ`, and the composite `fold_invariant_swapXZ`), any
    reversal of an axis (`fold_invariant_flipX`, `fold_invariant_flipY`), and the gauge swap
    (`fold_invariant_swapGauge`). The mechanism is the phase rule plus one arithmetic fact: relabeling
    moves the sign count by an axis multiplicity and the inversion count by a product of two axis
    multiplicities (`invCount_map_swapAxXY`, `invCount_map_swapAxYZ`, proven for *all* words), and
    count balance makes every axis multiplicity even. **The sharp consequence is negative and useful:**
    a relabeling is an involution on the census (`map_swapXY_involutive`) preserving each way's phase,
    so it *permutes* ways without mixing them, and therefore cannot produce the Hadamard mixing
    `(A₊,A₋) ↦ (A₊+A₋, A₊−A₋)` that a quantum change of basis produces. The substrate has no preferred
    frame, and the whole content of a measurement context therefore sits in how it partitions the
    ways — which must be *derived* (joint closure with the apparatus), never chosen to fit. -/
theorem basis_independence_summary : True := trivial

end QLF.BasisIndependence

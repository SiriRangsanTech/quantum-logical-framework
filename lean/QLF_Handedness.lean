-- QLF_Handedness.lean
-- Handedness is the primitive; charge is one of its four components.
--
-- QLF_ElectronClosure showed charge is the unmatched **gauge** count and that no
-- event is ever charged. That leaves a question it did not answer: if charge is
-- not fundamental, what is? This module answers it.
--
-- **A twist IS a handedness together with an axis, and nothing else.**
-- `QLF_AlphabetNecessity` proved the alphabet is the signed axis frame,
-- `Twist ≃ Bool × Axis` — so the only two data a distinction carries are *which
-- axis it distinguishes along* and *which of the two ways it went*. The second
-- is handedness. Charge is nowhere in the primitives; it is a derived count.
--
-- Four results make that precise:
--
-- 1. **ZFA is exactly zero net handedness, on every axis**
--    (`zfa_iff_handedness_balanced`). The selection principle is a statement
--    about handedness and nothing else. Count balance was always this.
--
-- 2. **Charge is the gauge component of handedness** — one of four, not a
--    separate kind of thing (`chiralCharge_eq_handednessOn_gauge`). This is why
--    charge cannot see spin or energy (`no_charge_between_spatial_modes`):
--    those are the *other three* components, and components do not mix.
--
-- 3. **Conjugation is handedness reversal on every axis**
--    (`handednessOn_map_conj`), and charge flips because handedness does — not
--    the other way round. `chiralCharge_conj` is the `Axis.I` case of it.
--
-- 4. **The primitive never vanishes; the derived quantity does.** Every twist is
--    handed (`handedness_ne_zero`), yet a closure's net handedness is zero on
--    every axis. The electron's cycle is neutral *and made entirely of handed
--    distinctions* (`electron_neutral_but_handed`). Neutral does not mean
--    handedness-free — it means handedness balanced.
--
-- A structural corollary worth having on its own: **C flips every component of
-- handedness, P flips one** (`reflect`), and charge is the gauge component — so
-- spatial reflection leaves charge alone by construction
-- (`reflect_preserves_charge`) while conjugation negates it. The asymmetry
-- between C and P is a statement about how many handedness components each one
-- touches.
--
-- Zero axioms.

import QLF_AlphabetNecessity
import QLF_ElectronClosure

namespace QLF

open QLF.Spin

-- ==========================================
-- 1. The primitive: a twist is a handedness on an axis
-- ==========================================

/-- The **handedness** of a twist: which of the two ways the distinction went.
    `+1` for `^ > / +`, `−1` for `v < \ −`. Read off the signed-frame
    decomposition `Twist ≃ Bool × Axis` of `QLF_AlphabetNecessity`. -/
def handedness (t : Twist) : Int := cond (Twist.toSignedAxis t).1 1 (-1)

/-- The axis a twist distinguishes along. -/
def twistAxis (t : Twist) : Axis := (Twist.toSignedAxis t).2

/-- **Handedness is never zero.** There is no unhanded distinction: to distinguish
    at all is to go one way rather than the other. -/
theorem handedness_ne_zero (t : Twist) : handedness t ≠ 0 := by
  cases t <;> decide

/-- **Conjugation is handedness reversal.** -/
theorem handedness_conj (t : Twist) : handedness t.conj = - handedness t := by
  cases t <;> decide

/-- …at a fixed axis. Conjugation does not move a distinction to another axis. -/
theorem twistAxis_conj (t : Twist) : twistAxis t.conj = twistAxis t := by
  cases t <;> decide

/-- The two twists on an axis: the right-handed one and the left-handed one. -/
def rightTwist : Axis → Twist
  | Axis.I => Twist.plus
  | Axis.X => Twist.right
  | Axis.Y => Twist.up
  | Axis.Z => Twist.slash

def leftTwist : Axis → Twist
  | Axis.I => Twist.minus
  | Axis.X => Twist.left
  | Axis.Y => Twist.down
  | Axis.Z => Twist.backslash

theorem rightTwist_eq (a : Axis) : rightTwist a = Twist.ofSignedAxis (true, a) := by
  cases a <;> rfl

theorem leftTwist_eq (a : Axis) : leftTwist a = Twist.ofSignedAxis (false, a) := by
  cases a <;> rfl

theorem handedness_rightTwist (a : Axis) : handedness (rightTwist a) = 1 := by
  cases a <;> decide

theorem handedness_leftTwist (a : Axis) : handedness (leftTwist a) = -1 := by
  cases a <;> decide

-- ==========================================
-- 2. Net handedness of a history, per axis
-- ==========================================

/-- **Net handedness of a history on one axis**: how far it went one way rather
    than the other. Four numbers, one per axis — and that is the entire
    conserved content of a history's counts. -/
def handednessOn (a : Axis) (ts : List Twist) : Int :=
  (ts.count (rightTwist a) : Int) - (ts.count (leftTwist a) : Int)

theorem handednessOn_nil (a : Axis) : handednessOn a [] = 0 := by
  simp [handednessOn]

/-- Handedness accumulates one twist at a time, each on its own axis. -/
theorem handednessOn_cons (a : Axis) (t : Twist) (ts : List Twist) :
    handednessOn a (t :: ts)
      = (if twistAxis t = a then handedness t else 0) + handednessOn a ts := by
  cases t <;> cases a <;>
    simp +decide [handednessOn, rightTwist, leftTwist, twistAxis, handedness,
      Twist.toSignedAxis, List.count_cons] <;>
    omega

theorem handednessOn_append (a : Axis) (l₁ l₂ : List Twist) :
    handednessOn a (l₁ ++ l₂) = handednessOn a l₁ + handednessOn a l₂ := by
  simp [handednessOn, List.count_append]
  omega

-- ==========================================
-- 3. ZFA is zero net handedness, on every axis
-- ==========================================

/-- **The selection principle, restated in the primitive.** A history achieves
    Zero Free Action exactly when its net handedness vanishes on every axis.
    Count balance was always a statement about handedness — one component per
    conjugate pair, which is why `F(h)` has four terms. -/
theorem zfa_iff_handedness_balanced (ts : List Twist) :
    countBalanced ts ↔ ∀ a : Axis, handednessOn a ts = 0 := by
  unfold countBalanced
  constructor
  · rintro ⟨h1, h2, h3, h4⟩ a
    cases a <;> simp only [handednessOn, rightTwist, leftTwist] <;> omega
  · intro h
    have hI := h Axis.I
    have hX := h Axis.X
    have hY := h Axis.Y
    have hZ := h Axis.Z
    simp only [handednessOn, rightTwist, leftTwist] at hI hX hY hZ
    exact ⟨by omega, by omega, by omega, by omega⟩

-- ==========================================
-- 4. Charge is one component of four
-- ==========================================

/-- **Charge is the gauge component of handedness — nothing more.** It is not a
    separate quantity, not a fifth axis, and not a substance: it is the same
    primitive read on the gauge axis that spin content is read on the spatial
    ones. This is *why* charge cannot see a spin or an energy
    (`no_charge_between_spatial_modes`) — those are the other three components,
    and components of a vector do not mix. -/
theorem chiralCharge_eq_handednessOn_gauge (ts : List Twist) :
    chiralCharge ts = handednessOn Axis.I ts := by
  rw [chiralCharge_eq_gauge_counts]
  rfl

/-- **Conjugation negates every component of handedness.** -/
theorem handednessOn_map_conj (a : Axis) (ts : List Twist) :
    handednessOn a (ts.map Twist.conj) = - handednessOn a ts := by
  induction ts with
  | nil => simp [handednessOn]
  | cons t rest ih =>
    rw [List.map_cons, handednessOn_cons, handednessOn_cons, ih, twistAxis_conj,
      handedness_conj]
    split <;> ring

/-- **The primitive never vanishes; the derived quantity does.** The electron's
    cycle has zero net handedness on every axis — hence is neutral — while every
    twist in it is handed. *Neutral does not mean handedness-free; it means
    handedness balanced.* That is the sense in which charge is emergent and
    handedness is not. -/
theorem electron_neutral_but_handed :
    (∀ a : Axis, handednessOn a electronCycle = 0) ∧
      (∀ t ∈ electronCycle, handedness t ≠ 0) := by
  refine ⟨?_, fun t _ => handedness_ne_zero t⟩
  exact (zfa_iff_handedness_balanced electronCycle).mp electronCycle_countBalanced

-- ==========================================
-- 5. C flips every component; P flips one
-- ==========================================

/-- **Reflection in one axis**: reverse handedness on that axis and leave the
    others alone. -/
def reflect (a : Axis) (t : Twist) : Twist :=
  if twistAxis t = a then Twist.conj t else t

theorem reflect_twistAxis (a : Axis) (t : Twist) :
    twistAxis (reflect a t) = twistAxis t := by
  unfold reflect
  split
  · exact twistAxis_conj t
  · rfl

theorem reflect_eq_of_ne {a : Axis} {t : Twist} (h : twistAxis t ≠ a) :
    reflect a t = t := by
  unfold reflect
  exact if_neg h

/-- Reflection leaves the handedness of every *other* axis untouched. -/
theorem handednessOn_map_reflect_other {a b : Axis} (hab : b ≠ a) (ts : List Twist) :
    handednessOn b (ts.map (reflect a)) = handednessOn b ts := by
  induction ts with
  | nil => simp [handednessOn]
  | cons t rest ih =>
    rw [List.map_cons, handednessOn_cons, handednessOn_cons, ih, reflect_twistAxis]
    by_cases h : twistAxis t = b
    · rw [if_pos h, if_pos h, reflect_eq_of_ne (by rw [h]; exact hab)]
    · rw [if_neg h, if_neg h]

/-- **Spatial reflection does not touch charge.** `P` flips one component of
    handedness; charge is the gauge component; so parity leaves charge alone by
    construction, while conjugation — which flips *all four* — negates it. The
    familiar asymmetry between `C` and `P` is a statement about how many
    handedness components each one touches. -/
theorem reflect_preserves_charge {a : Axis} (h : a ≠ Axis.I) (ts : List Twist) :
    chiralCharge (ts.map (reflect a)) = chiralCharge ts := by
  rw [chiralCharge_eq_handednessOn_gauge, chiralCharge_eq_handednessOn_gauge]
  exact handednessOn_map_reflect_other (Ne.symm h) ts

-- ==========================================
-- 6. The capstone
-- ==========================================

/-- **Handedness is the primitive; charge is one of its four components.**

    1. every twist *is* a handedness together with an axis, and nothing else —
       the round trip `Twist ≃ Bool × Axis` of `QLF_AlphabetNecessity`;
    2. conjugation is handedness reversal at a fixed axis;
    3. ZFA is exactly zero net handedness on every axis;
    4. charge is the gauge component of it — one of four, derived, and the only
       reason it looks like a thing of its own is that we named it separately. -/
theorem handedness_is_the_primitive (ts : List Twist) :
    (∀ t : Twist, Twist.ofSignedAxis (Twist.toSignedAxis t) = t) ∧
      (∀ t : Twist, handedness t.conj = - handedness t ∧ twistAxis t.conj = twistAxis t) ∧
      (countBalanced ts ↔ ∀ a : Axis, handednessOn a ts = 0) ∧
      chiralCharge ts = handednessOn Axis.I ts :=
  ⟨Twist.ofSignedAxis_toSignedAxis,
   fun t => ⟨handedness_conj t, twistAxis_conj t⟩,
   zfa_iff_handedness_balanced ts,
   chiralCharge_eq_handednessOn_gauge ts⟩

end QLF

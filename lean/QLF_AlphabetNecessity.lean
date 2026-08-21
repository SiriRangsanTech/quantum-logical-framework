-- QLF_AlphabetNecessity.lean
-- Why the alphabet has exactly eight twists.
--
-- QLF_TwistAlphabet defines the 8-twist alphabet and its Pauli mapping;
-- eight-twists-sufficiency.md argues the eight are *sufficient*. This module
-- attacks the other half — necessity — and reduces "8" from a chosen number
-- to a counted one.
--
-- The alphabet is the SIGNED PAULI FRAME: every twist is a sign together with
-- an axis (`twistNF : Twist → PauliScalar × Axis`), so
--
--     |alphabet| = 2 · |axis set|.
--
-- The axis set is not free. Axes compose (the σ-products), so an axis set
-- closed under composition is a subgroup of the Klein four-group
-- `Axis ≅ (ZMod 2)²` — hence its size divides 4 and the alphabet size is
-- quantized to 2, 4 or 8. **Six is impossible** (3 ∤ 4: Lagrange, here by
-- exhaustion over all 16 candidate axis sets). Two distinct spatial axes force
-- the third, because the product of two distinct non-identity elements of the
-- Klein group is the remaining one — so the axis count is 0, 1 or 3, never 2.
--
-- The residual trichotomy of possible substrates:
--   |Σ| = 2  — `{±I}` only: no axes, no space, every fold a scalar sign;
--   |Σ| = 4  — one axis: the fold group is abelian, so no non-commuting
--              observables, no SU(2), no double cover;
--   |Σ| = 8  — three axes: the unique size carrying non-commuting observables.
--
-- What remains posited (see eight-twists-sufficiency.md §7 and
-- ScientificApproach.md's assumption budget) is that an elementary distinction
-- IS a signed element of the observable frame of a two-valued system; the
-- two-valuedness itself is QLF_SpinorInformation's `spin_half_is_information_atom`.
--
-- Zero axioms.

import QLF_TwistAlphabet

namespace QLF

-- ==========================================
-- 1. The alphabet is the signed axis frame
-- ==========================================

/-- A twist read as a sign together with an axis. `true` = `+`. -/
def Twist.toSignedAxis : Twist → Bool × Axis
  | Twist.up        => (true,  Axis.Y)
  | Twist.down      => (false, Axis.Y)
  | Twist.right     => (true,  Axis.X)
  | Twist.left      => (false, Axis.X)
  | Twist.slash     => (true,  Axis.Z)
  | Twist.backslash => (false, Axis.Z)
  | Twist.plus      => (true,  Axis.I)
  | Twist.minus     => (false, Axis.I)

/-- The inverse reading: every signed axis IS a twist. -/
def Twist.ofSignedAxis : Bool × Axis → Twist
  | (true,  Axis.Y) => Twist.up
  | (false, Axis.Y) => Twist.down
  | (true,  Axis.X) => Twist.right
  | (false, Axis.X) => Twist.left
  | (true,  Axis.Z) => Twist.slash
  | (false, Axis.Z) => Twist.backslash
  | (true,  Axis.I) => Twist.plus
  | (false, Axis.I) => Twist.minus

/-- Reading a twist as a signed axis loses nothing. -/
theorem Twist.ofSignedAxis_toSignedAxis (t : Twist) :
    Twist.ofSignedAxis (Twist.toSignedAxis t) = t := by
  cases t <;> rfl

/-- Every signed axis is realised by a twist. -/
theorem Twist.toSignedAxis_ofSignedAxis (s : Bool × Axis) :
    Twist.toSignedAxis (Twist.ofSignedAxis s) = s := by
  obtain ⟨b, a⟩ := s
  cases b <;> cases a <;> rfl

/-- **The alphabet IS the signed frame.** The sign/axis reading agrees with the
    normal form `twistNF` already used by the Pauli-closure proof: same axis,
    and the sign is exactly the `one`/`negOne` phase. -/
theorem twistNF_eq_signedAxis (t : Twist) :
    twistNF t
      = (cond (Twist.toSignedAxis t).1 PauliScalar.one PauliScalar.negOne,
         (Twist.toSignedAxis t).2) := by
  cases t <;> rfl

/-- The conjugate of a twist is the same axis with the sign flipped: the four
    conjugate pairs of the ZFA free-action functional are the four axes. -/
theorem toSignedAxis_conj (t : Twist) :
    Twist.toSignedAxis t.conj
      = (!(Twist.toSignedAxis t).1, (Twist.toSignedAxis t).2) := by
  cases t <;> rfl

-- ==========================================
-- 2. Candidate axis sets
-- ==========================================

/-- The four axes, as the carrier of the Klein four-group. -/
def allAxes : List Axis := [Axis.I, Axis.X, Axis.Y, Axis.Z]

/-- A candidate axis set, as membership flags for `I, X, Y, Z`. -/
abbrev AxisFlags := Bool × Bool × Bool × Bool

/-- Membership in a candidate axis set. -/
def axisMem (s : AxisFlags) : Axis → Bool
  | Axis.I => s.1
  | Axis.X => s.2.1
  | Axis.Y => s.2.2.1
  | Axis.Z => s.2.2.2

/-- How many axes a candidate set contains. -/
def axisCount (s : AxisFlags) : Nat :=
  cond s.1 1 0 + cond s.2.1 1 0 + cond s.2.2.1 1 0 + cond s.2.2.2 1 0

/-- **A frame**: a non-empty axis set closed under axis composition. Closure is
    not an extra demand — composing two distinctions is a distinction, and the
    composite's axis is `axisMul`. -/
def IsAxisFrame (s : AxisFlags) : Bool :=
  allAxes.any (axisMem s) &&
  allAxes.all fun a => allAxes.all fun b =>
    !(axisMem s a && axisMem s b) || axisMem s (axisMul a b)

/-- The alphabet a frame generates: one twist per sign per axis. -/
def alphabetSize (s : AxisFlags) : Nat := 2 * axisCount s

/-- The full frame — QLF's own alphabet. -/
def fullFrame : AxisFlags := (true, true, true, true)

theorem fullFrame_isFrame : IsAxisFrame fullFrame = true := by decide

theorem fullFrame_axisCount : axisCount fullFrame = 4 := by decide

/-- **The QLF alphabet has eight twists** — `2 · 4`, not a choice. -/
theorem fullFrame_alphabetSize : alphabetSize fullFrame = 8 := by decide

-- ==========================================
-- 3. The alphabet size is quantized
-- ==========================================

/-- **Lagrange, by exhaustion.** A frame has 1, 2 or 4 axes; nothing else is
    closed. (All 16 candidate sets are checked.) -/
theorem frame_axisCount_trichotomy :
    ∀ s : AxisFlags, IsAxisFrame s = true →
      axisCount s = 1 ∨ axisCount s = 2 ∨ axisCount s = 4 := by
  rintro ⟨a, b, c, d⟩
  cases a <;> cases b <;> cases c <;> cases d <;> decide

/-- **The alphabet size is quantized: 2, 4 or 8.** -/
theorem alphabetSize_trichotomy :
    ∀ s : AxisFlags, IsAxisFrame s = true →
      alphabetSize s = 2 ∨ alphabetSize s = 4 ∨ alphabetSize s = 8 := by
  rintro ⟨a, b, c, d⟩
  cases a <;> cases b <;> cases c <;> cases d <;> decide

/-- **There is no six-twist alphabet.** Three axes cannot be closed without the
    fourth; `3 ∤ 4`. This is the sharp end of the necessity argument: the
    "obvious" alternative — three spatial axes and no gauge pair — is not an
    alphabet at all. -/
theorem no_six_twist_alphabet :
    ∀ s : AxisFlags, IsAxisFrame s = true → alphabetSize s ≠ 6 := by
  rintro ⟨a, b, c, d⟩
  cases a <;> cases b <;> cases c <;> cases d <;> decide

/-- Every frame contains the identity axis: the gauge pair `+`/`−` is not an
    add-on, it is what closure under composition forces. -/
theorem frame_contains_I :
    ∀ s : AxisFlags, IsAxisFrame s = true → axisMem s Axis.I = true := by
  rintro ⟨a, b, c, d⟩
  cases a <;> cases b <;> cases c <;> cases d <;> decide

-- ==========================================
-- 4. Two axes force three
-- ==========================================

/-- Two distinct spatial axes are present. -/
def HasTwoSpatialAxes (s : AxisFlags) : Bool :=
  (axisMem s Axis.X && axisMem s Axis.Y) ||
  (axisMem s Axis.Y && axisMem s Axis.Z) ||
  (axisMem s Axis.X && axisMem s Axis.Z)

/-- **Two axes force three** — the product of two distinct non-identity
    elements of the Klein group is the third, so an axis count of exactly 2 is
    impossible. The substrate has 0, 1 or 3 spatial axes. -/
theorem two_spatial_axes_force_three :
    ∀ s : AxisFlags, IsAxisFrame s = true → HasTwoSpatialAxes s = true →
      axisCount s = 4 := by
  rintro ⟨a, b, c, d⟩
  cases a <;> cases b <;> cases c <;> cases d <;> decide

/-- **Eight twists, forced.** Given two distinguishable spatial axes, the
    alphabet has exactly eight elements — the six signed spatial twists plus
    the gauge pair. -/
theorem alphabet_eight_of_two_spatial_axes :
    ∀ s : AxisFlags, IsAxisFrame s = true → HasTwoSpatialAxes s = true →
      alphabetSize s = 8 := by
  rintro ⟨a, b, c, d⟩
  cases a <;> cases b <;> cases c <;> cases d <;> decide

-- ==========================================
-- 5. Eight is the unique size with non-commuting observables
-- ==========================================

/-- The frame carries a pair of axes whose composition order matters — read off
    the cocycle, which is exactly the phase by which the two matrix orders
    differ (`axisMatrix_mul`). -/
def HasNoncommutingPair (s : AxisFlags) : Bool :=
  allAxes.any fun a => allAxes.any fun b =>
    axisMem s a && axisMem s b && !(cocycle a b == cocycle b a)

/-- **Only the eight-twist alphabet has non-commuting observables.** The 2- and
    4-element alphabets generate abelian fold groups: no uncertainty relation,
    no SU(2), no double cover, no spin. -/
theorem noncommuting_iff_eight :
    ∀ s : AxisFlags, IsAxisFrame s = true →
      (HasNoncommutingPair s = true ↔ alphabetSize s = 8) := by
  rintro ⟨a, b, c, d⟩
  cases a <;> cases b <;> cases c <;> cases d <;> decide

/-- The cocycle asymmetry is not bookkeeping: the matrices themselves fail to
    commute. `σx σy = iσ_z` while `σy σx = −iσ_z`. -/
theorem sigma_xy_noncomm : σx * σy ≠ σy * σx := by
  intro h
  rw [sigma_xy, sigma_yx] at h
  -- read entry (0,0), where `σz` is non-zero: `i = −i` is false.
  have h00 := congrArg (fun A : M => A 0 0) h
  simp [σz, Complex.ext_iff] at h00
  -- `h00 : (1 : ℝ) = -1` — the imaginary parts of `i` and `−i`.
  norm_num at h00

/-- The same statement at the axis level, tying §5's decision procedure to the
    matrices it is about. -/
theorem axisMatrix_X_Y_noncomm :
    axisMatrix Axis.X * axisMatrix Axis.Y ≠ axisMatrix Axis.Y * axisMatrix Axis.X := by
  show σx * σy ≠ σy * σx
  exact sigma_xy_noncomm

end QLF

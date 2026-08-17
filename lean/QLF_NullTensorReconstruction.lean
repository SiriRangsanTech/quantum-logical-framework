import QLF_Minkowski
import Mathlib

set_option linter.unusedVariables false

/-!
# QLF_NullTensorReconstruction — nine integer null probes reconstruct the metric multiple

Jacobson's horizon derivation (1995) reaches a **pointwise null-projection** relation: writing
`S_ab := R_ab − κ T_ab`, the Clausius relation `δQ = T δS` on every local Rindler horizon gives
`S_ab k^a k^b = 0` for null `k`. The step from there to the field equations is the algebraic claim
that a symmetric tensor annihilating the null cone is a **multiple of the metric**,
`S_ab = f g_ab` — after which the contracted Bianchi identity plus `∇^a T_ab = 0` fixes
`f = −R/2 + Λ`.

The textbook version of that algebraic step quantifies over the **continuum** of null directions.
This module shows the continuum is gratuitous: **nine null directions suffice, and all nine are
integer points** of the discrete Hermitian lattice `QLF_Minkowski` identifies as the substrate's
Minkowski space (`det X ∈ ℤ`):

  `(1,±1,0,0)`, `(1,0,±1,0)`, `(1,0,0,±1)`, `(5,3,4,0)`, `(5,3,0,4)`, `(5,0,3,4)`

— null because `1² = 1²` and `5² = 3² + 4²`. A generic null direction `(1, cos θ, …)` is *not* a
substrate point; these nine are. So the reconstruction runs entirely inside the realizable discrete
sector, the same pattern as the census recovering `π` and `ζ(3)` without a completed continuum
(`TheContinuum.md` §2, the *unneeded* strike).

Machine-checked here:

* **`finite_null_probes_force_metric`** — vanishing on the nine integer probes forces
  `S = S.tt · diag(1,−1,−1,−1)`. Six axis probes kill the time–space components and pin the spatial
  diagonal to `−S.tt`; the three `3-4-5` probes then kill the spatial off-diagonals.
* **`contract_metricMultiple`** — the converse direction: `contract (metricMultiple f) v =
  f · interval v`, so a metric multiple annihilates *every* null vector, integer or not.
* **`null_annihilator_iff_metric_multiple`** — the two together as a characterization: the symmetric
  tensors annihilating the null cone are **exactly** the metric multiples, a one-dimensional space
  spanned by `g`. Nine integer probes decide membership.
* **`axis_probes_insufficient`** — sharpness: the six axis probes alone do not suffice (the pure
  `xy` tensor passes all six and is not a metric multiple), so the Pythagorean probes are
  indispensable, not decoration.

## Honest scope

This is the **algebraic** rung of Jacobson's derivation, and only that. `SymTensor4` is ten reals
with a quadratic contraction; nothing here ties them to a curvature tensor — supplying `R_ab` is
the differential-geometry step QLF's Lean core does not carry. In the decomposition

  horizon thermodynamics → `S_ab k^a k^b = 0` → `S_ab = f g_ab` → `f = −R/2 + Λ`

this module closes the **middle** arrow, finitely. The first arrow (the local Rindler construction
and the Raychaudhuri focusing equation) and the third (contracted Bianchi) remain the open
dynamical-metric step of `QLF_EinsteinEquations` (`einstein_equations_in_progress`); their cost is
unchanged by this module. The claim made here is *not* "the Einstein equations are derived" — it is
that one continuum quantifier in the standard derivation is replaceable by nine lattice points.
-/

namespace QLF.NullTensor

/-- A symmetric covariant rank-2 tensor in `3+1` split into its ten independent components. -/
structure SymTensor4 where
  tt : ℝ
  tx : ℝ
  ty : ℝ
  tz : ℝ
  xx : ℝ
  xy : ℝ
  xz : ℝ
  yy : ℝ
  yz : ℝ
  zz : ℝ

/-- The quadratic contraction `S_ab v^a v^b` (no metric factors — `S` is covariant, `v`
    contravariant). -/
def contract (S : SymTensor4) (v : Form) : ℝ :=
    S.tt * v.t ^ 2
  + 2 * S.tx * v.t * v.x
  + 2 * S.ty * v.t * v.y
  + 2 * S.tz * v.t * v.z
  + S.xx * v.x ^ 2
  + 2 * S.xy * v.x * v.y
  + 2 * S.xz * v.x * v.z
  + S.yy * v.y ^ 2
  + 2 * S.yz * v.y * v.z
  + S.zz * v.z ^ 2

/-- **Null** with respect to the QLF Minkowski interval `t² − x² − y² − z²`
    (`QLF_Minkowski.det_toMatrix_eq_interval`: this interval *is* the determinant of the Hermitian
    state). -/
def IsNull (v : Form) : Prop := QLF.Minkowski.Form.interval v = 0

/-- The metric multiple `f · g_ab` in signature `(+,−,−,−)`. -/
def metricMultiple (f : ℝ) : SymTensor4 :=
  { tt := f, tx := 0, ty := 0, tz := 0
    xx := -f, xy := 0, xz := 0
    yy := -f, yz := 0
    zz := -f }

/-! ### The nine integer null probes

All nine are integer points of the substrate Hermitian lattice, null because `1² = 1²` and
`5² = 3² + 4²` — no square roots, hence no continuum, is needed to name them. -/

def kxP : Form := ⟨1,  1, 0, 0⟩
def kxM : Form := ⟨1, -1, 0, 0⟩
def kyP : Form := ⟨1, 0,  1, 0⟩
def kyM : Form := ⟨1, 0, -1, 0⟩
def kzP : Form := ⟨1, 0, 0,  1⟩
def kzM : Form := ⟨1, 0, 0, -1⟩
def kxy : Form := ⟨5, 3, 4, 0⟩
def kxz : Form := ⟨5, 3, 0, 4⟩
def kyz : Form := ⟨5, 0, 3, 4⟩

theorem kxP_null : IsNull kxP := by norm_num [IsNull, kxP, QLF.Minkowski.Form.interval]
theorem kxM_null : IsNull kxM := by norm_num [IsNull, kxM, QLF.Minkowski.Form.interval]
theorem kyP_null : IsNull kyP := by norm_num [IsNull, kyP, QLF.Minkowski.Form.interval]
theorem kyM_null : IsNull kyM := by norm_num [IsNull, kyM, QLF.Minkowski.Form.interval]
theorem kzP_null : IsNull kzP := by norm_num [IsNull, kzP, QLF.Minkowski.Form.interval]
theorem kzM_null : IsNull kzM := by norm_num [IsNull, kzM, QLF.Minkowski.Form.interval]
theorem kxy_null : IsNull kxy := by norm_num [IsNull, kxy, QLF.Minkowski.Form.interval]
theorem kxz_null : IsNull kxz := by norm_num [IsNull, kxz, QLF.Minkowski.Form.interval]
theorem kyz_null : IsNull kyz := by norm_num [IsNull, kyz, QLF.Minkowski.Form.interval]

/-- **Finite null reconstruction.** A symmetric tensor whose contraction vanishes on the nine
    integer null probes is the metric multiple `S.tt · diag(1,−1,−1,−1)`.

    Six axis probes: `contract S (1,±1,0,0) = S.tt ± 2 S.tx + S.xx`, whose difference gives
    `S.tx = 0` and whose sum gives `S.xx = −S.tt` (likewise `y`, `z`). Three Pythagorean probes:
    `contract S (5,3,4,0) = 25 S.tt + 9 S.xx + 16 S.yy + 24 S.xy`, and `25 − 9 − 16 = 0` collapses
    it to `24 S.xy = 0`.

    This is the algebraic step of Jacobson (1995) eqs. (5)→(6), with the continuum of null
    directions replaced by nine substrate lattice points. -/
theorem finite_null_probes_force_metric
    (S : SymTensor4)
    (hxp : contract S kxP = 0) (hxm : contract S kxM = 0)
    (hyp : contract S kyP = 0) (hym : contract S kyM = 0)
    (hzp : contract S kzP = 0) (hzm : contract S kzM = 0)
    (hxy : contract S kxy = 0) (hxz : contract S kxz = 0)
    (hyz : contract S kyz = 0) :
    S = metricMultiple S.tt := by
  norm_num [contract, kxP] at hxp
  norm_num [contract, kxM] at hxm
  norm_num [contract, kyP] at hyp
  norm_num [contract, kyM] at hym
  norm_num [contract, kzP] at hzp
  norm_num [contract, kzM] at hzm
  norm_num [contract, kxy] at hxy
  norm_num [contract, kxz] at hxz
  norm_num [contract, kyz] at hyz
  -- Every hypothesis is linear in the ten components, so `linarith` settles each one.
  have htx : S.tx = 0 := by linarith
  have hty : S.ty = 0 := by linarith
  have htz : S.tz = 0 := by linarith
  have hxx : S.xx = -S.tt := by linarith
  have hyy : S.yy = -S.tt := by linarith
  have hzz : S.zz = -S.tt := by linarith
  have hxy0 : S.xy = 0 := by linarith
  have hxz0 : S.xz = 0 := by linarith
  have hyz0 : S.yz = 0 := by linarith
  cases S
  simp_all [metricMultiple]

/-- **The converse direction.** A metric multiple contracts to `f` times the interval, so it
    annihilates *every* null vector — integer probe or not. -/
theorem contract_metricMultiple (f : ℝ) (v : Form) :
    contract (metricMultiple f) v = f * QLF.Minkowski.Form.interval v := by
  simp [contract, metricMultiple, QLF.Minkowski.Form.interval]
  ring

/-- A metric multiple annihilates the whole null cone. -/
theorem metricMultiple_annihilates_null (f : ℝ) (v : Form) (hv : IsNull v) :
    contract (metricMultiple f) v = 0 := by
  rw [contract_metricMultiple, hv, mul_zero]

/-- **Characterization: the null-cone annihilators are exactly the metric multiples.**

    The symmetric tensors vanishing on every null direction form the one-dimensional space spanned
    by `g_ab`; membership is decided by the nine integer probes. This is the algebraic content of
    Jacobson's step, stated as an equivalence rather than one implication. -/
theorem null_annihilator_iff_metric_multiple (S : SymTensor4) :
    (∀ v : Form, IsNull v → contract S v = 0) ↔ ∃ f : ℝ, S = metricMultiple f := by
  constructor
  · intro hnull
    exact ⟨S.tt, finite_null_probes_force_metric S
      (hnull kxP kxP_null) (hnull kxM kxM_null)
      (hnull kyP kyP_null) (hnull kyM kyM_null)
      (hnull kzP kzP_null) (hnull kzM kzM_null)
      (hnull kxy kxy_null) (hnull kxz kxz_null) (hnull kyz kyz_null)⟩
  · rintro ⟨f, rfl⟩ v hv
    exact metricMultiple_annihilates_null f v hv

/-- **The standard continuum premise reduces to the finite one.** Quantifying over all null
    directions gives the metric form, but only through nine of them. -/
theorem all_null_projections_force_metric
    (S : SymTensor4) (hnull : ∀ v : Form, IsNull v → contract S v = 0) :
    S = metricMultiple S.tt :=
  finite_null_probes_force_metric S
    (hnull kxP kxP_null) (hnull kxM kxM_null)
    (hnull kyP kyP_null) (hnull kyM kyM_null)
    (hnull kzP kzP_null) (hnull kzM kzM_null)
    (hnull kxy kxy_null) (hnull kxz kxz_null) (hnull kyz kyz_null)

/-! ### Sharpness

The six axis probes are not enough: the pure `xy` tensor passes all of them (each axis probe has at
most one non-zero spatial component, so the `xy` term never fires) yet is not a metric multiple. The
three Pythagorean probes are therefore load-bearing — the `3-4-5` triple is what reaches the spatial
off-diagonals while staying on the integer lattice. -/

/-- The pure `xy` tensor: a counterexample witness. -/
def pureXY : SymTensor4 :=
  { tt := 0, tx := 0, ty := 0, tz := 0
    xx := 0, xy := 1, xz := 0
    yy := 0, yz := 0
    zz := 0 }

theorem axis_probes_insufficient :
    contract pureXY kxP = 0 ∧ contract pureXY kxM = 0 ∧
    contract pureXY kyP = 0 ∧ contract pureXY kyM = 0 ∧
    contract pureXY kzP = 0 ∧ contract pureXY kzM = 0 ∧
    contract pureXY kxy ≠ 0 ∧ (∀ f : ℝ, pureXY ≠ metricMultiple f) := by
  refine ⟨by norm_num [contract, pureXY, kxP], by norm_num [contract, pureXY, kxM],
          by norm_num [contract, pureXY, kyP], by norm_num [contract, pureXY, kyM],
          by norm_num [contract, pureXY, kzP], by norm_num [contract, pureXY, kzM],
          by norm_num [contract, pureXY, kxy], ?_⟩
  intro f hf
  have : (1 : ℝ) = 0 := by
    have := congrArg SymTensor4.xy hf
    simpa [pureXY, metricMultiple] using this
  norm_num at this

/-- **Established constructively:** the algebraic step of Jacobson's derivation — symmetric tensor
    annihilating the null cone ⟹ metric multiple — holds with the continuum of null directions
    replaced by **nine integer points of the substrate Hermitian lattice**
    (`finite_null_probes_force_metric`), and the two directions assemble into the characterization
    `null_annihilator_iff_metric_multiple` (the annihilators are exactly the multiples of `g`).
    The nine are sharp in the sense that the axis probes alone fail (`axis_probes_insufficient`).
    **Open, unchanged:** the arrow *into* this step (the local Rindler construction and Raychaudhuri
    focusing giving `S_ab k^a k^b = 0`) and the arrow *out* (contracted Bianchi fixing
    `f = −R/2 + Λ`) — the differential-geometry machinery of
    `QLF_EinsteinEquations.einstein_equations_in_progress`. -/
theorem null_tensor_reconstruction_complete : True := trivial

end QLF.NullTensor

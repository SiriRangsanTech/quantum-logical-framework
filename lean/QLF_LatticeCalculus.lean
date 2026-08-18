import QLF_BianchiClosure
import Mathlib

set_option linter.unusedVariables false

/-!
# QLF_LatticeCalculus — the divergence interface is inhabited

[`QLF_BianchiClosure`](QLF_BianchiClosure.lean) derives `G_ab + Λ g_ab = κ T_ab` over a
`DivergenceCalculus` interface rather than an axiom, which is the honest way to carry a boundary QLF's
core cannot construct. But an interface nobody has instantiated is a liability: if its laws were jointly
unsatisfiable, every theorem conditioned on it would be **vacuously** true and worth nothing.

This module removes that possibility by building one.

## The instance

A **forward-difference calculus on the integer lattice** `M = ℤ`, with `D f p = f (p+1) − f p`:

* `grad f` puts the difference in the live direction — `(grad f)_b = D f · δ_{b0}`;
* `div A` contracts the first index, as a divergence should — `(div A)_b = D (A_{0b})`, reading the
  components `A_{00}, A_{01}, A_{02}, A_{03}` as `tt, tx, ty, tz`.

Metric compatibility is then not imposed but *computed*: `metricMultiple c` has `tt = c` and the other
first-row components `0`, so `div (f·g) = grad f` falls out (`latticeDiv_metricMultiple`). The remaining
laws follow from linearity of the difference operator.

**It is not degenerate.** A `div ≡ 0, grad ≡ 0` instance would satisfy every law vacuously and
demonstrate nothing; here `grad` is genuinely non-zero (`grad_nonzero_witness`), so
`const_of_grad_eq_zero` — the connectedness condition — has real content: it is discharged by induction
over `ℤ` in both directions (`const_of_forward_diff_zero`), which is exactly the connectedness the
continuum statement needs.

## What this settles, and what it does not

**Settles:** the interface is **inhabited**, so `einstein_field_equations` and
`scalar_multiple_is_curvature` are conditional on satisfiable hypotheses rather than vacuously true
(`interface_is_inhabited`, `field_equations_hold_on_the_lattice`).

**Does not settle:** that this is *the* physical calculus. It is a one-dimensional lattice model — the
live direction is `0` and the others are inert — so it witnesses consistency, not the Lorentzian
geometry the field equations are ultimately about. Constructing that remains the open step named in
`QLF_BianchiClosure`. No axioms.
-/

namespace QLF.LatticeCalculus

open QLF.NullTensor QLF.Bianchi

/-- The forward difference on the integer lattice. -/
def D (f : ℤ → ℝ) : ℤ → ℝ := fun p => f (p + 1) - f p

/-- The first row of a symmetric tensor, `A_{0b}` — the components a divergence contracts. -/
def row0 (A : SymTensor4) : Fin 4 → ℝ := ![A.tt, A.tx, A.ty, A.tz]

/-- `(grad f)_b = D f · δ_{b0}` — the difference, in the one live direction. -/
def latticeGrad (f : ScalarField ℤ) : CovectorField ℤ :=
  fun p b => if b = 0 then D f p else 0

/-- `(div A)_b = D (A_{0b})` — the divergence contracts the first index. -/
def latticeDiv (A : TensorField ℤ) : CovectorField ℤ :=
  fun p b => D (fun q => row0 (A q) b) p

/-! ### The laws -/

theorem D_add (f g : ℤ → ℝ) : D (fun p => f p + g p) = fun p => D f p + D g p := by
  funext p; simp [D]; ring

theorem D_smul (c : ℝ) (f : ℤ → ℝ) : D (fun p => c * f p) = fun p => c * D f p := by
  funext p; simp [D]; ring

theorem latticeDiv_add (A B : TensorField ℤ) :
    latticeDiv (fun p => A p + B p) = fun p => latticeDiv A p + latticeDiv B p := by
  funext p b
  fin_cases b <;> simp [latticeDiv, row0, D] <;> ring

theorem latticeDiv_smul (c : ℝ) (A : TensorField ℤ) :
    latticeDiv (fun p => c • A p) = fun p => c • latticeDiv A p := by
  funext p b
  fin_cases b <;> simp [latticeDiv, row0, D] <;> ring

/-- **Metric compatibility is computed, not imposed.** `metricMultiple c` has first row `(c,0,0,0)`, so
    contracting the first index returns the difference of the scalar — exactly `grad`. -/
theorem latticeDiv_metricMultiple (f : ScalarField ℤ) :
    latticeDiv (fun p => metricMultiple (f p)) = latticeGrad f := by
  funext p b
  fin_cases b <;> simp [latticeDiv, latticeGrad, row0, D]

theorem latticeGrad_add (f g : ScalarField ℤ) :
    latticeGrad (fun p => f p + g p) = fun p => latticeGrad f p + latticeGrad g p := by
  funext p b
  by_cases h : b = 0 <;> simp [latticeGrad, h, D] <;> ring

theorem latticeGrad_smul (c : ℝ) (f : ScalarField ℤ) :
    latticeGrad (fun p => c * f p) = fun p => c • latticeGrad f p := by
  funext p b
  by_cases h : b = 0 <;> simp [latticeGrad, h, D] <;> ring

/-- **Connectedness of the lattice**, discharged in both directions by induction over `ℤ`: a function
    whose forward difference vanishes everywhere is constant. This is the law a degenerate instance
    would have satisfied vacuously. -/
theorem const_of_forward_diff_zero (f : ℤ → ℝ) (h : ∀ p, f (p + 1) = f p) : ∀ p, f p = f 0 := by
  intro p
  induction p using Int.induction_on with
  | hz => rfl
  | hp k ih => rw [h k]; exact ih
  | hn k ih =>
      have := h (-(k : ℤ) - 1)
      have hk : -(k : ℤ) - 1 + 1 = -(k : ℤ) := by ring
      rw [hk] at this
      rw [← this] at ih
      exact ih

theorem latticeGrad_eq_zero_const (f : ScalarField ℤ) (h : latticeGrad f = 0) :
    ∃ c : ℝ, ∀ p, f p = c := by
  refine ⟨f 0, const_of_forward_diff_zero f (fun p => ?_)⟩
  have := congrFun (congrFun h p) 0
  simp [latticeGrad, D] at this
  linarith

/-! ### The instance -/

/-- **The divergence interface, inhabited.** -/
def latticeCalculus : DivergenceCalculus ℤ where
  div := latticeDiv
  grad := latticeGrad
  div_add := latticeDiv_add
  div_smul := latticeDiv_smul
  div_metricMultiple := latticeDiv_metricMultiple
  grad_add := latticeGrad_add
  grad_smul := latticeGrad_smul
  const_of_grad_eq_zero := latticeGrad_eq_zero_const

/-- **It is inhabited** — so nothing conditioned on `DivergenceCalculus` is vacuous. -/
theorem interface_is_inhabited : Nonempty (DivergenceCalculus ℤ) := ⟨latticeCalculus⟩

/-- **And not degenerately so**: the gradient is genuinely non-zero, so `const_of_grad_eq_zero` is a
    real constraint here rather than a triviality. Witness: `f p = p`, whose difference is `1`. -/
theorem grad_nonzero_witness : latticeGrad (fun p : ℤ => (p : ℝ)) ≠ 0 := by
  intro h
  have := congrFun (congrFun h 0) 0
  simp [latticeGrad, D] at this

/-- **The field equations hold over a calculus that exists.** Instantiating
    `QLF_BianchiClosure.einstein_field_equations` at the lattice: given the metric form, contracted
    Bianchi and conservation, `G_ab + Λ g_ab = κ T_ab` — now with the interface demonstrably satisfiable
    rather than merely assumed. -/
theorem field_equations_hold_on_the_lattice
    (κ : ℝ) (Ric T : TensorField ℤ) (f : ScalarField ℤ)
    (hform : ∀ p, Ric p = κ • T p + metricMultiple (f p))
    (hbianchi : latticeCalculus.div Ric = fun p => (1 / 2 : ℝ) • latticeCalculus.grad (scalarCurv Ric) p)
    (hcons : latticeCalculus.div T = 0) :
    ∃ Λ : ℝ, ∀ p, einsteinTensor Ric p + metricMultiple Λ = κ • T p :=
  einstein_field_equations latticeCalculus κ Ric T f hform hbianchi hcons

/-- **Established constructively, no axioms.** The `DivergenceCalculus` interface of
    `QLF_BianchiClosure` is **inhabited** (`latticeCalculus`, `interface_is_inhabited`), so the field
    equations derived over it are conditional on *satisfiable* hypotheses rather than vacuously true
    (`field_equations_hold_on_the_lattice`). The witness is a forward-difference calculus on `ℤ` in
    which metric compatibility is **computed** rather than imposed (`latticeDiv_metricMultiple`) and the
    gradient is genuinely non-zero (`grad_nonzero_witness`), so the connectedness law does real work —
    discharged by induction over `ℤ` in both directions (`const_of_forward_diff_zero`). **Honest scope:**
    this is a one-dimensional lattice model witnessing consistency, **not** the Lorentzian calculus the
    field equations are ultimately about; constructing that remains the open step. -/
theorem lattice_calculus_summary : True := trivial

end QLF.LatticeCalculus

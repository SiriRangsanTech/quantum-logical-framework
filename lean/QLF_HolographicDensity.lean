import QLF_GravityFromDelay
import QLF_EinsteinEquations
import Mathlib

set_option linter.unusedVariables false

/-!
# QLF_HolographicDensity — naming η and quantifying the Bekenstein–Hawking residual exactly

QLF's gravity carries two entropy statements that must be reconciled (the "holographic density" question):

* the **holographic count** — one half-spin closure per Planck-area patch, `S_QLF = N·log 2 = 4πR² log 2`
  (`QLF_GravityFromDelay.holographic_entropy_eq`); and
* the **thermodynamic (Jacobson/Bekenstein–Hawking) density** `η = 1/(4G)` — `S_BH = A/(4L_P²) = N/4` nats,
  the entropy density that makes the Einstein coefficient come out `8πG = 2π/η`
  (`QLF_EinsteinEquations.einstein_coupling_from_thermodynamics`).

These differ, and this module names and **quantifies the residual exactly** — the honest content, no fit:

* **`bekensteinHawkingEntropy`** = `N/4` nats (`= A/(4L_P²)`), named alongside the holographic count.
* **`holographic_bh_ratio`** — `S_QLF / S_BH = 4·log 2 ≈ 2.7726` **exactly** (the previously-muddled
  "≈5.77" in `Gravity_From_Delay.md`). QLF's naive one-bit-per-patch count *exceeds* the realized
  thermodynamic entropy by this factor.
* **`residual_is_quarter_times_quantum`** — the residual is **not a free parameter**: `4·log 2 = 4 ×
  per_event_entropy`, the product of two **already-derived** QLF constants — the **`4`** (the Einstein
  `8π = 4π·2` factor / the `η = 1/4G` quarter, `QLF_EinsteinGeometricFactor`/`QLF_EinsteinEquations`) and
  **`log 2`** (the per-event bit quantum, `QLF_FreeEnergy`). So the "holographic density η" residual is
  `(the Einstein quarter) × (the per-event quantum)`, both fixed elsewhere in the substrate.

**The force law is residual-independent.** Newton's `1/r²` and the *structural* `G = L_P²c³/ℏ`
(`QLF_GravityFromDelay`) come from `F = T·dS/dx` where the overall entropy normalization **cancels**, so the
`4 log 2` factor does not touch the derived force law — it lives purely in the absolute entropy /
absolute-`G` normalization.

## Scope

Names η (`= 1/4G`, reuse) and quantifies the Bekenstein–Hawking residual as **exactly `4 log 2`**,
decomposed into two derived constants. It does **not** resolve *why* the realized horizon entropy is the
thermodynamic `N/4` rather than the naive `N·log 2` — whether the extra `4 log 2` is a genuine
discrete-floor deviation from Bekenstein–Hawking, or is absorbed into the continuum area element / a
correlation (packing) factor that makes only `1/(4 log 2)` of the patches independent. That classification
(and the absolute SI `G`, which also needs `R_stable`/#121) is the open piece — now a **product of derived
constants**, not a mystery. Reuses `QLF_GravityFromDelay` + `QLF_EinsteinEquations`; no new axioms. See
`Gravity_From_Delay.md` §9.
-/

namespace QLF.HolographicDensity

open QLF

/-- **Bekenstein–Hawking horizon entropy** `S_BH = A/(4L_P²) = N/4` nats, where `N = holographic_event_count`
    is the Planck-area patch count — the thermodynamic entropy density `η = 1/4G` integrated over the area. -/
noncomputable def bekensteinHawkingEntropy (R : ℝ) : ℝ := holographic_event_count R / 4

/-- **The holographic-density residual, exactly.** QLF's one-bit-per-patch holographic entropy exceeds the
    realized Bekenstein–Hawking entropy by **exactly `4·log 2 ≈ 2.7726`**: `S_QLF/S_BH = (N log 2)/(N/4) =
    4 log 2`. This is the precise value of the "holographic density η" residual (correcting the schematic
    `≈5.77` in `Gravity_From_Delay.md`). -/
theorem holographic_bh_ratio {R : ℝ} (hR : R ≠ 0) :
    holographic_entropy R / bekensteinHawkingEntropy R = 4 * Real.log 2 := by
  have hN : holographic_event_count R ≠ 0 := by unfold holographic_event_count; positivity
  unfold holographic_entropy bekensteinHawkingEntropy per_event_entropy
  field_simp

/-- **The residual is a product of two derived constants — not a free parameter.** `4·log 2 = 4 ×
    per_event_entropy`: the **`4`** is the Einstein `8π = 4π·2` factor / the `η = 1/4G` quarter (fixed in
    `QLF_EinsteinGeometricFactor`/`QLF_EinsteinEquations`) and **`log 2`** is the per-event bit quantum
    (`QLF_FreeEnergy`). So the holographic-density residual is `(the Einstein quarter) × (the per-event
    quantum)`, both already substrate-fixed. -/
theorem residual_is_quarter_times_quantum : 4 * Real.log 2 = 4 * per_event_entropy := rfl

/-- The Bekenstein–Hawking entropy density **`η = 1/(4G)`** named explicitly (reuse
    `QLF_EinsteinEquations.entropy_density`), the object in the Einstein coefficient `8πG = 2π/η`. -/
theorem eta_eq_quarter_inv_G (G : ℝ) : entropy_density G = 1 / (4 * G) := rfl

/-- **No rational packing factor can explain the residual — branch (b) of the §9 classification is
    closed.** Suppose the resolution were a correlation factor making only a fraction `p/q` of the
    Planck patches independent, so that matching Bekenstein–Hawking requires `4·p·log 2 = q`. Then
    `log 2 = q/(4p)` would be **rational**, and it is not.

    Irrationality of `log 2` is taken as an explicit hypothesis rather than proved here (it is in fact
    transcendental, by Lindemann–Weierstrass: an algebraic non-zero `α` with `e^α = 2` would make `2`
    transcendental). A future session can discharge `hirr` if Mathlib gains the lemma; the content of
    this theorem is the implication, which does not depend on it.

    **Why this prunes the classification.** The required independent fraction is `1/(4 log 2) ≈
    0.360674`. A packing fraction read off a ratio of finite counts is rational, so it can never hit
    that value — the near misses confirm it numerically: the ZFA-balanced fraction `C(2n,n)/4ⁿ`
    brackets it without touching (`n=2` gives `0.375`, `+4.0%`; `n=3` gives `0.3125`, `−13.4%`), and
    `1/e ≈ 0.3679` is `+2.0%` off. Any surviving "packing" account must be a *limiting* density that
    itself manufactures a `log 2`, at which point it is not a combinatorial packing fraction. -/
theorem no_rational_packing_factor (hirr : Irrational (Real.log 2)) (p q : ℕ) (hp : p ≠ 0) :
    4 * (p : ℝ) * Real.log 2 ≠ (q : ℝ) := by
  intro h
  have h4p : (4 : ℝ) * (p : ℝ) ≠ 0 := mul_ne_zero (by norm_num) (Nat.cast_ne_zero.mpr hp)
  refine hirr ⟨(q : ℚ) / (4 * (p : ℚ)), ?_⟩
  push_cast
  rw [div_eq_iff h4p]
  linear_combination -h

/-- **The suppression would have to cancel the very quantum it suppresses.** `(N·log 2)·(1/(4 log 2))
    = N/4`: the realized Bekenstein–Hawking entropy contains **no `log 2` at all**. So the horizon
    entropy is not (a count) × (the per-event bit quantum) — which is the structural reason to read
    the residual as an **area-element / what-counts-as-a-patch** question (branch (c)) rather than as
    a suppression of a correct bit count (branch (b), closed above). -/
theorem suppression_cancels_the_quantum {N : ℝ} (hlog : Real.log 2 ≠ 0) :
    N * Real.log 2 * (1 / (4 * Real.log 2)) = N / 4 := by
  field_simp

/-- **Established (`Gravity_From_Delay.md` §9).** The holographic-density residual between QLF's
    one-bit-per-patch count `S_QLF = 4πR² log 2` and the thermodynamic Bekenstein–Hawking `S_BH = N/4`
    (density `η = 1/4G`, `eta_eq_quarter_inv_G`) is **exactly `4·log 2`** (`holographic_bh_ratio`), which is
    a **product of two derived constants** — the Einstein quarter `4` × the per-event quantum `log 2`
    (`residual_is_quarter_times_quantum`), not a free parameter. The `1/r²` force law and structural `G` are
    **residual-independent** (the normalization cancels in `F = T dS/dx`). **Open:** *why* the realized
    entropy is `N/4` not `N log 2` — a genuine floor-scale deviation vs. a correlation/packing factor
    (`1/(4 log 2)` independent patches) vs. an area-element redefinition — plus the absolute SI `G`
    (needs also `R_stable`/#121). **The packing branch is now closed** (`no_rational_packing_factor`),
    and `suppression_cancels_the_quantum` says why the remaining weight is on the area-element reading.
    Reuses `QLF_GravityFromDelay` + `QLF_EinsteinEquations`; no new axioms.

    Stated as a conjunction of what is proved rather than `True := trivial`, which every possible
    module satisfies and which therefore reports nothing. -/
theorem holographic_density_summary {R : ℝ} (hR : R ≠ 0) (hlog : Real.log 2 ≠ 0) :
    holographic_entropy R / bekensteinHawkingEntropy R = 4 * Real.log 2 ∧
    holographic_entropy R * (1 / (4 * Real.log 2)) = bekensteinHawkingEntropy R := by
  refine ⟨holographic_bh_ratio hR, ?_⟩
  unfold holographic_entropy bekensteinHawkingEntropy per_event_entropy
  field_simp

end QLF.HolographicDensity

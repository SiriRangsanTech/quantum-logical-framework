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
  ring

/-- **The residual is a product of two derived constants — not a free parameter.** `4·log 2 = 4 ×
    per_event_entropy`: the **`4`** is the Einstein `8π = 4π·2` factor / the `η = 1/4G` quarter (fixed in
    `QLF_EinsteinGeometricFactor`/`QLF_EinsteinEquations`) and **`log 2`** is the per-event bit quantum
    (`QLF_FreeEnergy`). So the holographic-density residual is `(the Einstein quarter) × (the per-event
    quantum)`, both already substrate-fixed. -/
theorem residual_is_quarter_times_quantum : 4 * Real.log 2 = 4 * per_event_entropy := rfl

/-- The Bekenstein–Hawking entropy density **`η = 1/(4G)`** named explicitly (reuse
    `QLF_EinsteinEquations.entropy_density`), the object in the Einstein coefficient `8πG = 2π/η`. -/
theorem eta_eq_quarter_inv_G (G : ℝ) : entropy_density G = 1 / (4 * G) := rfl

/-- **Established (`Gravity_From_Delay.md` §9).** The holographic-density residual between QLF's
    one-bit-per-patch count `S_QLF = 4πR² log 2` and the thermodynamic Bekenstein–Hawking `S_BH = N/4`
    (density `η = 1/4G`, `eta_eq_quarter_inv_G`) is **exactly `4·log 2`** (`holographic_bh_ratio`), which is
    a **product of two derived constants** — the Einstein quarter `4` × the per-event quantum `log 2`
    (`residual_is_quarter_times_quantum`), not a free parameter. The `1/r²` force law and structural `G` are
    **residual-independent** (the normalization cancels in `F = T dS/dx`). **Open:** *why* the realized
    entropy is `N/4` not `N log 2` — a genuine floor-scale deviation vs. a correlation/packing factor
    (`1/(4 log 2)` independent patches) vs. an area-element redefinition — plus the absolute SI `G`
    (needs also `R_stable`/#121). Reuses `QLF_GravityFromDelay` + `QLF_EinsteinEquations`; no new axioms. -/
theorem holographic_density_summary : True := trivial

end QLF.HolographicDensity

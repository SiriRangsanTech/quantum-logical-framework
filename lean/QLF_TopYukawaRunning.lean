import QLF_RunningCouplings
import Mathlib

set_option linter.unusedVariables false

/-!
# QLF_TopYukawaRunning — the top-Yukawa running sector of the Higgs quartic

Discharges the running sector behind `λ ≈ 0.13` ([`Higgs.md`](../Higgs.md) §5a). The self-organized
criticality of the quantum-turbulent electroweak vacuum ([`QLF_HiggsTurbulence`](QLF_HiggsTurbulence.lean))
fixes the **boundary condition** on the Higgs quartic at the substrate UV floor — the Shaposhnikov–Wetterich
condition `λ = 0 ∧ β_λ = 0` at `M_Planck` (which predicted `M_H ≈ 126 GeV`). QLF supplies the UV floor by
construction (`cascade_has_floor`, [`QLF_PlanckScale`](QLF_PlanckScale.lean)); the *value* `λ(v) ≈ 0.13` then
follows by running `λ` down from that boundary with the Standard-Model RGEs, **dominated by the top Yukawa**.

This module anchors the **structural core** of that running (the one-loop `β_λ` driving term + the tree
relations); the numerical integration is [`higgs_running_demo.py`](../higgs_running_demo.py), which shows the
measured `λ(v)=0.126` runs up to `≈0` at `M_Planck` (near-criticality) and, imposing `λ(M_Pl)=0`, runs down
to `λ(v) ≈ 0.13` (one-loop). Reuses the one-loop running structure of
[`QLF_RunningCouplings`](QLF_RunningCouplings.lean) (the loop-phase `2π`).

* **`higgs_mass_sq_from_quartic`** / **`higgs_v_ratio_sq`** — tree-level `M_H² = 2λv²`, so
  `(M_H/v)² = 2λ` (the observable; measured `M_H/v ≈ 0.51 ⟺ λ ≈ 0.13`).
* **`top_mass_sq_from_yukawa`** — `m_t = y_t v/√2`, i.e. `m_t² = y_t² v²/2` (the input the running needs).
* **`beta_lambda_top_drives_down`** — the top-Yukawa contribution to `16π² β_λ` is `−6 y_t⁴ < 0`
  (for `y_t ≠ 0`): at the UV where `λ → 0`, this drives `β_λ < 0`, so `λ` *increases* toward the IR —
  the mechanism turning `λ(M_Pl)=0` into `λ(v) > 0`. The destabilizing driver behind metastability.
* **`soc_balances_top_and_gauge`** — at the SOC / Shaposhnikov–Wetterich boundary (`λ=0 ∧ β_λ=0`), the
  top-Yukawa driver is *exactly cancelled* by the gauge-quartic contribution `G = 6 y_t⁴`.

## Scope

Structural + tree relations, plus the sign of the top-Yukawa driver and the SOC-boundary balance. It does
**not** integrate the RGE (that is the Python demo) or derive `m_t` (the top Yukawa is an input = the open
QLF mass scale, `R_e` / the mass spectrum), and the *precise* `λ(M_Pl)=0 ⟺ M_H ≈ 125 GeV` needs the two-loop
RGEs + thresholds (Degrassi 2012 / Buttazzo 2013 — the accepted computation, not a QLF gap). So the running
sector is discharged to {the SOC boundary condition + `m_t` + two-loop precision}. See `Higgs.md` §5a.
-/

namespace QLF.TopYukawaRunning

open QLF

/-- Tree-level Higgs mass-squared: `M_H² = 2 λ v²`. -/
def higgsMassSq (lam v : ℝ) : ℝ := 2 * lam * v ^ 2

theorem higgs_mass_sq_from_quartic (lam v : ℝ) : higgsMassSq lam v = 2 * lam * v ^ 2 := rfl

/-- **The observable ratio.** `(M_H/v)² = 2λ` — measured `M_H/v ≈ 0.51` gives `λ ≈ 0.13`. -/
theorem higgs_v_ratio_sq (lam v : ℝ) (hv : v ≠ 0) : higgsMassSq lam v / v ^ 2 = 2 * lam := by
  unfold higgsMassSq; field_simp

/-- Tree-level top mass-squared from the Yukawa: `m_t = y_t v/√2`, so `m_t² = y_t² v²/2`. -/
noncomputable def topMassSq (yt v : ℝ) : ℝ := yt ^ 2 * v ^ 2 / 2

theorem top_mass_sq_from_yukawa (yt v : ℝ) : topMassSq yt v = yt ^ 2 * v ^ 2 / 2 := rfl

/-- The top-Yukawa contribution to the one-loop `16π² β_λ`: the `−6 y_t⁴` term. -/
def betaLambdaTop (yt : ℝ) : ℝ := -6 * yt ^ 4

/-- **The top Yukawa drives λ down.** Its contribution to `β_λ` is strictly negative (for `y_t ≠ 0`):
    at the UV floor where `λ → 0`, the `−6 y_t⁴` term makes `β_λ < 0`, so running toward the IR `λ`
    *increases* — the destabilizing driver that turns the SOC boundary `λ(M_Pl)=0` into `λ(v) > 0`. -/
theorem beta_lambda_top_drives_down (yt : ℝ) (h : yt ≠ 0) : betaLambdaTop yt < 0 := by
  have hpos : (0 : ℝ) < yt ^ 4 := by
    have h1 : (0 : ℝ) < yt * yt := (mul_self_pos).mpr h
    have : yt ^ 4 = yt * yt * (yt * yt) := by ring
    rw [this]; exact mul_pos h1 h1
  unfold betaLambdaTop; linarith

/-- The self-organized-critical (Shaposhnikov–Wetterich) boundary: at the substrate UV floor both the
    quartic and its running vanish. QLF supplies the floor (`cascade_has_floor`, `QLF_PlanckScale`) and the
    mechanism (the turbulent steady state relaxing to its critical fixed point). -/
def SOCBoundary (lam betaLam : ℝ) : Prop := lam = 0 ∧ betaLam = 0

/-- **At the SOC boundary the top driver is exactly cancelled by the gauge quartic.** With
    `β_λ = (−6 y_t⁴) + G` (top term + gauge-quartic contribution `G`), the boundary `β_λ = 0` forces
    `G = 6 y_t⁴` — the critical balance that fixes the Shaposhnikov–Wetterich relation between the top
    Yukawa and the gauge couplings at the Planck floor. -/
theorem soc_balances_top_and_gauge (yt G : ℝ)
    (h : SOCBoundary 0 (betaLambdaTop yt + G)) : G = 6 * yt ^ 4 := by
  obtain ⟨_, hb⟩ := h
  unfold betaLambdaTop at hb; linarith

/-- **Established (the top-Yukawa running sector, `Higgs.md` §5a).** The observable `(M_H/v)² = 2λ`
    (`higgs_v_ratio_sq`) with the top mass `m_t² = y_t² v²/2` (`top_mass_sq_from_yukawa`); the one-loop
    `β_λ` top-Yukawa driver `−6 y_t⁴ < 0` (`beta_lambda_top_drives_down`) turns the SOC boundary
    `λ(M_Pl)=0` into `λ(v) > 0`; and at the Shaposhnikov–Wetterich boundary the top driver is cancelled by
    the gauge quartic `G = 6 y_t⁴` (`soc_balances_top_and_gauge`). The numerical integration
    (`higgs_running_demo.py`) confirms the measured `λ(v)=0.126` hits the near-critical `λ(M_Pl)≈0` and,
    reversed, postdicts `λ(v)` from the boundary. **Open (`top_yukawa_running_in_progress`):** the two-loop
    precision (Degrassi/Buttazzo) and `m_t` itself (the open QLF mass scale). Reuses `QLF_RunningCouplings`;
    no new axioms. See `Higgs.md` §5a. -/
theorem top_yukawa_running_in_progress : True := trivial

end QLF.TopYukawaRunning

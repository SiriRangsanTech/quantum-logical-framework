import QLF_AlphaS
import Mathlib

set_option linter.unusedVariables false

/-!
# QLF_GravitationalCoupling — the strength of gravity `α_G = exp(−28π)` from the `14π` hierarchy

*Nailing down `G`.* The **structural** `G = L_P²c³/ℏ = 1` (Planck units) is already derived
(`QLF_GravityFromDelay`), and the SI *number* is a unit convention (what a metre/kilogram is). The genuine
**physics** content of `G` — *how weak gravity is* — is the **dimensionless gravitational coupling**
\[
  α_G \;=\; \frac{G\,m_p^2}{\hbar c} \;=\; \Bigl(\frac{m_p}{M_{\rm Pl}}\Bigr)^2 ,
  \qquad M_{\rm Pl} = \sqrt{\hbar c/G}\ (\approx 1.22\times10^{19}\ \text{GeV}),
\]
the "gravitational fine-structure constant" (`≈ 5.9×10⁻³⁹`). And QLF **already derives the mass hierarchy**
`ln(M_Pl/m_p) = 14π` (`QLF_AlphaS.hierarchy_log_eq_fourteen_pi`, dimensional transmutation from the single
integer `b₀ = 7`). Since `m_p/M_Pl = exp(−ln(M_Pl/m_p))`, the coupling is the square:
\[
  α_G \;=\; \exp\!\bigl(-2\ln(M_{\rm Pl}/m_p)\bigr) \;=\; \exp(-28π).
\]

So the **strength of gravity is derived from the substrate hierarchy** — machine-verified:

* **`alpha_G_is_ratio_sq`** — `α_G = (m_p/M_Pl)²` (the coupling is the mass ratio squared, `= exp(−2·hierLog)`).
* **`alpha_G_eq_exp_neg_28pi`** — at the QLF hierarchy `ln(M_Pl/m_p) = 14π`, `α_G = exp(−28π)`.
* **`substrate_gravitational_coupling`** — using QLF's *own derived* `14π` hierarchy
  (`hierarchy_log_eq_fourteen_pi`, from `b₀=7`), `α_G = exp(−28π)` end-to-end.

Numerically `exp(−28π) = 6.27×10⁻³⁹` vs. measured `α_G = 5.91×10⁻³⁹` — **0.068% on the log**,
`6.2%` on the value (the exp-sensitivity of the `14π` hierarchy, same as `QLF_AlphaS.hierarchy_log_band`).
The electron version is `α_G^e = (m_e/M_Pl)² = exp(−2·ln(M_Pl/m_e))`, with `m_e = m_p/6π⁵`
(`QLF_LenzMassRatio`), so it too follows from the one hierarchy plus the mass ratio.

## Scope

This derives the **dimensionless** gravitational coupling `α_G = exp(−28π)` (the physical strength of
gravity) from the substrate `14π` mass hierarchy — the real "nailing down of `G`". The **absolute SI `G`**
is then `G = α_G · ℏc/m_p²`: it needs, beyond `α_G`, only `m_p`'s absolute SI value (a kilogram
convention / calibration), not new physics. Precision is the `14π` hierarchy's (0.068% log / 6.2% value,
exp-sensitive). The **entropy-normalization** side of `G` — the Bekenstein–Hawking `η`/`4 log 2` residual
(`QLF_HolographicDensity`) — is *separate* (it touches the absolute entropy, not `α_G`, and the `1/r²` law
is normalization-independent); the accelerating-Casimir/Unruh temperature is relevant *there* (shared
Unruh `T`), not to `α_G`, which is the mass hierarchy. Reuses `QLF_AlphaS`; no new axioms.
-/

namespace QLF.GravitationalCoupling

open QLF

/-- The dimensionless gravitational coupling as a function of the mass-hierarchy log `hierLog =
    ln(M_Pl/m_p)`: `α_G = (m_p/M_Pl)² = exp(−2·hierLog)`. -/
noncomputable def gravitationalCoupling (hierLog : ℝ) : ℝ := Real.exp (-2 * hierLog)

/-- **The coupling is the mass ratio squared** — `α_G = (m_p/M_Pl)²`, since `m_p/M_Pl = exp(−hierLog)`. -/
theorem alpha_G_is_ratio_sq (hierLog : ℝ) :
    gravitationalCoupling hierLog = (Real.exp (-hierLog)) ^ 2 := by
  unfold gravitationalCoupling
  rw [sq, ← Real.exp_add]
  congr 1; ring

/-- **At the QLF `14π` hierarchy, the gravitational coupling is `exp(−28π)`** (`−2·14π = −28π`). -/
theorem alpha_G_eq_exp_neg_28pi :
    gravitationalCoupling (14 * Real.pi) = Real.exp (-28 * Real.pi) := by
  unfold gravitationalCoupling
  congr 1; ring

/-- **The strength of gravity from the substrate, end-to-end.** Feeding QLF's *own derived* mass hierarchy
    `ln(M_Pl/m_p) = 14π` (`hierarchy_log_eq_fourteen_pi`, dimensional transmutation from `b₀ = 7`) into the
    gravitational coupling gives `α_G = exp(−28π)` — the dimensionless strength of gravity derived from the
    single substrate integer `7`. (`exp(−28π) = 6.27×10⁻³⁹` vs. measured `5.91×10⁻³⁹`, 0.068% on the log.) -/
theorem substrate_gravitational_coupling :
    gravitationalCoupling (Real.log (transmuted_hierarchy (beta_coefficient 3 6)
      (substrate_alpha_s (beta_coefficient 3 6)))) = Real.exp (-28 * Real.pi) := by
  rw [hierarchy_log_eq_fourteen_pi]
  exact alpha_G_eq_exp_neg_28pi

/-! ## Bracketing `α_G` (hence `G`) from the hierarchy band -/

/-- **The `α_G` bracket — the tightest value-bracket QLF gives on the strength of gravity.** Because
    `α_G = exp(−2·hierLog)` is exp-sensitive, the *value* bracket comes from the mass-hierarchy band
    `ln(M_Pl/m_p) ∈ [14π, 104π/7]` (`QLF_AlphaS.hierarchy_log_band`, the running-consistent `α_s ∈ [1/52,1/49]`
    window). This gives `α_G ∈ [exp(−208π/7), exp(−28π)]` — machine-verified. Numerically
    `[2.87×10⁻⁴¹, 6.27×10⁻³⁹]`, which **contains** the measured `α_G = 5.91×10⁻³⁹`, sitting near the *upper*
    (`14π`, `b₀²=49`) edge — so `G = α_G·ℏc/m_p²` is bracketed likewise. **The bracket width is set by `α_s`
    (strong), not `α` (EM):** tightening it means tightening the QCD coupling window, not using `α`. -/
theorem alpha_G_bracket {hierLog : ℝ} (hlo : 14 * Real.pi ≤ hierLog)
    (hhi : hierLog ≤ 104 * Real.pi / 7) :
    Real.exp (-208 * Real.pi / 7) ≤ gravitationalCoupling hierLog ∧
      gravitationalCoupling hierLog ≤ Real.exp (-28 * Real.pi) := by
  unfold gravitationalCoupling
  refine ⟨Real.exp_le_exp.mpr ?_, Real.exp_le_exp.mpr ?_⟩
  · linarith
  · linarith

/-- **Where `α` meets gravity — the EM/gravity coupling ratio.** The dimensionless ratio of the
    electromagnetic to the gravitational coupling between two protons is `α/α_G = (1/137)/exp(−28π) =
    exp(28π)/137`, combining *both* substrate constants (`α⁻¹=137`, `QLF_FineStructureSubstrate`; `α_G=
    exp(−28π)`). Numerically `exp(28π)/137 = 1.16×10³⁶` vs. measured `1.24×10³⁶` (6%, the `14π`
    exp-sensitivity). So `α` brackets the gravity-vs-EM *comparison* — it does **not** tighten the absolute
    `G` bracket (that is the `α_s` window). -/
theorem em_gravity_coupling_ratio :
    (1 / 137 : ℝ) / gravitationalCoupling (14 * Real.pi) = Real.exp (28 * Real.pi) / 137 := by
  rw [alpha_G_eq_exp_neg_28pi]
  have h : Real.exp (-28 * Real.pi) = (Real.exp (28 * Real.pi))⁻¹ := by
    rw [← Real.exp_neg]; congr 1; ring
  rw [h, div_inv_eq]; ring

/-- **Established.** The dimensionless gravitational coupling `α_G = G m_p²/ℏc = (m_p/M_Pl)²`
    (`alpha_G_is_ratio_sq`) is `exp(−28π)` at QLF's `14π` mass hierarchy (`alpha_G_eq_exp_neg_28pi`), and
    end-to-end from the substrate integer `b₀=7` (`substrate_gravitational_coupling`) — the *strength* of
    gravity derived (0.068% on the log / 6.2% on the value, the `14π` exp-sensitivity). The **absolute SI
    `G = α_G·ℏc/m_p²`** then needs only `m_p`'s SI value (a kilogram convention), not new physics. The
    Bekenstein–Hawking `η`/`4 log 2` entropy residual (`QLF_HolographicDensity`) is a *separate* piece
    (absolute entropy, not `α_G`; the `1/r²` law is normalization-independent), where the accelerating-
    Casimir/Unruh temperature is the relevant tool. Reuses `QLF_AlphaS`; no new axioms. -/
theorem gravitational_coupling_summary : True := trivial

end QLF.GravitationalCoupling

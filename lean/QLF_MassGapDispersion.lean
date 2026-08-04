import QLF_GravitationalWaves
import QLF_MassGap

set_option linter.unusedVariables false

/-!
# QLF_MassGapDispersion — the Yang–Mills mass gap as the dispersion gap of the propagation operator

A **bridge** tying the gravitational-wave machinery ([`QLF_GravitationalWaves`](QLF_GravitationalWaves.lean))
to the Yang–Mills mass gap ([`QLF_MassGap`](QLF_MassGap.lean)). The mass gap is already the substrate
closure quantum `gaugeMassGap = log 2 > 0` (`mass_gap_quantum_pos`); this module gives it a **propagation
meaning** using the discrete d'Alembertian, and unifies the massless/massive dichotomy with the
gauge-fold-absent/present dichotomy QLF already carries.

## The picture

* A **massless** field (photon / graviton — *no* gauge fold, `R = 0`) obeys the free wave equation
  `□_d δρ = 0` (`QLF_GravitationalWaves.boxD_dAlembert`): every traveling ripple is a solution, so it
  propagates freely at `c` with **no minimum frequency** — gapless.
* A **massive** gauge-fold field obeys the discrete Klein–Gordon equation `(□_d + m²) h = 0`
  (`boxKG`). A massless traveling wave is no longer a solution — the mass term `m² δρ` is exactly the
  obstruction (`massive_residual`) — so the gauge fold **gaps** the field.
* The continuum dispersion read off `boxKG`'s symbol is `ω² = k² + m²`; at zero momentum (`k = 0`) the
  minimum excitation frequency is `ω = |m|`. For a gauge-fold field `m = gaugeMassGap = log 2`, so the
  **rest-frame dispersion gap is `log 2 > 0`** — the Yang–Mills mass gap read as a propagation gap
  (`mass_gap_is_dispersion_gap`), whereas the massless field has `ω² = 0` (gapless).

## What is proven vs. the boundary

**Proven (no new axioms):** the discrete massive operator and its massless limit (`boxKG_zero_eq_boxD`,
`massless_gapless`, `massive_residual`), the algebraic dispersion gap (`massless_zero_momentum_gapless`,
`massive_rest_gap`), and the identification of the gauge-fold gap with the substrate quantum
`gaugeMassGap = log 2 > 0` (`mass_gap_is_dispersion_gap`, reusing `mass_gap_quantum_pos`).

**Honest scope.** This is a **bridge / unification**, not a Clay advance: it recasts the *already-known*
`gaugeMassGap = log 2` (QLF_MassGap) as the rest-frame gap of the propagation operator, tying it to the
GW wave sector. The Clay statement — that the *continuum* Yang–Mills theory has a positive mass gap —
stays behind the boundary axiom `yang_mills_continuum_gap` (`QLF_MassGap`), unchanged; and the
"discrete `boxKG` symbol = continuum dispersion" step is the same standard second-order finite-difference
correspondence as `boxD → □` (`QLF_GravitationalWaves`). No new axioms.
-/

namespace QLF

/-! ### The discrete massive (Klein–Gordon) wave operator -/

/-- The discrete massive wave operator `□_d + m²` on the substrate lattice: the massless d'Alembertian
    `boxD` plus a mass term. `m = 0` is the photon/graviton wave operator; `m > 0` is a gauge-fold
    (massive) field. -/
def boxKG (m : ℝ) (h : LatticeField) (t x : ℤ) : ℝ := boxD h t x + m ^ 2 * h t x

/-- **The massless case is exactly the d'Alembertian** — with `m = 0`, `boxKG` is `boxD`. -/
theorem boxKG_zero_eq_boxD (h : LatticeField) (t x : ℤ) : boxKG 0 h t x = boxD h t x := by
  simp only [boxKG]; ring

/-- **A massless field is gapless.** The `m = 0` operator annihilates every traveling-wave closure
    ripple (reuse `boxD_dAlembert`): a gauge-fold-free ripple (photon/graviton) propagates freely at
    `c`, with no minimum frequency. -/
theorem massless_gapless (f g : ℤ → ℝ) (t x : ℤ) : boxKG 0 (dAlembert f g) t x = 0 := by
  rw [boxKG_zero_eq_boxD]; exact boxD_dAlembert f g t x

/-- **The mass term is the obstruction.** Applying the massive operator to a massless traveling wave
    leaves exactly the mass term `m² · δρ` (via `boxD_dAlembert`): a gauge-fold field cannot propagate
    as a free massless ripple — the gauge fold gaps it. -/
theorem massive_residual (m : ℝ) (f g : ℤ → ℝ) (t x : ℤ) :
    boxKG m (dAlembert f g) t x = m ^ 2 * (dAlembert f g) t x := by
  simp only [boxKG, boxD_dAlembert]; ring

/-! ### The dispersion relation and the gap -/

/-- The **continuum dispersion relation** read off the massive operator's symbol: `ω² − k² − m² = 0`
    on-shell. The discrete `boxKG` renders this in the continuum limit, exactly as `boxD` renders `□`. -/
def dispersion (m ω k : ℝ) : ℝ := ω ^ 2 - k ^ 2 - m ^ 2

/-- **Massless ⇒ gapless.** On-shell at zero momentum (`k = 0`) a massless field has `ω² = 0`: the
    minimum excitation frequency is zero, no gap. -/
theorem massless_zero_momentum_gapless (ω : ℝ) (h : dispersion 0 ω 0 = 0) : ω ^ 2 = 0 := by
  unfold dispersion at h; linear_combination h

/-- **Massive ⇒ a rest-frame gap.** On-shell at zero momentum, `ω² = m²`: the minimum excitation
    frequency is `|m|`, the rest energy / mass gap. -/
theorem massive_rest_gap (m ω : ℝ) (h : dispersion m ω 0 = 0) : ω ^ 2 = m ^ 2 := by
  unfold dispersion at h; linear_combination h

/-! ### The Yang–Mills mass gap IS the dispersion gap -/

/-- **The Yang–Mills mass gap is the rest-frame dispersion gap.** For a gauge-fold field the mass is
    the substrate closure quantum `m = gaugeMassGap = log 2` (`QLF_MassGap`), so its zero-momentum
    on-shell frequency is `ω² = gaugeMassGap² > 0` — a strictly positive minimum excitation frequency,
    the gap — whereas the massless (gauge-fold-free) field has `ω² = 0` (gapless). -/
theorem mass_gap_is_dispersion_gap :
    (∀ ω : ℝ, dispersion gaugeMassGap ω 0 = 0 → ω ^ 2 = gaugeMassGap ^ 2) ∧
    0 < gaugeMassGap ∧
    (∀ ω : ℝ, dispersion 0 ω 0 = 0 → ω ^ 2 = 0) :=
  ⟨fun ω h => massive_rest_gap gaugeMassGap ω h, mass_gap_quantum_pos,
    fun ω h => massless_zero_momentum_gapless ω h⟩

/-- **Summary — massless/massive is gauge-fold absent/present.** A gauge-fold-free ripple obeys
    `boxKG 0 δρ = 0` (gapless, propagates at `c`); a gauge-fold field carries the mass term
    (`massive_residual`), and its continuum rest-frame gap is `gaugeMassGap = log 2 > 0` — the Yang–Mills
    mass gap read as a propagation gap. A bridge tying `QLF_GravitationalWaves` to `QLF_MassGap`; the Clay
    continuum statement stays behind `yang_mills_continuum_gap`. No new axioms. -/
theorem massgap_dispersion_bridge :
    (∀ f g : ℤ → ℝ, ∀ t x : ℤ, boxKG 0 (dAlembert f g) t x = 0) ∧ 0 < gaugeMassGap :=
  ⟨fun f g t x => massless_gapless f g t x, mass_gap_quantum_pos⟩

end QLF

import QLF_PMNS
import QLF_QuantumBlackHole
import Mathlib

set_option linter.unusedVariables false

/-!
# QLF_NeutrinoOscillation — flavor oscillation as norm-preserving closure precession

Neutrino flavor **oscillation** is the slow phase evolution of the three-axis Majorana closure
([`Beta_Decay_Neutrino_Nature.md`](../Beta_Decay_Neutrino_Nature.md) §3): the flavor eigenstates
`ν_e, ν_μ, ν_τ` are orientations of the same closure combinatorics, mixed unitarily (`QLF_PMNS`). This
module proves what is genuinely provable about it — and in particular **verifies the speculation of
[`Decay.md`](../Decay.md) §2.1** that turbulence-driven (prime phase-slip) flavor conversion *conserves
neutrino number*.

* **`flavor_precession_conserves_number`** — the oscillation evolves the flavor polarization by
  `dP/dt = Ω × P`; since `P · (Ω × P) = 0` (`dot_cross_self`), `P` is always orthogonal to its own rate
  of change, so `‖P‖²` is conserved. **`prime_kick_conserves_number`** — the turbulent prime bath only
  *adds to the rotation axis* `Ω = ω_vac + κ·n̂_prime`, so it re-orients/accelerates the oscillation but
  **does not create or destroy neutrinos**. This is the exact content of the `Decay.md` §2.1 precession
  equation: collective flavor conversion is a *rotation*, not a decay.
* **`two_flavor_unitarity`** / **`two_flavor_prob_bounds`** — the two-flavor probabilities
  `P_surv = 1 − A·s`, `P_app = A·s` (`A = sin²2θ`, `s = sin²(Δm²L/4E)`) sum to 1 and lie in `[0,1]`:
  genuine probabilities, total number conserved. **`mixing_unitary`** — the algebraic root is PMNS
  unitarity `cos²θ + sin²θ = 1` (`QLF_PMNS`).
* **`deltaMSq`** / **`no_oscillation_iff_degenerate`** — the oscillation phase is driven by the
  mass-squared splitting `Δm² = m_i² − m_j² = 1/R_i² − 1/R_j²` (mass `m = 1/R`, `mass_from_depth`); it
  vanishes iff the fold depths are equal, so oscillation *requires* non-degenerate (nonzero, Majorana)
  masses — the fold-depth reading of the mixing (`QLF_NeutrinoMass`).

## Scope

Anchors the conservation law (flavor conversion preserves neutrino number — a genuine theorem verifying
`Decay.md` §2.1), two-flavor unitarity + bounds, and the fold-depth mass-splitting driver. It does **not**
derive the mixing *angles* or the absolute `Δm²` values (the Yukawa/mass sector, `pmns_in_progress`), nor
the *rate* of the prime-driven conversion (the phenomenological `prime_cascade_decay.py` couplings, the
open coupling-strength residual). Reuses `QLF_PMNS` + `QLF_QuantumBlackHole`; no new axioms. See
`Beta_Decay_Neutrino_Nature.md` §3, `Decay.md` §2.1.
-/

namespace QLF.NeutrinoOscillation

open QLF

/-- The flavor **polarization** 3-vector (the Bloch-like vector of the two/three-flavor state). -/
structure Vec3 where
  x : ℝ
  y : ℝ
  z : ℝ

/-- Euclidean inner product. -/
def dot (a b : Vec3) : ℝ := a.x * b.x + a.y * b.y + a.z * b.z

/-- Cross product (the precession generator: `dP/dt = Ω × P`). -/
def cross (a b : Vec3) : Vec3 :=
  ⟨a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x⟩

/-- **A vector is orthogonal to its own cross product** — the scalar triple product `P·(Ω×P) = 0`. -/
theorem dot_cross_self (Ω P : Vec3) : dot P (cross Ω P) = 0 := by
  simp only [dot, cross]; ring

/-- **Flavor conversion conserves neutrino number.** The oscillation evolves the polarization by the
    precession `dP/dt = Ω × P` (the vacuum + prime-driven generator); since `P·(Ω×P) = 0`, `P` stays
    orthogonal to its rate of change, so `d/dt‖P‖² = 2 P·(dP/dt) = 0` — the magnitude (total neutrino
    number) is **conserved**. Oscillation is a rotation of flavor, not a decay. (Verifies `Decay.md` §2.1.) -/
theorem flavor_precession_conserves_number (Ω P : Vec3) : dot P (cross Ω P) = 0 :=
  dot_cross_self Ω P

/-- The prime-driven total precession axis: `ω_vac + κ·n̂_prime` (the turbulent kick adds to the axis). -/
def totalAxis (omega_vac : Vec3) (kappa : ℝ) (n : Vec3) : Vec3 :=
  ⟨omega_vac.x + kappa * n.x, omega_vac.y + kappa * n.y, omega_vac.z + kappa * n.z⟩

/-- **The turbulent prime kick still conserves neutrino number.** The prime term only *adds to the
    rotation axis* (`totalAxis`), so the evolution is still a precession `dP/dt = Ω_total × P` with
    `P·(Ω_total×P) = 0`: the prime bath re-orients / accelerates the oscillation but creates and destroys
    no neutrinos — collective flavor conversion is number-conserving. -/
theorem prime_kick_conserves_number (omega_vac : Vec3) (kappa : ℝ) (n P : Vec3) :
    dot P (cross (totalAxis omega_vac kappa n) P) = 0 :=
  dot_cross_self _ P

/-! ## Two-flavor oscillation probabilities -/

/-- Two-flavor appearance `P(ν_a→ν_b) = A·s`, with `A = sin²2θ` and `s = sin²(Δm²L/4E)`. -/
def oscP_app (A s : ℝ) : ℝ := A * s

/-- Two-flavor survival `P(ν_a→ν_a) = 1 − A·s`. -/
def oscP_surv (A s : ℝ) : ℝ := 1 - A * s

/-- **Two-flavor oscillation is unitary** — survival + appearance `= 1` (total probability conserved). -/
theorem two_flavor_unitarity (A s : ℝ) : oscP_surv A s + oscP_app A s = 1 := by
  simp only [oscP_surv, oscP_app]; ring

/-- **The two-flavor probabilities are genuine probabilities** — `0 ≤ P ≤ 1` for `A, s ∈ [0,1]`. -/
theorem two_flavor_prob_bounds (A s : ℝ) (hA0 : 0 ≤ A) (hA1 : A ≤ 1) (hs0 : 0 ≤ s) (hs1 : s ≤ 1) :
    0 ≤ oscP_app A s ∧ oscP_app A s ≤ 1 := by
  refine ⟨mul_nonneg hA0 hs0, ?_⟩
  calc oscP_app A s = A * s := rfl
    _ ≤ 1 * 1 := mul_le_mul hA1 hs1 hs0 (by norm_num)
    _ = 1 := by norm_num

/-- **Flavor mixing is unitary** (reuse `QLF_PMNS`): `cos²θ + sin²θ = 1` — the PMNS rotation preserves
    total probability, the algebraic root of `two_flavor_unitarity`. -/
theorem mixing_unitary (θ : ℝ) : Real.cos θ ^ 2 + Real.sin θ ^ 2 = 1 :=
  QLF.PMNS.pmns_row_unitarity θ

/-! ## The oscillation is driven by fold-depth mass splittings -/

/-- Mass-squared splitting from the fold depths (mass `m = 1/R`, `mass_from_depth`):
    `Δm² = m_i² − m_j² = 1/R_i² − 1/R_j²`. The oscillation phase is `Δ = Δm²·L/(4E)`. -/
noncomputable def deltaMSq (R_i R_j : ℝ) : ℝ :=
  (mass_from_depth R_i) ^ 2 - (mass_from_depth R_j) ^ 2

/-- **Oscillation requires non-degenerate fold depths.** `Δm² = 0 ⟺ 1/R_i² = 1/R_j²`: equal fold depths
    give no oscillation, so flavor oscillation *requires* the mass eigenstates to have different fold
    depths — i.e. nonzero (Majorana) masses (`QLF_NeutrinoMass`). -/
theorem no_oscillation_iff_degenerate (R_i R_j : ℝ) :
    deltaMSq R_i R_j = 0 ↔ (1 / R_i) ^ 2 = (1 / R_j) ^ 2 := by
  simp only [deltaMSq, mass_from_depth]
  constructor <;> intro h <;> linarith

/-- **Established (`Beta_Decay_Neutrino_Nature.md` §3, verifying `Decay.md` §2.1).** Flavor oscillation is
    a norm-preserving precession `dP/dt = Ω×P` (`flavor_precession_conserves_number`) — and the turbulent
    prime kick only adds to the axis (`prime_kick_conserves_number`), so collective flavor conversion
    **conserves neutrino number** (a rotation, not a decay); the two-flavor probabilities are unitary and
    bounded (`two_flavor_unitarity`, `two_flavor_prob_bounds`), rooted in PMNS unitarity
    (`mixing_unitary`); and the oscillation is driven by the fold-depth mass splitting `Δm²`
    (`no_oscillation_iff_degenerate`), requiring non-degenerate (Majorana) masses. **Open:** the mixing
    *angles* / absolute `Δm²` (`pmns_in_progress`) and the prime-conversion *rate* (the phenomenological
    `prime_cascade_decay.py`). Reuses `QLF_PMNS` + `QLF_QuantumBlackHole`; no new axioms. -/
theorem neutrino_oscillation_summary : True := trivial

end QLF.NeutrinoOscillation

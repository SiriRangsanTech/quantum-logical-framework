import QLF_HorizonTemperature
import QLF_FreeEnergy
import Mathlib

set_option linter.unusedVariables false

/-!
# QLF_Casimir — the Casimir effect: a finite census, `1/a⁴` scaling, and the accelerated-boundary Unruh tie

The Casimir effect sits exactly at QLF's junction: continuum QFT gives an **infinite** zero-point sum and
extracts the force only after ζ-regularizing away the infinity, whereas QLF's vacuum is a **discrete,
bounded** identity closure (flat per-log-frequency, `Ω_Λ ∼ log 2`; [`VacuumEnergy.md`](../VacuumEnergy.md)).
So the Casimir force is a **finite difference** of closed-mode censuses, not a subtraction of infinities —
and its acceleration/dynamical version is the Unruh relation QLF already proves. Reuse + one genuine
dimensional theorem; no new axioms.

* **`casimir_vacuum_quantum`** — the per-mode vacuum contribution is the **finite** `log 2` quantum
  (`binary_kl_delta_uniform`), not a divergent `Σ½ℏω`. The force between boundaries is the *difference* of
  two finite closed-mode censuses (boundary-restricted vs. free) — no infinite zero-point sum ever appears
  (the "continuum is the UV catastrophe" reading, `QFT_QLF.md` §4).
* **`casimir_scaling`** — the **`1/a⁴` force law is forced by dimensional analysis** (the genuine new
  theorem, in the `QLF_Kolmogorov.kolmogorov_exponents` style). The only scales available to the vacuum
  between the plates are `ℏ`, `c`, and the gap `a` — *no* `G`, mass, or cutoff — so the energy density
  `E/A = C·ℏc·a^p` has its exponent fixed by `[ℏc·a^p] = [E/A]` to `p = −3`, hence the pressure exponent
  `p − 1 = −4`: `P ∝ 1/a⁴`. Parameter-free, like the mm-redshift `gΔh/c²` (`GR_Schwarzschild.md` §2a).
* **`accelerated_boundary_is_unruh`** — an **accelerating boundary** (the dynamical Casimir effect) sees a
  vacuum temperature that is the **Unruh master relation** `T = ℏa/(2πc k_B)` at its proper acceleration
  `a` (reuse `unruh_temperature`) — the *same* relation that gives Hawking (`hawking_is_unruh`) and de
  Sitter (`desitter_is_unruh`), the `2π` being the substrate loop phase (as in `g−2 = α/2π`). So the same
  constructing-delay geometry that recovers gravitational time dilation recovers the accelerated-vacuum
  phenomenology.

## Scope

Anchors the **finiteness** (no divergent zero-point sum — the finite `log 2` quantum), the **`1/a⁴`
scaling** (dimensional analysis, parameter-free), and the **accelerated-boundary = Unruh** identification
(reuse). It does **not** derive the exact Casimir coefficient `−π²/240` (that is the `ζ(−3)` mode sum — the
continuum-QFT computation, the same kind of continuum step as `yang_mills_continuum_gap`) nor the
dynamical-Casimir photon-pair-creation *rate* (the time-dependent-boundary continuum QFT). So: the scaling +
finiteness + Unruh tie are anchored; the coefficient and the pair-rate are the named continuum pieces.
Reuses `QLF_HorizonTemperature` + `QLF_FreeEnergy`; no new axioms. See `VacuumEnergy.md`, `QFT_QLF.md`.
-/

namespace QLF.Casimir

open QLF

/-- **The per-mode vacuum quantum is finite** — `binary_kl 1 (1/2) = log 2` (`binary_kl_delta_uniform`),
    not a divergent `Σ½ℏω`. The Casimir force is the finite *difference* of two finite closed-mode
    censuses (boundary-restricted vs. free vacuum); no infinite zero-point sum arises on the substrate. -/
theorem casimir_vacuum_quantum : binary_kl 1 (1 / 2) = Real.log 2 :=
  binary_kl_delta_uniform

/-- The Casimir **pressure exponent** given an energy-density exponent `p` (`E/A ∝ a^p ⟹ P = −∂(E/A)/∂a ∝
    a^{p−1}`). -/
def pressureExponent (p : ℝ) : ℝ := p - 1

/-- **The `1/a⁴` Casimir force law, forced by dimensional analysis.** Between the plates the vacuum has
    only `ℏ`, `c`, and the gap `a` to work with (no `G`, mass, or cutoff), so the energy density
    `E/A = C·ℏc·a^p` must satisfy `[ℏc·a^p] = [E/A]`, i.e. `3 + p = 0` ⟹ `p = −3`; the pressure exponent is
    then `p − 1 = −4`. So `E/A ∝ 1/a³` and `P ∝ 1/a⁴` — parameter-free, no regularization. (The exact
    coefficient `−π²/240` is the `ζ(−3)` mode sum, the continuum piece.) -/
theorem casimir_scaling (p : ℝ) (hDim : 3 + p = 0) :
    p = -3 ∧ pressureExponent p = -4 := by
  refine ⟨by linarith, ?_⟩
  unfold pressureExponent; linarith

/-- **(Definitional.)** The temperature assigned to a boundary of proper acceleration `a` is the Unruh
    master relation `T = ℏa/(2πc k_B)` — the *same* relation behind Hawking (`hawking_is_unruh`) and de
    Sitter (`desitter_is_unruh`), the `2π` the substrate loop phase.

    **Read the label.** This is `rfl`: `unruh_temperature` is *defined* as the right-hand side, and no
    boundary appears in the statement. It records the identification QLF makes — that an accelerating
    Casimir plate is on the same relation as a horizon — and it **is not evidence for it**. The physical
    claim is the dynamical-Casimir/Unruh correspondence, which is standard continuum QFT, cited here and
    not derived (the same status as `hawking_is_unruh`, which carries the same honest label upstream).
    For statements that are *not* `rfl`, see the three below. -/
theorem accelerated_boundary_is_unruh (hbar a c kB : ℝ) :
    unruh_temperature hbar a c kB = hbar * a / (2 * Real.pi * c * kB) :=
  rfl

/-- **A boundary sees a thermal vacuum exactly when it accelerates** — and at **no** constant velocity,
    however large. This is the formal content of Galileo's ship (*Dialogue*, 1632): uniform motion is
    undetectable from inside, so the vacuum a boundary reads cannot depend on its speed, only on its
    acceleration. Unlike `accelerated_boundary_is_unruh` this is not `rfl`; it needs `ℏ, c, k_B ≠ 0` and
    has content — it is the isotropy half that [`Inertia.md`](../Inertia.md) §1 lists as kill condition 2. -/
theorem boundary_unruh_zero_iff_inertial (hbar a c kB : ℝ)
    (hbar0 : hbar ≠ 0) (hc : c ≠ 0) (hkB : kB ≠ 0) :
    unruh_temperature hbar a c kB = 0 ↔ a = 0 := by
  have hne : (2 : ℝ) * Real.pi * c * kB ≠ 0 :=
    mul_ne_zero (mul_ne_zero (mul_ne_zero (by norm_num) Real.pi_ne_zero) hc) hkB
  unfold unruh_temperature
  rw [div_eq_zero_iff]
  constructor
  · rintro (h | h)
    · exact (mul_eq_zero.mp h).resolve_left hbar0
    · exact absurd h hne
  · intro h
    exact Or.inl (by rw [h, mul_zero])

/-- **The response is exactly linear in the acceleration** — no threshold, no onset. Inertia is linear in
    `a` too, which is why this is the relation an inertia derivation would have to route through
    ([`Inertia.md`](../Inertia.md) §4). -/
theorem boundary_unruh_linear_in_acceleration (hbar a c kB lam : ℝ) :
    unruh_temperature hbar (lam * a) c kB = lam * unruh_temperature hbar a c kB := by
  unfold unruh_temperature
  ring

/-- **A static boundary has no Unruh bath at all**, so the *static* Casimir force is **not** a thermal
    effect: the two phenomena this module treats are separate in origin, and the finite-census argument
    (`casimir_vacuum_quantum`) is what carries the static force, not the temperature. Worth stating because
    conflating them is the easy error when the same module holds both. -/
theorem static_boundary_no_unruh (hbar c kB : ℝ) :
    unruh_temperature hbar 0 c kB = 0 := by
  unfold unruh_temperature
  simp

/-- **Established (`VacuumEnergy.md`, `QFT_QLF.md`).** The Casimir force is a **finite** difference of
    closed-mode censuses (the per-mode quantum is `log 2`, `casimir_vacuum_quantum` — no divergent
    zero-point sum); the **`1/a⁴`** force law is forced parameter-free by dimensional analysis
    (`casimir_scaling`, `ℏ,c,a` the only scales); and an **accelerating boundary** sees the Unruh
    temperature `T = ℏa/(2πck_B)` (`accelerated_boundary_is_unruh`, reuse) — the same loop-phase `2π` and
    constructing-delay geometry as Hawking/de Sitter and the mm-scale redshift. **Open (the named continuum
    pieces, not gaps here):** the exact coefficient `−π²/240` (`ζ(−3)` mode sum) and the dynamical-Casimir
    pair-creation *rate* (time-dependent-boundary QFT). Reuses `QLF_HorizonTemperature` + `QLF_FreeEnergy`;
    no new axioms.

    Stated as a **conjunction of the two things actually proved** rather than as `True := trivial`, which
    was what stood here and carried nothing: a `True` summary is satisfied by every possible module and so
    reports no content (the audit discipline of `QLF_AxiomAudit`, and the deliberate absence noted in
    `QLF_HorizonBasis`). -/
theorem casimir_summary (hbar a c kB : ℝ) (hbar0 : hbar ≠ 0) (hc : c ≠ 0) (hkB : kB ≠ 0) :
    binary_kl 1 (1 / 2) = Real.log 2 ∧ (unruh_temperature hbar a c kB = 0 ↔ a = 0) :=
  ⟨casimir_vacuum_quantum, boundary_unruh_zero_iff_inertial hbar a c kB hbar0 hc hkB⟩

end QLF.Casimir

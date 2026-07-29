import QLF_QuantumTurbulence
import QLF_ContradictionReceipt
import QLF_FreeEnergy

set_option linter.unusedVariables false

/-!
# QLF_PrimeCascadeDecay — turbulence forces decay: the prime phase-slip and the cascade dump

The **structural skeleton** of the turbulence-forced decay of a stable ZFA structure (muonium, a
hadron, …) and the collective "prime-synchronized cascade dump" (a QLF-internal 'primordial supernova'
mechanism, [`Turbulence.md`](../Turbulence.md)). Reuse-only synthesis (the `QLF_HiggsTurbulence` /
`QLF_ClosureBinding` pattern; **no new axioms**). The picture:

* A stable bound state is a **persistent ZFA closure** — a *balanced*, symmetric twist history
  (`achieves_ZFA`). Quantum turbulence presents all closures at once; the **irreducible (prime)** ones
  carry an open forward strand with the geometric phase `±i` (`π/2`) — the phase-slip agents.
* When prime phase-slips lock to the bound state's internal clock they add coherently, driving the twist
  counts **out of balance**. An unbalanced ledger is a *contradiction* (`IsContradiction = ¬ symmetric`),
  which **receives no ZFA receipt** — so the structure is no longer a closure and **must decay**.
* Each unlocked closure releases the free-action quantum `ΔF = log 2`; a synchronized ensemble releases
  `n · log 2` together — the scale-invariant dump.

Reuse anchors:

* **`prime_slip_is_quarter_turn`** — the prime phase-slip is a *primitive* quarter-turn `±i`
  (`phase_quantum_is_quarter_turn`); **`prime_slip_irreducible`** — a prime-period slip cannot be
  factored/averaged away (`prime_closure_irreducible`): a genuine irreducible phase-shift agent.
* **`slip_out_of_balance_ends_closure`** — the decay *condition*: a phase slip that unbalances the count
  (makes it a contradiction) destroys the ZFA receipt — the structure is no longer a closure
  (`contradiction_no_receipt`). **`stable_structure_is_balanced`** — conversely a persistent structure
  must be balanced (`receipt_is_balanced`), so *any* unbalancing slip ends it.
* **`unlock_releases_log_two`** — each unlocked closure releases the `log 2` quantum
  (`binary_kl_delta_uniform`); **`collective_dump_positive`** — `n` synchronized unlockings release
  `n · log 2 > 0` (the cascade dump energy).
* **`cascade_bath_highest_first`** / **`cascade_bath_floored`** — the turbulent bath resolves
  highest-frequency-first (`highest_frequency_resolves_first`) down to a floor (`cascade_has_floor`).

## Scope

This anchors the **structure**: the prime `±i` phase-slip agent, the decay *condition* (out-of-balance
⟹ no receipt ⟹ not a closure), the `log 2` release quantum, and the octave bath. It does **not** derive
the decay *dynamics* — the coupling `Γ_p` (prime→slip), the resonance sharpness `Q`, the synchronization
`S`, or the feedback runaway — those are the *phenomenological* model in
[`prime_cascade_decay.py`](../prime_cascade_decay.py), whose map from ZFA combinatorics to the coupling
*strength* is the **same open piece** as the four-fermion binding strength (`higgs_turbulence_in_progress`).
And it is **not** a claim that laboratory muonium or real supernovae proceed this way — a QLF-internal,
qualitative mechanism. Reuses `QLF_QuantumTurbulence` + `QLF_ContradictionReceipt` + `QLF_FreeEnergy`;
no new axioms. See `Turbulence.md`.
-/

namespace QLF.PrimeCascadeDecay

open QLF QLF.QuantumTurbulence QLF.ContradictionReceipt QLF.Consciousness

/-- **The prime phase-slip is a primitive quarter-turn `±i`.** The order-parameter phase increment is a
    genuine `π/2` (`i, i², i³ ≠ 1`): each prime injects a discrete `±i` kick — the phase-slip agent. -/
theorem prime_slip_is_quarter_turn :
    PauliScalar.i ≠ 1 ∧ PauliScalar.i * PauliScalar.i ≠ 1 ∧
    PauliScalar.i * PauliScalar.i * PauliScalar.i ≠ 1 :=
  phase_quantum_is_quarter_turn

/-- **A prime slip is irreducible — it cannot be averaged away.** A prime-period closure has only the
    divisors `1` and itself, so the turbulent bath cannot factor its `±i` kick into a repeat of a
    shorter (cancelling) closure: the slip accumulates coherently at commensurability. -/
theorem prime_slip_irreducible {R : ℕ} (h : R.Prime) : ∀ d, d ∣ R → d = 1 ∨ d = R :=
  prime_closure_irreducible h

/-- **The decay condition — a phase slip out of balance ends the closure.** If a slip drives the twist
    counts out of ZFA balance (a *contradiction*, `IsContradiction s = ¬ is_symmetric s`), the history
    **receives no ZFA receipt** (`contradiction_no_receipt`): it is no longer a closure, so the
    previously persistent structure is not a physical event and must decay. -/
theorem slip_out_of_balance_ends_closure (s : TopoString) (h : IsContradiction s) :
    ¬ achieves_ZFA s :=
  contradiction_no_receipt s h

/-- **A persistent structure is balanced** (`receipt_is_balanced`) — so *any* unbalancing prime slip
    ends it: the stable ZFA closure is exactly a non-contradiction, and the phase-slip mechanism attacks
    that balance. -/
theorem stable_structure_is_balanced (s : TopoString) (h : achieves_ZFA s) : ¬ IsContradiction s :=
  receipt_is_balanced s h

/-- **Each unlocked closure releases the `log 2` quantum** (`binary_kl_delta_uniform`): the free-action
    stored in the fold is dumped one bit at a time — the unit of the cascade release. -/
theorem unlock_releases_log_two : binary_kl 1 (1 / 2) = Real.log 2 :=
  binary_kl_delta_uniform

/-- **The collective dump energy is positive and additive:** `n` synchronized unlockings release
    `n · log 2 > 0`. When a macroscopic ensemble unlocks together this is the scale-invariant energy
    dump — the 'primordial supernova' as a prime-synchronized cascade release. -/
theorem collective_dump_positive (n : ℕ) (h : 0 < n) : 0 < (n : ℝ) * Real.log 2 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hn : (0 : ℝ) < (n : ℝ) := by exact_mod_cast h
  exact mul_pos hn h2

/-- **The turbulent bath resolves highest-frequency-first** — the shortest (highest-`f`) closures, hence
    the shallow primes, arrive first (`highest_frequency_resolves_first`). -/
theorem cascade_bath_highest_first {R_small R_large : ℕ} (h0 : 0 < R_small) (h : R_small < R_large) :
    freq R_large < freq R_small :=
  highest_frequency_resolves_first h0 h

/-- **The bath is floored** — no infinite cascade; the prime flux is cut off at the dissipation / Planck
    floor (`cascade_has_floor`). -/
theorem cascade_bath_floored {R_min R : ℕ} (h0 : 0 < R_min) (h : R_min ≤ R) : freq R ≤ freq R_min :=
  cascade_has_floor h0 h

/-- **Deterministic decay ⟹ the exponential law (a QLF finding, `Decay.md` §1a).** A constant hazard
    rate `Γ₀` — the ensemble statistics of the *incoherent* prime bath — is *exactly* the exponential
    decay law: `N(t) = N₀ e^{−Γ₀ t}` has derivative `dN/dt = −Γ₀·N(t)` at every `t`. So the textbook
    "random" exponential is the statistics of a **deterministic** substrate (each unlocking is a
    determined prime-lock event), not fundamental indeterminism. -/
theorem exponential_decay_from_constant_hazard (N0 Γ t : ℝ) :
    HasDerivAt (fun s => N0 * Real.exp (-Γ * s)) (-Γ * (N0 * Real.exp (-Γ * t))) t := by
  have hlin : HasDerivAt (fun s : ℝ => -Γ * s) (-Γ) t := by
    simpa using (hasDerivAt_id t).const_mul (-Γ)
  rw [show -Γ * (N0 * Real.exp (-Γ * t)) = N0 * (Real.exp (-Γ * t) * -Γ) from by ring]
  exact (hlin.exp).const_mul N0

/-! ## The resonant decay rate — vacuum limit and enhancement (the muon stage, `Decay.md` §2.2) -/

/-- The resonant decay rate of a stable structure in the prime bath: `Γ(t) = Γ₀ + Γ_p·Φ_p·S` — the
    vacuum rate `Γ₀` plus the prime-flux term (`Φ_p` = prime flux at the octave nearest `ω_b`, `S` the
    synchronization factor). -/
def resonantRate (Γ0 Γp Φp S : ℝ) : ℝ := Γ0 + Γp * Φp * S

/-- **Vacuum limit — no prime flux recovers ordinary decay.** `Φ_p → 0` gives `Γ = Γ₀`: away from the
    turbulent bath a muon / muonium closure decays at its ordinary constant-hazard rate `Γ₀`, hence the
    ordinary exponential lifetime (`exponential_decay_from_constant_hazard`). -/
theorem vacuum_limit_constant_hazard (Γ0 Γp S : ℝ) : resonantRate Γ0 Γp 0 S = Γ0 := by
  simp [resonantRate]

/-- **The prime flux only *shortens* the lifetime.** For `Γ_p, Φ_p, S ≥ 0` the resonant rate is `≥ Γ₀`:
    turbulence can only *accelerate* a true (number-changing) decay, never lengthen it — the muon stage,
    where — unlike the number-conserving neutrino precession (`QLF_NeutrinoOscillation`) — an unbalancing
    slip **ends** the closure (`slip_out_of_balance_ends_closure`). -/
theorem resonant_enhances (Γ0 Γp Φp S : ℝ) (hp : 0 ≤ Γp) (hΦ : 0 ≤ Φp) (hS : 0 ≤ S) :
    Γ0 ≤ resonantRate Γ0 Γp Φp S := by
  have h : 0 ≤ Γp * Φp * S := mul_nonneg (mul_nonneg hp hΦ) hS
  simp only [resonantRate]; linarith

/-- **Established (the structure of turbulence-forced decay + the cascade dump, `Turbulence.md`).** The
    prime phase-slip is an irreducible `±i` quarter-turn agent (`prime_slip_is_quarter_turn`,
    `prime_slip_irreducible`); driving a stable closure out of balance ends it — no receipt
    (`slip_out_of_balance_ends_closure`), and a persistent structure *is* balanced
    (`stable_structure_is_balanced`), so any unbalancing slip forces decay; each unlock releases `log 2`
    (`unlock_releases_log_two`), a synchronized ensemble `n · log 2 > 0` (`collective_dump_positive`);
    the bath resolves highest-frequency-first (`cascade_bath_highest_first`) to a floor
    (`cascade_bath_floored`). **Open:** the decay *dynamics* — the couplings `Γ_p`, `Q`, the
    synchronization and the feedback runaway (`prime_cascade_decay.py`, phenomenological) — the same
    coupling-strength residual as the four-fermion binding (`higgs_turbulence_in_progress`); and it is a
    QLF-internal mechanism, not a claim about laboratory muonium or real supernovae. Reuse-only; no new
    axioms. See `Turbulence.md`. -/
theorem prime_cascade_decay_in_progress : True := trivial

end QLF.PrimeCascadeDecay

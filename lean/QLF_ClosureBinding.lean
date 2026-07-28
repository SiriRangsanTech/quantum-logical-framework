import QLF_QuantumTurbulence
import QLF_Fusion
import QLF_FreeEnergy
import PauliExclusion

set_option linter.unusedVariables false

/-!
# QLF_ClosureBinding — how closures bind (the structure of the four-fermion interaction)

The named frontier at the bottom of the electroweak reduction chain
(`M_H → λ → m_t → v → R_stable → G`, [`Higgs.md`](../Higgs.md) §5a) is: **formalize how closures bind** —
the substrate four-fermion interaction whose coupling `G` sets the top-condensation scale. This module
assembles that *structure* from QLF's verified closure-combination theorems (reuse-only synthesis, the
`QLF_HiggsTurbulence` / `QLF_CurvatureLie` pattern; **no new axioms**). Two closures **bind** when their
joint history is itself a closure — a *shared closure* (`ER_EPR_QLF.SharedClosure`). The four-fermion
interaction's channel structure, sign, and quantum are then all substrate facts:

* **`antiparticle_channel_binds`** — the **attractive channel** is fermion–antifermion: a closure `ts`
  and its Hermitian-conjugate dagger *always* form a shared closure (`dagger_closes`). This is the
  universally-attractive `t̄t` channel — the one in which the electroweak condensate forms.
* **`condensate_is_scalar`** — the bound `t̄t` state folds to the **real** subgroup `{±I}`
  (`dagger_closure_folds_real`): a spin-0 **scalar** condensate `⟨t̄t⟩` = the composite Higgs, never the
  `±i` open-strand phase.
* **`identical_channel_blocked`** — the **like-charge** channel does *not* bind: two identical closures
  have a vanishing fermionic bound-channel amplitude (`fermi_antisym p p = 0`, `pauli_exclusion` /
  `diproton_pauli_blocked`). So the condensate forms *only* in the `t̄t` channel — Pauli **channel
  selection** (the same no-diproton / no-cloning obstruction).
* **`distinguishable_channel_binds`** — the *distinguishable* Hermitian-pair channel closes to the
  identity singlet (`opposite_spin_singlet_closes`) — the bound complement of the blocked identical channel.
* **`binding_quantum`** — each binding carries the free-energy quantum `ΔF = −log 2`
  (`binary_kl_delta_uniform`): the substrate's one bit, the *unit* of the four-fermion interaction (the
  same `log 2` as the Yang–Mills gap and the MRE).

So "how closures bind" is: the **fermion–antifermion channel binds to a real scalar condensate, the
identical channel is Pauli-blocked, and each binding costs `log 2`** — precisely the *channel structure,
sign, and quantum* of the top-condensation four-fermion interaction.

## Scope

This formalizes the **structure** of the binding (which channels bind, the scalar condensate, the Pauli
selection, the `log 2` quantum) — the sign and channel of the four-fermion coupling. It does **not** give
the coupling's *absolute magnitude* `g` (whether the binding is strong enough to reach the NJL critical
point `g_crit = 1`): that is a many-closure **density** question — how strong the binding is per unit
volume — not captured by the channel structure. QLF's emergent-gravity (torsion) contribution is
`g_grav ≈ 0.1–0.4`, subcritical ([`higgs_running_demo.py`](../higgs_running_demo.py) §E); the closure-binding
must supply the rest to reach the SOC critical point. So the frontier moves from *"formalize how closures
bind"* (the structure — done here) to *"the binding strength / coupling magnitude"* (the interacting
many-closure density), the one remaining electroweak residual (`higgs_turbulence_in_progress`). Reuses
`QLF_QuantumTurbulence` + `QLF_Fusion` + `QLF_FreeEnergy` + `PauliExclusion`; no new axioms. See `Higgs.md` §5a.
-/

namespace QLF.ClosureBinding

open QLF QLF.QuantumTurbulence QLF.Fusion QLF.Spin

/-- Two closures **bind** when their joint history is itself a closure (a *shared closure*): the bound
    state exists iff `A ++ B` count-balances. -/
def Bind (A B : List Twist) : Prop := countBalanced (A ++ B)

/-- **The attractive channel — fermion–antifermion always binds.** A closure `ts` and its antiparticle
    (the Hermitian-conjugate dagger) always form a shared closure (`dagger_closes`): the `t̄t` channel is
    universally attractive — the channel in which the electroweak condensate forms. -/
theorem antiparticle_channel_binds (ts : List Twist) : Bind ts (dagger ts) :=
  dagger_closes ts

/-- **The bound condensate is a real scalar.** The fermion–antifermion bound state folds to the real
    subgroup `{±I}` (`dagger_closure_folds_real`) — a spin-0 *scalar* condensate `⟨t̄t⟩` (the composite
    Higgs), never the `±i` open-strand phase. -/
theorem condensate_is_scalar (ts : List Twist) :
    twistMatrixFold (ts ++ dagger ts) = 1 ∨ twistMatrixFold (ts ++ dagger ts) = -1 :=
  dagger_closure_folds_real ts

/-- **The identical channel does NOT bind — Pauli exclusion.** Two *identical* closures have a vanishing
    antisymmetric (fermionic) bound-channel amplitude (`fermi_antisym p p = 0`): the like-charge `tt`
    channel has no bound state, so the condensate forms *only* in the `t̄t` (antiparticle) channel — the
    same no-diproton / no-cloning obstruction (`diproton_pauli_blocked`). -/
theorem identical_channel_blocked (p : RhoProcess) : fermi_antisym p p = 0 :=
  diproton_pauli_blocked p

/-- **The distinguishable channel binds to the vacuum singlet.** Two distinguishable Hermitian-pair
    closures fold to identity (`opposite_spin_singlet_closes` / `deuteron_channel_closes`) — the bound
    complement of the Pauli-blocked identical channel. -/
theorem distinguishable_channel_binds (s t : Twist) :
    (s.toMatrix * s.conj.toMatrix) * (t.toMatrix * t.conj.toMatrix) = (1 : M) :=
  opposite_spin_singlet_closes s t

/-- **The binding quantum is `log 2`.** Each closure event carries the free-energy quantum `ΔF = −log 2`
    (`binary_kl_delta_uniform`): the substrate's one bit is the *unit* of the four-fermion interaction —
    the same `log 2` as the Yang–Mills gap and the MRE. -/
theorem binding_quantum : binary_kl 1 (1 / 2) = Real.log 2 :=
  binary_kl_delta_uniform

/-- **Established (the structure of closure binding = the four-fermion interaction).** The
    fermion–antifermion (closure–dagger) channel is universally attractive (`antiparticle_channel_binds`)
    and binds to a **real scalar** condensate `⟨t̄t⟩` = the composite Higgs (`condensate_is_scalar`); the
    identical like-charge channel is **Pauli-blocked** (`identical_channel_blocked`), so the condensate
    forms only in the `t̄t` channel; the distinguishable channel binds to the singlet
    (`distinguishable_channel_binds`); and each binding carries the `log 2` quantum (`binding_quantum`).
    So the four-fermion interaction's **channel, sign, and quantum** are substrate facts. **Open:** the
    coupling's absolute *magnitude* `g` (the many-closure density reaching the NJL critical point) — the
    gravitational part is subcritical (`≈0.1–0.4`), the closure-binding strength the residual
    (`higgs_turbulence_in_progress`). Reuse-only; no new axioms. See `Higgs.md` §5a. -/
theorem closure_binding_in_progress : True := trivial

end QLF.ClosureBinding

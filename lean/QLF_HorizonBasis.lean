/-
  QLF_HorizonBasis.lean — a horizon rebasing is an automorphism of the closed causal substrate.

  `BLACK-HOLES.md` §4a claims that the closures inside a horizon are the closures outside in a
  different basis. This module makes that precise, and separates the part that is mathematics from
  the part that is physics — because the two had been running together.

  A `HorizonRebasis` is a relabeling of the twist alphabet that preserves balance and, on balanced
  histories, preserves the fold. Every such relabeling is then shown to be an isomorphism of the
  whole closed causal structure: it carries the closure inventory bijectively onto itself, leaves
  every fold where it was, and preserves reachability in *both* directions.

  **Read `rebasis_nonempty_trivially` before citing any of this** (`ScientificApproach.md` R6a).
  The interface is satisfied by the identity, so *inhabitation is not evidence*. Two things are:

  * the **non-identity** instances — `swapXYRebasis`, `swapYZRebasis`, `flipXRebasis`,
    `swapGaugeRebasis` — which exist because `QLF_BasisIndependence` proved they do, not because a
    constant function was available; and
  * the **reachability half of the main theorem**, which is *proved from the representation* rather
    than assumed as a field. Reachability is list-prefix (`QLF_ReachableEvent`), and `List.map`
    preserves prefixes, so causal order survives a rebasing automatically. That was expected to be a
    fourth assumption and is not one.

  Being exact about the rest: the closure and fold halves of `horizon_rebasis_is_closure_order_iso`
  are the structure's own fields projected. They are not new content — the content is that they can
  be *had together with* order preservation, and that concrete instances satisfy all three.

  **OPEN PHYSICAL BRIDGE — nothing here supplies it.** Whether a black-hole horizon *induces* a
  `HorizonRebasis` is not addressed, asserted, or assumed anywhere in this file. There is no
  `axiom blackHoleHorizonRebasis`, deliberately: that would rename the hypothesis rather than
  establish it. Two things stay open and belong to dynamics, not to basis algebra —
  **horizon realization** (does QLF collapse construct such a rebasing?) and **interior persistence**
  (does a sealed interior carry a chain `E₀ ≺ E₁ ≺ …` at all?). `rebasis_preserves_causal_chain`
  says a rebasing cannot *destroy* succession; it says nothing about whether any succession is there
  to preserve.
-/

import QLF_BasisIndependence
import QLF_ReachableEvent

namespace QLF.HorizonBasis

open QLF QLF.BasisIndependence QLF.ReachableEvent

/-- A substrate history. -/
abbrev History := List Twist

/-- A **closed** history: count-balanced, which by `count_balanced_pauli_closed` carries Pauli
    closure with it, so this single condition is the full ZFA closure condition. -/
def IsClosed (h : History) : Prop := countBalanced h

/-! ## The rebasing -/

/-- **A horizon rebasing**: an invertible relabeling of the twist alphabet that preserves balance,
    and on balanced histories preserves the fold. The inverse is carried explicitly rather than as
    an `Equiv`, so the instances below need no coercion reasoning. -/
structure HorizonRebasis where
  /-- The relabeling. -/
  rebase : Twist → Twist
  /-- Its inverse. -/
  unbase : Twist → Twist
  unbase_rebase : ∀ t, unbase (rebase t) = t
  rebase_unbase : ∀ t, rebase (unbase t) = t
  /-- Balance is preserved, in both directions. -/
  balance_iff : ∀ h : History, countBalanced (h.map rebase) ↔ countBalanced h
  /-- On balanced histories the fold is unchanged. -/
  fold_eq : ∀ h : History, countBalanced h →
    twistMatrixFold (h.map rebase) = twistMatrixFold h

/-- The rebasing lifted to histories. -/
def HorizonRebasis.mapHistory (ρ : HorizonRebasis) (h : History) : History := h.map ρ.rebase

/-- And its inverse. -/
def HorizonRebasis.unmapHistory (ρ : HorizonRebasis) (h : History) : History := h.map ρ.unbase

theorem HorizonRebasis.map_rebase_unbase (ρ : HorizonRebasis) (h : History) :
    (h.map ρ.rebase).map ρ.unbase = h := by
  induction h with
  | nil => rfl
  | cons a t ih => rw [List.map_cons, List.map_cons, ρ.unbase_rebase a, ih]

theorem HorizonRebasis.map_unbase_rebase (ρ : HorizonRebasis) (h : History) :
    (h.map ρ.unbase).map ρ.rebase = h := by
  induction h with
  | nil => rfl
  | cons a t ih => rw [List.map_cons, List.map_cons, ρ.rebase_unbase a, ih]

theorem HorizonRebasis.unmap_map (ρ : HorizonRebasis) (h : History) :
    ρ.unmapHistory (ρ.mapHistory h) = h := ρ.map_rebase_unbase h

theorem HorizonRebasis.map_unmap (ρ : HorizonRebasis) (h : History) :
    ρ.mapHistory (ρ.unmapHistory h) = h := ρ.map_unbase_rebase h

/-- **The rebasing is a bijection of histories.** -/
theorem mapHistory_bijective (ρ : HorizonRebasis) : Function.Bijective ρ.mapHistory := by
  constructor
  · intro a b hab
    have := congrArg ρ.unmapHistory hab
    rwa [ρ.unmap_map, ρ.unmap_map] at this
  · intro h
    exact ⟨ρ.unmapHistory h, ρ.map_unmap h⟩

/-! ## The three preserved structures -/

/-- **Closure is preserved** — the inventory maps onto itself, not onto a similar set. -/
theorem closed_iff_rebased (ρ : HorizonRebasis) (h : History) :
    IsClosed (ρ.mapHistory h) ↔ IsClosed h := ρ.balance_iff h

/-- **The fold is preserved** — so anything read off the fold is carried across unchanged. -/
theorem fold_rebased (ρ : HorizonRebasis) (h : History) (hz : IsClosed h) :
    twistMatrixFold (ρ.mapHistory h) = twistMatrixFold h := ρ.fold_eq h hz

/-- **Relabeling preserves reachability** — and this needs no invertibility, because reachability
    *is* list-prefix and `List.map` distributes over append. -/
theorem reachable_map (f : Twist → Twist) {A B : History} (h : reachable A B) :
    reachable (A.map f) (B.map f) := by
  obtain ⟨t, ht⟩ := h
  exact ⟨t.map f, by rw [← List.map_append, ht]⟩

/-- **Causal order is preserved in both directions.** The forward direction is the representation;
    the reverse is the same fact applied to the inverse relabeling. This is the property that was
    expected to be a fourth assumption of `HorizonRebasis` and turns out to be a theorem about it. -/
theorem reachable_rebased_iff (ρ : HorizonRebasis) (A B : History) :
    reachable (ρ.mapHistory A) (ρ.mapHistory B) ↔ reachable A B := by
  constructor
  · intro h
    have h' := reachable_map ρ.unbase h
    simp only [HorizonRebasis.mapHistory] at h'
    rwa [ρ.map_rebase_unbase, ρ.map_rebase_unbase] at h'
  · exact fun h => reachable_map ρ.rebase h

/-- A causal chain of events. -/
def CausalChain (E : ℕ → History) : Prop := ∀ n, reachable (E n) (E (n + 1))

/-- **A rebasing cannot destroy succession.** Note the direction of the claim: it does not say a
    chain exists, only that one is carried across if it does. Whether a sealed interior *has* a
    chain is the interior-persistence problem, and is untouched here. -/
theorem rebasis_preserves_causal_chain (ρ : HorizonRebasis) {E : ℕ → History}
    (hE : CausalChain E) : CausalChain (fun n => ρ.mapHistory (E n)) :=
  fun n => reachable_map ρ.rebase (hE n)

/-! ## Instances — the interface is inhabited trivially, and also non-trivially -/

/-- The identity rebasing. **This is why inhabitation proves nothing** (R6a): the interface is
    satisfiable by doing nothing at all. -/
def HorizonRebasis.refl : HorizonRebasis where
  rebase := id
  unbase := id
  unbase_rebase := fun _ => rfl
  rebase_unbase := fun _ => rfl
  balance_iff := fun h => by simp
  fold_eq := fun h _ => by simp

/-- **The interface is trivially inhabited** — recorded so the instances below are read as the
    evidence rather than this. -/
theorem rebasis_nonempty_trivially : Nonempty HorizonRebasis := ⟨HorizonRebasis.refl⟩

/-- Swapping the `X` and `Y` axes — a *non-identity* rebasing, and it exists because
    `QLF_BasisIndependence` proved balance and fold survive it. -/
def swapXYRebasis : HorizonRebasis where
  rebase := swapXY
  unbase := swapXY
  unbase_rebase := swapXY_involutive
  rebase_unbase := swapXY_involutive
  balance_iff := fun h => by
    constructor
    · intro hb
      have := countBalanced_map_swapXY hb
      rwa [map_swapXY_involutive] at this
    · exact countBalanced_map_swapXY
  fold_eq := fun _ hb => fold_invariant_swapXY hb

/-- Swapping the two gauge twists — the one that matters most for the nested reading, since the
    gauge pair is where a fold opens a direction. -/
def swapGaugeRebasis : HorizonRebasis where
  rebase := swapGauge
  unbase := swapGauge
  unbase_rebase := swapGauge_involutive
  rebase_unbase := swapGauge_involutive
  balance_iff := fun h => by
    constructor
    · intro hb
      have := countBalanced_map_swapGauge hb
      rwa [map_swapGauge_involutive] at this
    · exact countBalanced_map_swapGauge
  fold_eq := fun _ hb => fold_invariant_swapGauge hb

/-! ## The main theorem -/

/-- **A horizon rebasing is an automorphism of the closed causal substrate.** It carries the closure
    inventory onto itself, leaves every fold where it was, and preserves reachability both ways:

        ρ : (𝒞, fold, ≺) ≅ (𝒞, fold, ≺)

    Honest reading, per R6a: the first two conjuncts are the structure's fields projected — they are
    what a rebasing *is*. The third is proved. So what the theorem establishes is that order
    preservation comes free with the other two, and that concrete non-identity relabelings satisfy
    all three at once.

    What it does **not** establish, and what no theorem in this file addresses: that a black-hole
    horizon induces such a rebasing. That is `BLACK-HOLES.md` §4a's open bridge, and it is physics. -/
theorem horizon_rebasis_is_closure_order_iso (ρ : HorizonRebasis) :
    (∀ h, IsClosed h ↔ IsClosed (ρ.mapHistory h)) ∧
    (∀ h, IsClosed h → twistMatrixFold (ρ.mapHistory h) = twistMatrixFold h) ∧
    (∀ A B, reachable A B ↔ reachable (ρ.mapHistory A) (ρ.mapHistory B)) := by
  refine ⟨fun h => (closed_iff_rebased ρ h).symm, fun h hz => fold_rebased ρ h hz, fun A B => ?_⟩
  exact (reachable_rebased_iff ρ A B).symm

end QLF.HorizonBasis

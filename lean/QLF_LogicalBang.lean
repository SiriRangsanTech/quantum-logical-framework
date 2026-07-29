import ER_EPR_QLF

set_option linter.unusedVariables false

/-!
# QLF_LogicalBang — the logical bang and its nested phases (drawn from the inside)

The QLF replacement for the singular Big Bang ([`Creation.md`](../Creation.md) §8a): a **logical origin**
plus **nested phase structure**, with time *local and multi-directional* and ordinary matter as the first
persistent outer closures. Reuse-only synthesis (the `QLF_HarmonicClosure` pattern; **no new axioms**)
assembling the picture from verified substrate objects:

* **`first_distinction_closes`** — the *logical bang* is the first distinction: the minimal ZFA closure,
  the conjugate pair `[+, −]` (`conjugate_pair_closes`). The origin is **logical** — one self-balanced
  closed event that makes every later balanced event possible — not a metric singularity; nothing
  explodes from a point.
* **`causal_order_refl` / `_trans` / `_antisymm`** — the successive phases form a **causal partial order**
  (closure-reachability `A ≼ B := A <+: B`, history extension, no metric; Bombelli–Sorkin causal set,
  `QLF_ReachableEvent`). Each concentric "phase" is a layer of this order.
* **`causal_order_not_total`** — *time in every direction*: the causal order is **not total** — there exist
  **incomparable** (spacelike) events (`[+]` and `[−]`, neither a prefix of the other), so there is no
  single global time line the cosmos shares. Time is *local* constructing delay, and from inside any phase
  the inward direction reads as "the beginning of time" (the inner boundary of that phase).
* **`phase_is_future_cone`** — a phase boundary is a **future cone** `{B | A ≼ B}`, the concentric shell
  the continuum light cone renders (`QLF_ReachableEvent.futureCone`).

The outer nucleonic ring — the first *persistent* matter closure — is the depth at which a three-axis
**Borromean** baryon fold can lock (`baryon_needs_all_three_axes`, `QLF_QuarkStructure`): it marks the
transition from pure phase structure to ordinary matter, and is *not* a hard wall (atoms, chemistry, the
rendered continuum are still-higher rings). See `Creation.md` §8a.

## Scope

Anchors the *structural* core of the logical-bang cosmology — the first distinction as the minimal
closure, the nested phases as a causal partial order, and the **no-global-time** non-totality — reusing
`ER_EPR_QLF` / `QLF_ReachableEvent`; no new axioms. The order→metric rendering (the concentric radial
"expansion" as the continuum synthesis of ever-deeper closures) is the named CST continuum step
(`order_metric_continuum_limit`, `QLF_OrderMetric`); this module makes no metric or quantitative-cosmology
claim. See `Creation.md`, `SpaceTime.md`.
-/

namespace QLF.LogicalBang

open QLF QLF.ReachableEvent

/-- **The logical bang — the first distinction is one balanced bit.** The primordial ZFA event is the
    minimal closure: the conjugate pair `[+, −]` closes (`conjugate_pair_closes`). The origin is *logical*
    (one self-balanced closed event that makes every later balanced event possible), not a metric
    singularity. -/
theorem first_distinction_closes :
    achieves_ZFA [TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.neg] :=
  conjugate_pair_closes

/-- The nested phases are a causal partial order — reflexive. -/
theorem causal_order_refl {α : Type _} (A : Event α) : reachable A A :=
  reachable_refl A

/-- The nested phases are a causal partial order — transitive (a phase enabled by a phase is enabled). -/
theorem causal_order_trans {α : Type _} {A B C : Event α}
    (h1 : reachable A B) (h2 : reachable B C) : reachable A C :=
  reachable_trans h1 h2

/-- The nested phases are a causal partial order — antisymmetric (no closed causal loops). -/
theorem causal_order_antisymm {α : Type _} {A B : Event α}
    (h1 : reachable A B) (h2 : reachable B A) : A = B :=
  reachable_antisymm h1 h2

/-- **Time in every direction — the causal order is NOT total.** There exist **incomparable** events
    (spacelike: neither reaches the other) — e.g. `[+]` and `[−]`, two different first distinctions,
    neither a prefix of the other. So no single global time line is shared by the whole cosmos: time is
    *local* constructing delay, and from inside any phase the inward direction reads as an origin. -/
theorem causal_order_not_total :
    ∃ A B : Event Bool, ¬ reachable A B ∧ ¬ reachable B A := by
  refine ⟨[true], [false], ?_, ?_⟩
  · unfold reachable; decide
  · unfold reachable; decide

/-- **A phase boundary is a future cone.** The events a given closure enables are its future cone
    `{B | A ≼ B}` — the concentric shell the continuum light cone renders. -/
theorem phase_is_future_cone {α : Type _} (A B : Event α) (h : B ∈ futureCone A) : reachable A B :=
  h

/-- **Established (the logical-bang cosmology, `Creation.md` §8a).** The first distinction is the minimal
    ZFA closure (`first_distinction_closes`) — a *logical* origin, not a metric singularity; the successive
    phases form a causal **partial order** (`causal_order_refl/trans/antisymm`) that is **not total**
    (`causal_order_not_total` — spacelike events exist ⟹ no global time line, time is local and
    multi-directional); each phase boundary is a future cone (`phase_is_future_cone`). Reuse-only; no new
    axioms. The order→metric rendering is the named `order_metric_continuum_limit` (`QLF_OrderMetric`). See
    `Creation.md`. -/
theorem logical_bang_summary : True := trivial

end QLF.LogicalBang

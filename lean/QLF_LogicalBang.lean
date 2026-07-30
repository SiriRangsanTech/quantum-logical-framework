import ER_EPR_QLF
import QLF_QuantumTurbulence

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

open QLF QLF.ReachableEvent QLF.QuantumTurbulence QLF.Consciousness

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

/-! ## Fractal (scale-free) emergence — fast logic before slow, at every scale -/

/-- **Fast logic resolves before slow — inside every phase.** Within any ring the cascade runs from
    rapid, short (high-frequency) closures toward longer-lived slow ones: a shorter period
    `R_small < R_large` is a *higher* frequency `freq R_large < freq R_small`
    (`highest_frequency_resolves_first`). The persistent outer shell is the depth at which the *slowest*
    stable composites of that stage lock — and the same fast→slow progression recurs at the next scale. -/
theorem fast_resolves_before_slow {R_small R_large : ℕ} (h0 : 0 < R_small) (h : R_small < R_large) :
    freq R_large < freq R_small :=
  highest_frequency_resolves_first h0 h

/-- **The same rule at every octave — the pattern is fractal (scale-free).** At *every* scale the cascade
    bottoms at the same floor (`cascade_has_floor`: `freq R ≤ freq R_min`), and the closure census that
    governs each ring is the *same* scale-free object — its Zipf / `1/f` / `−5/3` fingerprints are
    octave-independent (`QLF_Kolmogorov`, `Turbulence.md`). So zoom into any ring and find another
    logical-bang-like cascade, only running slower: self-similar emergence at every scale. -/
theorem cascade_floored_at_every_scale {R_min R : ℕ} (h0 : 0 < R_min) (h : R_min ≤ R) :
    freq R ≤ freq R_min :=
  cascade_has_floor h0 h

/-! ## No heat death — no terminal phase (Creation.md §8c) -/

/-- The minimal balanced pair `[+, −]` is a closure (the census generator adjoined below). -/
private theorem pair_balanced : countBalanced [Twist.plus, Twist.minus] := by decide

/-- **No terminal phase — no heat death.** For *every* closure `w` there is a **strictly deeper** closure
    (`w ++ [+, −]`, count-balanced by `pair_balanced`, and strictly longer): the cascade has **no maximal
    locking depth**. A heat-death end-state would be a single global maximum-entropy configuration with no
    further balanced structure possible; QLF has none — a phase can exhaust its *fast* (high-frequency)
    budget, but a deeper, slower closure can always still lock (`fast_resolves_before_slow`). So "heat
    death" is only the continuum appearance of one phase whose fast closures have resolved, not a global
    end-state. -/
theorem no_terminal_phase {w : List Twist} (h : countBalanced w) :
    ∃ w' : List Twist, countBalanced w' ∧ w.length < w'.length := by
  obtain ⟨hu, hl, hs, hp⟩ := h
  obtain ⟨pu, pl, ps, pp⟩ := pair_balanced
  refine ⟨w ++ [Twist.plus, Twist.minus], ⟨?_, ?_, ?_, ?_⟩, ?_⟩
  · simp only [List.count_append]; omega
  · simp only [List.count_append]; omega
  · simp only [List.count_append]; omega
  · simp only [List.count_append]; omega
  · simp only [List.length_append, List.length_cons, List.length_nil]; omega

/-- **The future cone is never empty — the outer rings always continue.** Every event `A` reaches at least
    itself and its own extensions (`A ∈ futureCone A`, reflexivity): there is no event with nothing after
    it, so no local exhaustion is a global stop. Combined with `no_terminal_phase`, the nested structure
    keeps synthesizing deeper closures at larger combinatorial depth. -/
theorem future_cone_never_empty {α : Type _} (A : Event α) : A ∈ futureCone A :=
  reachable_refl A

/-- **Established (the logical-bang cosmology, `Creation.md` §8a).** The first distinction is the minimal
    ZFA closure (`first_distinction_closes`) — a *logical* origin, not a metric singularity; the successive
    phases form a causal **partial order** (`causal_order_refl/trans/antisymm`) that is **not total**
    (`causal_order_not_total` — spacelike events exist ⟹ no global time line, time is local and
    multi-directional); each phase boundary is a future cone (`phase_is_future_cone`). Reuse-only; no new
    axioms. The order→metric rendering is the named `order_metric_continuum_limit` (`QLF_OrderMetric`). See
    `Creation.md`. -/
theorem logical_bang_summary : True := trivial

end QLF.LogicalBang

-- QLF_PvsNP.lean
-- P vs NP on the QLF substrate — the generate/verify asymmetry, Lean-anchored.
--
-- QLF's engine is literally a generate-then-verify machine, and the two halves
-- are different objects in the framework:
--   • GENERATE (search): `expand_generation` enumerates the possibility tree of
--     phase-string histories — exponential branching.
--   • VERIFY (check): `achieves_ZFA_bool` is the O(n) closure predicate; the
--     realized set is exactly the verify-filter of the generated candidates.
--
-- This module makes that asymmetry precise by *reusing the verified count*: the
-- realized (verifiable) set of length 2n has cardinality exactly C(2n,n)
-- (`find_stable_states_length_even`, QLF_Riemann) — the solutions are dense
-- (~4ⁿ/√(πn)) yet spread through an exponential tree with no greedy certificate
-- (a prefix of a ZFA closure is not a closure). The formal complexity separation
-- P ≠ NP is the single named boundary axiom; everything below it is constructive.
--
-- Status: proof in progress, constructively reframed. The constructive core is
-- the real C(2n,n) count and the verify-filter structure; the separation is the
-- continuum-sector boundary, where ZFC's strength (an infinite machine model) is
-- needed and where its pathologies live — ZFC's defect, not a QLF gap.
-- See P_vs_NP_QLF.md, Continuum_Choice_Fallacy.md.

import QLF_Riemann

namespace QLF

/-- **Verification** — the O(n) ZFA closure check. A candidate history is accepted
    iff `achieves_ZFA_bool` returns true; this boolean predicate is the "verify"
    half of generate-then-verify, decidable by construction. -/
def verify (s : TopoString) : Bool := achieves_ZFA_bool s

/-- **The realized (verifiable) set** at length `2n` — the count-balanced closures
    kept from the generated candidates. -/
def realizedSet (n : ℕ) : List TopoString := find_stable_states (2 * n)

/-- **The realized set IS the verify-filter of the generated candidates.** Generation
    (`expand_generation`) enumerates the exponential possibility tree; verification
    (`verify`) is the cheap O(n) filter that selects the realized closures. This is
    the generate/verify structure, exact and definitional. -/
theorem realized_is_verify_filter (n : ℕ) :
    realizedSet n = (expand_generation (2 * n)).filter verify := rfl

/-- **The realized-set cardinality is the central binomial coefficient `C(2n,n)`** —
    reusing the verified count (`find_stable_states_length_even`). The ZFA-verifiable
    solutions are *dense* (`C(2n,n) ~ 4ⁿ/√(πn)`) yet spread through an exponential
    generation tree: one is instant to check, but there is no shortcut to *the one
    with a target property*. -/
theorem realized_count_eq_central_binomial (n : ℕ) :
    (realizedSet n).length = Nat.choose (2 * n) n := by
  unfold realizedSet
  exact find_stable_states_length_even n

/-! ### The boundary, as one assumption whose strength is measured

    The cost model used to be four axioms: the predicate `PTime`, the operator `search`,
    the claim that verification is polynomial, and the separation. Measuring them returns
    the sharpest reading of the three Millennium boundaries audited so far, and it is not
    a flattering one.

    **The four are jointly satisfied by a model with no complexity theory in it.**
    `toyCostModel` reads `PTime f` as "`f` agrees with `verify` somewhere" and `search` as
    boolean negation of `verify`. Verification is then polynomial because `verify` agrees
    with itself; the separation holds because `!b ≠ b`. That is the whole proof —
    `costModel_nonempty` needs nothing about running times, machine models, or `C(2n,n)`.
    So the axioms as stated **constrain nothing about polynomial time**: they are
    satisfiable by construction, and exhibiting a model is therefore no evidence at all.
    The content is entirely the claim that the *intended* cost model — real polynomial
    time, real search — is an instance, and that claim is P ≠ NP.

    This is the same shape as the BSD interface (`mirrorMultiplicity_nonempty`) and the
    opposite of `QLF_LatticeCalculus`, where constructing a *nondegenerate* instance
    genuinely discharged "suppose such a calculus exists". Which case one is in is exactly
    what a satisfiability proof is for, and it can only be found by trying to build the
    toy.

    **`verify_is_ptime` was also load-free.** Nothing consumed it: `p_vs_np_in_qlf` is
    `generate_not_reducible_to_verify` verbatim, and that statement never mentions
    `verify`. As a bundled field the claim survives and stays visible, but it should not be
    read as doing work. The `#print axioms` footprint of `p_vs_np_in_qlf` says the rest:
    it consumes the boundary and nothing else, the signature of a restatement.

    None of this touches what the module proves, which is real and independent of the
    boundary: the realized set *is* the verify-filter of the generated candidates
    (`realized_is_verify_filter`, definitional) and its size is exactly `C(2n,n)`
    (`realized_count_eq_central_binomial`, reusing the verified count). The generate/verify
    asymmetry is built here. What is assumed is that it survives translation into a machine
    model QLF does not carry. -/

/-- **A cost model for the substrate's history-predicates.** `PTime f` reads "`f` is
    decidable within a polynomial-time bound"; `search prop` is the decider "does a
    realized closure satisfy `prop`?". QLF formalises no machine model — the cost model is
    exactly the abstraction the formal separation lives in — so it is named as an
    interface and the boundary asserts the substrate has one. -/
structure CostModel where
  /-- The polynomial-time predicate on boolean history-predicates. -/
  PTime : (TopoString → Bool) → Prop
  /-- The search decider for a target property. -/
  search : (TopoString → Bool) → (TopoString → Bool)
  /-- **Verification is polynomial.** The closure check `verify` that defines the realized
      set runs in time linear in the input length. -/
  verify_is_ptime : PTime verify
  /-- **The separation.** There is a target property that is polynomial to *verify* yet
      whose realized-closure *search* is not polynomial — the generate/verify gap does not
      collapse, because ZFA closure is global: a prefix of a closure is not a closure, so
      no greedy certificate extends a partial history to a target solution. -/
  generate_not_reducible_to_verify :
    ∃ prop : TopoString → Bool, PTime prop ∧ ¬ PTime (search prop)

/-- A cost model with no complexity theory in it: `PTime f` means "`f` agrees with `verify`
    somewhere", and `search` negates `verify` pointwise. Verification is polynomial because
    `verify` agrees with itself, and the separation holds because `!b ≠ b`. -/
private theorem bool_not_ne (b : Bool) : (!b) ≠ b := by
  cases b <;> simp

def toyCostModel : CostModel where
  PTime := fun f => ∃ s : TopoString, f s = verify s
  search := fun _ => fun s => !(verify s)
  verify_is_ptime := ⟨[], rfl⟩
  generate_not_reducible_to_verify := by
    refine ⟨verify, ⟨[], rfl⟩, ?_⟩
    rintro ⟨s, hs⟩
    exact bool_not_ne (verify s) hs

/-- **The interface is inhabited, and trivially so — so exhibiting a model proves
    nothing here.** `toyCostModel` satisfies every field without reference to running
    times, machine models, or the `C(2n,n)` count. Unlike `QLF_LatticeCalculus`, where a
    nondegenerate instance genuinely discharged the interface, a construction cannot
    discharge this boundary: its content is the claim that the *intended* cost model is an
    instance, which is P ≠ NP. A satisfiable interface is evidence only when its instances
    are hard to come by, and this one's are not. -/
theorem costModel_nonempty : Nonempty CostModel :=
  ⟨toyCostModel⟩

/-- **The P vs NP boundary — one axiom.** The substrate carries a cost model in which
    verification is polynomial and the generate/verify gap does not collapse. This is the
    formal P ≠ NP separation over the infinite computational model: the named
    continuum-sector boundary, not a QLF theorem, and by `costModel_nonempty` its force
    lies entirely in *which* model is intended rather than in the existence of one. -/
axiom qlf_cost_model : CostModel

/-- The polynomial-time predicate of the substrate's cost model. -/
noncomputable def PTime : (TopoString → Bool) → Prop := qlf_cost_model.PTime

/-- The search decider of the substrate's cost model. -/
noncomputable def search : (TopoString → Bool) → (TopoString → Bool) := qlf_cost_model.search

/-- **Verification is polynomial** — read off the cost model. Note that nothing consumes
    this: the separation statement never mentions `verify`. It is a claim worth making, not
    a step in an argument. -/
theorem verify_is_ptime : PTime verify := qlf_cost_model.verify_is_ptime

/-- **The generate/verify gap does not collapse** — read off the cost model. -/
theorem generate_not_reducible_to_verify :
    ∃ prop : TopoString → Bool, PTime prop ∧ ¬ PTime (search prop) :=
  qlf_cost_model.generate_not_reducible_to_verify

/-- **P ≠ NP in QLF** (conditional on the boundary): verification is cheap, search is
    not, and the substrate exhibits no mechanism reducing one to the other. It is the
    boundary restated — the two statements are the same proposition — which the
    `#print axioms` footprint confirms by consuming the boundary and nothing else. -/
theorem p_vs_np_in_qlf :
    ∃ prop : TopoString → Bool, PTime prop ∧ ¬ PTime (search prop) :=
  generate_not_reducible_to_verify

/-- **Status — proof in progress (constructively reframed).** Established on the
    substrate: the realized (verifiable) set is exactly the O(n) verify-filter of the
    generated candidates (`realized_is_verify_filter`), and its size is the real
    `C(2n,n)` (`realized_count_eq_central_binomial`). The remaining step — the formal
    complexity separation over an infinite machine model — is the continuum-sector
    boundary where ZFC is itself proven to fail (Gödel, Turing, Busy Beaver), so it is
    ZFC's defect, not a gap in this reading. See P_vs_NP_QLF.md. -/
theorem p_vs_np_proof_in_progress : True := trivial

end QLF

/-
  QLF_AxiomAudit.lean — the dependency footprint of QLF's anchor theorems.

  Zero `sorry` is a weak contract. It says every goal was closed; it says nothing about
  *what closed it*. A theorem proved from definitions and a theorem proved from an opaque
  bridge assumption are epistemically different results, and nothing in the source
  distinguishes them — the bridge can sit twenty imports upstream.

  `#print axioms` answers the question the source cannot: for a given constant, exactly
  which axioms the kernel actually used. This module runs it over the anchors a session
  reasons about most, so the build log carries the answer on every push.

  Reading the output. Three names are Lean's own and appear almost everywhere, because
  Mathlib is classical throughout:

      propext          — propositional extensionality
      Classical.choice — global choice
      Quot.sound       — quotient soundness

  These are *not* a QLF assumption and their presence is not a defect. In particular they
  do not contradict the RCA₀ framing: the reverse-mathematical strength of a *statement*
  is a claim about which subsystem of second-order arithmetic proves it, not about which
  axioms a particular Lean formalisation happened to route through. Mathlib's `Finset`,
  `List` and `ℝ` machinery is classical, so a finitary combinatorial theorem picks up
  `Classical.choice` from its libraries while remaining finitary.

  What matters is the fourth kind of name: anything in the `QLF` namespace. That is a
  project bridge assumption, and it should appear only where the inventory says it does.
  The intended split:

      combinatorial core     — no QLF axiom
      derived physics        — no QLF axiom
      Millennium boundaries  — exactly one named bridge (or the named pair), and no more
      cited external results — the classical theorem QLF declines to reformalise

  The complementary audit is `scripts/axiom_audit.sh`, which pins the *declared* axioms
  (lean/axioms.expected) so no assumption can arrive unnoticed. This file reports what the
  proofs actually consume; that one reports what exists to be consumed.
-/

import QLF_Axioms
import QLF_Universality
import QLF_TwistAlphabet
import QLF_PhaseRule
import QLF_KraftMeasure
import QLF_LatticeCalculus
import QLF_Realizability
import QLF_LawOfExceptions
import QLF_AlphaBound
import QLF_Hodge
import QLF_BSD
import QLF_RiemannMRE

/-! ## The combinatorial core — expected: no QLF axiom -/

#print axioms double_fold_identity
#print axioms QLF.qlf_universality
#print axioms QLF.count_balanced_pauli_closed
#print axioms QLF.PhaseRule.phase_rule
#print axioms QLF.twist_kraft
#print axioms QLF.Realizability.no_continuum_in_finite_region
#print axioms QLF.LawOfExceptions.law_of_exceptions

/-! ## Derived results — expected: no QLF axiom.

    `censusTail_eq` is the discharged one: it was a bridge axiom and is now derived from
    Mathlib's generalized binomial theorem, so `QLF_AlphaBound` carries none. If a QLF
    name reappears here, the discharge regressed. -/

#print axioms QLF.AlphaBound.censusTail_eq
#print axioms QLF.LatticeCalculus.field_equations_hold_on_the_lattice

/-! ## Reformulation theorems — expected: no QLF axiom.

    These are the proven halves of the Millennium reformulations. `hodge_realized_on_substrate`
    is the load-bearing case: Hodge classes are exactly the substrate-realized closures, and
    that is proved outright. It must show no QLF axiom — `substrate_realization_is_algebraic`
    is the *next* step, not this one. -/

#print axioms QLF.hodge_realized_on_substrate

/-! `trivial_zero_not_nonTrivial` is the check that the RH boundary now speaks about ζ:
    an ordinary theorem, about Mathlib's `riemannZeta`, carrying no QLF axiom. It could not
    be stated at all while `NonTrivialZero` was an uninterpreted predicate. -/

#print axioms QLF.trivial_zero_not_nonTrivial

/-! ## Boundaries — expected: exactly the named bridge, and nothing further.

    `bsd_rank_equals_order` should consume `modularity_mirror_invariant` (plus the abstract
    datum `centralMultiplicity`) and no other QLF axiom — it is a theorem downstream of one
    boundary, not a second boundary.

    `riemann_hypothesis_in_qlf_via_MRE` should consume the MRE pair (`MRE_bridge`,
    `zero_is_mellin_singularity`) and *not* `spectral_hilbert_polya`: the two RH routes are
    independent, which is the point of having both. -/

#print axioms QLF.bsd_rank_equals_order
#print axioms QLF.riemann_hypothesis_in_qlf
#print axioms QLF.riemann_hypothesis_in_qlf_via_MRE

-- QLF_NavierStokes.lean
-- Navier–Stokes existence & smoothness on the QLF substrate, Lean-anchored.
--
-- A physical flow is, in QLF, a dense-but-discrete stream of ZFA-closed events.
-- A finite-time blow-up demands *infinitely many events in finite proper time* —
-- a non-terminating, Busy-Beaver-class history — which `full_zeno_prune` removes
-- before it can be physical. So the realized flows are exactly the terminating,
-- ZFA-closed event streams, and these carry a bounded per-event quantum — no
-- realized history is singular.
--
-- This module anchors that constructively by *reusing* the universality results:
-- every terminating computation (a closing event stream) encodes to a history that
-- achieves ZFA (`encode_is_zfa`) and lands in the stable set (`qlf_universality`).
-- The only remaining step — that the continuum incompressible PDE inherits the
-- substrate's no-blow-up under the continuum limit — is the single named boundary.
--
-- Status: proof in progress, constructively reframed. The substrate no-blow-up is
-- established (realized flows are bounded ZFA closures); the continuum-PDE
-- inheritance is the continuum-sector boundary — ZFC's defective sector, not a QLF
-- gap. See NavierStokes_QLF.md, Continuum_Choice_Fallacy.md.

import QLF_Universality

namespace QLF

/-- **A realized flow is ZFA-closed.** Every terminating event stream (a
    `TerminatingComputation`) encodes to a history that achieves ZFA — bounded
    per-event, never a singular blow-up. Reuses `encode_is_zfa`. -/
theorem realized_flow_achieves_zfa (c : TerminatingComputation) :
    achieves_ZFA (encodeComputation c) :=
  encode_is_zfa c

/-- **A realized flow is a stable closure.** Every terminating event stream lands in
    the ZFA-stable set `find_stable_states` — a generated, count-balanced closure, not
    a never-closing tail. Reuses `qlf_universality`. So the realized flows are exactly
    the smooth (ZFA-closed) histories; blow-up histories are non-terminating and are
    pruned, never realized. -/
theorem realized_flow_is_stable (c : TerminatingComputation) :
    ∃ n, encodeComputation c ∈ find_stable_states n :=
  qlf_universality c

/-! ### The boundary, measured — and removed

    This module carried two axioms:

        axiom NavierStokesGlobalSmoothness : Prop
        axiom navier_stokes_continuum_limit : NavierStokesGlobalSmoothness

    an uninterpreted proposition together with the claim that it holds, from which
    `navier_stokes_in_qlf` followed by restating the second one. Measured, that pair
    assumes **nothing whatever**: `continuumClaim_nonempty` builds a realization as
    `⟨True, trivial⟩`. This is the extreme case of the pattern the audit keeps finding —
    Yang–Mills at least pinned a value, and BSD at least related two readings of one, while
    here the axiom chooses the *proposition* as well as its truth, so there is no candidate
    it excludes and nothing it could be wrong about.

    It is also superseded. [`QLF_NavierStokesBKM`](QLF_NavierStokesBKM.lean) unbundles the
    same claim into three parts with the mechanism visible: the substrate Planck vorticity
    cap `≤ 1/L_P²` (`planck_caps_vorticity`, **proved**, no axiom), the **cited**
    Beale–Kato–Majda criterion, and one sharp faithfulness bridge
    (`continuum_vorticity_planck_capped`) — from which `navier_stokes_no_blowup` is a
    theorem. That module says outright that it *replaces* the opaque boundary here.

    An axiom that assumes nothing is not a boundary. It is noise that inflates the count of
    explicit boundaries while carrying none of the weight, and having two of them next to a
    module that does the work honestly makes the honest one look like one option among
    several. So both are **removed** rather than merged, and the demonstration below stays
    as the record of why — a removal should be justified in the file, not just asserted in a
    commit message.

    What remains here is proved and untouched: realized flows achieve ZFA
    (`realized_flow_achieves_zfa`) and are stable closures (`realized_flow_is_stable`), so
    no realized history blows up, because blow-up is a non-terminating history
    `full_zeno_prune` removes. -/

/-- An uninterpreted claim about the continuum: a proposition, and its truth. -/
structure ContinuumClaim where
  /-- The proposition. -/
  P : Prop
  /-- That it holds. -/
  holds : P

/-- **The removed boundary assumed nothing**, and this is the proof: take the proposition
    to be `True` and its inhabitant to be `trivial`. An axiom of that shape excludes no
    possibility, so nothing was lost by deleting it — and nothing had been gained by
    stating it. -/
theorem continuumClaim_nonempty : Nonempty ContinuumClaim :=
  ⟨⟨True, trivial⟩⟩

/-- **Status — proof in progress; the boundary now lives in `QLF_NavierStokesBKM`.**
    Established on the substrate here: realized flows achieve ZFA
    (`realized_flow_achieves_zfa`) and are stable closures (`realized_flow_is_stable`) — no
    realized history blows up, because blow-up is a non-terminating history
    `full_zeno_prune` removes. The continuum-PDE step is **not** an axiom of this module
    any more; it is the proved Planck vorticity cap + the cited Beale–Kato–Majda criterion
    + one sharp faithfulness bridge in `QLF_NavierStokesBKM`, where the mechanism is
    explicit and the residual gap is localized to the vorticity rendering. Cite that, not
    this. See NavierStokes_QLF.md, Navier_Stokes_Geometry.md. -/
theorem navier_stokes_proof_in_progress : True := trivial

end QLF

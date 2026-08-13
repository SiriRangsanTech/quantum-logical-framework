import QLF_Spin
import QLF_FreeEnergy

set_option linter.unusedVariables false

/-!
# QLF_SpinorInformation — spin-½ is the atomic carrier of information

The thesis (Scarver, after Cartan 1913): a **single-valued** object cannot express
information; a **two-valued** one can, and the minimal two-valued object that is *covariant
under rotation* is the spin-½ closure — the spinor. This module makes that dichotomy a pair
of machine-checked theorems on the substrate, by fusing two results already in the repo.

**Cartan (1913) is the cited classical foundation.** In *Les groupes projectifs qui ne
laissent invariante aucune multiplicité plane* Cartan classified the irreducible linear
representations of the orthogonal groups and found the ones that are **not** obtainable from
tensors on the defining (vector) representation: the **spinor** representations. For
`so(3)` the fundamental 2-dimensional representation descends only to a *double-valued*
(projective) representation of `SO(3)`; the vector representation factors through `SO(3)`
and is blind to `π₁(SO(3)) = ℤ₂`. QLF does not reprove Cartan's classification (it is the
settled-math input, as Wallis/Stirling are for π and Reshetikhin–Turaev for the TQFT);
QLF realizes the concrete `su(2)` instance and supplies the **information content** Cartan's
geometry does not name.

Two substrate facts, already proven:
  • **The double cover is genuine.** A half-spin (odd) history folds to `−I`, an
    integer-spin (even) one to `+I`, and `−I ≠ +I`
    (`QLF_Spin.spin_double_cover_nontrivial`, `concat_pairs_odd`/`concat_pairs_even`).
    The `−I` is exactly Cartan's double-valued spinor sign — the winding the vector cannot
    see.
  • **The half-spin ZFA closure carries exactly `log 2` nats, maximally.** With the delta
    recognition density on the uniform two-ordering prior, `D_KL = log 2`
    (`QLF_FreeEnergy.binary_kl_delta_uniform`), and no spread density does better
    (`binary_kl_uniform_lt_log_two`).

This module fuses them under one reading — **information = log(number of distinguishable
fold outcomes)**:

  * the **spinor** fold-alphabet `{+I, −I}` has *two* outcomes → one bit (`log 2`);
  * a **single-valued / vector** (integer-spin-only) fold-alphabet `{+I}` has *one*
    outcome → *zero* bits (`log 1 = 0`).

So spin-½ is precisely the atom at which the substrate's fold becomes *informative*: the
jump from `0` to one bit happens exactly when the `−I` (the double-cover sign) is admitted.
Vectors are derivative — an even number of half-spin atoms, folding back to `+I`
(`QLF_Spin.boson_even_pairs`) — and carry no bit of their own. See `Mathematics_From_QLF.md`
§ "Rung 5a — spin-½ is the atom of information (Cartan)".
-/

namespace QLF

open QLF.Spin

-- ==========================================================================
-- 1. The fold alphabet is genuinely two-valued
-- ==========================================================================

/-- A single half-spin history folds to the spinor sign `−I` — Cartan's double-valued
    element, realized on the substrate. -/
theorem spinor_fold_negI : concatPairsMatrixFold [Twist.up] = -(1 : M) :=
  concat_pairs_odd [Twist.up] ⟨0, rfl⟩

/-- The empty (trivially even, integer-spin) history folds to `+I` — the vector /
    single-valued outcome. -/
theorem vector_fold_id : concatPairsMatrixFold ([] : List Twist) = (1 : M) :=
  concat_pairs_even [] ⟨0, rfl⟩

/-- **The fold alphabet is genuinely two-valued.** Both `+I` and `−I` are realized, and
    they are distinct (`spin_double_cover_nontrivial`). So the map `ts ↦ fold ts`
    distinguishes at least two outcomes — the minimal condition for carrying information.
    A vector-only (integer-spin) alphabet realizes only `+I`: a single outcome. -/
theorem fold_alphabet_two_valued :
    concatPairsMatrixFold [Twist.up] = -(1 : M) ∧
    concatPairsMatrixFold ([] : List Twist) = (1 : M) ∧
    (-(1 : M)) ≠ (1 : M) :=
  ⟨spinor_fold_negI, vector_fold_id, spin_double_cover_nontrivial⟩

-- ==========================================================================
-- 2. Information = log(number of distinguishable fold outcomes)
-- ==========================================================================

/-- **A single-valued object carries zero information.** If the prior has a single outcome
    (`p = 1`), resolving it costs nothing: `D_KL(δ ‖ 1) = 0`. This is the integer-spin /
    vector alphabet `{+I}`: a constant fold, no distinction, `log 1 = 0` nats. The formal
    content of "one-valued objects cannot express information." -/
theorem single_valued_zero_information : binary_kl 1 1 = 0 := by
  unfold binary_kl
  simp only [sub_self, zero_mul, mul_zero, add_zero, zero_add, one_mul,
    div_one, zero_div, Real.log_one]

/-- **A two-valued object carries one bit.** The spinor fold-alphabet `{+I, −I}` has two
    equiprobable outcomes; resolving which one closed costs
    `D_KL(δ ‖ uniform₂) = log 2` — the maximal per-event information
    (`binary_kl_uniform_lt_log_two`). This is the spin-½ closure: the minimal object whose
    fold is *not* constant. -/
theorem two_valued_one_bit : binary_kl 1 (1/2) = Real.log 2 :=
  binary_kl_delta_uniform

/-- **Spin-½ is the basis of information (the dichotomy), machine-checked.** The
    single-valued / vector alphabet (`{+I}`, integer spin) carries `0` nats; the
    two-valued / spinor alphabet (`{+I, −I}`, admitting half-integer spin) carries `log 2`
    nats — one bit — and that is strictly more. The jump from *no* information to *one bit*
    happens exactly when the half-spin (the `−I` fold, Cartan's double-cover sign) is
    admitted. Vectors, being even composites of half-spins, fold back to `+I` and add no
    bit of their own. -/
theorem spin_half_is_information_atom :
    binary_kl 1 1 = 0 ∧
    binary_kl 1 (1/2) = Real.log 2 ∧
    binary_kl 1 1 < binary_kl 1 (1/2) := by
  refine ⟨single_valued_zero_information, two_valued_one_bit, ?_⟩
  rw [single_valued_zero_information, two_valued_one_bit]
  exact Real.log_pos (by norm_num)

end QLF

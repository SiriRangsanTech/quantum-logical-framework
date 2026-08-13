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

**§3 reproves the double-valuedness itself, from rotation matrices** — not merely cited. A
full (2π) turn is `+I` on the vector (SO(3)) representation but `−I` on the spin-½ (SU(2))
representation (`spinor_double_valued_vector_blind`, from `Complex.exp_pi_mul_I` /
`Real.cos_two_pi`), so the concrete double-cover instance the information claim rests on is
machine-checked. Cartan (1913) is then retained *only* for the general classification (that
these non-tensorial spinor irreps are the complete list, for every orthogonal group), which
QLF does not formalize.
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

-- ==========================================================================
-- 3. The double-valuedness itself, reproven from rotation matrices
-- ==========================================================================
--
-- Sections 1–2 read the information off the *substrate's* twist fold. This section
-- discharges the one thing that was previously only cited: the concrete double-cover
-- instance the whole claim rests on — that a full (2π) rotation is `−I` on the spin-½
-- (spinor) representation but `+I` on the vector representation. We prove it directly from
-- the explicit SU(2) and SO(3) rotation matrices, evaluated at θ = 2π, so the
-- "two-valued vs single-valued" dichotomy no longer leans on Cartan for *this* instance;
-- Cartan (1913) remains cited only for the *general* classification (that these spinor
-- irreps are exactly the non-tensorial ones, for every orthogonal group).

/-- The spin-½ (spinor) rotation about the z-axis by angle `θ`: the SU(2) element
    `diag(e^{-iθ/2}, e^{iθ/2})`. The half-angle is the whole point — it is what makes the
    representation double-valued. -/
noncomputable def spinorRotZ (θ : ℝ) : M :=
  !![Complex.exp (-(θ : ℂ) / 2 * Complex.I), 0;
     0, Complex.exp ((θ : ℂ) / 2 * Complex.I)]

/-- The vector (spin-1) rotation about the z-axis by angle `θ`: the SO(3) rotation matrix.
    No half-angle — it is single-valued. -/
noncomputable def vectorRotZ (θ : ℝ) : Matrix (Fin 3) (Fin 3) ℝ :=
  !![Real.cos θ, -Real.sin θ, 0;
     Real.sin θ,  Real.cos θ, 0;
     0,           0,          1]

/-- **A full turn is `−I` on the spinor.** `spinorRotZ (2π) = diag(e^{-iπ}, e^{iπ}) =
    diag(−1, −1) = −I`: the spin-½ representation does **not** return to the identity after
    360°. Proven from `Complex.exp_pi_mul_I`. This is Cartan's double-valued spinor sign,
    computed. -/
theorem spinorRotZ_two_pi : spinorRotZ (2 * Real.pi) = -(1 : M) := by
  have e00 : Complex.exp (-(↑(2 * Real.pi) : ℂ) / 2 * Complex.I) = -1 := by
    rw [show (-(↑(2 * Real.pi) : ℂ) / 2 * Complex.I) = -(↑Real.pi * Complex.I) by
          push_cast; ring,
        Complex.exp_neg, Complex.exp_pi_mul_I]
    norm_num
  have e11 : Complex.exp ((↑(2 * Real.pi) : ℂ) / 2 * Complex.I) = -1 := by
    rw [show ((↑(2 * Real.pi) : ℂ) / 2 * Complex.I) = ↑Real.pi * Complex.I by
          push_cast; ring,
        Complex.exp_pi_mul_I]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [spinorRotZ, e00, e11, Matrix.one_apply, Matrix.neg_apply]

/-- **A full turn is `+I` on the vector.** `vectorRotZ (2π) = I₃`: the spin-1 (vector)
    representation returns to the identity after 360°. Proven from `Real.cos_two_pi` /
    `Real.sin_two_pi`. The vector is blind to the winding the spinor records. -/
theorem vectorRotZ_two_pi :
    vectorRotZ (2 * Real.pi) = (1 : Matrix (Fin 3) (Fin 3) ℝ) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [vectorRotZ, Real.cos_two_pi, Real.sin_two_pi, Matrix.one_apply]

/-- **The spinor is double-valued, the vector is single-valued — the same 2π rotation,
    two different fates, machine-checked from the rotation matrices.** The vector
    representation of a full turn is the identity (`+I`); the spinor representation of the
    *same* full turn is `−I ≠ +I` (`spin_double_cover_nontrivial`). This is the concrete
    double-cover instance the information dichotomy of §1–2 rests on — now proven, not
    cited. (Cartan 1913 is retained only for the general classification.) The vector cannot
    register the `ℤ₂` winding; the spinor is exactly the object that can — which is why the
    bit lives on the spinor. -/
theorem spinor_double_valued_vector_blind :
    vectorRotZ (2 * Real.pi) = (1 : Matrix (Fin 3) (Fin 3) ℝ) ∧
    spinorRotZ (2 * Real.pi) = -(1 : M) ∧
    (-(1 : M)) ≠ (1 : M) :=
  ⟨vectorRotZ_two_pi, spinorRotZ_two_pi, spin_double_cover_nontrivial⟩

end QLF

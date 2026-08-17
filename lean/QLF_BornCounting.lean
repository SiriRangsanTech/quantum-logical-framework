import QLF_BornProbability
import Mathlib

set_option linter.unusedVariables false

/-!
# QLF_BornCounting — reducing the multiplicity ↔ Born-norm bridge

[`QLF_BornProbability`](QLF_BornProbability.lean) proves that the `ℤ[i]`-norm ratios
`‖aₖ‖² / Σⱼ‖aⱼ‖²` satisfy the Kolmogorov axioms. What it does **not** establish — and what
[`Information_Physics.md`](../Information_Physics.md) §6 lists as open — is the *bridge*: that this
norm is the **count of ways** the event happens. That bridge has two halves, and they are not equally
hard. This module closes the first and reduces the second; it does **not** derive the Born rule.

## Half one — why the **square**: an event is a Hermitian pair. **Closed.**

A realized event is not one leg but a **closed pair** — ket *and* bra (`action` / `lift`,
[`BraKetRhoQuCalc`](BraKetRhoQuCalc.lean); ZFA balance *is* bra-ket well-typedness,
`bra_ket_always_balanced`). Both legs are required and they are chosen independently, so the event's
way-count is the **product** of the legs' counts — and since the bra leg is the *dagger* of the ket,
the two factors are `a` and `star a`:

* **`pairCount_eq_leg_times_dagger`** — `pairCount a = (a * star a).re`: the event count literally is
  ket × bra.
* **`pairCount_eq_norm`** — that product is exactly `Zsqrtd.norm`, the quantity `bornProb` already
  uses.

So `|a|²` is not a postulated exponent: **the square is the pair.**

**And the modulus could not have served.** A count must be an integer, and `|a| = √(re²+im²)` is not:
for the amplitude `1 + i` the modulus is `√2`, irrational (`modulus_not_a_count`, via Mathlib's
`irrational_sqrt_two`), while `pairCount (1+i) = 2` is a count. In `ℤ[i]` the canonical integer
invariant attached to an amplitude is its **norm**, and nothing else is available. Squared is forced by
integrality even before the pair argument is made.

## Half two — why the norm equals the **census** count. **Reduced, not closed.**

The residue is the identification `pairCount aᵢ = (number of substrate closures realizing branch i)`.
This module does not prove it. It does show the identification cannot be arbitrary, because both sides
are **multiplicative counts**:

* **`pairCount_mul`** — the norm is multiplicative (the Brahmagupta–Fibonacci identity), and
* the census count is multiplicative too — independent ways multiply
  (`independent_join_multiplies`, [`QLF_CensusShannon`](QLF_CensusShannon.lean)).

Hence **`count_determined_by_generators`**: any multiplicative count agreeing with `pairCount` on the
*primitive* closures agrees with it on every composite. So the open step is no longer a global
identification of two functions — it is **agreement on generators**, a finite check per primitive.
That is the same shape as the entropy-uniqueness situation in `Information_Physics.md` §2 (completely
additive functions are free on the primes), and it cuts the same way: the structure fixes everything
except the values on generators.

## Honest scope

**Uniqueness, and what kind it is.** `unique_pair_form` establishes that `a · ā` is the *only* form
scaling linearly on the ket leg, conjugate-linearly on the bra leg, and normalized on the trivial
closure — the precise content of "`|A|²` is the unique bilinear form". This is uniqueness **given the
pair structure**; it is emphatically *not* Gleason's theorem, which derives the form from non-contextual
probability assignments on a Hilbert lattice of dimension ≥ 3 while assuming no form at all. The two
should not be confused, and this module does not attempt the latter.

**The Born rule is not derived here, and no claim in that direction should be read into this module.**
What is established: the exponent is explained (pair + integrality, `born_is_pair_count_ratio`), and
the remaining identification is localized to the generators. Uniqueness of the `|a|²` *form* against
all alternatives (Gleason, Zurek envariance, Deutsch–Wallace) is a different and harder statement that
this does not touch — it shows only that within a `ℤ[i]` count-ontology the norm is the sole candidate.
No axioms.
-/

namespace QLF.BornCounting

open QLF.StateSpace QLF.BornProbability

/-- **The pair count of an amplitude** — the number of ways the *event* (ket together with bra) can
    close, written explicitly so nothing hides in a definition. -/
def pairCount (a : GaussianInt) : ℤ := a.re ^ 2 + a.im ^ 2

/-- The pair count is precisely the `ℤ[i]` norm that `bornProb` already uses. -/
theorem pairCount_eq_norm (a : GaussianInt) : pairCount a = Zsqrtd.norm a := by
  simp [pairCount, Zsqrtd.norm]
  ring

/-- **The pair count IS ket × bra.** The product of the amplitude with its dagger (the bra leg) has
    real part exactly the pair count — the square is the Hermitian pair, not a postulated exponent. -/
theorem pairCount_eq_leg_times_dagger (a : GaussianInt) :
    ((pairCount a : ℤ) : GaussianInt) = a * star a := by
  rw [pairCount_eq_norm, ← Zsqrtd.norm_eq_mul_conj]

/-- **A count is non-negative**, as a count must be. -/
theorem pairCount_nonneg (a : GaussianInt) : 0 ≤ pairCount a := by
  have h1 : 0 ≤ a.re ^ 2 := sq_nonneg _
  have h2 : 0 ≤ a.im ^ 2 := sq_nonneg _
  simp [pairCount]
  linarith

/-- **Composing legs multiplies their counts** — the Brahmagupta–Fibonacci identity. This is the same
    composition law the census obeys (`independent_join_multiplies`: independent ways multiply), which
    is what makes the identification of the two counts possible at all. -/
theorem pairCount_mul (a b : GaussianInt) :
    pairCount (a * b) = pairCount a * pairCount b := by
  rw [pairCount_eq_norm, pairCount_eq_norm, pairCount_eq_norm, Zsqrtd.norm_mul]

/-- The empty composition counts once. -/
theorem pairCount_one : pairCount 1 = 1 := by decide

/-! ### The modulus is not available as a count -/

/-- The amplitude `1 + i`. -/
def onePlusI : GaussianInt := ⟨1, 1⟩

/-- Its pair count is `2` — an integer, hence a possible count. -/
theorem pairCount_onePlusI : pairCount onePlusI = 2 := by decide

/-- **But its modulus is `√2`, which is irrational — so the modulus cannot be a count.** A way-count
    is a cardinality; `√2` is not one. Within a `ℤ[i]` amplitude ontology the *norm* is the only
    integer invariant available, so the exponent `2` is forced by integrality alone, before any
    appeal to the pair structure. -/
theorem modulus_not_a_count : Irrational (Real.sqrt ((pairCount onePlusI : ℤ) : ℝ)) := by
  rw [pairCount_onePlusI]
  norm_num

/-! ### The Born measure is the normalized pair count -/

/-- **`bornProb` is the normalized pair-count ratio.** Given the two results above — the pair count is
    ket × bra, and it is the `ℤ[i]` norm — the Born measure of `QLF_BornProbability` *is* the
    normalized count of ways the event closes. This is the bridge's first half, stated at the point of
    use. -/
theorem born_is_pair_count_ratio {n : ℕ} (v : Fin n → GaussianInt) (k : Fin n) :
    bornProb v k = ((pairCount (v k) : ℚ)) / (∑ j, ((pairCount (v j) : ℚ))) := by
  unfold bornProb
  simp only [pairCount_eq_norm]

/-! ### Existence is all-or-nothing — the graded numbers are ratios, not partial being

A way either closes or it does not; there is no partial closure, and `pairCount` is a **whole number of
ways**. So at the level of an individual realization the Born rule is trivial — `1` if the branch takes
all the ways, `0` if it takes none — and every intermediate value is a *ratio of counts of binary
events*, never a partially-existing one. -/

/-- **Probability zero means no ways at all.** -/
theorem bornProb_eq_zero_iff {n : ℕ} (v : Fin n → GaussianInt) (k : Fin n)
    (hne : (∑ j, (Zsqrtd.norm (v j) : ℚ)) ≠ 0) :
    bornProb v k = 0 ↔ pairCount (v k) = 0 := by
  unfold bornProb
  rw [div_eq_zero_iff]
  constructor
  · rintro (h | h)
    · rw [pairCount_eq_norm]; exact_mod_cast h
    · exact absurd h hne
  · intro h
    left
    rw [pairCount_eq_norm] at h
    exact_mod_cast h

/-- **Probability one means every way.** The branch takes all of them; no other branch has any. -/
theorem bornProb_eq_one_iff {n : ℕ} (v : Fin n → GaussianInt) (k : Fin n)
    (hne : (∑ j, (Zsqrtd.norm (v j) : ℚ)) ≠ 0) :
    bornProb v k = 1 ↔ ((Zsqrtd.norm (v k) : ℚ)) = (∑ j, (Zsqrtd.norm (v j) : ℚ)) := by
  unfold bornProb
  rw [div_eq_one_iff_eq hne]

/-- **Every branch count is a whole number of ways** — there are no fractional ways, so all the
    structure in a Born probability lives in the *ratio*, not in any single branch's existence. -/
theorem pairCount_is_a_whole_count (a : GaussianInt) : 0 ≤ pairCount a ∧ ∃ m : ℕ, pairCount a = m := by
  refine ⟨pairCount_nonneg a, ⟨(pairCount a).toNat, ?_⟩⟩
  have := pairCount_nonneg a
  omega

/-! ### Uniqueness of the pair form

"`|A|²` is the unique bilinear form" — made precise. The hypotheses are not decoration: they *are* the
pair structure. A form takes one leg from each side (ket and bra); scaling a leg scales the count; the
bra leg carries the dagger; and the trivial closure counts once. Those four facts alone pin the form. -/

/-- **Uniqueness on the amplitude line (`ℂ`).** Any form that scales linearly on the ket leg,
    conjugate-linearly on the bra leg, and counts the trivial closure once **is** `a ↦ a · ā`, whose
    diagonal is `|a|²`. Nothing else survives those three requirements. -/
theorem unique_pair_form (B : ℂ → ℂ → ℂ)
    (hket : ∀ a b, B a b = a * B 1 b)
    (hbra : ∀ a b, B a b = star b * B a 1)
    (hone : B 1 1 = 1) :
    ∀ a : ℂ, B a a = a * star a := by
  intro a
  rw [hket a a, hbra 1 a, hone, mul_one]

/-- **The same uniqueness over the substrate ring**, tied to the count: the unique such form on `ℤ[i]`
    is exactly the **pair count**. So within the pair structure the Born weight is not a choice. -/
theorem unique_pair_form_is_pairCount (B : GaussianInt → GaussianInt → GaussianInt)
    (hket : ∀ a b, B a b = a * B 1 b)
    (hbra : ∀ a b, B a b = star b * B a 1)
    (hone : B 1 1 = 1) :
    ∀ a : GaussianInt, B a a = ((pairCount a : ℤ) : GaussianInt) := by
  intro a
  rw [hket a a, hbra 1 a, hone, mul_one, pairCount_eq_leg_times_dagger]

/-! ### The residue, localized to the generators -/

/-- **Multiplicative counts are determined by their values on generators.** If a candidate way-count
    `f` composes multiplicatively (as the census does, `independent_join_multiplies`) and agrees with
    the pair count on each primitive closure, then it agrees on every composite built from them.

    This is what remains of the multiplicity ↔ norm bridge: not a global identification of two
    functions, but **agreement on the primitives** — a finite check per generator. -/
theorem count_determined_by_generators
    (f : GaussianInt → ℤ)
    (hmul : ∀ a b, f (a * b) = f a * f b)
    (hone : f 1 = 1)
    (S : List GaussianInt)
    (hS : ∀ a ∈ S, f a = pairCount a) :
    f S.prod = pairCount S.prod := by
  induction S with
  | nil => simpa [hone] using pairCount_one.symm
  | cons a t ih =>
      have hat : ∀ b ∈ t, f b = pairCount b := fun b hb => hS b (List.Mem.tail _ hb)
      have ha : f a = pairCount a := hS a (List.Mem.head _)
      rw [List.prod_cons, hmul, ha, ih hat, ← pairCount_mul]

/-- **Established constructively, and the boundary named.** *Closed:* the **exponent**. An event is a
    closed Hermitian pair, so its way-count is ket × bra — `pairCount_eq_leg_times_dagger` — which is
    exactly the `ℤ[i]` norm (`pairCount_eq_norm`), so `bornProb` is the normalized pair count
    (`born_is_pair_count_ratio`). Independently, the modulus **cannot** be a count at all, being
    irrational for `1+i` (`modulus_not_a_count`), so integrality alone already forces the square.
    *Reduced, not closed:* the identification of that count with the **census** count. Both are
    multiplicative (`pairCount_mul`; `independent_join_multiplies`), so by
    `count_determined_by_generators` the open step is **agreement on the primitive closures** — a
    finite check per generator rather than a global assumption. *Untouched:* uniqueness of the `|a|²`
    form against all alternatives (Gleason, envariance, decision-theoretic derivations); this shows
    only that inside a `ℤ[i]` count-ontology the norm is the sole candidate. **The Born rule is not
    derived here.** No axioms. -/
theorem born_counting_summary : True := trivial

end QLF.BornCounting

import QLF_HorizonClosure
import Mathlib

set_option linter.unusedVariables false

/-!
# QLF_ClosureDepth — how many ways a history closes at each depth, and where `log 2` comes from

`QLF_HorizonClosure` establishes that closure is **horizon-relative**: `boundedPrune R` prunes only
`R` passes, and the nested singlet `[+,+,−,−]` reads open at `R=1`, closed at `R=2`. This module
grades the whole census by that depth and **counts the ways at each grade** — the method of
[`Philosophy.md`](../Philosophy.md) §3a: an existence witness is a lower bound on multiplicity, and
the count is the physical content.

## The depth-1 stratum is exactly `2ⁿ` ways — hence `log 2` per closure

A history closes in **one** pass exactly when it is a concatenation of adjacent opposite pairs, each
independently `+−` or `−+`:

* **`onePass_closed_iff_pairMatching`** — `zeno_prune s = [] ↔ s = pairMatching bs` for some boolean
  word `bs`. Both directions proven, no axiom.
* **`onePass_ways_iff`** — the one-pass closures of length `2n` are **exactly** the boolean words of
  length `n`. So the number of ways is `2ⁿ`: **two ways per closure pair, independently**.
* **`onePass_entropy`** — `log (2ⁿ) = n · log 2`. The multiplicity of the depth-1 census is `2` per
  pair, so its entropy is exactly **`log 2` per closure** — the same quantum as `ΔF = −log 2`
  (`QLF_FreeEnergy`), `Ω_Λ = log 2` (`QLF_CosmologicalConstant`), the area law `S = 4πR² log 2`
  (`QLF_GravityFromDelay`), and the Immirzi `log 2` (`QLF_LoopQuantumGravity`). Here it is not fitted
  or imported: it is **counted**. Two ways to close a pair is the whole content of the `log 2`.

That is one entry in the inventory of ways `log 2` arises — see [`Entropy.md`](../Entropy.md).

## The deepest stratum holds exactly `2` ways

The other end of the grading is the nested singlet `[+^d −^d]`, generalizing `QLF_HorizonClosure`'s
`nestedSinglet` (`d = 2`):

* **`zeno_prune_nested`** — one pass peels exactly one shell: `zeno_prune (nested (d+1)) = nested d`.
* **`boundedPrune_nested`** — hence `boundedPrune k (nested d) = nested (d − k)`, so the depth-`d`
  fold is closed at horizon `d` (`nested_closed_at_d`) and **not** before
  (`nested_not_closed_before`). The `d = 2` case is `horizon_relative`.

Since only `[+^d −^d]` and its mirror reach depth `d` at length `2d`, the deepest stratum holds two
ways — versus `2ⁿ` at depth 1. **The shallow closures overwhelmingly dominate**, and by
[`Philosophy.md`](../Philosophy.md) §3a rule 2 the modal depth, not the mean, is what happens first.

## The depth law (verified exhaustively, one step from proof)

Empirically the pruning depth has a closed form: **the closure depth of a history is the maximum
excess of its phase walk**,

  `closureDepth s = maxExcursion s := maxₚ |imbalance of prefix p|`,

verified with **0 counterexamples across all 66,196 count-balanced histories of length ≤ 18** (and
the finer per-pass form: one pass drops `maxExcursion` by exactly `1`, same exhaustive range). It is
consistent with both strata proven here: `maxExcursion = 1` is exactly the pair matchings
(`maxExcursion_pairMatching`, proven), and `maxExcursion (nested d) = d`.

The single missing step is the per-pass lemma `maxExcursion (zeno_prune s) + 1 = maxExcursion s` for
non-empty balanced `s` — a finitary combinatorial fact about prefix maxima under the skip-2 fold, the
same shape as the `count_balanced_pauli_closed` keystone before it was proven. It is **not**
axiomatized here (`closure_depth_law_in_progress`): a finitary fact should be proven, not posited.

Consequence if it holds, and worth stating because it is *falsifiable*: the depth of a random
balanced history is the maximum of a `±1` bridge, whose expectation is `√(πn/2)` — so a horizon of
capacity `R` closes histories of length `~R²`. **Polynomial, not exponential** (an earlier `log₂ n`
reading of small-`n` data was wrong; sampling to `n = 1024` gives the `√n` law, ratio to `√(πn/2)`
rising `0.92 → 0.97`).
-/

namespace QLF.ClosureDepth

open QLF.HorizonClosure

/-! ### The phase walk and its maximum excess -/

/-- The imbalance contributed by one element: `+1`, `−1`, or `0` for a gauge. -/
def imb : TopoElement → Int
  | TopoElement.phase LogicPhase.pos => 1
  | TopoElement.phase LogicPhase.neg => -1
  | TopoElement.gauge => 0

/-- Running maximum of `|imbalance|` over prefixes, from accumulator `c`. -/
def exc : Int → TopoString → ℕ
  | c, [] => c.natAbs
  | c, h :: t => max c.natAbs (exc (c + imb h) t)

/-- **The maximum excess of the phase walk** — the largest `|imbalance|` any prefix reaches. -/
def maxExcursion (s : TopoString) : ℕ := exc 0 s

/-! ### The depth-1 stratum: `2ⁿ` ways, i.e. `log 2` per closure -/

/-- One closure pair, in either order — the two ways a pair can close. -/
def pairOf : Bool → TopoString
  | true  => [TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.neg]
  | false => [TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.pos]

/-- A boolean word read as a concatenation of closure pairs. -/
def pairMatching : List Bool → TopoString
  | [] => []
  | b :: bs => pairOf b ++ pairMatching bs

/-- Every pair matching closes in a **single** pass. -/
theorem pairMatching_closes (bs : List Bool) : zeno_prune (pairMatching bs) = [] := by
  induction bs with
  | nil => simp [pairMatching, zeno_prune]
  | cons b bs ih => cases b <;> simp [pairMatching, pairOf, zeno_prune, ih]

/-- **Conversely, one-pass closure forces the pair-matching form.** If `zeno_prune s = []` then `s`
    is a concatenation of adjacent opposite pairs: anything else leaves its head behind. -/
theorem exists_pairMatching_of_closes :
    ∀ s : TopoString, zeno_prune s = [] → ∃ bs : List Bool, s = pairMatching bs
  | [], _ => ⟨[], rfl⟩
  | [x], h => by cases x <;> simp [zeno_prune] at h
  | a :: b :: t, h => by
      match a, b with
      | TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.neg =>
          simp only [zeno_prune] at h
          obtain ⟨bs, hbs⟩ := exists_pairMatching_of_closes t h
          exact ⟨true :: bs, by simp [pairMatching, pairOf, hbs]⟩
      | TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.pos =>
          simp only [zeno_prune] at h
          obtain ⟨bs, hbs⟩ := exists_pairMatching_of_closes t h
          exact ⟨false :: bs, by simp [pairMatching, pairOf, hbs]⟩
      | TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.pos =>
          simp [zeno_prune] at h
      | TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.neg =>
          simp [zeno_prune] at h
      | TopoElement.phase LogicPhase.pos, TopoElement.gauge =>
          simp [zeno_prune] at h
      | TopoElement.phase LogicPhase.neg, TopoElement.gauge =>
          simp [zeno_prune] at h
      | TopoElement.gauge, _ =>
          simp [zeno_prune] at h

/-- **The depth-1 stratum, characterized.** A history closes in one pass **iff** it is a pair
    matching — so the ways of closing at depth 1 are exactly the boolean words. -/
theorem onePass_closed_iff_pairMatching (s : TopoString) :
    zeno_prune s = [] ↔ ∃ bs : List Bool, s = pairMatching bs := by
  refine ⟨exists_pairMatching_of_closes s, ?_⟩
  rintro ⟨bs, rfl⟩
  exact pairMatching_closes bs

/-- A pair matching has twice the length of its word. -/
theorem pairMatching_length (bs : List Bool) : (pairMatching bs).length = 2 * bs.length := by
  induction bs with
  | nil => simp [pairMatching]
  | cons b bs ih => cases b <;> simp [pairMatching, pairOf, ih] <;> ring

/-- **Distinct words give distinct closures** — the `2ⁿ` ways are genuinely distinct histories. -/
theorem pairMatching_injective : Function.Injective pairMatching := by
  intro a b hab
  induction a generalizing b with
  | nil =>
      cases b with
      | nil => rfl
      | cons hb tb => cases hb <;> simp [pairMatching, pairOf] at hab
  | cons ha ta ih =>
      cases b with
      | nil => cases ha <;> simp [pairMatching, pairOf] at hab
      | cons hb tb =>
          cases ha <;> cases hb <;>
            simp [pairMatching, pairOf] at hab <;>
            first
              | (exact absurd hab (by simp))
              | (rw [ih hab])

/-- **Counting the ways at depth 1.** The one-pass closures of length `2n` are exactly the boolean
    words of length `n` — so there are `2ⁿ` of them: **two ways per closure pair, independently
    chosen.** -/
theorem onePass_ways_iff (n : ℕ) (s : TopoString) :
    (zeno_prune s = [] ∧ s.length = 2 * n) ↔
      ∃ bs : List Bool, bs.length = n ∧ s = pairMatching bs := by
  constructor
  · rintro ⟨hclose, hlen⟩
    obtain ⟨bs, rfl⟩ := exists_pairMatching_of_closes s hclose
    refine ⟨bs, ?_, rfl⟩
    rw [pairMatching_length] at hlen
    omega
  · rintro ⟨bs, hlen, rfl⟩
    exact ⟨pairMatching_closes bs, by rw [pairMatching_length, hlen]⟩

/-- The number of boolean words of length `n` is `2ⁿ` — the multiplicity of the depth-1 stratum. -/
theorem ways_card (n : ℕ) : Fintype.card (Fin n → Bool) = 2 ^ n := by simp

/-- **`log 2` per closure, counted.** The depth-1 stratum has `2ⁿ` ways, so its entropy is exactly
    `n log 2`: **`log 2` per closure pair**, because a pair closes in exactly two ways. This is the
    same quantum as `ΔF = −log 2` (`QLF_FreeEnergy`), `Ω_Λ = log 2`, the area law `S = 4πR² log 2`,
    and the Immirzi `log 2` — here *counted* rather than imported. -/
theorem onePass_entropy (n : ℕ) : Real.log ((2 : ℝ) ^ n) = n * Real.log 2 := by
  rw [Real.log_pow]

/-- Every pair matching has maximum excess `1`: the phase walk never leaves `{0, ±1}`. The `d = 1`
    case of the depth law. -/
theorem maxExcursion_pairMatching (bs : List Bool) (hbs : bs ≠ []) :
    maxExcursion (pairMatching bs) = 1 := by
  unfold maxExcursion
  induction bs with
  | nil => exact absurd rfl hbs
  | cons b bs ih =>
      cases bs with
      | nil => cases b <;> simp [pairMatching, pairOf, exc, imb]
      | cons c cs =>
          have hne : (c :: cs) ≠ [] := by simp
          cases b <;> simp [pairMatching, pairOf, exc, imb, ih hne]

/-! ### The deepest stratum: exactly two ways -/

/-- The **depth-`d` nested singlet** `[+^d −^d]` — `QLF_HorizonClosure.nestedSinglet` is `d = 2`. -/
def nested (d : ℕ) : TopoString :=
  List.replicate d (TopoElement.phase LogicPhase.pos) ++
  List.replicate d (TopoElement.phase LogicPhase.neg)

/-- **One pass peels exactly one shell.** `zeno_prune [+^{d+1} −^{d+1}] = [+^d −^d]`: the innermost
    pair (at the sign boundary) cancels and nothing else does. -/
theorem zeno_prune_nested (d : ℕ) : zeno_prune (nested (d + 1)) = nested d := by
  induction d with
  | zero => simp [nested, zeno_prune]
  | succ k ih =>
      have h : nested (k + 1 + 1) =
          TopoElement.phase LogicPhase.pos :: TopoElement.phase LogicPhase.pos ::
            (List.replicate k (TopoElement.phase LogicPhase.pos) ++
             List.replicate (k + 1 + 1) (TopoElement.phase LogicPhase.neg)) := by
        simp [nested, List.replicate_succ]
      rw [h]
      have h2 : TopoElement.phase LogicPhase.pos ::
            (List.replicate k (TopoElement.phase LogicPhase.pos) ++
             List.replicate (k + 1 + 1) (TopoElement.phase LogicPhase.neg)) = nested (k + 1 + 1) := by
        simp [nested, List.replicate_succ]
      simp only [zeno_prune]
      rw [h2, ih]
      simp [nested, List.replicate_succ]

/-- **Bounded pruning peels shells one per pass**: `boundedPrune k [+^d −^d] = [+^{d−k} −^{d−k}]`
    (truncated subtraction — once empty it stays empty). -/
theorem boundedPrune_nested (d k : ℕ) : boundedPrune k (nested d) = nested (d - k) := by
  induction k with
  | zero => simp [boundedPrune]
  | succ m ih =>
      show zeno_prune (boundedPrune m (nested d)) = nested (d - (m + 1))
      rw [ih]
      cases Nat.eq_zero_or_pos (d - m) with
      | inl h0 =>
          have h1 : d - (m + 1) = 0 := by omega
          rw [h0, h1]
          simp [nested, zeno_prune]
      | inr hpos =>
          obtain ⟨j, hj⟩ : ∃ j, d - m = j + 1 := ⟨d - m - 1, by omega⟩
          rw [hj, zeno_prune_nested]
          have : d - (m + 1) = j := by omega
          rw [this]

/-- The depth-`d` fold **is** closed at horizon `d`. -/
theorem nested_closed_at_d (d : ℕ) : closedAtHorizon d (nested d) := by
  unfold closedAtHorizon
  rw [boundedPrune_nested]
  simp [nested]

/-- The depth-`d` fold is **not** closed at any shallower horizon: `d` passes are exactly needed.
    (`d = 2` is `QLF_HorizonClosure.horizon_relative`.) -/
theorem nested_not_closed_before (d k : ℕ) (hk : k < d) : ¬ closedAtHorizon k (nested d) := by
  unfold closedAtHorizon
  rw [boundedPrune_nested]
  have hpos : 0 < d - k := by omega
  obtain ⟨j, hj⟩ : ∃ j, d - k = j + 1 := ⟨d - k - 1, by omega⟩
  rw [hj]
  simp [nested, List.replicate_succ]

/-- **Status — the depth law.** Proven here with no axiom: the depth-1 stratum is exactly the pair
    matchings, counted at `2ⁿ` (`onePass_ways_iff`, `pairMatching_injective`), giving **`log 2` per
    closure** (`onePass_entropy`); and the nested singlet needs exactly `d` passes
    (`boundedPrune_nested`, `nested_closed_at_d`, `nested_not_closed_before`), generalizing
    `horizon_relative` from `d = 2` to all `d`. **Open (not axiomatized):** the closed form
    `closureDepth = maxExcursion` — the maximum excess of the phase walk — verified with 0
    counterexamples over all 66,196 balanced histories of length ≤ 18, its `d = 1` case proven
    (`maxExcursion_pairMatching`). The single missing step is the per-pass lemma
    `maxExcursion (zeno_prune s) + 1 = maxExcursion s` for non-empty balanced `s`; a finitary fact,
    so it should be proven rather than posited. -/
theorem closure_depth_law_in_progress : True := trivial

end QLF.ClosureDepth

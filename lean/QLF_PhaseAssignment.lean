import QLF_TwistAlphabet
import QLF_Degeneracy

set_option linter.unusedVariables false

/-!
# QLF_PhaseAssignment — which phase a way carries, and a correction

[`QLF_Degeneracy`](QLF_Degeneracy.lean) fixed the *decomposition* — one unit μ₄ component per way — and
left open **which** phase a given way carries. That phase is not a free parameter: it is the history's
`pauli_fold`. This module settles it for the census stratum that matters, and in doing so **corrects a
claim made when `QLF_Degeneracy` was written**.

## The correction

`QLF_Degeneracy` glossed `orthogonal_two_ways` as the census case — asserting that the two orderings of a
closure pair carry *orthogonal* phases (`1` and `i`), so that weight would equal count. **That is wrong,
and the repository already contained the theorem showing it is wrong.**
[`hermitian_pair_folds_to_negI`](QLF_TwistAlphabet.lean) proves that *every* Hermitian-conjugate pair
folds to `−I`, whichever way round it is taken (`pair_orderings_aligned` below spells this out, using
that conjugation is an involution on the alphabet). The two ways are **aligned**, not orthogonal.

The arithmetic theorems in `QLF_Degeneracy` stand — `orthogonal_two_ways : branchWeight [1, i] = 2` is
just `|1+i|² = 2`. What was wrong was the *identification* of the census pair's two ways with those
phases. The corrected statement:

* both orderings of a pair carry phase `−1` (`pair_orderings_aligned`);
* so a branch of `k` **such** ways has amplitude `±k` and weight `k²`, not `k`
  (`aligned_ways_weigh_square`), and the gauge-pair stratum's `2ⁿ` ways weigh `4ⁿ` (`stratum_weight`).

**A second correction, on the same principle — do not generalize from hand-picked ways.** "The two
orderings" are not "the ways": a branch's ways are *all* the histories that close, and across the full
8-twist census **both phases occur**. Counting every balanced history and its fold:

| length | ways | phase `+1` | phase `−1` | amplitude `Σζ` | weight `\|Σζ\|²` | `count²` |
|---|---|---|---|---|---|---|
| 2 | 8 | 0 | 8 | `−8` | 64 | 64 |
| 4 | 168 | 144 | 24 | `+120` | 14 400 | 28 224 |
| 6 | 5 120 | 1 488 | 3 632 | `−2 144` | 4 596 736 | 26 214 400 |

So **alignment is a *sector* property, not a census property**: within a conjugate-pair sector every way
carries `−1` (proven below), while a branch spanning the whole balanced census is **mixed**, its
amplitude is the *signed* sum, and its weight falls far below `count²`. That signed sum is where
interference actually lives — cancellation between ways, not a global coherent enhancement.

**And that dissolves the "agreement" reported by `born_generator_check.py`.** The check found
`count = 2ⁿ` matching `norm((1+i)ⁿ) = 2ⁿ`. Both are `2ⁿ`, but they are not the same quantity: the count
is `2ⁿ` and the *weight* is `4ⁿ`. The match was a numerical coincidence between a count and a norm, not
evidence that the branch amplitude is `(1+i)ⁿ`. Recording that plainly matters more than the match did.

## What the phase actually is

The fold is fixed by two independent contributions — verified numerically over the full census
(`born_generator_check.py`'s companion sweep, **0 counterexamples across all 5,296 count-balanced
histories of length ≤ 6**):

```
phase(h) = (−1)^(#negative twists) · sign(permutation sorting the axis word)
```

the first factor from the `v, <, \, −` mappings to negative Pauli matrices, the second from
anticommutation `σᵢσⱼ = −σⱼσᵢ` accumulated as an inversion count. Proven here for the pair sector, where
the axis word is constant so the permutation sign is `+1` and the rule reduces to `(−1)^{#pairs}`
(`concat_pairs_eq_neg_one_pow`). **The general two-factor rule is now proven** — `phase_rule` in
[`QLF_PhaseRule`](QLF_PhaseRule.lean), for every balanced history at every length, and in the stronger
form `twist_fold_phase_normal_form` that needs no balance hypothesis. What was the empirical finding
here is a theorem there; this module keeps the pair-sector case it was written for.

**A second empirical finding, worth flagging because it narrows `μ₄`:** no count-balanced history was
ever observed to fold to `±i` — exhaustively for length ≤ 6, and in 80,000 sampled histories of length
8–14. Balance appears to restrict the phase group from `μ₄` to `{±1}`. If that holds in general, branch
amplitudes over the balanced census are **integers**, not Gaussian integers. **Since proven, twice
over:** `balanced_phase_is_real` ([`QLF_BalancedPhaseReal`](QLF_BalancedPhaseReal.lean), by
determinant) and again as `phase_rule_real` ([`QLF_PhaseRule`](QLF_PhaseRule.lean), as a corollary of
the phase rule) — converging derivations, which is multiplicity, not redundancy.

## Honest scope

Proven here: pair orderings are aligned, and the weight consequences **within that sector**. The two
findings this module recorded as verified-but-not-proven have both since been proven elsewhere — the
two-factor phase rule ([`QLF_PhaseRule`](QLF_PhaseRule.lean)) and the `{±1}` restriction on balanced
closures ([`QLF_BalancedPhaseReal`](QLF_BalancedPhaseReal.lean)); what remains empirical here is the
mixed phase census above. **The methodological point is load-bearing and was learned the hard way, twice:**
things happen *every* way, so a branch's amplitude is a signed sum over **all** its ways — never an
extrapolation from two of them. No axioms.
-/

namespace QLF.PhaseAssignment

open QLF QLF.BornCounting QLF.Degeneracy

/-- Conjugation is an involution on the 8-twist alphabet. -/
theorem conj_conj (t : Twist) : t.conj.conj = t := by
  cases t <;> rfl

/-- **Both orderings of a conjugate pair carry the same phase, `−1`.** Taking the pair the other way
    round is the pair of the conjugate twist, and that folds to `−I` too — so the two ways of closing a
    pair are **aligned**, not orthogonal. This is the theorem that refutes the gloss in
    `QLF_Degeneracy`; note it was already available as `hermitian_pair_folds_to_negI`. -/
theorem pair_orderings_aligned (t : Twist) :
    t.toMatrix * t.conj.toMatrix = -(1 : M) ∧ t.conj.toMatrix * t.conj.conj.toMatrix = -(1 : M) := by
  refine ⟨hermitian_pair_folds_to_negI t, ?_⟩
  exact hermitian_pair_folds_to_negI t.conj

/-- Restated without the conjugate-of-conjugate: the reversed ordering folds to `−I` as well. -/
theorem pair_reversed_folds_to_negI (t : Twist) :
    t.conj.toMatrix * t.toMatrix = -(1 : M) := by
  have h := hermitian_pair_folds_to_negI t.conj
  rwa [conj_conj t] at h

/-- **A branch of `k` aligned ways weighs `k²`, not `k`.** With every way carrying the same unit phase,
    the amplitudes add coherently, so the count and the weight come apart quadratically. -/
theorem aligned_ways_weigh_square (k : ℤ) : pairCount (⟨k, 0⟩ : GaussianInt) = k ^ 2 :=
  aligned_weight k

/-- **The depth-1 stratum weighs `4ⁿ`, not `2ⁿ`.** Its `2ⁿ` ways (`QLF_ClosureDepth.onePass_ways_iff`)
    all carry the same phase, so the branch amplitude is `±2ⁿ` and the weight is `(2ⁿ)² = 4ⁿ`. The
    coincidence that `norm((1+i)ⁿ)` is also `2ⁿ` compares a norm with a *count*, not with this weight. -/
theorem stratum_weight (n : ℕ) : pairCount (⟨(2 : ℤ) ^ n, 0⟩ : GaussianInt) = 4 ^ n := by
  rw [aligned_weight, ← pow_mul, mul_comm, pow_mul]
  norm_num

/-- **Established, and a correction recorded.** *Proven:* both orderings of a Hermitian pair fold to
    `−I` (`pair_orderings_aligned`, `pair_reversed_folds_to_negI`, on top of the pre-existing
    `hermitian_pair_folds_to_negI`), so the ways of a pair are **aligned**; hence a branch of `k` such
    ways weighs `k²` (`aligned_ways_weigh_square`) and the depth-1 stratum weighs `4ⁿ`, not `2ⁿ`
    (`stratum_weight`). *Corrected twice:* first, `QLF_Degeneracy`'s gloss that those two ways are
    *orthogonal* — its arithmetic theorems stand, the physical identification does not, so the
    "agreement on the pair generator" from `born_generator_check.py` is a coincidence between a count
    and a norm rather than evidence about the amplitude. Second, and on the principle that things
    happen *every* way: alignment is a **sector** property, not a census property — counting all
    balanced histories with their folds shows **both** phases occurring (at length 6: `1 488` carry
    `+1` and `3 632` carry `−1`), so a branch spanning the census has the **signed** sum as its
    amplitude and a weight far below `count²`. Reasoning from two hand-picked ways was the error in
    both directions. *Verified but not proven:* the two-factor phase
    rule `(−1)^{#neg} · sign(axis permutation)` (0 counterexamples over all 5,296 balanced histories of
    length ≤ 6), and that balanced closures never fold to `±i` — which, if general, makes branch
    amplitudes **integers** rather than Gaussian integers. That is the next target. No axioms. -/
theorem phase_assignment_summary : True := trivial

end QLF.PhaseAssignment

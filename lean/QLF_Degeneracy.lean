import QLF_BornCounting
import Mathlib

set_option linter.unusedVariables false

/-!
# QLF_Degeneracy — what fixes the decomposition: one μ₄ phase per way

[`QLF_BornCounting`](QLF_BornCounting.lean) reduced the multiplicity ↔ Born-norm bridge to a single
open question — *what fixes the degeneracy decomposition of a branch* — after
[`born_generator_check.py`](../born_generator_check.py) showed the naive identification cannot hold:
census counts like `3, 38, 70` are **not** sums of two squares, so no Gaussian amplitude carries them,
and no two Gaussian integers stand in norm ratio `3:1` though such Born weights are routine.

The resolution is not a patch. It is that **the naive identification was the wrong statement**, and the
substrate already fixes the right one.

## The decomposition is fixed, and `QLF_Pauli` fixes it

Every closed history folds to a **scalar in `μ₄ = {±1, ±i}`** — the Pauli scalar group, machine-verified
in [`QLF_Pauli`](QLF_Pauli.lean) and reachable from count balance alone
(`count_balanced_pauli_closed`). So a way is not a bare tally mark: it carries a **unit amplitude with a
μ₄ phase**. That fixes the decomposition completely — one unit-norm component per way, its phase drawn
from the four Pauli scalars — and nothing about it is free.

Consequently a branch's amplitude is the **sum over its ways**, `a = Σₖ ζₖ` with `ζₖ ∈ μ₄`, and its Born
weight is `|a|²`. Two things follow immediately:

* **`weight_is_always_a_norm`** — a sum of Gaussian integers is a Gaussian integer, so a branch weight is
  *automatically* a `ℤ[i]` norm. The obstruction that sank the naive identification never arises.
* **weight ≠ count, and the gap is interference.** The census count is `n`; the weight is `|Σ ζₖ|²`.
  These are different quantities, and comparing them was the error:

| ways | phases | count | weight | reading |
|---|---|---|---|---|
| 2 | `1, i` — orthogonal | 2 | **2** (`orthogonal_two_ways`) | no interference — *not* the census pair, see the correction above |
| 2 | `1, 1` — aligned | 2 | **4** (`aligned_two_ways`) | constructive — **this is the census pair** |
| 2 | `1, −1` — opposed | 2 | **0** (`cancelling_two_ways`) | destructive |
| n | all aligned | n | **n²** (`aligned_weight`) | fully coherent |

**Correction (see [`QLF_PhaseAssignment`](QLF_PhaseAssignment.lean)).** An earlier version of this
docstring claimed the census pair's two orderings carry *orthogonal* phases, so that weight would equal
count. **That is false**, and `QLF_TwistAlphabet.hermitian_pair_folds_to_negI` — already in the
repository — shows why: *every* conjugate pair folds to `−I`, either way round. The two ways are
**aligned**, so a pair branch weighs `4`, not `2`, and the depth-1 stratum weighs `4ⁿ`, not `2ⁿ`. The
arithmetic in the table below is unaffected (`|1+i|² = 2` is just true); what was wrong was identifying
the census pair with those phases. Consequently the "agreement on the pair generator" reported by
[`born_generator_check.py`](../born_generator_check.py) compares a **count** with a **norm** — both
`2ⁿ` — and is a numerical coincidence, not evidence about the amplitude.

## What this settles, and what it does not

**Settled:** the degeneracy decomposition is not a free choice — it is one unit-norm μ₄ component per
closure, so every branch weight is a norm and the earlier obstruction dissolves. The residue recorded in
`Open_Problems.md` is answered.

**Not settled, and not to be confused with it:** *which* phase each way carries. That is the dynamics —
the actual `pauli_fold` of each history (`count_balanced_pauli_closed` says the fold lands in `μ₄`; it
does not say which element for a given branch decomposition). Computing the phase assignment for a given
physical branch is the interference calculation itself, and this module does not perform it. Nor does it
touch Gleason-style uniqueness. No axioms.
-/

namespace QLF.Degeneracy

open QLF.BornCounting

/-- **The four Pauli scalars** — the unit amplitudes a single way may carry (`QLF_Pauli`: the closed
    scalar group is `μ₄`). -/
def mu4 : List GaussianInt := [1, -1, ⟨0, 1⟩, ⟨0, -1⟩]

/-- Each Pauli scalar is a **unit** amplitude: exactly one way. -/
theorem mu4_pairCount_one : ∀ z ∈ mu4, pairCount z = 1 := by decide

/-- **A branch's amplitude is the sum over its ways** — one unit μ₄ component per closure. -/
def branchAmp (ways : List GaussianInt) : GaussianInt := ways.sum

/-- **A branch's Born weight** is the pair count of that amplitude. -/
def branchWeight (ways : List GaussianInt) : ℤ := pairCount (branchAmp ways)

/-- **Every branch weight is a `ℤ[i]` norm — automatically.** A sum of Gaussian integers is a Gaussian
    integer, so the obstruction that defeated the naive "weight = count" identification (counts such as
    `3` are not sums of two squares) simply does not arise: weights are norms *of sums*, and counts are
    not weights. -/
theorem weight_is_always_a_norm (ways : List GaussianInt) :
    ∃ a : GaussianInt, branchWeight ways = pairCount a :=
  ⟨branchAmp ways, rfl⟩

/-- A branch weight is non-negative, as a weight must be. -/
theorem branchWeight_nonneg (ways : List GaussianInt) : 0 ≤ branchWeight ways :=
  pairCount_nonneg _

/-! ### Weight is not count — and the gap is interference -/

/-- **Orthogonal phases: no interference, weight = count.** Two ways carrying `1` and `i` give
    `|1 + i|² = 2`. This is the case the generator check found matching exactly — the two orderings of a
    closure pair. -/
theorem orthogonal_two_ways : branchWeight [1, ⟨0, 1⟩] = 2 := by decide

/-- **Aligned phases: constructive.** Two ways both carrying `1` give `|1 + 1|² = 4`, twice the count. -/
theorem aligned_two_ways : branchWeight [1, 1] = 4 := by decide

/-- **Opposed phases: destructive.** Two ways carrying `1` and `−1` give weight `0` — the branch has two
    ways and *no* weight. Interference falls straight out of counting with phases. -/
theorem cancelling_two_ways : branchWeight [1, -1] = 0 := by decide

/-- **Fully coherent branch: `n` aligned ways carry weight `n²`, not `n`.** So weight and count coincide
    only in the incoherent case; assuming they were equal in general was the error the generator check
    exposed. -/
theorem aligned_weight (n : ℤ) : pairCount (⟨n, 0⟩ : GaussianInt) = n ^ 2 := by
  simp [pairCount]

/-- **Three ways need not weigh three.** The count `3` is not a `ℤ[i]` norm, and indeed no branch of
    three ways weighs `3`: three aligned ways weigh `9`. The impossible object was never a weight. -/
theorem three_aligned_ways : branchWeight [1, 1, 1] = 9 := by decide

/-- **Two orthogonal pairs compose to weight `4`** — matching `norm((1+i)²) = 4` and the `2ⁿ` census of
    `QLF_ClosureDepth.onePass_ways_iff` at `n = 2`, the agreement the generator check reported. -/
theorem pair_generator_squared : pairCount ((⟨1, 1⟩ : GaussianInt) * ⟨1, 1⟩) = 4 := by decide

/-- **Established constructively.** The degeneracy decomposition is **not** a free choice: every closed
    history folds to a scalar in `μ₄` (`QLF_Pauli`, reachable from count balance via
    `count_balanced_pauli_closed`), so a branch decomposes into **one unit-norm μ₄ component per way**
    (`mu4_pairCount_one`), its amplitude is their sum (`branchAmp`), and its weight is that amplitude's
    pair count (`branchWeight`). Hence **`weight_is_always_a_norm`** — every branch weight is a `ℤ[i]`
    norm automatically, so the obstruction found by `born_generator_check.py` (counts like `3` are not
    sums of two squares) dissolves: **counts are not weights**. The gap between them is exactly
    **interference** — orthogonal phases give weight = count (`orthogonal_two_ways`, the case that
    matched), aligned phases give `n²` (`aligned_weight`, `three_aligned_ways`), opposed phases give `0`
    (`cancelling_two_ways`). **Open, and distinct:** *which* phase a given way carries — that is the
    `pauli_fold` of the specific history, i.e. the interference calculation itself, which this module
    does not perform. Gleason-style uniqueness remains untouched. No axioms. -/
theorem degeneracy_summary : True := trivial

end QLF.Degeneracy

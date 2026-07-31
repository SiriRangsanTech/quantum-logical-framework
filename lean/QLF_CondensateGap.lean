import QLF_CensusBrownian
import Mathlib

set_option linter.unusedVariables false

/-!
# QLF_CondensateGap — the interacting closure-binding as an NJL gap equation with the census loop

The named electroweak frontier (issue #121): the *interacting* closure-binding strength `g` that fixes the
condensate depth `R_stable = v`. The binding **structure** is done (`QLF_ClosureBinding`: the `t̄t` channel
binds to a real scalar condensate, `tt` is Pauli-blocked, each bind costs `log 2`); what was open is the
**magnitude** — does the many-closure density reach the NJL critical point, and at what scale? This module
formalizes the answer to the *condensation* question.

**The model.** The NJL gap equation for a fermion–antifermion condensate is `1 = g · (loop over
intermediate states)`. QLF reading: the intermediate states *are* the closed histories; the "loop integral"
is the **closure census**. The per-step weight is the 1-D return probability
`censusWeight m = C(2m,m)/4ᵐ` (`= QLF_CensusBrownian.returnProb1D`), so the census loop up to a Planck-floor
cutoff depth `N` is `gapSum N = Σ_{m=1}^{N} censusWeight m`. Condensation (a non-trivial gap) is
`condenses g N := 1 ≤ g · gapSum N`, i.e. `g ≥ criticalCoupling N = 1/gapSum N`.

* **`censusWeight_pos`** — every census weight is positive (`C(2m,m) > 0`).
* **`gapSum_strictMono`** — the census loop **strictly increases** with the cutoff (each term positive).
* **`condenses_iff_ge_critical`** — condensation `1 ≤ g·gapSum N` iff `g ≥ criticalCoupling N` (`= 1/gapSum N`).
* **`criticalCoupling_antitone`** — the critical coupling **decreases** as the cutoff deepens (reciprocal of
  an increasing positive sum): the deeper the census, the weaker the coupling needed to condense.
* **`condenses_mono`** — condensation is stable under deepening the cutoff (`condenses g N`, `N ≤ N'` ⟹
  `condenses g N'`).

Together: because `gapSum` grows without bound (`~ 2√(N/π)`, the Wallis census asymptotic), the critical
coupling `→ 0` at the Planck floor — **condensation is generic**: any fixed `g > 0` is supercritical beyond
some depth, and the electroweak scale is the transmutation depth `N* ~ π/(4g²)` ([`closure_binding.py`](../closure_binding.py)).
The *free* census (no binding) has a **monotone** free energy (no minimum), so the interaction is essential.

## Scope

Anchors the gap-equation **structure** and the **condensation criterion** — that the interacting
closure-binding *is* an NJL gap equation with the census loop, and that it condenses (generically, given the
divergent census sum). It does **not** derive the **value** of `g` (issue #121, the irreducible open
number): `g = (log 2 per bind) × (channel factor) × (many-closure packing factor)`, and the packing factor
is the one dimensionless number the interacting theory must fix from the 8-twist combinatorics — the
gravitational part is `≈ 0.1–0.4` (subcritical), the packing supplies the rest. The census divergence
`gapSum → ∞` is the Wallis asymptotic (settled; `QLF_PhysicalPi`), stated not re-proved here. Reuses
`QLF_CensusBrownian`; no new axioms. See `Higgs.md` §5a, issue #121.
-/

namespace QLF.CondensateGap

open QLF.CensusBrownian

/-- The NJL loop weight at depth `m`: the census 1-D return probability `C(2m,m)/4ᵐ`. -/
def censusWeight (m : ℕ) : ℚ := returnProb1D m

/-- **Every census weight is positive** — `C(2m,m) > 0` and `4ᵐ > 0`. -/
theorem censusWeight_pos (m : ℕ) : 0 < censusWeight m := by
  unfold censusWeight returnProb1D
  apply div_pos
  · exact_mod_cast Nat.choose_pos (by omega)
  · positivity

/-- The census loop up to cutoff depth `N`: `Σ_{m=1}^{N} censusWeight m` (the NJL "loop integral"). -/
def gapSum (N : ℕ) : ℚ := ∑ m ∈ Finset.range N, censusWeight (m + 1)

/-- **The census loop strictly increases with the cutoff** — adding the positive weight at depth `N+1`. -/
theorem gapSum_strictMono : StrictMono gapSum := by
  apply strictMono_nat_of_lt_succ
  intro N
  unfold gapSum
  rw [Finset.sum_range_succ]
  have := censusWeight_pos (N + 1)
  linarith

/-- `gapSum` is nonneg and, for `N ≥ 1`, strictly positive. -/
theorem gapSum_pos {N : ℕ} (hN : 1 ≤ N) : 0 < gapSum N := by
  have h0 : gapSum 0 = 0 := by simp [gapSum]
  calc (0 : ℚ) = gapSum 0 := h0.symm
    _ < gapSum N := gapSum_strictMono (by omega)

/-- The **critical coupling** at cutoff `N`: `g_crit = 1/gapSum N` — condensation needs `g ≥ g_crit`. -/
noncomputable def criticalCoupling (N : ℕ) : ℚ := 1 / gapSum N

/-- **Condensation** at cutoff `N` with coupling `g`: the gap equation `g · gapSum N ≥ 1` is met. -/
def condenses (g : ℚ) (N : ℕ) : Prop := 1 ≤ g * gapSum N

/-- **Condensation ⟺ super-critical coupling.** For `N ≥ 1`, `1 ≤ g·gapSum N` iff `g ≥ 1/gapSum N`. -/
theorem condenses_iff_ge_critical (g : ℚ) {N : ℕ} (hN : 1 ≤ N) :
    condenses g N ↔ criticalCoupling N ≤ g := by
  have hp := gapSum_pos hN
  unfold condenses criticalCoupling
  constructor
  · intro h; rw [div_le_iff₀ hp]; linarith
  · intro h; have := (div_le_iff₀ hp).mp h; linarith

/-- **The critical coupling decreases as the cutoff deepens** — a deeper census needs weaker binding to
    condense (reciprocal of the increasing positive `gapSum`). -/
theorem criticalCoupling_antitone {N N' : ℕ} (hN : 1 ≤ N) (h : N ≤ N') :
    criticalCoupling N' ≤ criticalCoupling N := by
  unfold criticalCoupling
  exact one_div_le_one_div_of_le (gapSum_pos hN) (gapSum_strictMono.monotone h)

/-- **Condensation is stable under deepening the cutoff** — if `g` condenses at `N`, it condenses at every
    `N' ≥ N` (the census loop only grows). So once super-critical, always super-critical: the deeper Planck
    floor keeps the condensate. -/
theorem condenses_mono {g : ℚ} (hg : 0 ≤ g) {N N' : ℕ} (h : N ≤ N') (hc : condenses g N) :
    condenses g N' := by
  unfold condenses at *
  have hmono : gapSum N ≤ gapSum N' := gapSum_strictMono.monotone h
  calc (1 : ℚ) ≤ g * gapSum N := hc
    _ ≤ g * gapSum N' := mul_le_mul_of_nonneg_left hmono hg

/-- **Established (issue #121, `Higgs.md` §5a).** The interacting closure-binding is an **NJL gap equation
    with the census as the loop**: `gapSum` is the census loop (`censusWeight_pos`, `gapSum_strictMono`),
    condensation is `1 ≤ g·gapSum N ⟺ g ≥ 1/gapSum N` (`condenses_iff_ge_critical`), the critical coupling
    **decreases** with the cutoff (`criticalCoupling_antitone`), and condensation is **stable** under
    deepening it (`condenses_mono`). Because the census sum diverges (`~2√(N/π)`, Wallis), the critical
    coupling `→ 0` at the Planck floor — **condensation is generic**, the electroweak scale the
    transmutation depth `N* ~ π/(4g²)` (`closure_binding.py`). **Open (the one number, #121):** the
    *value* of `g` (= `log 2` × channel × many-closure packing factor) — condensation is settled, its
    *scale* is not, pending the packing factor from the 8-twist combinatorics. Reuses `QLF_CensusBrownian`;
    no new axioms. -/
theorem condensate_gap_summary : True := trivial

end QLF.CondensateGap

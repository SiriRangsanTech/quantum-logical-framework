import QLF_ClosureDepthLaw

set_option linter.unusedVariables false

/-!
# QLF_Mpemba — anomalous relaxation: what the substrate forbids, permits, and does not deliver

The Mpemba effect is a state *farther* from equilibrium relaxing *faster*. The modern understanding is
structural rather than thermal: relaxation is a sum over modes, and a preparation whose amplitude on the
slowest mode is small — or zero, the **strong** effect — converges sooner regardless of its distance
(Lu–Raz; Klich–Raz–Hirschberg–Vucelja). See [`Mpemba.md`](../Mpemba.md).

On the substrate, relaxation to equilibrium *is* closure, and its time is the closure depth — which
`QLF_ClosureDepthLaw` proves equals the **maximum phase excursion**. That makes three statements
decidable rather than interpretive, and they do not all point the same way.

## 1. A no-go: no Mpemba for the imbalance measure — **`relaxation_ge_distance`**

If "distance from equilibrium" means the history's own imbalance `|level s|`, then relaxation is bounded
**below** by it: `|level s| ≤ maxExcursion s`, because the walk must reach its final level and the
excursion is a maximum over prefixes (`level_le_hmax`). A farther state can never relax faster by that
measure — the effect is *impossible*, not merely unobserved. Any Mpemba claim must therefore use a
distance that is not the imbalance.

## 2. The enabler: a scalar cannot fix the relaxation time — **`equal_length_unequal_relaxation`**

At one length, with identical (zero) imbalance, relaxation ranges over a factor of `n`: the pair matching
`[+−][+−]…` closes in **one** pass (`maxExcursion_pairMatching`) while the nested singlet `[+ⁿ −ⁿ]` needs
**`n`** (`maxExcursion_nested`). So no scalar macrostate variable determines relaxation, and that is
exactly the room an anomalous ordering needs. It is a statement about the substrate, not about water.

## 3. Strong Mpemba, made a sector condition — **`strong_mpemba`**

The spectral statement *"the slow mode has zero amplitude"* becomes a **census** statement: the
preparation has no histories in the deep-excursion sector. If every history of `H` has
`maxExcursion ≤ R` while some history of `C` exceeds `R`, then at capacity `R` the hot preparation has
**fully** closed and the cold one has not — by `closedAtHorizon_iff_maxExcursion_le`, with no appeal to
eigenmodes.

## Honest scope — what this is not

**This does not derive the Mpemba effect, in water or anywhere.** The blind test
([`mpemba_census.py`](../mpemba_census.py)) is explicit: with *uniform* balanced preparations, relaxation
is **monotone** in length and **no** crossing occurs. The anomalous ordering requires a preparation
biased toward the shallow tail — which is the substrate translation of "suppressed slow mode," not an
independent prediction of it. What is proven here is the surrounding structure: one distance measure
provably admits no effect, a scalar provably cannot determine relaxation, and the strong effect is
provably a sector-emptiness condition. No axioms.
-/

namespace QLF.Mpemba

open QLF.HorizonClosure QLF.ClosureDepth QLF.ClosureDepthLaw

/-! ### 1. The no-go: relaxation is bounded below by the imbalance -/

/-- The walk must reach its own final level, so the running maximum dominates it. -/
theorem level_le_hmax : ∀ (c : Int) (s : TopoString), c + level s ≤ hmax c s
  | c, [] => by simp
  | c, x :: t => by
      have ih := level_le_hmax (c + imb x) t
      have h2 := le_max_right c (hmax (c + imb x) t)
      rw [hmax_cons, level_cons]
      have : c + (imb x + level t) = (c + imb x) + level t := by ring
      rw [this]
      exact le_trans ih h2

/-- **No Mpemba effect for the imbalance measure.** If distance from equilibrium is the history's own
    imbalance, relaxation time is bounded **below** by it — so a farther preparation can never relax
    faster by that measure. The effect is impossible there, not merely unobserved. -/
theorem relaxation_ge_distance (s : TopoString) :
    |level s| ≤ ((maxExcursion s : ℕ) : Int) := by
  have hpos : level s ≤ ((maxExcursion s : ℕ) : Int) := by
    have h := level_le_hmax 0 s
    have hm := maxExcursion_eq_hmax s
    have hle := le_max_left (hmax 0 s) (hmax 0 (flip s))
    rw [hm]
    simp only [zero_add] at h
    exact le_trans h hle
  have hneg : -level s ≤ ((maxExcursion s : ℕ) : Int) := by
    have h := level_le_hmax 0 (flip s)
    have hm := maxExcursion_eq_hmax s
    have hle := le_max_right (hmax 0 s) (hmax 0 (flip s))
    rw [hm]
    rw [level_flip] at h
    simp only [zero_add] at h
    exact le_trans h hle
  exact abs_le.mpr ⟨by linarith, hpos⟩

/-! ### 2. The enabler: one length, relaxation differing by a factor of `n` -/

/-- **A scalar cannot determine the relaxation time.** Two preparations of the same length `2n`, both
    of imbalance `0`, whose relaxation differs by a factor of `n`: the pair matching closes in one pass,
    the nested singlet needs `n`. This is the structural room an anomalous ordering requires. -/
theorem equal_length_unequal_relaxation (n : ℕ) (hn : 0 < n) (bs : List Bool)
    (hbs : bs.length = n) (hne : bs ≠ []) :
    (pairMatching bs).length = (nested n).length ∧
      maxExcursion (pairMatching bs) = 1 ∧ maxExcursion (nested n) = n := by
  refine ⟨?_, maxExcursion_pairMatching bs hne, maxExcursion_nested n⟩
  rw [pairMatching_length, hbs]
  simp [nested, poss, negs]
  omega

/-- The same statement as an ordering: at equal length the nested preparation relaxes strictly slower
    once `n > 1`, though neither is farther from balance than the other. -/
theorem nested_relaxes_slower (n : ℕ) (hn : 1 < n) (bs : List Bool)
    (hbs : bs.length = n) (hne : bs ≠ []) :
    maxExcursion (pairMatching bs) < maxExcursion (nested n) := by
  rw [maxExcursion_pairMatching bs hne, maxExcursion_nested n]
  exact hn

/-! ### 2a. A concrete instance — the effect exhibited, with energy as the distance

The imbalance measure is closed off by §1, so a legitimate instance must use a different distance. Take
**energy** — the number of twists, i.e. the length: the amount of structure that has to be cancelled.
Then instances exist, unboundedly, and they are provable. -/

/-- A pair matching is balanced: each pair contributes nothing to the imbalance. -/
theorem level_pairMatching : ∀ bs : List Bool, level (pairMatching bs) = 0
  | [] => rfl
  | b :: bs => by
      have h : pairMatching (b :: bs) = pairOf b ++ pairMatching bs := rfl
      rw [h, level_append, level_pairMatching bs]
      cases b <;> simp [pairOf, level_cons_pos, level_cons_neg]

/-- The length of a nested fold is twice its depth. -/
theorem nested_length (d : ℕ) : (nested d).length = 2 * d := by
  simp [nested, poss, negs]
  omega

/-- **A Mpemba instance, and an unbounded family of them.** For every depth `d > 1` and every `n > d`
    there are two balanced preparations — closing to the *same* equilibrium — such that the one with
    strictly **more energy** closes strictly **faster**, by a factor of `d`:

    * hot: the pair matching of `n` pairs — length `2n`, closes in **one** pass;
    * cold: the nested fold `[+^d −^d]` — length `2d < 2n`, needs **`d`** passes.

    So with energy as the distance from equilibrium, the effect is not merely permitted but exhibited,
    with an arbitrarily large speed ratio. (Whether *energy* is an admissible distance measure is exactly
    the question thermomajorization asks of the ordinary effect; §1 shows the *imbalance* measure admits
    no instance at all.) -/
theorem mpemba_instance (n d : ℕ) (hd : 1 < d) (hdn : d < n) :
    ∃ H C : TopoString,
      C.length < H.length ∧ level H = 0 ∧ level C = 0 ∧
      maxExcursion H = 1 ∧ maxExcursion C = d := by
  refine ⟨pairMatching (List.replicate n true), nested d, ?_, level_pairMatching _,
    level_nested d, ?_, maxExcursion_nested d⟩
  · rw [nested_length, pairMatching_length, List.length_replicate]
    omega
  · exact maxExcursion_pairMatching _ (by simp [List.replicate_eq_nil_iff]; omega)

/-- The same instance stated as the anomalous ordering itself: more energy, strictly faster closure. -/
theorem mpemba_ordering (n d : ℕ) (hd : 1 < d) (hdn : d < n) :
    ∃ H C : TopoString,
      C.length < H.length ∧ maxExcursion H < maxExcursion C := by
  obtain ⟨H, C, hlen, _, _, hH, hC⟩ := mpemba_instance n d hd hdn
  exact ⟨H, C, hlen, by rw [hH, hC]; omega⟩

/-! ### 3. Strong Mpemba as a sector-emptiness condition -/

/-- **Strong Mpemba, without eigenmodes.** If every history of the preparation `H` stays within
    excursion `R` while some history of `C` exceeds it, then at capacity `R` the `H` preparation has
    **fully closed** and `C` has not. The spectral "slow mode has zero amplitude" becomes "the deep
    sector is empty". -/
theorem strong_mpemba (R : ℕ) (H C : List TopoString)
    (hHng : ∀ s ∈ H, NoGauge s) (hHbal : ∀ s ∈ H, level s = 0)
    (hCng : ∀ s ∈ C, NoGauge s) (hCbal : ∀ s ∈ C, level s = 0)
    (hH : ∀ s ∈ H, maxExcursion s ≤ R)
    (hC : ∃ s ∈ C, R < maxExcursion s) :
    (∀ s ∈ H, closedAtHorizon R s) ∧ (∃ s ∈ C, ¬ closedAtHorizon R s) := by
  refine ⟨fun s hs => ?_, ?_⟩
  · exact (closedAtHorizon_iff_maxExcursion_le (hHng s hs) (hHbal s hs) R).mpr (hH s hs)
  · obtain ⟨s, hs, hlt⟩ := hC
    refine ⟨s, hs, fun hclosed => ?_⟩
    have := (closedAtHorizon_iff_maxExcursion_le (hCng s hs) (hCbal s hs) R).mp hclosed
    omega

/-- **Established constructively, no axioms.** Three decidable statements about anomalous relaxation,
    which do not all point the same way. **A no-go:** if distance from equilibrium is the imbalance,
    relaxation is bounded below by it (`relaxation_ge_distance`, via `level_le_hmax`) — the effect is
    *impossible* for that measure, so any Mpemba claim must use another. **An enabler:** no scalar fixes
    the relaxation time — at one length and equal imbalance, the pair matching closes in one pass and
    the nested singlet needs `n` (`equal_length_unequal_relaxation`, `nested_relaxes_slower`), which is
    the room an anomalous ordering needs. **A translation:** strong Mpemba is sector emptiness rather
    than a vanishing eigenmode amplitude (`strong_mpemba`). **An instance:** with **energy** as the distance
    (the imbalance being closed off), the effect is exhibited and unbounded — `mpemba_instance` /
    `mpemba_ordering` give, for every `d > 1` and `n > d`, two balanced preparations closing to the same
    equilibrium where the one with `2n` twists closes in **one** pass and the one with `2d < 2n` needs
    **`d`**. Uniform draws cross too, 13–17% of the time at a 2× energy ratio
    ([`mpemba_census.py`](../mpemba_census.py)). **Still not delivered:** the *ensemble* effect — median
    relaxation is monotone in energy, so the crossing is between individual preparations rather than a
    property of the uniform ensemble, and whether energy is an admissible distance is the question
    thermomajorization asks of the ordinary effect. -/
theorem mpemba_summary : True := trivial

end QLF.Mpemba

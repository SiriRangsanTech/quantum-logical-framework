import QLF_ClosureDepth

set_option linter.unusedVariables false

/-!
# QLF_ClosureDepthLaw — the depth law, closed: closure depth IS the maximum phase excess

`QLF_ClosureDepth` left one step open (`closure_depth_law_in_progress`): the closed form for how many
pruning passes a history needs. This module proves it, and with it the sharp characterization of what a
finite-capacity horizon can close:

> **`closedAtHorizon_iff_maxExcursion_le`** — for a gauge-free, count-balanced history,
> `boundedPrune R s = []` **iff** `maxExcursion s ≤ R`.

A finite closure admits exactly the histories whose phase walk **never strays further than `R` from
balance**. Capacity is a bound on excursion, not on length — which is why `QLF_LawOfExceptions` can
always break a finite closure with one more shell, and why capacity `R` buys length `~R²` rather than
`~2^R` (the walk's maximum is `√(πn/2)` on average).

## Why the obvious statement had to be generalized

The per-pass claim `maxExcursion (zeno_prune s) + 1 = maxExcursion s` does **not** generalize over an
accumulator: starting the walk at `c`, the maximum can be attained at the boundary `c` itself, which no
pass removes (`exc 5 [−,+] = 5 = exc 5 []`), so the drop is `0`. And it is outright **false** when gauge
elements are present: `[+, gauge, −]` is count-balanced yet prune-fixed, since `zeno_prune` cancels only
*adjacent* opposite phases. Hence the hypotheses `NoGauge` and `level s = 0`.

What *does* generalize is the **signed** height with an arbitrary accumulator
(`hmax_zeno_prune`, the load-bearing lemma):

```
hmax c (zeno_prune s) = max (hmax c s − 1) (max c (c + level s))
```

for **every** `s`, balanced or not — and the unbalanced case is exactly what the induction needs, because
the emit step (`+ + …`) hands the recursion an unbalanced tail. The boundary term `max c (c + level s)`
is what the naive statement was missing.

## Structure of the proof

1. **`hmax_zeno_prune`** — the invariant above, by recursion on `zeno_prune`'s own case structure. The
   two cancel cases lose the peak; the two emit cases pass to the tail with a shifted accumulator, where
   `hmax_pos_cons` (`c+1 ≤ hmax c (+ :: t)`) supplies the bound that makes the boundary terms agree.
   *Mathematically* this is the statement that greedy leftmost cancellation removes **every** attainment
   of the extreme level: an attainment at level `M` is a peak `(+,−)`, and it could only be skipped by
   being the second element of an earlier pair, which would force level `M+1` — impossible.
2. **`zeno_prune_flip`** — pruning commutes with swapping `+↔−`, so the negative extreme needs no
   separate argument.
3. **`exc_eq_hmax`** — `|walk|`-maximum splits into the two signed heights:
   `(exc c s : ℤ) = max (hmax c s) (hmax (−c) (flip s))`.
4. **`per_pass`** — combining: for gauge-free, balanced, non-empty `s`,
   `maxExcursion (zeno_prune s) + 1 = maxExcursion s`. Balance kills the boundary term
   (`level s = 0`), leaving `max (M − 1) 0`.
5. **`maxExcursion_boundedPrune`** — `maxExcursion (boundedPrune k s) = maxExcursion s − k`, carrying
   balance (`level_zeno_prune`) and gauge-freeness (`noGauge_zeno_prune`) through the passes.
6. **`closedAtHorizon_iff_maxExcursion_le`** — the characterization, and
   `closureDepth_eq_maxExcursion`: the exact number of passes is the maximum excess.

## Consequences recovered

`maxExcursion_nested` (`[+^d −^d]` has maximum excess `d`) now **derives** `QLF_ClosureDepth`'s
`nested_closed_at_d` / `nested_not_closed_before` rather than being checked alongside them, and
`maxExcursion_pairMatching` (`= 1`) is the `d = 1` stratum whose `2ⁿ` count gives `log 2` per closure.
No axioms; the empirical check (0 counterexamples over all 66,196 balanced histories of length ≤ 18) is
now a theorem.
-/

namespace QLF.ClosureDepthLaw

open QLF.HorizonClosure QLF.ClosureDepth

/-! ### The signed walk -/

/-- The total imbalance of a history (the walk's final level). -/
def level : TopoString → Int
  | [] => 0
  | h :: t => imb h + level t

/-- `hmax c s` — the **maximum signed level** over all prefixes of `s`, walking from `c` (the empty
    prefix included, so `hmax c s ≥ c`). -/
def hmax : Int → TopoString → Int
  | c, [] => c
  | c, h :: t => max c (hmax (c + imb h) t)

/-- Swap `+` and `−`, fixing gauges — the mirror that exchanges the two signed extremes. -/
def flipEl : TopoElement → TopoElement
  | TopoElement.phase LogicPhase.pos => TopoElement.phase LogicPhase.neg
  | TopoElement.phase LogicPhase.neg => TopoElement.phase LogicPhase.pos
  | TopoElement.gauge => TopoElement.gauge

/-- The mirrored history. -/
def flip (s : TopoString) : TopoString := s.map flipEl

/-- Gauge-free: every element is a phase. `zeno_prune` cancels only adjacent opposite **phases**, so a
    gauge blocks cancellation (`[+, gauge, −]` is prune-fixed) and the depth law needs this. -/
def NoGauge (s : TopoString) : Prop := TopoElement.gauge ∉ s

/-! ### Basic algebra of the walk -/

theorem hmax_cons (c : Int) (x : TopoElement) (t : TopoString) :
    hmax c (x :: t) = max c (hmax (c + imb x) t) := rfl

theorem level_cons (x : TopoElement) (t : TopoString) : level (x :: t) = imb x + level t := rfl

/-- The empty prefix is always a candidate, so the running maximum never drops below the start. -/
theorem hmax_ge : ∀ (c : Int) (s : TopoString), c ≤ hmax c s
  | c, [] => le_refl c
  | c, x :: t => by rw [hmax_cons]; exact le_max_left _ _

/-- A leading `+` pushes the maximum at least one above the start. -/
theorem hmax_pos_cons (c : Int) (t : TopoString) :
    c + 1 ≤ hmax c (TopoElement.phase LogicPhase.pos :: t) := by
  rw [hmax_cons]
  have h := hmax_ge (c + imb (TopoElement.phase LogicPhase.pos)) t
  have hi : imb (TopoElement.phase LogicPhase.pos) = 1 := rfl
  rw [hi] at h
  have := le_max_right c (hmax (c + imb (TopoElement.phase LogicPhase.pos)) t)
  rw [hi] at this
  omega

theorem noGauge_tail {x : TopoElement} {t : TopoString} (h : NoGauge (x :: t)) : NoGauge t :=
  fun hm => h (List.Mem.tail _ hm)

/-! ### The load-bearing lemma

`hmax c (zeno_prune s) = max (hmax c s − 1) (max c (c + level s))`, for **every** `s` — the unbalanced
case included, since the emit step hands the recursion an unbalanced tail. -/

theorem hmax_zeno_prune : ∀ (s : TopoString), NoGauge s → ∀ c : Int,
    hmax c (zeno_prune s) = max (hmax c s - 1) (max c (c + level s))
  | [], _, c => by
      simp only [zeno_prune, hmax, level]
      omega
  | [x], hng, c => by
      cases x with
      | gauge => exact absurd (List.Mem.head _) hng
      | phase p =>
          cases p <;>
            simp only [zeno_prune, hmax, level, imb] <;>
            norm_num <;>
            omega
  | a :: b :: t, hng, c => by
      have hngt : NoGauge t := noGauge_tail (noGauge_tail hng)
      have hngbt : NoGauge (b :: t) := noGauge_tail hng
      match a, b with
      | TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.neg =>
          -- cancel: the peak is removed, and the tail is reached with the same accumulator
          have ih := hmax_zeno_prune t hngt c
          have hge := hmax_ge c t
          have hz : zeno_prune (TopoElement.phase LogicPhase.pos ::
              TopoElement.phase LogicPhase.neg :: t) = zeno_prune t := by
            simp only [zeno_prune]
          rw [hz, ih, hmax_cons, hmax_cons, level_cons, level_cons]
          have h1 : imb (TopoElement.phase LogicPhase.pos) = 1 := rfl
          have h2 : imb (TopoElement.phase LogicPhase.neg) = -1 := rfl
          rw [h1, h2]
          have harg : c + 1 + -1 = c := by ring
          rw [harg]
          omega
      | TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.pos =>
          have ih := hmax_zeno_prune t hngt c
          have hge := hmax_ge c t
          have hz : zeno_prune (TopoElement.phase LogicPhase.neg ::
              TopoElement.phase LogicPhase.pos :: t) = zeno_prune t := by
            simp only [zeno_prune]
          rw [hz, ih, hmax_cons, hmax_cons, level_cons, level_cons]
          have h1 : imb (TopoElement.phase LogicPhase.pos) = 1 := rfl
          have h2 : imb (TopoElement.phase LogicPhase.neg) = -1 := rfl
          rw [h1, h2]
          have harg : c + -1 + 1 = c := by ring
          rw [harg]
          omega
      | TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.pos =>
          -- emit: recurse on the tail with the accumulator raised; `hmax_pos_cons` bounds it
          have ih := hmax_zeno_prune (TopoElement.phase LogicPhase.pos :: t) hngbt
            (c + imb (TopoElement.phase LogicPhase.pos))
          have hb := hmax_pos_cons (c + imb (TopoElement.phase LogicPhase.pos)) t
          have hz : zeno_prune (TopoElement.phase LogicPhase.pos ::
              TopoElement.phase LogicPhase.pos :: t)
              = TopoElement.phase LogicPhase.pos ::
                zeno_prune (TopoElement.phase LogicPhase.pos :: t) := by
            simp only [zeno_prune]
          rw [hz, hmax_cons, ih, hmax_cons, level_cons]
          have h1 : imb (TopoElement.phase LogicPhase.pos) = 1 := rfl
          rw [h1] at *
          omega
      | TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.neg =>
          have ih := hmax_zeno_prune (TopoElement.phase LogicPhase.neg :: t) hngbt
            (c + imb (TopoElement.phase LogicPhase.neg))
          have hb := hmax_ge (c + imb (TopoElement.phase LogicPhase.neg))
            (TopoElement.phase LogicPhase.neg :: t)
          have hz : zeno_prune (TopoElement.phase LogicPhase.neg ::
              TopoElement.phase LogicPhase.neg :: t)
              = TopoElement.phase LogicPhase.neg ::
                zeno_prune (TopoElement.phase LogicPhase.neg :: t) := by
            simp only [zeno_prune]
          rw [hz, hmax_cons, ih, hmax_cons, level_cons]
          have h2 : imb (TopoElement.phase LogicPhase.neg) = -1 := rfl
          rw [h2] at *
          omega
      | TopoElement.phase LogicPhase.pos, TopoElement.gauge =>
          exact absurd (List.Mem.tail _ (List.Mem.head _)) hng
      | TopoElement.phase LogicPhase.neg, TopoElement.gauge =>
          exact absurd (List.Mem.tail _ (List.Mem.head _)) hng
      | TopoElement.gauge, _ =>
          exact absurd (List.Mem.head _) hng

/-! ### The mirror: pruning commutes with swapping `+ ↔ −` -/

theorem imb_flipEl (x : TopoElement) : imb (flipEl x) = - imb x := by
  cases x with
  | gauge => rfl
  | phase p => cases p <;> rfl

theorem flip_cons (x : TopoElement) (t : TopoString) : flip (x :: t) = flipEl x :: flip t := rfl

theorem level_flip : ∀ s : TopoString, level (flip s) = - level s
  | [] => rfl
  | x :: t => by
      rw [flip_cons, level_cons, level_cons, level_flip t, imb_flipEl]
      ring

theorem noGauge_flip : ∀ s : TopoString, NoGauge s → NoGauge (flip s)
  | [], _ => by simp [NoGauge, flip]
  | x :: t, hng => by
      have ht := noGauge_flip t (noGauge_tail hng)
      cases x with
      | gauge => exact absurd (List.Mem.head _) hng
      | phase p =>
          cases p <;>
            (rw [flip_cons]; simp only [flipEl]; intro hm;
             rcases List.mem_cons.mp hm with h | h
             · exact absurd h (by simp)
             · exact ht h)

theorem zeno_prune_flip : ∀ s : TopoString, zeno_prune (flip s) = flip (zeno_prune s)
  | [] => rfl
  | [x] => by
      cases x with
      | gauge => simp [flip, flipEl, zeno_prune]
      | phase p => cases p <;> simp [flip, flipEl, zeno_prune]
  | a :: b :: t => by
      match a, b with
      | TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.neg =>
          rw [flip_cons, flip_cons]
          simp only [flipEl, zeno_prune]
          exact zeno_prune_flip t
      | TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.pos =>
          rw [flip_cons, flip_cons]
          simp only [flipEl, zeno_prune]
          exact zeno_prune_flip t
      | TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.pos =>
          rw [flip_cons, flip_cons]
          simp only [flipEl, zeno_prune]
          rw [← flip_cons, zeno_prune_flip (TopoElement.phase LogicPhase.pos :: t)]
          rfl
      | TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.neg =>
          rw [flip_cons, flip_cons]
          simp only [flipEl, zeno_prune]
          rw [← flip_cons, zeno_prune_flip (TopoElement.phase LogicPhase.neg :: t)]
          rfl
      | TopoElement.phase LogicPhase.pos, TopoElement.gauge =>
          rw [flip_cons, flip_cons]
          simp only [flipEl, zeno_prune]
          rw [← flip_cons, zeno_prune_flip (TopoElement.gauge :: t)]
          rfl
      | TopoElement.phase LogicPhase.neg, TopoElement.gauge =>
          rw [flip_cons, flip_cons]
          simp only [flipEl, zeno_prune]
          rw [← flip_cons, zeno_prune_flip (TopoElement.gauge :: t)]
          rfl
      | TopoElement.gauge, b =>
          rw [flip_cons]
          simp only [flipEl, zeno_prune]
          rw [zeno_prune_flip (b :: t), flip_cons]

/-! ### `|walk|` splits into the two signed heights -/

theorem exc_eq_hmax : ∀ (c : Int) (s : TopoString),
    ((exc c s : ℕ) : Int) = max (hmax c s) (hmax (-c) (flip s))
  | c, [] => by
      simp only [exc, hmax, flip, List.map_nil]
      omega
  | c, x :: t => by
      have ih := exc_eq_hmax (c + imb x) t
      have hfl : (-c) + imb (flipEl x) = -(c + imb x) := by
        rw [imb_flipEl]; ring
      simp only [exc, flip_cons, hmax_cons]
      rw [hfl]
      have hcast : ((max (Int.natAbs c) (exc (c + imb x) t) : ℕ) : Int)
          = max ((Int.natAbs c : Int)) ((exc (c + imb x) t : ℕ) : Int) := by
        push_cast
        rfl
      rw [hcast, ih]
      have habs : ((Int.natAbs c : Int)) = max c (-c) := by omega
      rw [habs]
      have h1 := hmax_ge (c + imb x) t
      have h2 := hmax_ge (-(c + imb x)) (flip t)
      omega

/-- The maximum excess is the larger of the two signed heights. -/
theorem maxExcursion_eq_hmax (s : TopoString) :
    ((maxExcursion s : ℕ) : Int) = max (hmax 0 s) (hmax 0 (flip s)) := by
  have h := exc_eq_hmax 0 s
  simpa [maxExcursion] using h

/-! ### Invariants carried through a pass -/

theorem level_zeno_prune : ∀ s : TopoString, level (zeno_prune s) = level s
  | [] => rfl
  | [x] => rfl
  | a :: b :: t => by
      match a, b with
      | TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.neg =>
          simp only [zeno_prune, level_cons, imb]
          rw [level_zeno_prune t]; ring
      | TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.pos =>
          simp only [zeno_prune, level_cons, imb]
          rw [level_zeno_prune t]; ring
      | TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.pos =>
          simp only [zeno_prune, level_cons]
          rw [level_zeno_prune (TopoElement.phase LogicPhase.pos :: t), level_cons]
      | TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.neg =>
          simp only [zeno_prune, level_cons]
          rw [level_zeno_prune (TopoElement.phase LogicPhase.neg :: t), level_cons]
      | TopoElement.phase LogicPhase.pos, TopoElement.gauge =>
          simp only [zeno_prune, level_cons]
          rw [level_zeno_prune (TopoElement.gauge :: t), level_cons]
      | TopoElement.phase LogicPhase.neg, TopoElement.gauge =>
          simp only [zeno_prune, level_cons]
          rw [level_zeno_prune (TopoElement.gauge :: t), level_cons]
      | TopoElement.gauge, b =>
          simp only [zeno_prune, level_cons]
          rw [level_zeno_prune (b :: t)]

theorem noGauge_zeno_prune : ∀ s : TopoString, NoGauge s → NoGauge (zeno_prune s)
  | [], _ => by simp [NoGauge, zeno_prune]
  | [x], hng => by
      cases x with
      | gauge => exact absurd (List.Mem.head _) hng
      | phase p => cases p <;> simpa [zeno_prune] using hng
  | a :: b :: t, hng => by
      have hngt : NoGauge t := noGauge_tail (noGauge_tail hng)
      have hngbt : NoGauge (b :: t) := noGauge_tail hng
      match a, b with
      | TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.neg =>
          simp only [zeno_prune]; exact noGauge_zeno_prune t hngt
      | TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.pos =>
          simp only [zeno_prune]; exact noGauge_zeno_prune t hngt
      | TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.pos =>
          have h := noGauge_zeno_prune (TopoElement.phase LogicPhase.pos :: t) hngbt
          simp only [zeno_prune]
          intro hm
          rcases List.mem_cons.mp hm with hh | hh
          · exact absurd hh (by simp)
          · exact h hh
      | TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.neg =>
          have h := noGauge_zeno_prune (TopoElement.phase LogicPhase.neg :: t) hngbt
          simp only [zeno_prune]
          intro hm
          rcases List.mem_cons.mp hm with hh | hh
          · exact absurd hh (by simp)
          · exact h hh
      | TopoElement.phase LogicPhase.pos, TopoElement.gauge =>
          exact absurd (List.Mem.tail _ (List.Mem.head _)) hng
      | TopoElement.phase LogicPhase.neg, TopoElement.gauge =>
          exact absurd (List.Mem.tail _ (List.Mem.head _)) hng
      | TopoElement.gauge, _ =>
          exact absurd (List.Mem.head _) hng

/-! ### The per-pass lemma and the depth law -/

/-- A non-empty gauge-free history has a non-zero excess (its first step already leaves `0`). -/
theorem maxExcursion_pos {s : TopoString} (hng : NoGauge s) (hs : s ≠ []) : 1 ≤ maxExcursion s := by
  cases s with
  | nil => exact absurd rfl hs
  | cons x t =>
      have h := maxExcursion_eq_hmax (x :: t)
      cases x with
      | gauge => exact absurd (List.Mem.head _) hng
      | phase p =>
          cases p
          · -- `+` : the positive height already reaches 1
            have hb := hmax_pos_cons 0 t
            rw [hmax_cons] at h
            have h1 : imb (TopoElement.phase LogicPhase.pos) = 1 := rfl
            rw [hmax_cons, h1] at hb
            omega
          · -- `−` : the mirrored history leads with `+`
            have hb := hmax_pos_cons 0 (flip t)
            have hfe : flipEl (TopoElement.phase LogicPhase.neg)
                = TopoElement.phase LogicPhase.pos := rfl
            rw [flip_cons, hfe] at h
            rw [hmax_cons] at hb
            have h1 : imb (TopoElement.phase LogicPhase.pos) = 1 := rfl
            rw [h1] at hb
            have hge := hmax_ge 0 (TopoElement.phase LogicPhase.neg :: t)
            rw [hmax_cons] at h
            omega

/-- **The per-pass lemma.** One pass drops the maximum excess by exactly one: for a gauge-free,
    count-balanced, non-empty history,

      `maxExcursion (zeno_prune s) + 1 = maxExcursion s`.

    Balance is what kills the boundary term of `hmax_zeno_prune`; gauge-freeness is what guarantees a
    cancellation happens at all. -/
theorem per_pass {s : TopoString} (hng : NoGauge s) (hbal : level s = 0) (hs : s ≠ []) :
    maxExcursion (zeno_prune s) + 1 = maxExcursion s := by
  have hM : 1 ≤ maxExcursion s := maxExcursion_pos hng hs
  have hp := hmax_zeno_prune s hng 0
  have hf := hmax_zeno_prune (flip s) (noGauge_flip s hng) 0
  have hfl : level (flip s) = 0 := by rw [level_flip, hbal]; ring
  rw [hbal] at hp
  rw [hfl] at hf
  have hpr := maxExcursion_eq_hmax (zeno_prune s)
  have hs' := maxExcursion_eq_hmax s
  rw [← zeno_prune_flip s] at hpr
  have h0a := hmax_ge 0 s
  have h0b := hmax_ge 0 (flip s)
  rw [hp, hf] at hpr
  omega

/-- Each pass peels one unit of excess: `maxExcursion (boundedPrune k s) = maxExcursion s − k`. -/
theorem maxExcursion_boundedPrune {s : TopoString} (hng : NoGauge s) (hbal : level s = 0) :
    ∀ k : ℕ, maxExcursion (boundedPrune k s) = maxExcursion s - k := by
  intro k
  induction k with
  | zero => simp [boundedPrune]
  | succ m ih =>
      have hngm : NoGauge (boundedPrune m s) := by
        induction m with
        | zero => simpa [boundedPrune] using hng
        | succ j ihj =>
            show NoGauge (zeno_prune (boundedPrune j s))
            exact noGauge_zeno_prune _ ihj
      have hbalm : level (boundedPrune m s) = 0 := by
        induction m with
        | zero => simpa [boundedPrune] using hbal
        | succ j ihj =>
            show level (zeno_prune (boundedPrune j s)) = 0
            rw [level_zeno_prune]; exact ihj
      show maxExcursion (zeno_prune (boundedPrune m s)) = maxExcursion s - (m + 1)
      by_cases hnil : boundedPrune m s = []
      · rw [hnil]
        simp only [zeno_prune, maxExcursion, exc]
        rw [hnil] at ih
        simp only [maxExcursion, exc] at ih
        omega
      · have h := per_pass hngm hbalm hnil
        omega

/-- **The depth law.** A finite-capacity horizon closes exactly the histories whose phase walk never
    strays further than `R` from balance:

      `closedAtHorizon R s ↔ maxExcursion s ≤ R`.

    Capacity bounds **excursion**, not length. -/
theorem closedAtHorizon_iff_maxExcursion_le {s : TopoString}
    (hng : NoGauge s) (hbal : level s = 0) (R : ℕ) :
    closedAtHorizon R s ↔ maxExcursion s ≤ R := by
  have hk := maxExcursion_boundedPrune hng hbal R
  have hngR : NoGauge (boundedPrune R s) := by
    induction R with
    | zero => simpa [boundedPrune] using hng
    | succ j ihj =>
        show NoGauge (zeno_prune (boundedPrune j s))
        exact noGauge_zeno_prune _ ihj
  constructor
  · intro hclosed
    unfold closedAtHorizon at hclosed
    rw [hclosed] at hk
    simp only [maxExcursion, exc] at hk
    omega
  · intro hle
    unfold closedAtHorizon
    have h0 : maxExcursion (boundedPrune R s) = 0 := by omega
    by_contra hne
    have := maxExcursion_pos hngR hne
    omega

/-- **The number of passes IS the maximum excess.** The horizon that closes `s` and no smaller one:
    `maxExcursion s` passes suffice and `maxExcursion s − 1` do not. -/
theorem closureDepth_eq_maxExcursion {s : TopoString} (hng : NoGauge s) (hbal : level s = 0) :
    closedAtHorizon (maxExcursion s) s ∧
      ∀ k : ℕ, k < maxExcursion s → ¬ closedAtHorizon k s := by
  refine ⟨(closedAtHorizon_iff_maxExcursion_le hng hbal _).mpr (le_refl _), ?_⟩
  intro k hk hclosed
  have := (closedAtHorizon_iff_maxExcursion_le hng hbal k).mp hclosed
  omega

/-! ### The nested folds, now derived -/

theorem level_append : ∀ a b : TopoString, level (a ++ b) = level a + level b
  | [], b => by simp [level]
  | x :: t, b => by
      rw [List.cons_append, level_cons, level_cons, level_append t b]
      ring

theorem level_poss : ∀ n : ℕ, level (poss n) = (n : Int)
  | 0 => by simp [poss, level]
  | n + 1 => by
      have h : poss (n + 1) = TopoElement.phase LogicPhase.pos :: poss n := by
        simp [poss, List.replicate_succ]
      rw [h, level_cons, level_poss n]
      have : imb (TopoElement.phase LogicPhase.pos) = 1 := rfl
      rw [this]
      push_cast
      ring

theorem level_negs : ∀ n : ℕ, level (negs n) = -(n : Int)
  | 0 => by simp [negs, level]
  | n + 1 => by
      have h : negs (n + 1) = TopoElement.phase LogicPhase.neg :: negs n := by
        simp [negs, List.replicate_succ]
      rw [h, level_cons, level_negs n]
      have : imb (TopoElement.phase LogicPhase.neg) = -1 := rfl
      rw [this]
      push_cast
      ring

theorem level_nested (d : ℕ) : level (nested d) = 0 := by
  unfold nested
  rw [level_append, level_poss, level_negs]
  ring

theorem noGauge_nested (d : ℕ) : NoGauge (nested d) := by
  unfold NoGauge nested poss negs
  intro hm
  rcases List.mem_append.mp hm with h | h
  · exact absurd (List.eq_of_mem_replicate h) (by simp)
  · exact absurd (List.eq_of_mem_replicate h) (by simp)

/-- **The nested fold's excess is its depth** — so `QLF_ClosureDepth`'s `nested_closed_at_d` and
    `nested_not_closed_before` are now *consequences* of the depth law rather than separate facts. -/
theorem maxExcursion_nested (d : ℕ) : maxExcursion (nested d) = d := by
  have h1 := (closedAtHorizon_iff_maxExcursion_le (noGauge_nested d) (level_nested d) d).mp
    (nested_closed_at_d d)
  by_cases hd : d = 0
  · subst hd
    simp only [nested, poss, negs] at *
    omega
  · obtain ⟨j, hj⟩ : ∃ j, d = j + 1 := ⟨d - 1, by omega⟩
    have h2 := nested_not_closed_before d j (by omega)
    have h3 := (closedAtHorizon_iff_maxExcursion_le (noGauge_nested d) (level_nested d) j).mpr
    omega

/-- **Established constructively:** the depth law, with no axiom. `hmax_zeno_prune` is the
    generalization that makes the induction go through — the signed height with an arbitrary
    accumulator, valid for unbalanced histories too, which is exactly what the emit step needs. From it
    `per_pass` (one pass drops the maximum excess by exactly one, for gauge-free balanced non-empty
    histories), `maxExcursion_boundedPrune`, and the characterization
    `closedAtHorizon_iff_maxExcursion_le`: **a finite-capacity horizon closes exactly the histories
    whose phase walk never strays further than `R` from balance** — capacity bounds excursion, not
    length. `closureDepth_eq_maxExcursion` gives the exact pass count, and `maxExcursion_nested`
    re-derives the nested-fold witnesses of `QLF_ClosureDepth` / `QLF_LawOfExceptions`. The hypotheses
    are both necessary: gauge-freeness because `[+, gauge, −]` is prune-fixed, balance because the
    boundary term of `hmax_zeno_prune` survives otherwise. This closes
    `QLF_ClosureDepth.closure_depth_law_in_progress`. -/
theorem closure_depth_law_complete : True := trivial

end QLF.ClosureDepthLaw

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
balance**. Capacity is a bound on *excursion*, not on length — which is why `QLF_LawOfExceptions` can
always break a finite closure with one more shell, and why capacity `R` buys length `~R²` (a balanced
walk's mean maximum is `√(πn/2)`) rather than `~2^R`.

## Why the obvious statement had to be generalized

The per-pass claim `maxExcursion (zeno_prune s) + 1 = maxExcursion s` does **not** generalize over an
accumulator: starting the walk at `c`, the maximum may be attained at the boundary `c` itself, which no
pass removes (`exc 5 [−,+] = 5 = exc 5 []`), so the drop is `0`. And it is outright **false** when gauge
elements are present: `[+, gauge, −]` is count-balanced yet prune-fixed, because `zeno_prune` cancels
only *adjacent* opposite phases. Hence the hypotheses `NoGauge` and `level s = 0`; both are necessary.

What *does* generalize is the **signed** height with an arbitrary accumulator — `hmax_zeno_prune`:

```
hmax c (zeno_prune s) = max (hmax c s − 1) (max c (c + level s))
```

for **every** `s`, balanced or not. The unbalanced case is exactly what the induction needs, because the
emit step (`+ + …`) hands the recursion an unbalanced tail, and the boundary term `max c (c + level s)`
is what the naive statement was missing.

*Mathematically* the content is that greedy leftmost cancellation removes **every** attainment of the
extreme level: an attainment at level `M` is a peak `(+,−)`, and it could only be skipped by being the
second element of an earlier pair, which would force level `M+1` — impossible for a maximum.

## Structure

1. **`hmax_zeno_prune`** — the invariant, by recursion on `zeno_prune`'s own case structure.
2. **`zeno_prune_flip`** — pruning commutes with swapping `+↔−`, so the negative extreme needs no
   separate argument.
3. **`exc_eq_hmax`** — `|walk|`-maximum splits into the two signed heights.
4. **`per_pass`** — one pass drops the maximum excess by exactly one.
5. **`maxExcursion_boundedPrune`** — `k` passes drop it by `k`, carrying balance and gauge-freeness.
6. **`closedAtHorizon_iff_maxExcursion_le`**, **`closureDepth_eq_maxExcursion`** — the law, and the
   exact pass count. `maxExcursion_nested` then *derives* `QLF_ClosureDepth`'s nested-fold witnesses.

No axioms. The empirical check (0 counterexamples over all 66,196 balanced histories of length ≤ 18) is
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

/-- Swap `+` and `−`, fixing gauges — the mirror exchanging the two signed extremes. -/
def flipEl : TopoElement → TopoElement
  | TopoElement.phase LogicPhase.pos => TopoElement.phase LogicPhase.neg
  | TopoElement.phase LogicPhase.neg => TopoElement.phase LogicPhase.pos
  | TopoElement.gauge => TopoElement.gauge

/-- The mirrored history. -/
def flip (s : TopoString) : TopoString := s.map flipEl

/-- Gauge-free: every element is a phase. `zeno_prune` cancels only adjacent opposite **phases**, so a
    gauge blocks cancellation (`[+, gauge, −]` is prune-fixed) and the law needs this. -/
def NoGauge (s : TopoString) : Prop := TopoElement.gauge ∉ s

/-! ### Normalized unfolding lemmas

Every accumulator is kept in the syntactic form `c + 1` / `c - 1` so that arithmetic atoms match. -/

theorem hmax_cons (c : Int) (x : TopoElement) (t : TopoString) :
    hmax c (x :: t) = max c (hmax (c + imb x) t) := rfl

theorem level_cons (x : TopoElement) (t : TopoString) : level (x :: t) = imb x + level t := rfl

@[simp] theorem hmax_cons_pos (c : Int) (t : TopoString) :
    hmax c (TopoElement.phase LogicPhase.pos :: t) = max c (hmax (c + 1) t) := by
  have h : c + imb (TopoElement.phase LogicPhase.pos) = c + 1 := by simp [imb]
  rw [hmax_cons, h]

@[simp] theorem hmax_cons_neg (c : Int) (t : TopoString) :
    hmax c (TopoElement.phase LogicPhase.neg :: t) = max c (hmax (c - 1) t) := by
  have h : c + imb (TopoElement.phase LogicPhase.neg) = c - 1 := by simp [imb]; ring
  rw [hmax_cons, h]

@[simp] theorem level_cons_pos (t : TopoString) : level (TopoElement.phase LogicPhase.pos :: t) = level t + 1 := by
  rw [level_cons]; simp [imb]; ring

@[simp] theorem level_cons_neg (t : TopoString) : level (TopoElement.phase LogicPhase.neg :: t) = level t - 1 := by
  rw [level_cons]; simp [imb]; ring

@[simp] theorem level_cons_gauge (t : TopoString) : level (TopoElement.gauge :: t) = level t := by
  rw [level_cons]; simp [imb]

@[simp] theorem level_nil : level [] = 0 := rfl

@[simp] theorem hmax_nil (c : Int) : hmax c [] = c := rfl

/-- The empty prefix is always a candidate, so the running maximum never drops below the start. -/
theorem hmax_ge : ∀ (c : Int) (s : TopoString), c ≤ hmax c s
  | c, [] => le_refl c
  | c, x :: t => by rw [hmax_cons]; exact le_max_left _ _

/-- A leading `+` pushes the maximum at least one above the start. -/
theorem hmax_pos_cons (c : Int) (t : TopoString) : c + 1 ≤ hmax c (TopoElement.phase LogicPhase.pos :: t) := by
  rw [hmax_cons_pos]
  have h := hmax_ge (c + 1) t
  have h2 := le_max_right c (hmax (c + 1) t)
  omega

theorem noGauge_tail {x : TopoElement} {t : TopoString} (h : NoGauge (x :: t)) : NoGauge t :=
  fun hm => h (List.Mem.tail _ hm)

/-! ### The load-bearing lemma -/

theorem hmax_zeno_prune : ∀ (s : TopoString), NoGauge s → ∀ c : Int,
    hmax c (zeno_prune s) = max (hmax c s - 1) (max c (c + level s))
  | [], _, c => by simp only [zeno_prune, hmax_nil, level_nil]; omega
  | [x], hng, c => by
      cases x with
      | gauge => exact absurd (List.Mem.head _) hng
      | phase p =>
          cases p
          · simp only [zeno_prune, hmax_cons_pos, hmax_nil, level_cons_pos, level_nil]
            omega
          · simp only [zeno_prune, hmax_cons_neg, hmax_nil, level_cons_neg, level_nil]
            omega
  | a :: b :: t, hng, c => by
      have hngt : NoGauge t := noGauge_tail (noGauge_tail hng)
      have hngbt : NoGauge (b :: t) := noGauge_tail hng
      match a, b with
      | TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.neg =>
          have ih := hmax_zeno_prune t hngt c
          have hge := hmax_ge c t
          have hz : zeno_prune (TopoElement.phase LogicPhase.pos :: TopoElement.phase LogicPhase.neg :: t) = zeno_prune t := by simp only [zeno_prune]
          rw [hz, ih]
          simp only [hmax_cons_pos, hmax_cons_neg, level_cons_pos, level_cons_neg]
          rw [show c + 1 - 1 = c from by ring]
          omega
      | TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.pos =>
          have ih := hmax_zeno_prune t hngt c
          have hge := hmax_ge c t
          have hz : zeno_prune (TopoElement.phase LogicPhase.neg :: TopoElement.phase LogicPhase.pos :: t) = zeno_prune t := by simp only [zeno_prune]
          rw [hz, ih]
          simp only [hmax_cons_pos, hmax_cons_neg, level_cons_pos, level_cons_neg]
          rw [show c - 1 + 1 = c from by ring]
          omega
      | TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.pos =>
          have ih := hmax_zeno_prune (TopoElement.phase LogicPhase.pos :: t) hngbt (c + 1)
          have hb := hmax_pos_cons (c + 1) t
          have hz : zeno_prune (TopoElement.phase LogicPhase.pos :: TopoElement.phase LogicPhase.pos :: t) = TopoElement.phase LogicPhase.pos :: zeno_prune (TopoElement.phase LogicPhase.pos :: t) := by
            simp only [zeno_prune]
          rw [hz]
          simp only [hmax_cons_pos, level_cons_pos] at ih hb ⊢
          rw [ih]
          omega
      | TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.neg =>
          have ih := hmax_zeno_prune (TopoElement.phase LogicPhase.neg :: t) hngbt (c - 1)
          have hb := hmax_ge (c - 1) (TopoElement.phase LogicPhase.neg :: t)
          have hz : zeno_prune (TopoElement.phase LogicPhase.neg :: TopoElement.phase LogicPhase.neg :: t) = TopoElement.phase LogicPhase.neg :: zeno_prune (TopoElement.phase LogicPhase.neg :: t) := by
            simp only [zeno_prune]
          rw [hz]
          simp only [hmax_cons_neg, level_cons_neg] at ih hb ⊢
          rw [ih]
          omega
      | TopoElement.phase LogicPhase.pos, TopoElement.gauge => exact absurd (List.Mem.tail _ (List.Mem.head _)) hng
      | TopoElement.phase LogicPhase.neg, TopoElement.gauge => exact absurd (List.Mem.tail _ (List.Mem.head _)) hng
      | TopoElement.gauge, _ => exact absurd (List.Mem.head _) hng

/-! ### The mirror -/

@[simp] theorem flip_nil : flip [] = [] := rfl

@[simp] theorem flip_cons (x : TopoElement) (t : TopoString) : flip (x :: t) = flipEl x :: flip t := rfl

@[simp] theorem flipEl_pos : flipEl (TopoElement.phase LogicPhase.pos) = TopoElement.phase LogicPhase.neg := rfl
@[simp] theorem flipEl_neg : flipEl (TopoElement.phase LogicPhase.neg) = TopoElement.phase LogicPhase.pos := rfl
@[simp] theorem flipEl_gauge : flipEl TopoElement.gauge = TopoElement.gauge := rfl

theorem imb_flipEl (x : TopoElement) : imb (flipEl x) = - imb x := by
  cases x with
  | gauge => rfl
  | phase p => cases p <;> rfl

theorem level_flip : ∀ s : TopoString, level (flip s) = - level s
  | [] => by simp
  | x :: t => by
      rw [flip_cons, level_cons, level_cons, level_flip t, imb_flipEl]
      ring

theorem noGauge_flip : ∀ s : TopoString, NoGauge s → NoGauge (flip s)
  | [], _ => by simp [NoGauge]
  | x :: t, hng => by
      have ht := noGauge_flip t (noGauge_tail hng)
      cases x with
      | gauge => exact absurd (List.Mem.head _) hng
      | phase p =>
          cases p
          · rw [flip_cons, flipEl_pos]
            intro hm
            rcases List.mem_cons.mp hm with h | h
            · exact absurd h (by simp)
            · exact ht h
          · rw [flip_cons, flipEl_neg]
            intro hm
            rcases List.mem_cons.mp hm with h | h
            · exact absurd h (by simp)
            · exact ht h

theorem zeno_prune_flip : ∀ s : TopoString, zeno_prune (flip s) = flip (zeno_prune s)
  | [] => rfl
  | [x] => by
      cases x with
      | gauge => simp [zeno_prune]
      | phase p => cases p <;> simp [zeno_prune]
  | a :: b :: t => by
      match a, b with
      | TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.neg =>
          have ih := zeno_prune_flip t
          simp only [flip_cons, flipEl_pos, flipEl_neg, zeno_prune]
          exact ih
      | TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.pos =>
          have ih := zeno_prune_flip t
          simp only [flip_cons, flipEl_pos, flipEl_neg, zeno_prune]
          exact ih
      | TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.pos =>
          have ih := zeno_prune_flip (TopoElement.phase LogicPhase.pos :: t)
          rw [flip_cons, flipEl_pos] at ih
          simp only [flip_cons, flipEl_pos, zeno_prune]
          rw [ih]
      | TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.neg =>
          have ih := zeno_prune_flip (TopoElement.phase LogicPhase.neg :: t)
          rw [flip_cons, flipEl_neg] at ih
          simp only [flip_cons, flipEl_neg, zeno_prune]
          rw [ih]
      | TopoElement.phase LogicPhase.pos, TopoElement.gauge =>
          simp only [flip_cons, flipEl_pos, flipEl_gauge, zeno_prune]
          rw [zeno_prune_flip t]
      | TopoElement.phase LogicPhase.neg, TopoElement.gauge =>
          simp only [flip_cons, flipEl_neg, flipEl_gauge, zeno_prune]
          rw [zeno_prune_flip t]
      | TopoElement.gauge, b =>
          have ih := zeno_prune_flip (b :: t)
          rw [flip_cons] at ih
          simp only [flip_cons, flipEl_gauge, zeno_prune]
          rw [ih]

/-! ### `|walk|` splits into the two signed heights -/

theorem exc_eq_hmax : ∀ (c : Int) (s : TopoString),
    ((exc c s : ℕ) : Int) = max (hmax c s) (hmax (-c) (flip s))
  | c, [] => by
      show ((c.natAbs : ℕ) : Int) = max (hmax c []) (hmax (-c) (flip []))
      simp only [flip_nil, hmax_nil]
      omega
  | c, x :: t => by
      have ih := exc_eq_hmax (c + imb x) t
      have harg : (-c) + imb (flipEl x) = -(c + imb x) := by rw [imb_flipEl]; ring
      show ((max c.natAbs (exc (c + imb x) t) : ℕ) : Int)
          = max (hmax c (x :: t)) (hmax (-c) (flip (x :: t)))
      rw [flip_cons, hmax_cons, hmax_cons, harg]
      have h1 := hmax_ge (c + imb x) t
      have h2 := hmax_ge (-(c + imb x)) (flip t)
      have hcast : ((max c.natAbs (exc (c + imb x) t) : ℕ) : Int)
          = max ((c.natAbs : ℕ) : Int) ((exc (c + imb x) t : ℕ) : Int) := by
        exact Nat.cast_max ..
      have habs : ((c.natAbs : ℕ) : Int) = max c (-c) := by omega
      rw [hcast, habs, ih]
      omega

/-- The maximum excess is the larger of the two signed heights. -/
theorem maxExcursion_eq_hmax (s : TopoString) :
    ((maxExcursion s : ℕ) : Int) = max (hmax 0 s) (hmax 0 (flip s)) := by
  have h := exc_eq_hmax 0 s
  rw [show -(0 : Int) = 0 from by ring] at h
  exact h

/-! ### Invariants carried through a pass -/

theorem level_zeno_prune : ∀ s : TopoString, level (zeno_prune s) = level s
  | [] => rfl
  | [x] => by
      cases x with
      | gauge => simp only [zeno_prune]
      | phase p => cases p <;> simp only [zeno_prune]
  | a :: b :: t => by
      match a, b with
      | TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.neg =>
          simp only [zeno_prune, level_cons_pos, level_cons_neg, level_zeno_prune t]
          ring
      | TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.pos =>
          simp only [zeno_prune, level_cons_pos, level_cons_neg, level_zeno_prune t]
          ring
      | TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.pos =>
          simp only [zeno_prune, level_cons_pos, level_zeno_prune (TopoElement.phase LogicPhase.pos :: t), level_cons_pos]
      | TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.neg =>
          simp only [zeno_prune, level_cons_neg, level_zeno_prune (TopoElement.phase LogicPhase.neg :: t), level_cons_neg]
      | TopoElement.phase LogicPhase.pos, TopoElement.gauge =>
          simp only [zeno_prune, level_cons_pos, level_cons_gauge, level_zeno_prune t]
      | TopoElement.phase LogicPhase.neg, TopoElement.gauge =>
          simp only [zeno_prune, level_cons_neg, level_cons_gauge, level_zeno_prune t]
      | TopoElement.gauge, b =>
          simp only [zeno_prune, level_cons, level_zeno_prune (b :: t)]

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
      | TopoElement.phase LogicPhase.pos, TopoElement.phase LogicPhase.neg => simp only [zeno_prune]; exact noGauge_zeno_prune t hngt
      | TopoElement.phase LogicPhase.neg, TopoElement.phase LogicPhase.pos => simp only [zeno_prune]; exact noGauge_zeno_prune t hngt
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
      | TopoElement.phase LogicPhase.pos, TopoElement.gauge => exact absurd (List.Mem.tail _ (List.Mem.head _)) hng
      | TopoElement.phase LogicPhase.neg, TopoElement.gauge => exact absurd (List.Mem.tail _ (List.Mem.head _)) hng
      | TopoElement.gauge, _ => exact absurd (List.Mem.head _) hng

theorem level_boundedPrune (s : TopoString) (hbal : level s = 0) :
    ∀ k : ℕ, level (boundedPrune k s) = 0
  | 0 => by simpa [boundedPrune] using hbal
  | k + 1 => by
      show level (zeno_prune (boundedPrune k s)) = 0
      rw [level_zeno_prune]
      exact level_boundedPrune s hbal k

theorem noGauge_boundedPrune (s : TopoString) (hng : NoGauge s) :
    ∀ k : ℕ, NoGauge (boundedPrune k s)
  | 0 => by simpa [boundedPrune] using hng
  | k + 1 => by
      show NoGauge (zeno_prune (boundedPrune k s))
      exact noGauge_zeno_prune _ (noGauge_boundedPrune s hng k)

/-! ### The per-pass lemma and the depth law -/

/-- A non-empty gauge-free history already leaves `0` on its first step. -/
theorem maxExcursion_pos {s : TopoString} (hng : NoGauge s) (hs : s ≠ []) : 1 ≤ maxExcursion s := by
  cases s with
  | nil => exact absurd rfl hs
  | cons x t =>
      have h := maxExcursion_eq_hmax (x :: t)
      cases x with
      | gauge => exact absurd (List.Mem.head _) hng
      | phase p =>
          cases p
          · have hb := hmax_pos_cons 0 t
            have hge := hmax_ge 0 (flip (TopoElement.phase LogicPhase.pos :: t))
            rw [hmax_cons_pos] at h hb
            omega
          · have hb := hmax_pos_cons 0 (flip t)
            have hge := hmax_ge 0 (TopoElement.phase LogicPhase.neg :: t)
            rw [flip_cons, flipEl_neg, hmax_cons_pos] at h
            rw [hmax_cons_pos] at hb
            omega

/-- **The per-pass lemma.** One pass drops the maximum excess by exactly one, for a gauge-free,
    count-balanced, non-empty history. Balance kills the boundary term of `hmax_zeno_prune`;
    gauge-freeness guarantees a cancellation happens at all. -/
theorem per_pass {s : TopoString} (hng : NoGauge s) (hbal : level s = 0) (hs : s ≠ []) :
    maxExcursion (zeno_prune s) + 1 = maxExcursion s := by
  have hM : 1 ≤ maxExcursion s := maxExcursion_pos hng hs
  have hp := hmax_zeno_prune s hng 0
  have hf := hmax_zeno_prune (flip s) (noGauge_flip s hng) 0
  have hfl : level (flip s) = 0 := by rw [level_flip, hbal]; ring
  rw [hbal] at hp
  rw [hfl] at hf
  rw [zeno_prune_flip s] at hf
  have hpr := maxExcursion_eq_hmax (zeno_prune s)
  have hs' := maxExcursion_eq_hmax s
  have h0a := hmax_ge 0 s
  have h0b := hmax_ge 0 (flip s)
  rw [hp, hf] at hpr
  omega

/-- Each pass peels one unit of excess. -/
theorem maxExcursion_boundedPrune {s : TopoString} (hng : NoGauge s) (hbal : level s = 0) :
    ∀ k : ℕ, maxExcursion (boundedPrune k s) = maxExcursion s - k
  | 0 => by simp [boundedPrune]
  | k + 1 => by
      have ih := maxExcursion_boundedPrune hng hbal k
      have hngk : NoGauge (boundedPrune k s) := noGauge_boundedPrune s hng k
      have hbalk : level (boundedPrune k s) = 0 := level_boundedPrune s hbal k
      show maxExcursion (zeno_prune (boundedPrune k s)) = maxExcursion s - (k + 1)
      by_cases hnil : boundedPrune k s = []
      · rw [hnil]
        have h0 : maxExcursion ([] : TopoString) = 0 := rfl
        rw [hnil, h0] at ih
        simp only [zeno_prune, h0]
        omega
      · have h := per_pass hngk hbalk hnil
        omega

/-- **The depth law.** A finite-capacity horizon closes exactly the histories whose phase walk never
    strays further than `R` from balance. Capacity bounds **excursion**, not length. -/
theorem closedAtHorizon_iff_maxExcursion_le {s : TopoString}
    (hng : NoGauge s) (hbal : level s = 0) (R : ℕ) :
    closedAtHorizon R s ↔ maxExcursion s ≤ R := by
  have hk := maxExcursion_boundedPrune hng hbal R
  have hngR : NoGauge (boundedPrune R s) := noGauge_boundedPrune s hng R
  constructor
  · intro hclosed
    unfold closedAtHorizon at hclosed
    have h0 : maxExcursion ([] : TopoString) = 0 := rfl
    rw [hclosed, h0] at hk
    omega
  · intro hle
    unfold closedAtHorizon
    by_contra hne
    have h1 := maxExcursion_pos hngR hne
    omega

/-- **The number of passes IS the maximum excess.** -/
theorem closureDepth_eq_maxExcursion {s : TopoString} (hng : NoGauge s) (hbal : level s = 0) :
    closedAtHorizon (maxExcursion s) s ∧ ∀ k : ℕ, k < maxExcursion s → ¬ closedAtHorizon k s := by
  refine ⟨(closedAtHorizon_iff_maxExcursion_le hng hbal _).mpr (le_refl _), ?_⟩
  intro k hk hclosed
  have := (closedAtHorizon_iff_maxExcursion_le hng hbal k).mp hclosed
  omega

/-! ### The nested folds, now derived -/

theorem level_append : ∀ a b : TopoString, level (a ++ b) = level a + level b
  | [], b => by simp
  | x :: t, b => by
      rw [List.cons_append, level_cons, level_cons, level_append t b]
      ring

theorem level_poss : ∀ n : ℕ, level (poss n) = (n : Int)
  | 0 => by simp [poss]
  | n + 1 => by
      have h : poss (n + 1) = TopoElement.phase LogicPhase.pos :: poss n := by simp [poss, List.replicate_succ]
      rw [h, level_cons_pos, level_poss n]
      push_cast
      ring

theorem level_negs : ∀ n : ℕ, level (negs n) = -(n : Int)
  | 0 => by simp [negs]
  | n + 1 => by
      have h : negs (n + 1) = TopoElement.phase LogicPhase.neg :: negs n := by simp [negs, List.replicate_succ]
      rw [h, level_cons_neg, level_negs n]
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
    `nested_not_closed_before` become *consequences* of the depth law. -/
theorem maxExcursion_nested (d : ℕ) : maxExcursion (nested d) = d := by
  have h1 := (closedAtHorizon_iff_maxExcursion_le (noGauge_nested d) (level_nested d) d).mp
    (nested_closed_at_d d)
  by_cases hd : d = 0
  · omega
  · obtain ⟨j, hj⟩ : ∃ j, d = j + 1 := ⟨d - 1, by omega⟩
    have h2 := nested_not_closed_before d j (by omega)
    have h3 := (closedAtHorizon_iff_maxExcursion_le (noGauge_nested d) (level_nested d) j).mpr
    by_contra hne
    exact h2 (h3 (by omega))

/-- **Established constructively:** the depth law, no axiom. `hmax_zeno_prune` is the generalization
    that makes the induction go through — the signed height with an arbitrary accumulator, valid for
    unbalanced histories, which is what the emit step needs. From it `per_pass` (one pass drops the
    maximum excess by exactly one), `maxExcursion_boundedPrune`, and
    `closedAtHorizon_iff_maxExcursion_le`: **a finite-capacity horizon closes exactly the histories
    whose phase walk never strays further than `R` from balance** — capacity bounds excursion, not
    length. `closureDepth_eq_maxExcursion` gives the exact pass count; `maxExcursion_nested`
    re-derives the nested-fold witnesses of `QLF_ClosureDepth` / `QLF_LawOfExceptions`. Both
    hypotheses are necessary: gauge-freeness because `[+, gauge, −]` is prune-fixed, balance because
    the boundary term survives otherwise. This closes
    `QLF_ClosureDepth.closure_depth_law_in_progress`. -/
theorem closure_depth_law_complete : True := trivial

end QLF.ClosureDepthLaw

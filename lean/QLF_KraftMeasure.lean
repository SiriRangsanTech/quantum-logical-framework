import QLF_TwistAlphabet
import Mathlib

set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

/-!
# QLF_KraftMeasure — **the closure-depth measure is counted, not chosen**

The contextual census ([`contextual_census.py`](../contextual_census.py)) reads outcome weights off
the histories that **first** close a joint preparation–apparatus run. A run that has closed is not
continued — a closure *is* an event, and continuing past it describes a longer, different history —
so the first-closure histories of a given experiment form a **prefix-free** set: no one of them
extends another.

That single structural fact hands the census its weighting over closure depths, and hands it for
free. There is no need to postulate how a closure at depth `d` should be weighed against one at
depth `d'`, and no room to fit one:

> **`kraft_count`** — for a prefix-free `F` whose words are no longer than `D`,
> `∑_{h ∈ F} b^(D − |h|) ≤ b^D`, where `b` is the size of the alphabet.
>
> **`kraft_measure`** — equivalently `∑_{h ∈ F} (1/b)^{|h|} ≤ 1`.
>
> **`twist_kraft`** — over the 8-twist alphabet, `∑_{h ∈ F} (1/8)^{|h|} ≤ 1`.

## Why this is multiplicity, not a probability postulate

Read `b^(D − |h|)` as what it counts. A first closure `h` at depth `|h|` is the prefix of exactly
`b^(D − |h|)` complete histories of length `D`: **everything after a closed event can still happen
every way.** Prefix-freeness makes those completion sets disjoint, and they all sit inside the `b^D`
histories of length `D`. So the inequality is the possibility tree counting itself, and the weight
`b^{−|h|}` says the QLF thing exactly:

> **an earlier closure weighs more because more complete histories contain it.**

The leftover mass `1 − ∑ b^{−|h|}` is the runs that never close in this experiment — they exceed the
physical closure capacity, or wander forever. Capacity therefore causes **leakage**, never
renormalisation: it removes cylinders, it does not reweigh the survivors. Normalising depth by depth
against the *surviving* capacity-limited population instead is what pushed an earlier numerical
version of this sum past `1`; this theorem is why that had to be an error rather than a discovery.

## What it does and does not settle

It settles the **measure**. It does not settle the Born rule: with the measure in hand the
multiplicity reading converges, while the phase-weighted readings diverge, because a weight
`∑ b^{−d}|A(d)|²` needs `|A(d)|` to grow no faster than `√b^d = 2.828…^d` and the measured signed
census grows like `3.91^d … 4.56^d`. See [`Born_Rule.md`](../Born_Rule.md) §8. The gap is now a
number, and this module is the half of it that is a theorem.
-/

namespace QLF

open Finset

section Kraft

variable {α : Type} [DecidableEq α] [Fintype α]

/-- Every word of length `n` over the alphabet `α`. -/
def words (α : Type) [DecidableEq α] [Fintype α] : ℕ → Finset (List α)
  | 0 => {([] : List α)}
  | n + 1 => (univ : Finset α).biUnion (fun a => (words α n).image (fun w => a :: w))

theorem mem_words (n : ℕ) (w : List α) : w ∈ words α n ↔ w.length = n := by
  induction n generalizing w with
  | zero =>
      constructor
      · intro h
        rw [words, Finset.mem_singleton] at h
        subst h; rfl
      · intro h
        cases w with
        | nil => simp [words]
        | cons a t => simp at h
  | succ n ih =>
      constructor
      · intro h
        rw [words, Finset.mem_biUnion] at h
        obtain ⟨a, -, ha⟩ := h
        rw [Finset.mem_image] at ha
        obtain ⟨v, hv, rfl⟩ := ha
        have hlen := (ih v).mp hv
        simp [hlen]
      · intro h
        cases w with
        | nil => simp at h
        | cons a t =>
            rw [words, Finset.mem_biUnion]
            refine ⟨a, Finset.mem_univ a, ?_⟩
            rw [Finset.mem_image]
            exact ⟨t, (ih t).mpr (by simpa using h), rfl⟩

theorem card_words (n : ℕ) : (words α n).card = (Fintype.card α) ^ n := by
  induction n with
  | zero => simp [words]
  | succ n ih =>
      have hinj : ∀ a : α, Function.Injective (fun w : List α => a :: w) := by
        intro a w₁ w₂ h
        simpa using h
      have hdisj : ∀ a ∈ (univ : Finset α), ∀ b ∈ (univ : Finset α), a ≠ b →
          Disjoint ((words α n).image (fun w => a :: w))
                   ((words α n).image (fun w => b :: w)) := by
        intro a _ b _ hab
        refine Finset.disjoint_left.mpr ?_
        intro w hwa hwb
        rw [Finset.mem_image] at hwa hwb
        obtain ⟨u, -, rfl⟩ := hwa
        obtain ⟨v, -, hv⟩ := hwb
        injection hv with hba hvu
        exact hab hba.symm
      have hstep : ∀ a ∈ (univ : Finset α),
          ((words α n).image (fun w => a :: w)).card = (Fintype.card α) ^ n := by
        intro a _
        rw [Finset.card_image_of_injective _ (hinj a), ih]
      rw [words, Finset.card_biUnion hdisj, Finset.sum_congr rfl hstep, Finset.sum_const,
        Finset.card_univ, smul_eq_mul]
      ring

private theorem append_cancel_left : ∀ {s t₁ t₂ : List α}, s ++ t₁ = s ++ t₂ → t₁ = t₂ := by
  intro s
  induction s with
  | nil => intro t₁ t₂ h; simpa using h
  | cons a s ih => intro t₁ t₂ h; exact ih (by simpa using h)

theorem append_mem_words {m n : ℕ} {h t : List α}
    (hh : h ∈ words α m) (ht : t ∈ words α n) : h ++ t ∈ words α (m + n) := by
  rw [mem_words] at hh ht ⊢
  rw [List.length_append, hh, ht]

/-- The length-`D` completions of a word: everything that can still happen after it. -/
def completions (D : ℕ) (h : List α) : Finset (List α) :=
  (words α (D - h.length)).image (fun t => h ++ t)

theorem card_completions (D : ℕ) (h : List α) :
    (completions D h).card = (Fintype.card α) ^ (D - h.length) := by
  have hinj : Function.Injective (fun t : List α => h ++ t) :=
    fun t₁ t₂ heq => append_cancel_left heq
  rw [completions, Finset.card_image_of_injective _ hinj, card_words]

theorem completions_subset {D : ℕ} {h : List α} (hlen : h.length ≤ D) :
    completions D h ⊆ words α D := by
  intro w hw
  rw [completions, Finset.mem_image] at hw
  obtain ⟨t, ht, rfl⟩ := hw
  have hh : h ∈ words α h.length := (mem_words _ _).mpr rfl
  have := append_mem_words hh ht
  rwa [Nat.add_sub_cancel' hlen] at this

/-- `a` is a prefix of `b`. -/
def HasPrefix (a b : List α) : Prop := ∃ t, a ++ t = b

/-- No word of `F` extends another — the structure of a set of **first** closures. -/
def PrefixFree (F : Finset (List α)) : Prop :=
  ∀ a ∈ F, ∀ b ∈ F, HasPrefix a b → a = b

private theorem prefix_of_append_eq : ∀ {a b s t : List α},
    a ++ s = b ++ t → a.length ≤ b.length → HasPrefix a b := by
  intro a
  induction a with
  | nil => intro b s t _ _; exact ⟨b, by simp⟩
  | cons x a ih =>
      intro b s t heq hlen
      cases b with
      | nil => simp at hlen
      | cons y b =>
          have h' : x = y ∧ a ++ s = b ++ t := by simpa using heq
          obtain ⟨hxy, htail⟩ := h'
          have hlen' : a.length ≤ b.length := by simpa using hlen
          obtain ⟨u, hu⟩ := ih htail hlen'
          exact ⟨u, by simp [hxy, hu]⟩

theorem completions_disjoint {F : Finset (List α)} (hF : PrefixFree F) {D : ℕ}
    {a b : List α} (ha : a ∈ F) (hb : b ∈ F) (hab : a ≠ b) :
    Disjoint (completions D a) (completions D b) := by
  refine Finset.disjoint_left.mpr ?_
  intro w hwa hwb
  rw [completions, Finset.mem_image] at hwa hwb
  obtain ⟨s, -, hs⟩ := hwa
  obtain ⟨t, -, ht⟩ := hwb
  have heq : a ++ s = b ++ t := by rw [hs, ht]
  rcases le_total a.length b.length with hle | hle
  · exact hab (hF a ha b hb (prefix_of_append_eq heq hle))
  · exact hab (hF b hb a ha (prefix_of_append_eq heq.symm hle)).symm

/-- **Kraft, by counting.** A prefix-free set of histories owns disjoint sets of completions
inside the `b^D` histories of length `D`, so their sizes cannot overflow it. -/
theorem kraft_count {F : Finset (List α)} (hF : PrefixFree F) {D : ℕ}
    (hlen : ∀ h ∈ F, h.length ≤ D) :
    ∑ h ∈ F, (Fintype.card α) ^ (D - h.length) ≤ (Fintype.card α) ^ D := by
  have hcards : ∑ h ∈ F, (Fintype.card α) ^ (D - h.length) = (F.biUnion (completions D)).card := by
    rw [Finset.card_biUnion (fun a ha b hb hab => completions_disjoint hF ha hb hab)]
    exact Finset.sum_congr rfl (fun h _ => (card_completions D h).symm)
  rw [hcards, ← card_words (α := α) D]
  refine Finset.card_le_card ?_
  intro w hw
  rw [Finset.mem_biUnion] at hw
  obtain ⟨h, hh, hw⟩ := hw
  exact completions_subset (hlen h hh) hw

/-- **The closure-depth measure.** The same statement as a mass: cylinder weights `(1/b)^{|h|}`
over a prefix-free set total at most `1`, the rest being what never closes here. -/
theorem kraft_measure {F : Finset (List α)} (hF : PrefixFree F) {D : ℕ}
    (hlen : ∀ h ∈ F, h.length ≤ D) (hcard : 0 < Fintype.card α) :
    ∑ h ∈ F, ((1 : ℚ) / (Fintype.card α)) ^ h.length ≤ 1 := by
  have hc : (0 : ℚ) < (Fintype.card α : ℚ) := by exact_mod_cast hcard
  have key : ∀ h ∈ F, ((1 : ℚ) / (Fintype.card α)) ^ h.length
      = ((Fintype.card α : ℚ) ^ (D - h.length)) / ((Fintype.card α : ℚ) ^ D) := by
    intro h hh
    have hsum : (D - h.length) + h.length = D := Nat.sub_add_cancel (hlen h hh)
    have hne : ((Fintype.card α : ℚ)) ≠ 0 := ne_of_gt hc
    rw [div_pow, one_pow, div_eq_div_iff (pow_ne_zero _ hne) (pow_ne_zero _ hne), one_mul,
      ← pow_add, hsum]
  rw [Finset.sum_congr rfl key, ← Finset.sum_div, div_le_one (by positivity)]
  exact_mod_cast kraft_count hF hlen

end Kraft

instance : Fintype Twist :=
  ⟨{Twist.up, Twist.down, Twist.left, Twist.right,
    Twist.slash, Twist.backslash, Twist.plus, Twist.minus}, by intro x; cases x <;> decide⟩

theorem card_twist : Fintype.card Twist = 8 := by decide

/-- **The census reading.** Over the 8-twist alphabet, the cylinder mass of any prefix-free set of
histories — the first closures of one experiment — is at most `1`. The depth weighting the
contextual census needs is therefore *counted*, not chosen. -/
theorem twist_kraft {F : Finset (List Twist)} (hF : PrefixFree F) {D : ℕ}
    (hlen : ∀ h ∈ F, h.length ≤ D) :
    ∑ h ∈ F, ((1 : ℚ) / 8) ^ h.length ≤ 1 := by
  have h := kraft_measure (α := Twist) hF hlen (by rw [card_twist]; norm_num)
  simpa [card_twist] using h

section EventWeights

/-!
## The normalized-event weight, and why it cannot be the Born rule

With the measure settled, the contextual census weighs an event class of `W` ways carrying signed
total `A` at depth `d` as

    B = (W / b^d) . (A / W)^2 = A^2 / (W . b^d)      -- multiplicity mass times squared mean phase,

which is summable for free: `|A| ≤ W` gives `A^2/W ≤ W`, and Kraft caps the rest
(`normalized_le_mass`, `normalized_event_mass_le_one`). That was the point of it.

The same inequality kills it as a Born rule. Merging two families of ways into **one** event can
only *lower* the weight (`merge_le_sum`, Cauchy–Schwarz in Engel form), with equality exactly when
the two families carry the same mean phase (`merge_eq_sum_iff`). So opening a second path can never
enhance a detection:

> **`no_constructive_interference`** — `B(A ∪ B) ≤ B(A) + B(B)`, always.

Quantum mechanics needs the opposite. Two coherent paths of equal amplitude give `|A + A|^2 = 4|A|^2`
against `|A|^2 + |A|^2`, a factor of **two** enhancement; here the equal-mean-phase case is exactly
the equality case, so the two paths merely add. Measured, in `contextual_census.py --two-path`: a
matched pair gives ratio `1.000000` to the sum, an unequal pair `0.999288`, and the destructive
configuration `0.000000` — destructive interference survives, constructive interference cannot.

The dichotomy this leaves is sharp, and it is the state of the Born question
([`Born_Rule.md`](../Born_Rule.md) §8):

* **normalise per event** — summable by Kraft, but sub-additive, so no constructive interference;
* **do not normalise** — interference-capable, but the signed census grows like `3.9^d`–`4.6^d`
  against the `√8^d` the cylinder measure allows, so nothing sums.

The substrate's signed census cannot presently be both summable and interference-capable under the
measure its own tree defines.
-/

/-- Cauchy–Schwarz in Engel form, two terms. -/
theorem sq_div_add_sq_div {a b p q : ℚ} (hp : 0 < p) (hq : 0 < q) :
    (a + b) ^ 2 / (p + q) ≤ a ^ 2 / p + b ^ 2 / q := by
  rw [div_add_div _ _ (ne_of_gt hp) (ne_of_gt hq), div_le_div_iff (by positivity) (by positivity)]
  nlinarith [sq_nonneg (a * q - b * p), hp.le, hq.le, mul_pos hp hq]

/-- **Merging ways into one event can only lower its weight.** -/
theorem merge_le_sum {a b p q : ℚ} (hp : 0 < p) (hq : 0 < q) :
    (a + b) ^ 2 / (p + q) ≤ a ^ 2 / p + b ^ 2 / q :=
  sq_div_add_sq_div hp hq

/-- **No constructive interference**, stated as the physics: two paths open weigh no more than the
two paths apart, whatever their phases. -/
theorem no_constructive_interference {a b p q : ℚ} (hp : 0 < p) (hq : 0 < q) :
    ¬ (a ^ 2 / p + b ^ 2 / q < (a + b) ^ 2 / (p + q)) :=
  not_lt.mpr (merge_le_sum hp hq)

/-- The equality case: two families add rather than interfere exactly when their **mean phases**
agree, `a/p = b/q`. -/
theorem merge_eq_sum_iff {a b p q : ℚ} (hp : 0 < p) (hq : 0 < q) :
    (a + b) ^ 2 / (p + q) = a ^ 2 / p + b ^ 2 / q ↔ a * q = b * p := by
  rw [div_add_div _ _ (ne_of_gt hp) (ne_of_gt hq), div_eq_div_iff (by positivity) (by positivity)]
  constructor
  · intro h
    nlinarith [sq_nonneg (a * q - b * p), mul_pos hp hq, hp, hq]
  · intro h
    nlinarith [h, mul_pos hp hq]

/-- A single event class weighs no more than its multiplicity mass, since `|A| ≤ W`. -/
theorem normalized_le_mass {a w : ℚ} (hw : 0 < w) (ha : |a| ≤ w) : a ^ 2 / w ≤ w := by
  have hsq : a ^ 2 ≤ w ^ 2 := by
    rw [← sq_abs]
    exact pow_le_pow_left (abs_nonneg _) ha 2
  rw [div_le_iff hw]
  nlinarith [hsq]

/-- **The normalized-event mass is bounded by the Kraft mass.** Whatever the phases do, the total
weight of a prefix-free family of events stays under `1`. -/
theorem normalized_event_mass_le_one {ι : Type} (s : Finset ι) (a w μ : ι → ℚ)
    (hw : ∀ i ∈ s, 0 < w i) (ha : ∀ i ∈ s, |a i| ≤ w i) (hμ : ∀ i ∈ s, 0 ≤ μ i)
    (hmass : ∑ i ∈ s, w i * μ i ≤ 1) :
    ∑ i ∈ s, (a i) ^ 2 / w i * μ i ≤ 1 := by
  refine le_trans (Finset.sum_le_sum ?_) hmass
  intro i hi
  exact mul_le_mul_of_nonneg_right (normalized_le_mass (hw i hi) (ha i hi)) (hμ i hi)

end EventWeights

end QLF

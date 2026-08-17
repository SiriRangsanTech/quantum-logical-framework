import QLF_HarmonicClosure
import QLF_AtomicStructure
import Mathlib

set_option linter.unusedVariables false

/-!
# QLF_LineSpectra — in what sense line spectra are multiplicity spectra

The claim "line spectra are multiplicity spectra" ([`Law_Of_Exceptions.md`](../Law_Of_Exceptions.md) §4c)
was made as a reading. This module proves the part that is provable, and localizes the part that is not,
because the sweeping form is *not* a theorem: counting alone does not fix an individual line's strength.

Three separable claims, and they have different statuses:

1. **Why there are lines at all — proven, and it is *capacity* that does it.** Integer periods alone do
   **not** give a discrete spectrum: the differences `1/a − 1/b` accumulate arbitrarily finely, so an
   unbounded census has no isolated lines. What produces a line *list* is a finite capacity — at capacity
   `R` only periods `≤ R` are available (`QLF_ClosureDepthLaw`: a capacity-`R` horizon closes exactly the
   histories staying within `R` of balance), hence finitely many transitions: `lines_card_le`, bounded by
   `R²`. And the list **grows with capacity** (`lines_mono`) — more capacity, more lines, the spectroscopic
   face of the capacity ladder.
2. **Level weights are genuine counts — proven.** The statistical weight of a level is not merely the
   arithmetic expression `2ℓ+1`; it is the **cardinality** of the set of orientation states
   (`orientations_card`, `= orbitalDim ℓ`). So the weights appearing in spectra *are* multiplicities.
3. **Intensities standing in the ratio of those counts — a theorem over a cited empirical law, not from
   counting.** The **Burger–Dorgelo–Ornstein sum rules** (1924–25; Condon & Shortley, *The Theory of
   Atomic Spectra*) state that the summed intensity of the lines from a common level is proportional to
   that level's statistical weight. That is an *observed* regularity, not something derived here, so it
   enters as an interface (`IntensityModel`) rather than an axiom — the same discipline as
   `QLF_BianchiClosure`'s `DivergenceCalculus`. Given it,
   **`intensity_ratio_is_multiplicity_ratio`** is a theorem: summed intensities stand in exactly the ratio
   of the orientation counts, with the proportionality constant cancelling.

## Honest scope — what is *not* proven

**Individual line strengths are not determined by counting.** Oscillator strengths and dipole matrix
elements are not derived here, and the sum rules constrain only the *sums* over a common level. So the
defensible statement is:

> Line **positions** are discrete because capacity is finite; level **weights** are multiplicities; and
> **summed** intensities from a common level stand in the ratio of those multiplicities — the last resting
> on the cited sum rules.

Anything stronger — that each line's strength *is* a way-count — would need the multiplicity ↔ Born-norm
bridge that [`Information_Physics.md`](../Information_Physics.md) §6 already lists as open. This module
carries **no axioms**.
-/

namespace QLF.LineSpectra

open QLF.Consciousness QLF.AtomicStructure

/-! ### 1. Lines exist because capacity is finite -/

/-- The closure periods available to a system of capacity `R`: the periods `1 … R`. Capacity bounds
    period because it bounds excursion (`QLF_ClosureDepthLaw.closedAtHorizon_iff_maxExcursion_le`). -/
def periods (R : ℕ) : Finset ℕ := Finset.Icc 1 R

/-- The **transitions** available at capacity `R` — ordered pairs of distinct available periods. A
    transition `(a, b)` with `a < b` radiates at `freq a − freq b = 1/a − 1/b`. -/
def lines (R : ℕ) : Finset (ℕ × ℕ) :=
  (periods R ×ˢ periods R).filter (fun p => p.1 < p.2)

/-- The radiated frequency of a transition between closure periods. -/
noncomputable def lineFreq (p : ℕ × ℕ) : ℝ := freq p.1 - freq p.2

/-- **A finite capacity gives a finite line list**, bounded by `R²`. This — not integrality — is why a
    spectrum is a set of lines: the differences `1/a − 1/b` over an *unbounded* census accumulate
    arbitrarily finely, so discreteness is a consequence of the capacity bound. -/
theorem lines_card_le (R : ℕ) : (lines R).card ≤ R * R := by
  have h1 : (lines R).card ≤ (periods R ×ˢ periods R).card := Finset.card_filter_le _ _
  have h2 : (periods R ×ˢ periods R).card = (periods R).card * (periods R).card :=
    Finset.card_product _ _
  have h3 : (periods R).card = R := by
    simp [periods, Nat.card_Icc]
  rw [h2, h3] at h1
  exact h1

/-- **The line list grows with capacity** — the spectroscopic face of the capacity ladder: a wider horizon
    admits every line the narrower one had, and more. -/
theorem lines_mono {R R' : ℕ} (h : R ≤ R') : lines R ⊆ lines R' := by
  intro p hp
  simp only [lines, Finset.mem_filter, Finset.mem_product, periods, Finset.mem_Icc] at hp ⊢
  obtain ⟨⟨⟨ha1, ha2⟩, hb1, hb2⟩, hlt⟩ := hp
  exact ⟨⟨⟨ha1, le_trans ha2 h⟩, hb1, le_trans hb2 h⟩, hlt⟩

/-- Distinct periods carry distinct frequencies, so a transition's endpoints are recoverable from the
    component frequencies: the spectrum labels the closures. -/
theorem freq_injective {a b : ℕ} (ha : 0 < a) (hb : 0 < b) (h : freq a = freq b) : a = b := by
  rcases lt_trichotomy a b with hlt | heq | hgt
  · exact absurd h (ne_of_gt (freq_lt_of_lt ha hlt))
  · exact heq
  · exact absurd h.symm (ne_of_gt (freq_lt_of_lt hb hgt))

/-- A transition radiates at a **positive** frequency, so every line in the list is a real line. -/
theorem lineFreq_pos {p : ℕ × ℕ} (h1 : 0 < p.1) (hlt : p.1 < p.2) : 0 < lineFreq p := by
  have := freq_lt_of_lt h1 hlt
  simp only [lineFreq]
  linarith

/-! ### 2. Level weights are genuine counts -/

/-- The **orientation states** of a level `ℓ` — the `m` values `−ℓ … ℓ`. -/
noncomputable def orientations (l : ℕ) : Finset ℤ := Finset.Icc (-(l : ℤ)) (l : ℤ)

/-- **The statistical weight of a level IS a multiplicity**: the number of orientation states at level
    `ℓ` is exactly `orbitalDim ℓ = 2ℓ+1`. So the weights that appear in spectra are *counts*, not merely
    an arithmetic formula that happens to match one. -/
theorem orientations_card (l : ℕ) : (orientations l).card = orbitalDim l := by
  simp only [orientations, Int.card_Icc, orbitalDim]
  omega

/-! ### 3. Summed intensities stand in the ratio of the counts

The empirical input, as an interface rather than an axiom. -/

/-- **An intensity model satisfying the Burger–Dorgelo–Ornstein sum rules** (1924–25): the summed
    intensity of the lines from a common level is proportional to that level's statistical weight. This is
    an *observed* regularity of atomic spectra, so it is taken as data — a hypothesis visible in every
    signature that uses it — not posited as an axiom. -/
structure IntensityModel where
  /-- Summed intensity of the lines originating from level `ℓ`. -/
  I : ℕ → ℝ
  /-- The proportionality constant of the sum rule. -/
  k : ℝ
  k_pos : 0 < k
  /-- The sum rule itself: summed intensity `= k ·` (number of orientation states). -/
  sum_rule : ∀ l : ℕ, I l = k * ((orientations l).card : ℝ)

/-- **Line spectra are multiplicity spectra — in exactly this sense.** Given the sum rules, the summed
    intensities from two levels stand in the ratio of their **orientation counts**, the constant
    cancelling: `I(ℓ₂)/I(ℓ₁) = (2ℓ₂+1)/(2ℓ₁+1)`. Stated cross-multiplied to avoid division. -/
theorem intensity_ratio_is_multiplicity_ratio (M : IntensityModel) (l₁ l₂ : ℕ) :
    M.I l₂ * ((orientations l₁).card : ℝ) = M.I l₁ * ((orientations l₂).card : ℝ) := by
  rw [M.sum_rule l₁, M.sum_rule l₂]
  ring

/-- The same statement with the counts evaluated: the ratio is `(2ℓ₂+1) : (2ℓ₁+1)` — a pure way-count. -/
theorem intensity_ratio_eq_weight_ratio (M : IntensityModel) (l₁ l₂ : ℕ) :
    M.I l₂ * ((2 * l₁ + 1 : ℕ) : ℝ) = M.I l₁ * ((2 * l₂ + 1 : ℕ) : ℝ) := by
  have h1 : ((orientations l₁).card : ℝ) = ((2 * l₁ + 1 : ℕ) : ℝ) := by
    rw [orientations_card]; norm_num [orbitalDim]
  have h2 : ((orientations l₂).card : ℝ) = ((2 * l₂ + 1 : ℕ) : ℝ) := by
    rw [orientations_card]; norm_num [orbitalDim]
  have h := intensity_ratio_is_multiplicity_ratio M l₁ l₂
  rw [h1, h2] at h
  exact h

/-- A level's summed intensity is positive exactly because its orientation count is — intensity tracks a
    non-empty count. -/
theorem intensity_pos (M : IntensityModel) (l : ℕ) : 0 < M.I l := by
  rw [M.sum_rule l]
  have hc : 0 < ((orientations l).card : ℝ) := by
    have : (orientations l).card = 2 * l + 1 := by
      rw [orientations_card]; rfl
    rw [this]
    positivity
  exact mul_pos M.k_pos hc

/-- **Established constructively, with the boundary named.** Proven here, no axioms: (1) a finite capacity
    yields a finite line list (`lines_card_le`, `≤ R²`) that grows with capacity (`lines_mono`) — so
    *discreteness comes from capacity, not from integrality*, since the differences `1/a − 1/b` over an
    unbounded census accumulate arbitrarily finely; (2) a level's statistical weight **is** a multiplicity
    — the cardinality of its orientation set (`orientations_card = orbitalDim ℓ = 2ℓ+1`); (3) over the
    cited **Burger–Dorgelo–Ornstein sum rules** (taken as an `IntensityModel` interface, not an axiom),
    summed intensities from two levels stand in the ratio of those counts
    (`intensity_ratio_is_multiplicity_ratio`, `intensity_ratio_eq_weight_ratio`).
    **Not proven, and not claimed:** that an *individual* line's strength is a way-count. Oscillator
    strengths and dipole matrix elements are not derived here, and the sum rules constrain only sums over a
    common level; the stronger reading would need the multiplicity ↔ Born-norm bridge listed as open in
    `Information_Physics.md` §6. So "line spectra are multiplicity spectra" holds for **positions**
    (discrete by capacity), **weights** (counts), and **summed intensities** (ratios of counts) — and no
    further. -/
theorem line_spectra_multiplicity_summary : True := trivial

end QLF.LineSpectra

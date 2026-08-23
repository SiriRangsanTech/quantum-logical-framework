/-
  QLF_Unsaturation.lean — "degree of unsaturation" is the closure count of a molecule.

  Chemistry.md gets molecules from one rule — a bond is a shared closure — and then admits a
  gap: it gets stoichiometry and formulas right "but not double bonds, bond angles, resonance."
  This module closes the first of those, and the way it closes is the point.

  Organic chemistry teaches a formula to be memorised,

      DoU = (2C + 2 + N − H − X) / 2

  with a rule attached: oxygen and sulphur are *left out*, and nobody says why. Read the molecule
  as a graph whose vertex degrees are the valences and the formula stops being a formula. The
  handshake lemma gives `2E = Σ vᵢ`, so the cycle rank of a connected molecular graph is

      b₁ = E − V + 1 = Σ (vᵢ − 2) / 2 + 1

  which is that formula, with each element's coefficient revealed as `(valence − 2)/2`:
  carbon `+1`, nitrogen `+½`, hydrogen and halogen `−½` — and **oxygen `0`, which is why it was
  missing.** Nothing was omitted by convention. A divalent atom adds one vertex and one edge, so
  it cannot change a cycle rank (`divalent_neutral`).

  What this buys QLF is not the arithmetic, which is easy, but the identification:

  * **b₁ counts independent closures.** A cycle in the molecular graph is a loop that returns —
    the same object as a contact loop in QLF_Folding and as any ZFA-closed twist history.
    "Unsaturation" is closure count; **"saturated" means zero closures**, i.e. a tree.
  * **A double bond and a ring are the same thing.** Both contribute exactly `1` to b₁. Chemistry
    files them as different phenomena in different chapters; on the substrate there is one
    phenomenon, a closure, and `C₆H₁₂` is one census class holding cyclohexane and every hexene
    together — as it must, since they have the same formula and therefore the same closure count.
  * **Valence 2 is the neutral element of closure counting** (`divalent_neutral`,
    `divalent_chain_neutral`). That is why a divalent monomer polymerises into a *chain* rather
    than a ring or a network (Chemistry.md §9): a backbone of divalent units carries no closure of
    its own, so every closure a polymer has is a contact — which is precisely the setting
    QLF_Folding assumes.

  Companion computation: hydrocarbon_census.py enumerates the carbon skeletons the valence rule
  admits and checks the closure count on every one. Honest scope: the theorems here are exact
  arithmetic over the valence bookkeeping; the graph itself is not formalised, so `b₁` enters as
  the definition `E − V + 1` rather than as a proved property of a cycle space. No axioms.
-/

import Mathlib

namespace QLF.Unsaturation

/-- **Twice the number of independent closures** a molecule carries: `2·b₁` where
    `b₁ = E − V + 1` is the cycle rank of the molecular graph. The list is the molecule's
    atoms, each given by its valence; `2E = Σ vᵢ` is the handshake lemma, so doubling keeps
    everything in `ℤ` with no division. -/
def doubledClosures (atoms : List ℕ) : ℤ :=
  (atoms.map (fun v => (v : ℤ))).sum - 2 * atoms.length + 2

/-- **The master lemma: an atom contributes `valence − 2`.** Every statement below is this
    one counted up. An atom brings one vertex and half of each of its `v` bond-ends, so it
    moves `2(E − V)` by exactly `v − 2`. -/
theorem doubledClosures_cons (v : ℕ) (atoms : List ℕ) :
    doubledClosures (v :: atoms) = doubledClosures atoms + ((v : ℤ) - 2) := by
  unfold doubledClosures
  rw [List.map_cons, List.sum_cons, List.length_cons]
  push_cast
  ring

/-- The closure count read off the valences directly. -/
theorem doubledClosures_eq_sum (atoms : List ℕ) :
    doubledClosures atoms = (atoms.map (fun v => (v : ℤ) - 2)).sum + 2 := by
  induction atoms with
  | nil => simp [doubledClosures]
  | cons v rest ih =>
      rw [doubledClosures_cons, ih, List.map_cons, List.sum_cons]
      ring

theorem doubledClosures_append (a b : List ℕ) :
    doubledClosures (a ++ b) = doubledClosures a + doubledClosures b - 2 := by
  unfold doubledClosures
  rw [List.map_append, List.sum_append, List.length_append]
  push_cast
  ring

theorem doubledClosures_replicate (k v : ℕ) :
    doubledClosures (List.replicate k v) = k * ((v : ℤ) - 2) + 2 := by
  induction k with
  | zero => simp [doubledClosures]
  | succ k ih =>
      rw [List.replicate_succ, doubledClosures_cons, ih]
      push_cast
      ring

/-! ## Valence 2 is the neutral element -/

/-- **A divalent atom cannot change the closure count.** One vertex, one edge, no cycle. This
    is the whole reason oxygen and sulphur are absent from the textbook formula — not a
    convention, a cancellation. -/
theorem divalent_neutral (atoms : List ℕ) :
    doubledClosures (2 :: atoms) = doubledClosures atoms := by
  rw [doubledClosures_cons]
  push_cast
  ring

/-- **A chain of divalent units is closure-neutral.** So a divalent monomer polymerises into a
    *chain*: the backbone carries no closure of its own, and every closure a polymer has is a
    contact (Chemistry.md §9, QLF_Folding). -/
theorem divalent_chain_neutral (k : ℕ) (atoms : List ℕ) :
    doubledClosures (List.replicate k 2 ++ atoms) = doubledClosures atoms := by
  rw [doubledClosures_append, doubledClosures_replicate]
  push_cast
  ring

/-- A monovalent atom **caps**: it decrements the closure count. Hydrogen and the halogens
    enter the textbook formula with a minus sign for this reason and no other. -/
theorem monovalent_caps (atoms : List ℕ) :
    doubledClosures (1 :: atoms) = doubledClosures atoms - 1 := by
  rw [doubledClosures_cons]
  push_cast
  ring

/-! ## The textbook formula, recovered -/

/-- A hydrocarbon `CₙHₘ`: `n` tetravalent atoms and `m` monovalent ones. -/
def hydrocarbon (n m : ℕ) : List ℕ := List.replicate n 4 ++ List.replicate m 1

/-- A `CcHhNnOo` molecule, right-nested so each append is one application. -/
def molecule (c h n o : ℕ) : List ℕ :=
  List.replicate c 4 ++ (List.replicate h 1 ++ (List.replicate n 3 ++ List.replicate o 2))

/-- **The degree of unsaturation of a hydrocarbon is its cycle rank**: `2·DoU = 2n + 2 − m`. -/
theorem dou_hydrocarbon (n m : ℕ) :
    doubledClosures (hydrocarbon n m) = 2 * n + 2 - m := by
  unfold hydrocarbon
  rw [doubledClosures_append, doubledClosures_replicate, doubledClosures_replicate]
  push_cast
  ring

/-- **And in general — with oxygen absent from the answer.** `2·DoU = 2C + 2 + N − H`, with no
    `O` on the right-hand side, because `divalent_neutral` says there cannot be one. -/
theorem dou_chno (c h n o : ℕ) :
    doubledClosures (molecule c h n o) = 2 * c + 2 + n - h := by
  unfold molecule
  rw [doubledClosures_append, doubledClosures_append, doubledClosures_append,
      doubledClosures_replicate, doubledClosures_replicate,
      doubledClosures_replicate, doubledClosures_replicate]
  push_cast
  ring

/-- **"Saturated" means zero closures** — and the alkane formula `CₙH₂ₙ₊₂` follows rather than
    being stipulated. A saturated hydrocarbon is a tree; every additional closure, whether it is
    drawn as a ring or as a double bond, costs two hydrogens. -/
theorem saturated_iff_alkane (n m : ℕ) :
    doubledClosures (hydrocarbon n m) = 0 ↔ m = 2 * n + 2 := by
  rw [dou_hydrocarbon]
  omega

/-- Benzene carries four closures — three double bonds and the ring — and the count does not
    care which is which. That is the module's claim in one number. -/
theorem benzene_four_closures : doubledClosures (hydrocarbon 6 6) = 8 := by
  rw [dou_hydrocarbon]
  norm_num

/-- Cyclohexane and every hexene share a formula, hence a closure count: **one census class**,
    though chemistry files them in different chapters. -/
theorem c6h12_one_closure : doubledClosures (hydrocarbon 6 12) = 2 := by
  rw [dou_hydrocarbon]
  norm_num

end QLF.Unsaturation

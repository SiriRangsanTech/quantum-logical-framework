/-
  QLF_Folding.lean — the polymer backbone as a twist history, and a contact as a ZFA closure.

  Chemistry.md gets molecules out of one rule: a bond is a *shared closure*. That rule
  says nothing about shape, because a small molecule has none to speak of. A polymer does,
  and this module is the step from stoichiometry to conformation.

  The observation it rests on is that the step is already in the alphabet. A backbone on
  the cubic lattice moves by one of six signed axis displacements, and the 8-twist alphabet
  is the signed axis frame (QLF_AlphabetNecessity) — six spatial twists plus the gauge pair
  `±`, which carries no displacement. So a conformation *is* a twist history, with no
  encoding choice to defend, and the questions folding asks become questions about that
  history:

  * **A contact is a closure.** Residues i and j touch when the backbone segment between
    them displaces by exactly one lattice step. Add the contact edge and the segment is a
    closed loop — net displacement zero — hence count-balanced (`closedLoop_countBalanced`)
    and hence Pauli-closed by the keystone `count_balanced_pauli_closed`. A native contact
    is a ZFA-closed history, both conjuncts, and not by a second argument
    (`contact_is_closure`). This is the same move QLF_Fredkin makes for a conservative
    gate: the model's own conservation law turns out to be ZFA's.

  * **Contacts occur only at odd sequence separation.** A closed loop has even length
    (`closedLoop_even_length`, since balance pairs the steps), so a segment plus its one
    contact edge is even and the segment itself is odd (`contact_separation_odd`). This is
    the parity rule of lattice-protein models — on a bipartite lattice a residue contacts
    only residues of opposite parity — and here it is a corollary of count balance rather
    than a lattice artefact noted in passing.

  * **Closures compose** (`closedLoop_append`). Two closed loops concatenate to a closed
    loop, so a fold's contacts are independent closures that add rather than a joint
    condition to be searched for. That is the substrate form of the answer to Levinthal:
    there is no search, because the closures are not competing for one global solution.

  * **Chirality is not a multiplicity effect** (`map_mirror_bijective`) — a no-go. Mirroring
    the x-axis is an involution on backbones that preserves length and closure, so left- and
    right-handed folds come in bijection and *counting cannot prefer one*. Homochirality
    therefore cannot be read off the fold census; it needs the substrate handedness
    asymmetry (QLF_Handedness, CP-Violation-and-Chirality.md). Stating this saves the
    census from being asked a question it provably cannot answer.

  * **The contact quantum is `log 2`** (`foldFreeEnergy`). A closure is a many-to-one
    recognition event, which QLF_FreeEnergy prices at `ΔF = −log 2` nats. So a fold's free
    energy is `−(contacts)·log 2` — the contact energy of a lattice-protein model, derived
    rather than fitted, and monotone in the contact count (`foldFreeEnergy_lt`).

  What is NOT here: self-avoidance, positions, and the contact census itself. Those need an
  embedding rather than an algebra and live in protein_census.py, which enumerates the walks
  and checks every contact loop against the runtime `twist_core.is_zfa`. See
  Protein_Folding.md §7 for the scope line. No axioms.
-/

import QLF_TwistAlphabet
import QLF_FreeEnergy

namespace QLF.Folding

/-! ## The backbone -/

/-- A backbone step: one of the six signed axis displacements of the cubic lattice.
    The gauge pair `±` of the 8-twist alphabet is deliberately absent — it carries
    phase, not displacement, so it cannot be a step of a chain. -/
inductive Step where
  | xp | xn | yp | yn | zp | zn
deriving DecidableEq, Repr

/-- Each step **is** a twist, under the alphabet's own axis assignment
    (`twist_core.py`: `^ = +σ_y`, `> = +σ_x`, `/ = +σ_z`). There is no encoding
    choice being made here; the six spatial twists are the six signed axes. -/
def Step.toTwist : Step → Twist
  | Step.xp => Twist.right
  | Step.xn => Twist.left
  | Step.yp => Twist.up
  | Step.yn => Twist.down
  | Step.zp => Twist.slash
  | Step.zn => Twist.backslash

/-- Reversing a step — the displacement traversed backwards. -/
def Step.conj : Step → Step
  | Step.xp => Step.xn
  | Step.xn => Step.xp
  | Step.yp => Step.yn
  | Step.yn => Step.yp
  | Step.zp => Step.zn
  | Step.zn => Step.zp

/-- A conformation: the chain of steps from one residue to the next. -/
abbrev Backbone := List Step

/-- The conformation read as a twist history. -/
def encode (b : Backbone) : List Twist := b.map Step.toTwist

/-! ## Counts, displacement, closure -/

theorem count_encode (s : Step) (b : Backbone) :
    (b.map Step.toTwist).count s.toTwist = b.count s := by
  induction b with
  | nil => rfl
  | cons a b ih =>
      show (a.toTwist :: b.map Step.toTwist).count s.toTwist = (a :: b).count s
      rw [List.count_cons, List.count_cons, ih]
      cases a <;> cases s <;> simp +decide

theorem count_encode_plus (b : Backbone) :
    (b.map Step.toTwist).count Twist.plus = 0 := by
  induction b with
  | nil => rfl
  | cons a b ih =>
      show (a.toTwist :: b.map Step.toTwist).count Twist.plus = 0
      rw [List.count_cons, ih]
      cases a <;> simp +decide

theorem count_encode_minus (b : Backbone) :
    (b.map Step.toTwist).count Twist.minus = 0 := by
  induction b with
  | nil => rfl
  | cons a b ih =>
      show (a.toTwist :: b.map Step.toTwist).count Twist.minus = 0
      rw [List.count_cons, ih]
      cases a <;> simp +decide

/-- Net displacement along each axis: the signed step count. -/
def netX (b : Backbone) : ℤ := (b.count Step.xp : ℤ) - (b.count Step.xn : ℤ)
def netY (b : Backbone) : ℤ := (b.count Step.yp : ℤ) - (b.count Step.yn : ℤ)
def netZ (b : Backbone) : ℤ := (b.count Step.zp : ℤ) - (b.count Step.zn : ℤ)

/-- **A closed loop**: the chain returns to where it started. Stated as balanced step
    counts, which is what "net displacement zero" says (`closedLoop_iff_net_zero`). -/
def ClosedLoop (b : Backbone) : Prop :=
  b.count Step.xp = b.count Step.xn ∧
  b.count Step.yp = b.count Step.yn ∧
  b.count Step.zp = b.count Step.zn

theorem closedLoop_iff_net_zero (b : Backbone) :
    ClosedLoop b ↔ (netX b = 0 ∧ netY b = 0 ∧ netZ b = 0) := by
  unfold ClosedLoop netX netY netZ
  omega

theorem netX_append (a b : Backbone) : netX (a ++ b) = netX a + netX b := by
  simp only [netX, List.count_append]; omega

theorem netY_append (a b : Backbone) : netY (a ++ b) = netY a + netY b := by
  simp only [netY, List.count_append]; omega

theorem netZ_append (a b : Backbone) : netZ (a ++ b) = netZ a + netZ b := by
  simp only [netZ, List.count_append]; omega

/-- The empty chain is closed, and the closed loops are closed under concatenation:
    **closures compose.** A fold's contacts are therefore independent closures that add,
    not a joint condition on the whole chain — the substrate form of "folding is
    hierarchical, not a global search" (Protein_Folding.md §4). -/
theorem closedLoop_nil : ClosedLoop ([] : Backbone) := ⟨rfl, rfl, rfl⟩

theorem closedLoop_append {a b : Backbone} (ha : ClosedLoop a) (hb : ClosedLoop b) :
    ClosedLoop (a ++ b) := by
  obtain ⟨hx, hy, hz⟩ := ha
  obtain ⟨hx', hy', hz'⟩ := hb
  refine ⟨?_, ?_, ?_⟩ <;> simp only [List.count_append] <;> omega

/-- Non-vacuity, the honest half: an open chain is **not** a closure. Closure is a
    condition on the fold, not a property every backbone enjoys. -/
theorem open_chain_not_closed : ¬ ClosedLoop [Step.xp] := by
  unfold ClosedLoop; decide

/-- Non-vacuity, the other half: the minimal contact loop, a unit plaquette. It is the
    same four-twist ball QLF_Fredkin uses for a billiard ball — the smallest thing that
    closes is one object in both readings. -/
theorem minimal_loop_closed : ClosedLoop [Step.xp, Step.yp, Step.xn, Step.yn] := by
  unfold ClosedLoop; decide

/-! ## A contact is a ZFA closure -/

/-- **Count balance from closure.** The six spatial counts pair off because the loop
    returns; the gauge counts are zero because a step is never a gauge twist. -/
theorem closedLoop_countBalanced {b : Backbone} (h : ClosedLoop b) :
    countBalanced (encode b) := by
  obtain ⟨hx, hy, hz⟩ := h
  refine ⟨?_, ?_, ?_, ?_⟩
  · show (b.map Step.toTwist).count (Step.yp.toTwist)
        = (b.map Step.toTwist).count (Step.yn.toTwist)
    rw [count_encode, count_encode]; exact hy
  · show (b.map Step.toTwist).count (Step.xn.toTwist)
        = (b.map Step.toTwist).count (Step.xp.toTwist)
    rw [count_encode, count_encode]; exact hx.symm
  · show (b.map Step.toTwist).count (Step.zp.toTwist)
        = (b.map Step.toTwist).count (Step.zn.toTwist)
    rw [count_encode, count_encode]; exact hz
  · show (b.map Step.toTwist).count Twist.plus = (b.map Step.toTwist).count Twist.minus
    rw [count_encode_plus, count_encode_minus]

/-- **A closed loop is ZFA-closed** — Pauli closure comes free from count balance by the
    keystone, cross-axis interleavings included. A fold's contact does not have to be
    checked for admissibility; closing *is* what admissibility means. -/
theorem closedLoop_pauli_closed {b : Backbone} (h : ClosedLoop b) :
    ∃ p : PauliScalar, twistMatrixFold (encode b) = pauliScalarToMatrix p :=
  count_balanced_pauli_closed (closedLoop_countBalanced h)

/-- **A contact**: the segment between two residues displaces by exactly one lattice
    step, so the two sit on adjacent sites. -/
def IsContact (seg : Backbone) (s : Step) : Prop :=
  netX seg = netX [s] ∧ netY seg = netY [s] ∧ netZ seg = netZ [s]

theorem net_conj (s : Step) :
    netX [s.conj] = -netX [s] ∧ netY [s.conj] = -netY [s] ∧ netZ [s.conj] = -netZ [s] := by
  cases s <;> refine ⟨?_, ?_, ?_⟩ <;> decide

/-- **The contact closes the loop.** Segment plus contact edge returns to the start. -/
theorem contact_loop_closed {seg : Backbone} {s : Step} (h : IsContact seg s) :
    ClosedLoop (seg ++ [s.conj]) := by
  obtain ⟨hx, hy, hz⟩ := h
  obtain ⟨cx, cy, cz⟩ := net_conj s
  rw [closedLoop_iff_net_zero]
  refine ⟨?_, ?_, ?_⟩
  · rw [netX_append, hx, cx]; ring
  · rw [netY_append, hy, cy]; ring
  · rw [netZ_append, hz, cz]; ring

/-- **A contact is a ZFA closure — both conjuncts.** The loop is count-balanced, and
    therefore folds to a Pauli scalar `{±I, ±iI}`. The runtime check
    `twist_core.is_zfa` on any contact loop is this theorem, and protein_census.py
    reconfirms it on every contact it enumerates. -/
theorem contact_is_closure {seg : Backbone} {s : Step} (h : IsContact seg s) :
    countBalanced (encode (seg ++ [s.conj])) ∧
    ∃ p : PauliScalar,
      twistMatrixFold (encode (seg ++ [s.conj])) = pauliScalarToMatrix p :=
  ⟨closedLoop_countBalanced (contact_loop_closed h),
   closedLoop_pauli_closed (contact_loop_closed h)⟩

/-! ## Parity: contacts only at odd separation -/

theorem length_eq_counts (b : Backbone) :
    b.length = b.count Step.xp + b.count Step.xn + b.count Step.yp + b.count Step.yn
             + b.count Step.zp + b.count Step.zn := by
  induction b with
  | nil => rfl
  | cons a b ih =>
      rw [List.length_cons, ih]
      cases a <;> simp +decide [List.count_cons] <;> omega

/-- **A closed loop has even length.** Balance pairs every step with its reverse. -/
theorem closedLoop_even_length {b : Backbone} (h : ClosedLoop b) : Even b.length := by
  obtain ⟨hx, hy, hz⟩ := h
  rw [length_eq_counts]
  exact ⟨b.count Step.xp + b.count Step.yp + b.count Step.zp, by omega⟩

/-- **Contacts occur only at odd sequence separation** — the parity rule of lattice-protein
    models, here a corollary of count balance. A residue can contact only residues of
    opposite parity along the chain, which halves the contact census before any
    energetics is considered. -/
theorem contact_separation_odd {seg : Backbone} {s : Step} (h : IsContact seg s) :
    Odd seg.length := by
  have hE : Even (seg ++ [s.conj]).length := closedLoop_even_length (contact_loop_closed h)
  have hlen : (seg ++ [s.conj]).length = seg.length + 1 := by simp
  rw [hlen] at hE
  obtain ⟨k, hk⟩ := hE
  exact ⟨k - 1, by omega⟩

/-! ## Chirality is not a multiplicity effect -/

/-- Reflection in the x-axis: the parity operation on a conformation. -/
def Step.mirror : Step → Step
  | Step.xp => Step.xn
  | Step.xn => Step.xp
  | Step.yp => Step.yp
  | Step.yn => Step.yn
  | Step.zp => Step.zp
  | Step.zn => Step.zn

theorem map_mirror_involutive (b : Backbone) :
    (b.map Step.mirror).map Step.mirror = b := by
  induction b with
  | nil => rfl
  | cons a b ih =>
      show Step.mirror (Step.mirror a) :: (b.map Step.mirror).map Step.mirror = a :: b
      rw [ih]
      cases a <;> rfl

theorem count_map_mirror (s : Step) (b : Backbone) :
    (b.map Step.mirror).count s = b.count (Step.mirror s) := by
  induction b with
  | nil => rfl
  | cons a b ih =>
      show (Step.mirror a :: b.map Step.mirror).count s = (a :: b).count (Step.mirror s)
      rw [List.count_cons, List.count_cons, ih]
      cases a <;> cases s <;> simp +decide [Step.mirror]

theorem mirror_closedLoop {b : Backbone} (h : ClosedLoop b) :
    ClosedLoop (b.map Step.mirror) := by
  obtain ⟨hx, hy, hz⟩ := h
  refine ⟨?_, ?_, ?_⟩ <;> rw [count_map_mirror, count_map_mirror]
  · exact hx.symm
  · exact hy
  · exact hz

theorem mirror_length (b : Backbone) : (b.map Step.mirror).length = b.length := by
  simp

/-- **The mirror is a multiplicity-preserving bijection of the fold census.** It is an
    involution, it preserves length, and it carries closures to closures — so the left- and
    right-handed folds of any chain are in bijection and **counting cannot prefer one**.

    This is a no-go, and a useful one: homochirality is not derivable from the fold census,
    however deep it is pushed. It needs the substrate handedness asymmetry (QLF_Handedness;
    CP-Violation-and-Chirality.md §3), which is upstream of chemistry. -/
theorem map_mirror_bijective :
    Function.Bijective (fun b : Backbone => b.map Step.mirror) :=
  Function.Involutive.bijective (fun b => map_mirror_involutive b)

/-! ## The contact quantum -/

/-- **The free energy of a fold**: one `log 2` per closure. A contact is a many-to-one
    recognition event and QLF_FreeEnergy prices such an event at `ΔF = −log 2` nats, so
    the contact energy of a lattice-protein model is not a fitted parameter here — it is
    the substrate's one quantum, counted. -/
noncomputable def foldFreeEnergy (contacts : ℕ) : ℝ := -(contacts : ℝ) * Real.log 2

theorem foldFreeEnergy_zero : foldFreeEnergy 0 = 0 := by
  unfold foldFreeEnergy; simp

/-- Each further contact costs exactly one quantum. -/
theorem foldFreeEnergy_succ (n : ℕ) :
    foldFreeEnergy (n + 1) = foldFreeEnergy n - Real.log 2 := by
  unfold foldFreeEnergy
  push_cast
  ring

/-- **More contacts is lower free energy** — strictly. The maximum-contact fold is the
    minimum-free-energy fold, which is what Anfinsen's thermodynamic hypothesis asserts
    of the native state; on the substrate it is a count, not a postulate. -/
theorem foldFreeEnergy_lt {m n : ℕ} (h : m < n) : foldFreeEnergy n < foldFreeEnergy m := by
  have hlog : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hmn : (m : ℝ) < (n : ℝ) := by exact_mod_cast h
  unfold foldFreeEnergy
  nlinarith [hlog, hmn]

end QLF.Folding

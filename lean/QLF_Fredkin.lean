/-
  QLF_Fredkin.lean — Fredkin's conservative logic on the twist substrate.

  Fredkin & Toffoli (1982) built computation out of a conservation law: the Fredkin gate
  CSWAP(c; a, b) permutes its inputs, so the count of set lines coming out is the count
  going in. QLF admits a history by a conservation law too — the signed twist counts
  vanish. This module is the proof that they are the same law.

  The argument has no analysis in it, which is the point. A ball is one closed plaquette
  `^<v>` = [up, left, down, right]; an empty line is the empty history; a register is the
  concatenation of its three lines. The gate permutes lines, so `encode (fredkin r)` is a
  *permutation* of `encode r` (`encode_fredkin_perm`), and a permutation preserves every
  count. Count balance therefore carries over as a relabelling rather than as a check that
  happens to pass.

  The last step is the keystone `count_balanced_pauli_closed` (QLF_TwistAlphabet): count
  balance entails Pauli closure for every history, cross-axis interleavings included. So
  full ZFA — both conjuncts — is preserved without a second argument, and the
  order-sensitive half comes for free.

  What this does NOT claim: that the encoding is the only faithful one, or anything about
  the billiard-ball dynamics. See Fredkin_QLF.md §6 for scope, and fredkin_qlf.py for the
  circuits (universality, a Fredkin-only full adder) that live outside Lean.
-/

import QLF_TwistAlphabet

namespace QLF.Fredkin

/-! ## The gate -/

/-- A three-line register: one control and two targets. -/
structure Reg where
  c : Bool
  a : Bool
  b : Bool
deriving DecidableEq, Repr

/-- **The Fredkin gate** — a controlled swap. The control passes through untouched; the
    targets exchange when it is set. Written by pattern match rather than `if`, so every
    proof below closes by case analysis and reduction. -/
def fredkin : Reg → Reg
  | ⟨true,  a, b⟩ => ⟨true,  b, a⟩
  | ⟨false, a, b⟩ => ⟨false, a, b⟩

/-- **The gate is its own inverse.** Running it twice restores the register, so no
    computation is lost by running it. -/
theorem fredkin_involutive (r : Reg) : fredkin (fredkin r) = r := by
  rcases r with ⟨c, a, b⟩
  cases c <;> rfl

/-- **The gate is a bijection.** This is the premise of the free-energy ledger: the map is
    one-to-one, so no two histories merge, nothing becomes unrecoverable, and there is no
    many-to-one closure to receipt. The `ΔF = −log 2` quantum (QLF_FreeEnergy) is the price
    of forgetting, and a permutation forgets nothing — the reversible core is free, and the
    bill is exactly the garbage one declines to keep. See Fredkin_QLF.md §5. -/
theorem fredkin_bijective : Function.Bijective fredkin :=
  Function.Involutive.bijective fredkin_involutive

/-- The number of set lines — Fredkin's conserved quantity, the count of balls. -/
def weight (r : Reg) : ℕ :=
  (if r.c then 1 else 0) + (if r.a then 1 else 0) + (if r.b then 1 else 0)

/-- **The gate is conservative**: it routes, it does not create or destroy. -/
theorem fredkin_conserves_weight (r : Reg) : weight (fredkin r) = weight r := by
  rcases r with ⟨c, a, b⟩
  cases c <;> cases a <;> cases b <;> rfl

/-! ## The encoding -/

/-- **One ball**: `^<v>` — up, left, down, right, the minimal closed plaquette. It is
    count-balanced and, by the keystone, Pauli-closed. It is *a* ball and not *the* ball:
    168 of the 4096 length-4 histories close (`fredkin_qlf.py` §8), and per the working
    method the count is the physical content while the exhibited witness is not. -/
def ball : List Twist := [Twist.up, Twist.left, Twist.down, Twist.right]

/-- A line carries a ball or nothing. Absence contributes no twists — it is the zero of
    the algebra, not a defective history. -/
def line : Bool → List Twist
  | true  => ball
  | false => []

/-- A register as one history. The right-nested bracketing is deliberate: it puts the two
    swapped lines in a single sub-append, which is exactly what the permutation argument
    needs. -/
def encode (r : Reg) : List Twist := line r.c ++ (line r.a ++ line r.b)

/-- **The gate acts by permutation.** The control's contribution is untouched and the two
    target contributions are exchanged, so the output history is a rearrangement of the
    input's letters — not a different multiset that happens to have the same counts. -/
theorem encode_fredkin_perm (r : Reg) : (encode (fredkin r)).Perm (encode r) := by
  rcases r with ⟨c, a, b⟩
  cases c
  · exact List.Perm.refl _
  · exact List.Perm.append_left _ List.perm_append_comm

/-- **Every count is preserved**, for every twist, because a permutation preserves counts. -/
theorem fredkin_preserves_counts (r : Reg) (t : Twist) :
    (encode (fredkin r)).count t = (encode r).count t :=
  (encode_fredkin_perm r).count_eq t

/-! ## The identification -/

/-- **Every register encodes to a count-balanced history.** Each ball is balanced on its
    own and concatenation adds counts, so a register of balls is balanced whatever it
    holds — the substrate admits every state of the machine. -/
theorem encode_countBalanced (r : Reg) : countBalanced (encode r) := by
  rcases r with ⟨c, a, b⟩
  cases c <;> cases a <;> cases b <;>
    refine ⟨?_, ?_, ?_, ?_⟩ <;> rfl

/-- **The gate preserves count balance** — Fredkin's conservation law *is* ZFA's. Stated in
    the conditional form to make the direction explicit, though `encode_countBalanced`
    shows the hypothesis is never in doubt. -/
theorem fredkin_preserves_countBalanced {r : Reg} (h : countBalanced (encode r)) :
    countBalanced (encode (fredkin r)) := by
  obtain ⟨hUD, hLR, hSB, hPM⟩ := h
  refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [fredkin_preserves_counts, fredkin_preserves_counts]
  · exact hUD
  · exact hLR
  · exact hSB
  · exact hPM

/-- **The Fredkin gate cannot take a realized history to an unrealized one.** The output
    folds to a Pauli scalar `{±I, ±iI}`, so it satisfies the order-sensitive conjunct of
    runtime ZFA as well as the count conjunct — and neither needed its own argument, since
    `count_balanced_pauli_closed` hands the second one over from the first.

    This is the module's point. Admissibility on the substrate is not something a
    conservative gate must be checked against; it is the same conservation law the gate was
    built to obey. -/
theorem fredkin_preserves_zfa (r : Reg) :
    ∃ p : PauliScalar, twistMatrixFold (encode (fredkin r)) = pauliScalarToMatrix p :=
  count_balanced_pauli_closed (encode_countBalanced (fredkin r))

end QLF.Fredkin

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
import QLF_FreeEnergy

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

/-! ## The free-energy ledger — the reversible core is free, the bill is external

    `QLF_FreeEnergy` attaches one quantum `binary_kl 1 (1/2) = log 2` to a *many-to-one*
    closure — the price of forgetting one bit. A Fredkin gate is a bijection
    (`fredkin_bijective`), so it forgets nothing and carries no such quantum; and a
    composition of gates is still a bijection (`fredkin_iterate_bijective`), so a whole
    reversible circuit carries none either, **regardless of gate count**. The only cost is
    the garbage a holder *declines* to keep — an optional external reset whose size is a
    function of the retained-line count and says nothing about the circuit that produced
    it. This is what §5 of `Fredkin_QLF.md` states in prose; the theorems below pin it. -/

/-- **The external tidy-up cost of discarding `k` garbage lines.** Resetting `k` bits to
    zero is a `2^k → 1` map — `k` many-to-one closures — so it costs `k · log 2` nats. It
    is a function of the *retained garbage count* `k`, not of the circuit: the gate count
    does not appear. -/
noncomputable def garbageBill (k : ℕ) : ℝ := (k : ℝ) * Real.log 2

/-- Each reset bit is exactly one half-spin ZFA closure quantum (`QLF_FreeEnergy`). The
    bill is not a separate erasure postulate — it is `k` copies of the one closure
    quantum QLF already has. -/
theorem garbageBill_eq_closures (k : ℕ) :
    garbageBill k = (k : ℝ) * QLF.binary_kl 1 (1/2) := by
  rw [garbageBill, QLF.binary_kl_delta_uniform]

/-- **Running the reversible circuit is free.** Keep every line — `k = 0` — and the bill
    is zero, whatever the gate count. The reversible core sits on the free side of the
    many-to-one line and never crosses it. -/
theorem reversible_run_cost_zero : garbageBill 0 = 0 := by
  simp [garbageBill]

/-- **A circuit of Fredkin gates is still a bijection**, to any depth `n` — so the
    "nothing merges, so nothing is receipted" premise of `reversible_run_cost_zero`
    survives composition. `n` gates deep, the state map is `fredkin^[n]`. -/
theorem fredkin_iterate_bijective (n : ℕ) : Function.Bijective (fredkin^[n]) := by
  induction n with
  | zero => simpa using Function.bijective_id
  | succ m ih =>
      rw [Function.iterate_succ]
      exact ih.comp fredkin_bijective

/-- **The bill is strictly positive exactly when garbage is discarded** — `0 < garbageBill k
    ↔ 0 < k`. Landauer/Bennett recovered: the cost lands precisely where, and only where,
    the computation stops being one-to-one. -/
theorem garbageBill_pos_iff (k : ℕ) : 0 < garbageBill k ↔ 0 < k := by
  rw [garbageBill]
  have hlog : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  constructor
  · intro h
    rcases Nat.eq_zero_or_pos k with hk | hk
    · rw [hk] at h; simp at h
    · exact hk
  · intro hk
    have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
    exact mul_pos hkR hlog

end QLF.Fredkin

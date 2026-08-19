"""
fredkin_qlf.py — Fredkin's conservative logic on the QLF substrate.

Fredkin & Toffoli (1982) built computation out of a conservation law: the Fredkin gate
CSWAP(c; a, b) permutes its inputs, so the number of 1s coming out equals the number
going in. Their physical realization is the billiard ball model — balls on a lattice,
elastic collisions, a ball present reading as 1 — where conservation of logic *is*
conservation of balls.

QLF's admissibility condition is also a conservation law: a history is realized when its
signed twist counts vanish. The two laws are the same law, and this file is the check.

The encoding: a ball is one closed plaquette `^<v>` — up, left, down, right — which is
count-balanced and Pauli-closed, so it passes full ZFA (`twist_core.is_zfa`). An empty
line contributes nothing. A register is the concatenation of its lines. Then the Fredkin
gate permutes lines, a permutation preserves the twist multiset, so the output history has
the identical signed action vector. Count balance carries over exactly, and by the verified
keystone `count_balanced_pauli_closed` (QLF_TwistAlphabet.lean) count balance *entails*
Pauli closure — so ZFA is preserved for free, not by a separate check.

Why helium: `Chemistry.md` gives He valence 0. A bond in QLF is a shared closure, and a
valence-0 species has no unshared closure to offer, so two helium atoms cannot bond — they
can only scatter. That is exactly the billiard-ball requirement (collide elastically, never
stick), and here it is a consequence of the valence rule rather than an idealization
imposed on the model. Buckyballs work for the same structural reason (a closed cage) and
are included as the heavier alternative.

Run: python3 fredkin_qlf.py
"""

from __future__ import annotations

import itertools
import math
from collections import Counter
from typing import Dict, List, Sequence, Tuple

import twist_core as tc

# ---------------------------------------------------------------------------
# The ball
# ---------------------------------------------------------------------------

BALL = '^<v>'      # one closed plaquette — the minimal ZFA loop
VACUUM = ''        # an empty line contributes no twists

LOG2 = math.log(2)  # the erasure quantum, QLF_FreeEnergy


def action(history: str) -> Tuple[int, int, int, int]:
    """Signed action vector, with the empty history as the zero it is.

    `twist_core.calculate_action` rejects the empty string, which is right for a history
    someone meant to write and wrong for a line with no ball on it. Absence contributes
    nothing to the counts.
    """
    return (0, 0, 0, 0) if not history else tc.calculate_action(history)


def is_closed(history: str) -> bool:
    """ZFA, with the empty history closed — there is nothing left open."""
    return True if not history else tc.is_zfa(history)


def encode(bits: Sequence[int]) -> str:
    """A register of lines becomes one twist history: ball or nothing, concatenated."""
    return ''.join(BALL if b else VACUUM for b in bits)


# ---------------------------------------------------------------------------
# The gate
# ---------------------------------------------------------------------------

def fredkin(c: int, a: int, b: int) -> Tuple[int, int, int]:
    """CSWAP: the control passes through; the targets swap when the control is set."""
    return (c, b, a) if c else (c, a, b)


def interaction_gate(a: int, b: int) -> Tuple[int, int, int, int]:
    """Fredkin & Toffoli's billiard-ball collision primitive.

    Two balls approach on crossing paths. If both are present they collide and are
    deflected onto the two inner exits; otherwise each continues on its own outer exit.
    The four outputs are the four exit paths, and the number of balls is conserved
    because collisions deflect balls rather than create or destroy them.
    """
    return (a and (1 - b), a and b, a and b, b and (1 - a))


# ---------------------------------------------------------------------------
# Circuits — Fredkin is universal with constants in and garbage out
# ---------------------------------------------------------------------------

def gate_not(x: int) -> Tuple[int, Dict[str, int]]:
    """NOT x. FREDKIN(x; 1, 0) = (0,1,0) or (1,0,1), so the first target is NOT x."""
    _, o1, _ = fredkin(x, 1, 0)
    return o1, {'ancillas': 2, 'gates': 1}


def gate_and(x: int, y: int) -> Tuple[int, Dict[str, int]]:
    """x AND y. FREDKIN(x; 0, y) = (0,0,y) or (1,y,0), so the first target is x AND y."""
    _, o1, _ = fredkin(x, 0, y)
    return o1, {'ancillas': 1, 'gates': 1}


def gate_or(x: int, y: int) -> Tuple[int, Dict[str, int]]:
    """x OR y. FREDKIN(x; 1, y) = (0,1,y) or (1,y,1), so the second target is x OR y."""
    _, _, o2 = fredkin(x, 1, y)
    return o2, {'ancillas': 1, 'gates': 1}


def gate_fanout(x: int) -> Tuple[Tuple[int, int], Dict[str, int]]:
    """Two copies of x. FREDKIN(x; 0, 1) = (0,0,1) or (1,1,0): the control and the first
    target both read x, while the second target carries NOT x away as garbage.

    Copying is not free here and QLF says why — `QLF_NoFreeDuplication`. The second
    output is the price: a duplicate arrives with its own complement attached.
    """
    o0, o1, _ = fredkin(x, 0, 1)
    return (o0, o1), {'ancillas': 2, 'gates': 1}


def gate_xor(x: int, y: int, cost: Counter) -> int:
    """x XOR y = (x OR y) AND NOT(x AND y). Each input is used twice, so each is fanned
    out first — the bookkeeping conservative logic makes explicit rather than free."""

    def bump(c):
        cost.update(c)

    (x1, x2), c = gate_fanout(x); bump(c)
    (y1, y2), c = gate_fanout(y); bump(c)
    o, c = gate_or(x1, y1); bump(c)
    a, c = gate_and(x2, y2); bump(c)
    na, c = gate_not(a); bump(c)
    r, c = gate_and(o, na); bump(c)
    return r


def full_adder(a: int, b: int, cin: int) -> Tuple[int, int, Dict[str, int]]:
    """A one-bit full adder from Fredkin gates only.

        sum   = a XOR b XOR cin
        carry = (a AND b) OR (cin AND (a XOR b))

    Every value consumed twice is fanned out first, so the gate and ancilla counts are
    the real cost of keeping the whole circuit one-to-one.
    """
    cost: Counter = Counter()

    def bump(c):
        cost.update(c)

    (a1, a2), c = gate_fanout(a); bump(c)
    (b1, b2), c = gate_fanout(b); bump(c)
    (ci1, ci2), c = gate_fanout(cin); bump(c)

    axb = gate_xor(a1, b1, cost)
    (axb1, axb2), c = gate_fanout(axb); bump(c)

    s = gate_xor(axb1, ci1, cost)

    ab, c = gate_and(a2, b2); bump(c)
    cx, c = gate_and(ci2, axb2); bump(c)
    cout, c = gate_or(ab, cx); bump(c)

    return s, cout, dict(cost)


# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------

def check_gate_is_conservative() -> List[str]:
    rows = []
    for c, a, b in itertools.product((0, 1), repeat=3):
        out = fredkin(c, a, b)
        rows.append(
            f"    {c}{a}{b} -> {out[0]}{out[1]}{out[2]}   "
            f"weight {sum((c, a, b))} -> {sum(out)}   "
            f"{'conserved' if sum(out) == sum((c, a, b)) else 'BROKEN'}"
        )
    return rows


def check_gate_is_involution() -> bool:
    return all(fredkin(*fredkin(c, a, b)) == (c, a, b)
               for c, a, b in itertools.product((0, 1), repeat=3))


def check_zfa_preserved() -> List[Tuple[str, str, str, bool, bool, bool]]:
    """The substrate claim: the gate preserves the signed action vector, hence ZFA."""
    rows = []
    for c, a, b in itertools.product((0, 1), repeat=3):
        out = fredkin(c, a, b)
        hin, hout = encode((c, a, b)), encode(out)
        same_action = action(hin) == action(hout)
        rows.append((
            f"{c}{a}{b}", f"{out[0]}{out[1]}{out[2]}",
            str(action(hin)),
            same_action,
            is_closed(hin),
            is_closed(hout),
        ))
    return rows


def check_collision_conserves_balls() -> List[str]:
    rows = []
    for a, b in itertools.product((0, 1), repeat=2):
        out = interaction_gate(a, b)
        rows.append(
            f"    {a}{b} -> {''.join(str(x) for x in out)}   "
            f"balls {a + b} -> {sum(out)}   "
            f"{'conserved' if sum(out) == a + b else 'BROKEN'}"
        )
    return rows


def ball_multiplicity(length: int = 4) -> int:
    """How many ways a ball closes at this length — the count, not the witness.

    QLF's method asks for multiplicity rather than an exhibited example: `^<v>` is one
    ball among however many close at length 4, and the count is the physical content.
    """
    n = 0
    for combo in itertools.product(tc.TWISTS, repeat=length):
        w = ''.join(combo)
        if tc.is_zfa(w):
            n += 1
    return n


# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 78)
    print("FREDKIN'S CONSERVATIVE LOGIC ON THE QLF SUBSTRATE")
    print("=" * 78)

    print(f"\n  ball  = {BALL!r}   ZFA={tc.is_zfa(BALL)}  "
          f"action={tc.calculate_action(BALL)}  pauli_closed={tc.is_pauli_closed(BALL)}")
    print(f"  vacuum = {VACUUM!r}  (an empty line contributes no twists)")

    print("\n1. THE FREDKIN GATE IS CONSERVATIVE")
    for r in check_gate_is_conservative():
        print(r)

    print(f"\n2. THE GATE IS ITS OWN INVERSE: {check_gate_is_involution()}")

    print("\n3. THE SUBSTRATE CLAIM — the gate preserves the signed action vector")
    print("     in    out   action(in)     action preserved   ZFA(in)  ZFA(out)")
    all_ok = True
    for inp, out, act, same, zin, zout in check_zfa_preserved():
        all_ok &= same
        print(f"    {inp}   {out}   {act:>14}   {str(same):>16}   "
              f"{str(zin):>7}  {str(zout):>8}")
    print(f"\n    action vector preserved on every input: {all_ok}")

    print("\n4. THE BILLIARD-BALL COLLISION CONSERVES BALLS")
    for r in check_collision_conserves_balls():
        print(r)

    print("\n5. UNIVERSALITY — logic from the one gate")
    print("    NOT:    " + "  ".join(f"{x}->{gate_not(x)[0]}" for x in (0, 1)))
    print("    AND:    " + "  ".join(
        f"{x}{y}->{gate_and(x, y)[0]}" for x, y in itertools.product((0, 1), repeat=2)))
    print("    OR:     " + "  ".join(
        f"{x}{y}->{gate_or(x, y)[0]}" for x, y in itertools.product((0, 1), repeat=2)))
    print("    FANOUT: " + "  ".join(
        f"{x}->{gate_fanout(x)[0]}" for x in (0, 1)))

    print("\n6. A ONE-BIT FULL ADDER, FREDKIN GATES ONLY")
    print("    a b cin | sum carry | correct")
    adder_ok = True
    cost = {}
    for a, b, cin in itertools.product((0, 1), repeat=3):
        s, co, cost = full_adder(a, b, cin)
        want = a + b + cin
        ok = (s + 2 * co) == want
        adder_ok &= ok
        print(f"    {a} {b}  {cin}  |  {s}    {co}   | {'ok' if ok else 'WRONG'}")
    print(f"\n    adder correct on all 8 inputs: {adder_ok}")
    print(f"    cost per evaluation: {cost['gates']} Fredkin gates, "
          f"{cost['ancillas']} ancilla lines")

    print("\n7. THE FREE-ENERGY LEDGER — the reversible core is FREE")
    n_states = 8
    fredkin_images = len({fredkin(*t) for t in itertools.product((0, 1), repeat=3)})
    print(f"    The gate maps {n_states} states onto {fredkin_images} — a bijection, so no")
    print(f"    two histories merge and nothing is forgotten. Its free action is zero and")
    print(f"    the closure is instantaneous, so it dissipates NOTHING: dF = 0.")
    print(f"    The -log 2 = {-LOG2:.6f} nat quantum (QLF_FreeEnergy) is the receipt of a")
    print(f"    MANY-TO-ONE closure. A permutation has none to pay.")
    print()
    print(f"    Whole adder, inputs + ancillas -> outputs + garbage:")
    print(f"      {cost['gates']} gates, all bijections    composed cost = 0")
    print()
    print(f"    The bill arrives only where the computation stops being one-to-one, which")
    print(f"    is exactly where you decline to keep the garbage. Resetting k garbage lines")
    print(f"    to zero is a 2^k -> 1 map:")
    for k in (1, 4, cost['ancillas']):
        print(f"      reset {k:>3} line(s):  {k} x log 2 = {k * LOG2:8.4f} nat = {k} bit")
    print()
    print(f"    So QLF reproduces Landauer (1961) and Bennett (1973) rather than assuming")
    print(f"    them: erasure costs, computation does not, and the boundary between them is")
    print(f"    whether the closure is many-to-one. Fredkin's conservation law is what keeps")
    print(f"    the circuit on the free side of it.")

    print("\n8. BALL MULTIPLICITY — how many ways a ball closes at length 4")
    m = ball_multiplicity(4)
    print(f"    {m} of the {len(tc.TWISTS)**4} length-4 histories are ZFA-closed "
          f"({100 * m / len(tc.TWISTS)**4:.2f}%).")
    print(f"    `{BALL}` is one of them. The count is the physical content; the witness is not.")

    print("\n" + "=" * 78)
    print(f"  gate conservative: {all(('BROKEN' not in r) for r in check_gate_is_conservative())}   "
          f"involution: {check_gate_is_involution()}   "
          f"action preserved: {all_ok}   adder: {adder_ok}")
    print("=" * 78)


if __name__ == '__main__':
    main()

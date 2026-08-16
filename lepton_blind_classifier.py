#!/usr/bin/env python3
"""
lepton_blind_classifier.py — blind topology test for QLF issue #140.

This deliberately avoids using measured lepton masses to select candidates.
It tests whether the existing QLF spatial alphabet, ZFA closure, axis content,
and baryon winding independently single out elementary lepton classes.

Key diagnostic:
`QLF_BaryonWinding.baryonNumber` is rooted-history dependent rather than
cyclically invariant for a closed word. Therefore a written B=0 representative
cannot automatically be treated as a topological free-lepton class unless the
root/cut has physical meaning.

Run from the quantum-logical-framework repository root:
    python3 lepton_blind_classifier.py
"""

from __future__ import annotations

import itertools
from collections import Counter

from twist_core import calculate_action, is_pauli_closed

SPATIAL = "^v<>/\\"
AXIS = {'^': 'Y', 'v': 'Y', '>': 'X', '<': 'X', '/': 'Z', '\\': 'Z'}

_EVEN = {('X', 'Y', 'Z'), ('Y', 'Z', 'X'), ('Z', 'X', 'Y')}
_ODD = {('X', 'Z', 'Y'), ('Z', 'Y', 'X'), ('Y', 'X', 'Z')}


def sign_triple(a: str, b: str, c: str) -> int:
    t = (a, b, c)
    return 1 if t in _EVEN else -1 if t in _ODD else 0


def baryon_number(h: str) -> int:
    ax = [AXIS[t] for t in h]
    return sum(
        sign_triple(ax[i], ax[i + 1], ax[i + 2])
        for i in range(len(ax) - 2)
    )


def cyclic_shifts(h: str):
    return [h[k:] + h[:k] for k in range(len(h))]


def cyclic_baryon_signature(h: str) -> tuple[int, ...]:
    return tuple(baryon_number(s) for s in cyclic_shifts(h))


def axes_engaged(h: str) -> str:
    return "".join(sorted({AXIS[t] for t in h}))


def spatial_zfa(h: str) -> bool:
    return all(x == 0 for x in calculate_action(h)) and is_pauli_closed(h)


def cyclic_irreducible(h: str) -> bool:
    """No proper contiguous cyclic substring is itself spatial ZFA."""
    n = len(h)
    doubled = h + h
    for start in range(n):
        for length in range(2, n):
            if length % 2:
                continue
            if spatial_zfa(doubled[start:start + length]):
                return False
    return True


def cut_invariant_free(h: str) -> bool:
    return all(b == 0 for b in cyclic_baryon_signature(h))


def balanced_words(length: int):
    for tup in itertools.product(SPATIAL, repeat=length):
        h = "".join(tup)
        c = Counter(h)
        if c['^'] != c['v'] or c['>'] != c['<'] or c['/'] != c['\\']:
            continue
        if is_pauli_closed(h):
            yield h


def summarize(length: int) -> dict[str, int]:
    out = {
        "zfa": 0,
        "rooted_B0": 0,
        "primitive": 0,
        "cut_invariant_B0": 0,
        "primitive_cut_invariant_B0": 0,
        "rooted_3axis_B0": 0,
        "primitive_3axis": 0,
        "primitive_3axis_cut_invariant_B0": 0,
    }

    for h in balanced_words(length):
        out["zfa"] += 1
        rooted = baryon_number(h) == 0
        prim = cyclic_irreducible(h)
        inv = cut_invariant_free(h)
        three = len(axes_engaged(h)) == 3

        out["rooted_B0"] += int(rooted)
        out["primitive"] += int(prim)
        out["cut_invariant_B0"] += int(inv)
        out["primitive_cut_invariant_B0"] += int(prim and inv)
        out["rooted_3axis_B0"] += int(rooted and three)
        out["primitive_3axis"] += int(prim and three)
        out["primitive_3axis_cut_invariant_B0"] += int(prim and three and inv)

    return out


def first_cut_dependent_example(length: int = 6):
    for h in balanced_words(length):
        sig = cyclic_baryon_signature(h)
        if 0 in sig and any(b != 0 for b in sig):
            return h, sig
    return None


def first_examples(length: int, predicate, limit: int = 5):
    out = []
    for h in balanced_words(length):
        if predicate(h):
            out.append(h)
            if len(out) >= limit:
                break
    return out


def main() -> None:
    print("=== ISSUE #140: BLIND LEPTON TOPOLOGY TEST ===\n")

    electron = "^<v>"
    print("Electron anchor:")
    print(
        f"  h={electron} axes={axes_engaged(electron)} "
        f"ZFA={spatial_zfa(electron)} B={baryon_number(electron)} "
        f"cyclic-B={cyclic_baryon_signature(electron)} "
        f"primitive={cyclic_irreducible(electron)}"
    )
    print()

    print("1. Is baryon number invariant under changing the cut?")
    witness = first_cut_dependent_example(6)
    if witness:
        h, sig = witness
        print(f"  NO: {h} has cyclic-B={sig}")
        print("  Current B is rooted-history dependent, not a closed-loop invariant.")
    print()

    tau_demo = "^v<>/\\"
    print("2. Previously cited 3-axis candidate:")
    print(
        f"  h={tau_demo} axes={axes_engaged(tau_demo)} "
        f"ZFA={spatial_zfa(tau_demo)} B={baryon_number(tau_demo)} "
        f"cyclic-B={cyclic_baryon_signature(tau_demo)} "
        f"primitive={cyclic_irreducible(tau_demo)}"
    )
    print("  It is rooted-B=0 but reducible into proper ZFA subclosures.")
    print()

    print("3. Blind census:")
    for L in (4, 6, 8):
        print(f"  L={L}: {summarize(L)}")
    print()

    print("Primitive 3-axis L=6 examples:")
    for h in first_examples(
        6, lambda h: cyclic_irreducible(h) and len(axes_engaged(h)) == 3, 3
    ):
        print(
            f"  {h} B={baryon_number(h):+d} "
            f"cyclic-B={cyclic_baryon_signature(h)}"
        )
    print()

    invariant = first_examples(
        8,
        lambda h: (
            cyclic_irreducible(h)
            and len(axes_engaged(h)) == 3
            and cut_invariant_free(h)
        ),
        3,
    )
    print("Primitive 3-axis, cut-invariant B=0 through L=8:",
          invariant or "NONE FOUND")
    print()

    print("VERDICT")
    print("  The simple e/mu/tau = successive elementary loop classes is not yet derived.")
    print("  #140 first has to choose between:")
    print("    A) physically rooted causal histories, where the root is part of the state; or")
    print("    B) closed loops modulo cyclic shift, requiring a cyclic baryon invariant.")
    print("  Do not expose the measured mass ratios to the selector until that is resolved.")


if __name__ == "__main__":
    main()

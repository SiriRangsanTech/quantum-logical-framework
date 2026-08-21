#!/usr/bin/env python3
"""Alphabet necessity — why the substrate alphabet has exactly eight twists.

The companion computation to `lean/QLF_AlphabetNecessity.lean`. Everything here
is exhaustive over a finite domain, so the outputs are *exact computational
results* by `ScientificApproach.md` §3, and every claim the Lean module proves
is asserted here against the mapping `twist_core.py` actually uses at runtime.

The argument, in one line:

    alphabet = signed axis frame  =>  |alphabet| = 2 * |axis set|,
    and an axis set closed under composition is a subgroup of the Klein
    four-group, so |axis set| in {1,2,4} and |alphabet| in {2,4,8}.

Run:  python3 alphabet_necessity.py
"""
from itertools import combinations, product

from twist_core import TWISTS, PAULI_MAP, _mat_mul

I  = (1, 0, 0, 1)
NI = (-1, 0, 0, -1)
SX = (0, 1, 1, 0)
SY = (0, -1j, 1j, 0)
SZ = (1, 0, 0, -1)

FRAME = {"I": I, "X": SX, "Y": SY, "Z": SZ}
AXES = ["I", "X", "Y", "Z"]

# Klein four-group law on axes (composition modulo phase).
KLEIN = {
    ("I", a): a for a in AXES
}
KLEIN.update({(a, "I"): a for a in AXES})
KLEIN.update({(a, a): "I" for a in AXES})
KLEIN.update({("X", "Y"): "Z", ("Y", "X"): "Z",
              ("Y", "Z"): "X", ("Z", "Y"): "X",
              ("Z", "X"): "Y", ("X", "Z"): "Y"})


def scale(m, c):
    return tuple(c * e for e in m)


def close_to(m, tol=1e-12):
    """Round a matrix's entries so it can be used as a dict key."""
    return tuple(complex(round(e.real, 9) + 0j) + 1j * round(e.imag, 9) for e in
                 (complex(x) for x in m))


def signed_frame(axis_set):
    """The alphabet a set of axes generates: one element per sign per axis."""
    out = []
    for a in axis_set:
        out.append(close_to(FRAME[a]))
        out.append(close_to(scale(FRAME[a], -1)))
    return out


def generated_group(alphabet):
    """Closure of an alphabet under matrix multiplication."""
    seen = set(alphabet)
    frontier = list(seen)
    while frontier:
        new = []
        for m in frontier:
            for n in seen.copy():
                for prod in (_mat_mul(m, n), _mat_mul(n, m)):
                    k = close_to(prod)
                    if k not in seen:
                        seen.add(k)
                        new.append(k)
        frontier = new
    return seen


def is_abelian(group):
    return all(close_to(_mat_mul(a, b)) == close_to(_mat_mul(b, a))
               for a in group for b in group)


def check(label, ok, detail=""):
    print(f"  [{'ok' if ok else 'FAIL'}] {label}" + (f"  — {detail}" if detail else ""))
    assert ok, label


def main() -> None:
    print("=" * 72)
    print("ALPHABET NECESSITY — exhaustive over all 16 candidate axis sets")
    print("=" * 72)

    # ---------------------------------------------------------------- 1
    print("\n1. The runtime alphabet IS the signed Pauli frame")
    full = set(signed_frame(AXES))
    runtime = {close_to(PAULI_MAP[t]) for t in TWISTS}
    check("twist_core's 8 twists = {+-I, +-sx, +-sy, +-sz}", runtime == full,
          f"|alphabet| = {len(runtime)} = 2 x {len(AXES)}")
    check("the alphabet is closed under negation (conjugate pairing)",
          all(close_to(scale(m, -1)) in runtime for m in runtime),
          "4 conjugate pairs = 4 axes = the 4 terms of F(h)")

    # ---------------------------------------------------------------- 2
    print("\n2. Axis composition is the Klein four-group")
    ok = True
    for a, b in product(AXES, AXES):
        prod = _mat_mul(FRAME[a], FRAME[b])
        target = FRAME[KLEIN[(a, b)]]
        # equal up to a phase in mu_4
        ok &= any(close_to(prod) == close_to(scale(target, p))
                  for p in (1, -1, 1j, -1j))
    check("sigma_a sigma_b = phase * sigma_(a.b) with phase in mu_4", ok)
    check("every axis is self-inverse", all(KLEIN[(a, a)] == "I" for a in AXES))
    check("two distinct non-identity axes compose to the third",
          all(KLEIN[(a, b)] not in ("I", a, b)
              for a, b in combinations(["X", "Y", "Z"], 2)))

    # ---------------------------------------------------------------- 3
    print("\n3. Which axis sets are closed?  (all 2^4 = 16 candidates)")
    frames = []
    for r in range(5):
        for cand in combinations(AXES, r):
            if not cand:
                continue
            if all(KLEIN[(a, b)] in cand for a in cand for b in cand):
                frames.append(cand)
    for f in frames:
        print(f"     closed: {'{' + ','.join(f) + '}':12s} "
              f"|axes| = {len(f)}  |alphabet| = {2 * len(f)}")
    sizes = sorted({len(f) for f in frames})
    check("closed axis-set sizes are exactly {1,2,4}", sizes == [1, 2, 4],
          "Lagrange: |subgroup| divides |Klein| = 4")
    check("no closed axis set of size 3", not any(len(f) == 3 for f in frames),
          "=> THERE IS NO SIX-TWIST ALPHABET")
    check("every closed set contains I", all("I" in f for f in frames),
          "the gauge pair +/- is forced, not added")
    check("two spatial axes force the third",
          all(len(f) == 4 for f in frames
              if len([a for a in f if a != "I"]) >= 2),
          "so the spatial axis count is 0, 1 or 3 — never 2")

    # ---------------------------------------------------------------- 4
    print("\n4. What each admissible alphabet can do")
    alphabet_sizes = []
    for f in frames:
        alpha = signed_frame(f)
        g = generated_group(alpha)
        ab = is_abelian(g)
        has_i = close_to(scale(I, 1j)) in g
        alphabet_sizes.append(2 * len(f))
        print(f"     |alphabet| = {2 * len(f)}  ({'{' + ','.join(f) + '}'})"
              f"  fold group order {len(g):2d}"
              f"  {'abelian    ' if ab else 'NON-ABELIAN'}"
              f"  reaches +-iI: {has_i}")
    check("alphabet sizes are exactly {2,4,8}",
          sorted(set(alphabet_sizes)) == [2, 4, 8])
    nonabelian = [2 * len(f) for f in frames
                  if not is_abelian(generated_group(signed_frame(f)))]
    check("non-commuting observables occur only at |alphabet| = 8",
          set(nonabelian) == {8},
          "=> 8 is the unique size with an uncertainty relation, "
          "SU(2), and a double cover")

    print("\n" + "=" * 72)
    print("CONCLUSION")
    print("=" * 72)
    print("""
  |alphabet| = 2 x |axis set|, and the axis set is a subgroup of the Klein
  four-group, so the alphabet size is QUANTIZED:

      2  — {+-I}: no axes, no space, every fold a sign
      4  — one axis: abelian, no non-commuting observables, no double cover
      8  — three axes: the unique size carrying non-commuting observables
      6  — IMPOSSIBLE (3 does not divide 4)

  Eight is therefore forced by one requirement — that two spatial directions
  be distinguishable. What remains posited is that an elementary distinction
  IS a signed element of the observable frame of a two-valued system; the
  two-valuedness is QLF_SpinorInformation's spin_half_is_information_atom.

  Lean: lean/QLF_AlphabetNecessity.lean      Doc: eight-twists-sufficiency.md §7
""")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
lepton_flavor_axes.py — the axis (colour) content of lepton-like closures.

An easy step toward issue #140 (lepton flavor mass-ratio map + μ/τ colour
content). QLF says colour = the three spatial axes; a lepton is a colour
**singlet** (B = 0, free), but the electron loop `^<v>` is machine-verified to
engage **two** axes {x, y} (`interleaved_xlvr_folds_to_negI`). The open question
is each generation's axis/colour **content**.

This tool reads off, for any twist loop, which spatial axes it engages
(`^v`=Y, `><`=X, `/\`=Z), its Pauli fold, and whether it closes (ZFA) — reusing
`twist_core.py`. It then **enumerates** short spatial ZFA loops and classifies
them by axis content, exhibiting the candidate space for e / μ / τ: the
electron's {x, y} is the verified anchor, and 1-axis, other-2-axis, and 3-axis
singlet closures also exist — candidate deeper-generation contents.

HONEST SCOPE: this maps the *available* axis contents; it does **not** assert
which loop is the muon or tau — that is the open derivation (#140). Reuses
`twist_core.py`; no other deps.  Run:  python3 lepton_flavor_axes.py
"""
import itertools
from twist_core import pauli_fold, is_zfa, is_pauli_closed, calculate_action

SPATIAL = "^v<>/\\"                                   # the six spatial twists (no gauge +-)
AXIS = {'^': 'Y', 'v': 'Y', '>': 'X', '<': 'X', '/': 'Z', '\\': 'Z'}


def axes_engaged(h: str) -> str:
    """The set of spatial axes a loop engages, as a sorted string e.g. 'XY'."""
    return "".join(sorted({AXIS[t] for t in h if t in AXIS}))


def fold_str(h: str) -> str:
    a, _, _, _ = pauli_fold(h)
    if not is_pauli_closed(h):
        return "open"
    for s, name in ((1, "+I"), (-1, "-I"), (1j, "+iI"), (-1j, "-iI")):
        if abs(a - s) < 1e-9:
            return name
    return f"{a:.2g}I"


def spatial_zfa(h: str) -> bool:
    """A spatial ZFA closure: count-balanced on each axis AND Pauli-closed.
    (Bypasses twist_core.is_zfa's min-length gate so length-4 loops like the
    electron count.)"""
    return all(x == 0 for x in calculate_action(h)) and is_pauli_closed(h)


def report(h: str, label: str = "") -> None:
    tag = f"   ({label})" if label else ""
    print(f"  {h:8}  axes={axes_engaged(h) or '—':3}  fold={fold_str(h):4}  "
          f"zfa={spatial_zfa(h)!s:5}  depth={len(h)//2}{tag}")


def main() -> None:
    print(__doc__.strip().split("\n\n")[0])
    print()
    print("Verified anchor — the electron:")
    report("^<v>", "engages {x,y}, folds to -I  (interleaved_xlvr_folds_to_negI)")
    print()

    for L in (4, 6):
        buckets: dict[str, list[str]] = {}
        for combo in itertools.product(SPATIAL, repeat=L):
            h = "".join(combo)
            if spatial_zfa(h):
                buckets.setdefault(axes_engaged(h), []).append(h)
        total = sum(len(v) for v in buckets.values())
        print(f"Spatial ZFA loops of length {L}  ({total} closures) — by axis (colour) content:")
        print(f"  {'#axes':>5}  {'axes':4}  {'count':>6}   examples")
        for ax in sorted(buckets, key=lambda a: (len(a), a)):
            exs = ", ".join(buckets[ax][:3])
            print(f"  {len(ax):>5}  {ax or '—':4}  {len(buckets[ax]):>6}   {exs}")
        print()

    print("Reading: closures engaging 1, 2, or all 3 spatial axes all exist and close as")
    print("singlets. The electron occupies a 2-axis {x,y} content; the candidate μ/τ")
    print("contents (the other axis-pairs {y,z}, {x,z}, or a 3-axis singlet) are laid out")
    print("here to test against Koide + B=0 — the open derivation of issue #140.")


if __name__ == "__main__":
    main()

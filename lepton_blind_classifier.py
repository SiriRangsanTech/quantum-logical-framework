#!/usr/bin/env python3
"""
lepton_blind_classifier.py (version 3) — rooted causal lepton-ladder attack on QLF #140.

This version performs two separate audits:

A. BLIND TOPOLOGY SELECTION (no measured masses)
   1. spatial twists only
   2. no immediate Hermitian reversal
   3. first-return ZFA (final closure; no proper causal prefix already closes)
   4. rooted baryon winding B = 0
   5. final Pauli fold = -I (electron-like half-spin)
   6. quotient signed spatial-axis permutations + antiparticle
   7. frequency = number of ways selects the L=6 class
   8. parent-child continuation selects the rooted L=8 class

B. KOIDE PHASE AUDIT (only after topology selection)
   Reproduce the exact-Q=2/3 phase implied by the repo's m_e and m_mu inputs,
   then compare it with the existing 2/9 candidate.

No QLF imports are required.
"""

from __future__ import annotations

import itertools
import math
from collections import Counter, defaultdict

SPATIAL = "^v<>/\\"

TWIST = {
    ">": (0, +1), "<": (0, -1),
    "^": (1, +1), "v": (1, -1),
    "/": (2, +1), "\\": (2, -1),
}
FROM = {v: k for k, v in TWIST.items()}
CONJ = {t: FROM[(a, -s)] for t, (a, s) in TWIST.items()}
AXNAME = "XYZ"
ORDER = {c: i for i, c in enumerate(SPATIAL)}

_EVEN = {("X", "Y", "Z"), ("Y", "Z", "X"), ("Z", "X", "Y")}
_ODD  = {("X", "Z", "Y"), ("Z", "Y", "X"), ("Y", "X", "Z")}


def axes_engaged(h: str) -> str:
    return "".join(sorted({AXNAME[TWIST[t][0]] for t in h}))


def balanced(h: str) -> bool:
    c = Counter(h)
    return c["^"] == c["v"] and c[">"] == c["<"] and c["/"] == c["\\"]


def admissible(h: str) -> bool:
    return all(h[i + 1] != CONJ[h[i]] for i in range(len(h) - 1))


def first_return_zfa(h: str) -> bool:
    if not balanced(h):
        return False
    return all(not balanced(h[:k]) for k in range(2, len(h)))


def sign_triple(a: str, b: str, c: str) -> int:
    t = (a, b, c)
    return 1 if t in _EVEN else -1 if t in _ODD else 0


def baryon_number(h: str) -> int:
    ax = [AXNAME[TWIST[t][0]] for t in h]
    return sum(
        sign_triple(ax[i], ax[i + 1], ax[i + 2])
        for i in range(len(ax) - 2)
    )


# ---------- exact 2x2 Pauli fold, pure Python ----------

I = (1+0j, 0j, 0j, 1+0j)
X = (0j, 1+0j, 1+0j, 0j)
Y = (0j, -1j, 1j, 0j)
Z = (1+0j, 0j, 0j, -1+0j)


def smul(s, m):
    return tuple(s*x for x in m)


PMAP = {
    ">": X, "<": smul(-1, X),
    "^": Y, "v": smul(-1, Y),
    "/": Z, "\\": smul(-1, Z),
}


def mmul(m1, m2):
    a, b, c, d = m1
    e, f, g, h = m2
    return (a*e+b*g, a*f+b*h, c*e+d*g, c*f+d*h)


def fold_phase(h: str) -> str:
    m = I
    for t in h:
        m = mmul(m, PMAP[t])
    for s, name in ((1, "+I"), (-1, "-I"), (1j, "+iI"), (-1j, "-iI")):
        if all(abs(m[i] - s*I[i]) < 1e-9 for i in range(4)):
            return name
    return "open"


# ---------- symmetry quotient ----------

def antiparticle(h: str) -> str:
    return "".join(CONJ[t] for t in reversed(h))


def signed_axis_transforms():
    for perm in itertools.permutations(range(3)):
        for flips in itertools.product((+1, -1), repeat=3):
            def tr(h: str, perm=perm, flips=flips) -> str:
                out = []
                for t in h:
                    a, s = TWIST[t]
                    out.append(FROM[(perm[a], s*flips[a])])
                return "".join(out)
            yield tr


TRANSFORMS = list(signed_axis_transforms())


def key(h: str):
    return tuple(ORDER[c] for c in h)


def orbit(h: str) -> set[str]:
    out = set()
    for tr in TRANSFORMS:
        q = tr(h)
        out.add(q)
        out.add(antiparticle(q))
    return out


def canonical(h: str) -> str:
    return min(orbit(h), key=key)


def generate_first_return(length: int) -> list[str]:
    out = []

    def rec(pref: str):
        if len(pref) == length:
            if first_return_zfa(pref):
                out.append(pref)
            return
        for t in SPATIAL:
            if pref and t == CONJ[pref[-1]]:
                continue
            rec(pref + t)

    rec("")
    return out


def half_spin_free(length: int) -> list[str]:
    return [
        h for h in generate_first_return(length)
        if baryon_number(h) == 0 and fold_phase(h) == "-I"
    ]


def classes(words: list[str]) -> dict[str, list[str]]:
    d = defaultdict(list)
    for h in words:
        d[canonical(h)].append(h)
    return d


# ---------- causal parent relation ----------

def conjugate_pair_deletions(h: str):
    """
    Delete one same-axis opposite-sign pair, preserving the causal order of
    everything else.
    """
    for i in range(len(h)):
        for j in range(i + 1, len(h)):
            if h[j] == CONJ[h[i]]:
                yield (i, j, h[i] + h[j], h[:i] + h[i+1:j] + h[j+1:])


def parent_edges(child_orbit: set[str], parent_orbit: set[str]) -> int:
    total = 0
    for h in child_orbit:
        for _, _, _, q in conjugate_pair_deletions(h):
            if q in parent_orbit:
                total += 1
    return total


def child_parent_degree(child_orbit: set[str], parent_orbit: set[str]) -> Counter:
    deg = Counter()
    for h in child_orbit:
        n = sum(1 for _, _, _, q in conjugate_pair_deletions(h) if q in parent_orbit)
        deg[n] += 1
    return deg


def select_topologies():
    print("=== A. BLIND ROOTED TOPOLOGY SELECTION ===\n")

    c4 = classes(half_spin_free(4))
    c6 = classes(half_spin_free(6))
    c8 = classes(half_spin_free(8))

    e = next(iter(c4))  # unique
    mu = max(c6.items(), key=lambda kv: len(kv[1]))[0]  # frequency=ways

    tau3 = {
        rep: members for rep, members in c8.items()
        if len(axes_engaged(rep)) == 3
    }

    print("L=4 free half-spin classes:")
    for rep, mem in c4.items():
        print(f"  {rep:10} ways={len(mem):3d} axes={axes_engaged(rep)}")
    print()

    print("L=6 free half-spin classes:")
    for rep, mem in sorted(c6.items(), key=lambda kv: key(kv[0])):
        print(f"  {rep:10} ways={len(mem):3d} axes={axes_engaged(rep)}")
    print(f"  -> number-of-ways selection: mu = {mu}\n")

    print("L=8 three-axis free half-spin classes:")
    omu = orbit(mu)
    parentful = []
    for rep, mem in sorted(tau3.items(), key=lambda kv: key(kv[0])):
        o = orbit(rep)
        edges = parent_edges(o, omu)
        deg = child_parent_degree(o, omu)
        print(
            f"  {rep:10} ways={len(mem):3d} "
            f"mu-parent-edges={edges:3d} degree={dict(deg)}"
        )
        if edges:
            parentful.append(rep)

    if len(parentful) != 1:
        raise RuntimeError(f"Expected unique rooted tau continuation, got {parentful}")
    tau = parentful[0]
    print(f"  -> causal-parent selection: tau = {tau}\n")

    oe, om, ot = orbit(e), orbit(mu), orbit(tau)
    print("Selected causal ladder:")
    for n, h in (("e", e), ("mu", mu), ("tau", tau)):
        print(
            f"  {n:3} = {h:10} L={len(h)} axes={axes_engaged(h)} "
            f"B={baryon_number(h):+d} fold={fold_phase(h)} orbit={len(orbit(h))}"
        )

    print("\nParent-edge audit:")
    print(f"  mu -> e deletion edges across orbit  = {parent_edges(om, oe)}")
    print(f"  per-mu rooted history                = {dict(child_parent_degree(om, oe))}")
    print(f"  tau -> mu deletion edges across orbit= {parent_edges(ot, om)}")
    print(f"  per-tau rooted history               = {dict(child_parent_degree(ot, om))}")

    old = "^v<>/\\"
    print("\nEarlier L=6 tau proposal:")
    print(
        f"  {old}: balanced={balanced(old)}, first-return={first_return_zfa(old)}, "
        f"B={baryon_number(old)}, fold={fold_phase(old)}"
    )
    print("  -> reject as elementary: (^v)(<>)(/\\) are already separate closures.")

    return e, mu, tau


# ---------- Koide audit ----------

ME = 0.51099895000
MMU = 105.6583755
MTAU = 1776.86


def koide_weights(delta: float):
    # k=(0,1,2) = (tau,e,mu)
    return [
        (1 + math.sqrt(2)*math.cos(delta + 2*math.pi*k/3))**2
        for k in range(3)
    ]


def mu_e_ratio(delta: float) -> float:
    w = koide_weights(delta)
    return w[2] / w[1]


def solve_delta_from_e_mu() -> float:
    target = MMU / ME
    lo, hi = 0.21, 0.23
    flo = mu_e_ratio(lo) - target
    fhi = mu_e_ratio(hi) - target
    if flo * fhi > 0:
        raise RuntimeError("Root not bracketed")
    for _ in range(100):
        mid = (lo + hi) / 2
        fm = mu_e_ratio(mid) - target
        if flo * fm <= 0:
            hi, fhi = mid, fm
        else:
            lo, flo = mid, fm
    return (lo + hi) / 2


def koide_tau_from_e_mu():
    a = math.sqrt(ME) + math.sqrt(MMU)
    b = ME + MMU
    s_tau = 2*a + math.sqrt(6*a*a - 3*b)
    return s_tau*s_tau


def koide_audit():
    print("\n=== B. KOIDE PHASE AUDIT (AFTER BLIND SELECTION) ===\n")

    delta_exactQ = solve_delta_from_e_mu()
    delta_29 = 2/9

    print("Repo inputs (koide_tau_demo.py):")
    print(f"  m_e   = {ME:.11f} MeV")
    print(f"  m_mu  = {MMU:.7f} MeV")
    print(f"  m_tau = {MTAU:.2f} MeV\n")

    print("If Q=2/3 is exact and m_e,m_mu are the two inputs:")
    print(f"  delta_required = {delta_exactQ:.15f} rad")
    print(f"  2/9            = {delta_29:.15f} rad")
    print(f"  difference     = {delta_29-delta_exactQ:+.3e} rad")
    print(f"  relative delta gap = {(delta_29/delta_exactQ-1)*100:+.8f}%\n")

    obs_mu_e = MMU / ME
    pred_mu_e = mu_e_ratio(delta_29)
    w = koide_weights(delta_29)
    pred_tau_e = w[0] / w[1]
    tau_from_e = ME * pred_tau_e

    print("Exact delta=2/9 as a zero-parameter ratio prediction:")
    print(f"  observed  m_mu/m_e = {obs_mu_e:.12f}")
    print(f"  predicted m_mu/m_e = {pred_mu_e:.12f}")
    print(f"  relative error      = {(pred_mu_e/obs_mu_e-1)*100:+.8f}%")
    print(f"  tau from e scale    = {tau_from_e:.6f} MeV")
    print(f"  tau relative error  = {(tau_from_e/MTAU-1)*100:+.6f}%\n")

    mt_koide = koide_tau_from_e_mu()
    print("For comparison, exact Q=2/3 with measured e,mu gives:")
    print(f"  m_tau = {mt_koide:.6f} MeV")
    print(f"  relative error vs repo tau = {(mt_koide/MTAU-1)*100:+.6f}%\n")

    print("VERDICT")
    print("  * Weak_Force.md's current 'delta=0.22227 from precise e,mu' is inconsistent")
    print("    with the exact-Q=2/3 parameterization used by koide_tau_demo.py.")
    print("  * Under that parameterization the required phase is 0.222222047...,")
    print("    extraordinarily close to 2/9.")
    print("  * Exact 2/9 is still NOT exact: the e/mu ratio residual is ~9.8 ppm,")
    print("    far above the experimental mass uncertainty.")
    print("  * Therefore 2/9 can only be a leading-order substrate candidate unless")
    print("    QLF derives a correction.")
    print("  * The missing physics is not arithmetic: QLF still needs a reason why")
    print("    the Koide cosine phase should equal the count ratio 2/9 at all.")


def main():
    select_topologies()
    koide_audit()


if __name__ == "__main__":
    main()

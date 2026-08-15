#!/usr/bin/env python3
"""
pair_production_demo.py — the QLF vacuum pair-production model, outside the browser.

This reproduces, faithfully, the model that drives the pair eruption in
`spacetime_constructor.html` (see `Particle_Ladder.md` §2, §5, and
`Spacetime_Constructor.md`). Its purpose is to make the *mechanism* inspectable
and reproducible in Python, and to make one subtle QLF point concrete:

    Pair CREATION is a DETERMINISTIC CENSUS cascade — no dice, no thermal gate.
    TEMPERATURE only sets how many created pairs freeze out as REAL (persistent)
    matter versus flicker back to virtual possibility.

Two ingredients, exactly as in the constructor:

  1. Creation (vacuum-independent).  A low-discrepancy census sequence f ∈ [0,1)
     is read out at a fixed cascade rate; the frequency bucket picks the species
     (m = 1/R = frequency, so lightest = lowest frequency = most numerous):
         f < 0.90            -> e+ e-
         0.90 <= f < 0.975   -> mu+ mu-
         f >= 0.975          -> p pbar   (deep fold, rare)
     The species ratios are therefore the CENSUS BUCKET WIDTHS
     (0.900 : 0.075 : 0.025) — "lightest dominate", not a Boltzmann factor.

  2. Freeze-out (temperature).  A pair is REAL with fraction
         real_frac(s) = min(0.97, 1.05 * s)
     where s in [0,1] is the temperature slider (s=0 -> all virtual foam;
     high s -> up to 97% real). Temperature is the local closure/logical density
     (`f = 1/latency`); it gates persistence, not creation.

Temperature <-> slider map (constructor constants):
     T(s) = T_FLOOR * (T_P / T_FLOOR) ** s ,  s > 0 ;  T(0) = 0

HONEST SCOPE. This reproduces the constructor's *illustrative* model; the bucket
widths and the freeze-out slope are pedagogical choices, not derived. The QLF
*mechanism* is the content — deterministic-census creation + thermal freeze-out,
"the census draws the space" (QLF_CensusBrownian / QLF_BornProbability), no
probability on creation. Calibrating the buckets/thresholds to the *measured*
pair-production onsets (e+e- ~1e10 K, then mu, then p) and deriving an analytic
rate from the census remain OPEN (Particle_Ladder.md §5, Open_Problems.md).
No dependencies; run:  python3 pair_production_demo.py
"""

import math

# --- constructor constants (spacetime_constructor.html) ---
T_FLOOR = 1e-3
T_P = 1.416784e32          # Planck temperature (K)
T_CMB = 2.725
BUCKETS = [(0.90, "e"), (0.975, "mu"), (1.01, "p")]   # upper edge -> species
LABEL = {"e": "e+e-", "mu": "mu+mu-", "p": "p pbar"}


def vacT(s: float) -> float:
    """Temperature (K) for slider position s in [0,1]; 0 at absolute zero."""
    if s <= 0:
        return 0.0
    return T_FLOOR * (T_P / T_FLOOR) ** s


def s_for_T(T: float) -> float:
    """Inverse: slider position for a target temperature T (K)."""
    if T <= T_FLOOR:
        return 0.0
    return math.log(T / T_FLOOR) / math.log(T_P / T_FLOOR)


def real_frac(s: float) -> float:
    """Fraction of created pairs that freeze out as REAL (persistent) matter."""
    return min(0.97, 1.05 * max(0.0, s))


def census_seq(n: int, inc: float = (math.sqrt(5.0) - 1.0) / 2.0, x0: float = 0.0):
    """A deterministic low-discrepancy census sequence in [0,1) (additive
    irrational-rotation / Weyl sequence), the stand-in for the constructor's
    `lseq()` — deterministic, not random. Default increment = 1/phi. Pass a
    different irrational `inc` for an independent (decorrelated) stream."""
    x = x0
    for _ in range(n):
        x = (x + inc) % 1.0
        yield x


def species_of(f: float) -> str:
    for edge, name in BUCKETS:
        if f < edge:
            return name
    return "p"


def simulate(s: float, n_events: int = 200_000):
    """Run n_events of the census cascade at temperature-slider s.
    Returns (created, real) species counts."""
    created = {"e": 0, "mu": 0, "p": 0}
    real = {"e": 0, "mu": 0, "p": 0}
    rf = real_frac(s)
    # an INDEPENDENT deterministic stream (different irrational increment) decides
    # real vs virtual, decorrelated from the species stream
    freeze = census_seq(n_events, inc=math.sqrt(2.0) - 1.0, x0=0.5)
    for f in census_seq(n_events):
        sp = species_of(f)
        created[sp] += 1
        if next(freeze) < rf:      # deterministic freeze-out draw
            real[sp] += 1
    return created, real


def main():
    print(__doc__.strip().split("\n\n")[0])
    print()

    # 1. Creation ratios are the census bucket widths (temperature-independent).
    created, _ = simulate(1.0)
    tot = sum(created.values())
    print("1. CREATION species ratios (deterministic census — temperature-independent):")
    print(f"   {'species':8} {'count':>8} {'fraction':>10}   bucket width")
    widths = {"e": 0.900, "mu": 0.075, "p": 0.025}
    for sp in ("e", "mu", "p"):
        print(f"   {LABEL[sp]:8} {created[sp]:8d} {created[sp]/tot:10.4f}   {widths[sp]:.3f}")
    print("   -> lightest closure dominates; the ratio IS the census multiplicity, not a Boltzmann factor.\n")

    # 2. Freeze-out: temperature sets REAL vs virtual, not the species.
    print("2. FREEZE-OUT vs temperature (real yields per 200k cascade events):")
    print(f"   {'T (K)':>12} {'slider s':>9} {'real%':>7} {'real e':>9} {'real mu':>9} {'real p':>9}")
    targets = [
        ("absolute zero", 0.0),
        ("CMB 2.7 K", s_for_T(T_CMB)),
        ("e+e- onset ~1e10 K", s_for_T(1e10)),
        ("mu ~1e12 K", s_for_T(1e12)),
        ("hadron ~1e13 K", s_for_T(1e13)),
        ("near Planck", 0.95),
        ("Planck", 1.0),
    ]
    for label, s in targets:
        created, real = simulate(s)
        T = vacT(s)
        print(f"   {T:12.3e} {s:9.3f} {100*real_frac(s):6.1f}% "
              f"{real['e']:9d} {real['mu']:9d} {real['p']:9d}   ({label})")
    print()
    print("Note: creation counts are identical across rows (deterministic census);")
    print("only the REAL fraction scales with temperature — the QLF freeze-out mechanism.")
    print("Matching the bucket edges to the *measured* onsets and deriving an analytic")
    print("census rate are the open pieces (Particle_Ladder.md §5).")


if __name__ == "__main__":
    main()

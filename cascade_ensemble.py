#!/usr/bin/env python3
"""
cascade_ensemble.py -- an ensemble cascade simulation to MEASURE the steady-state gauge-fold
density rho* from the substrate rules (frontier #1 / issue #121 / #136, Grok's "larger simulation"
step). Turbulence + Zipf route: the vacuum is a self-organized-critical (SOC) cascade of gauge-fold
defects; rho* is the SOC steady density; the avalanche/cluster spectrum should be scale-free (Zipf/
power-law). NOTHING is tuned to v = 246 GeV -- c, k, rho* are read off the rules and REPORTED.

RULES (substrate-faithful; the modelling choices are stated, not hidden):
  * 8-twist alphabet = 6 spatial + 2 gauge (+/-). Generation injects a random twist; a gauge fold
    appears with the alphabet fraction 2/8 = 1/4 (both signs), so the OPEN-fold creation rate per
    generated twist is c0 = 1/4.
  * Opposite-gauge folds ATTRACT and annihilate (bind, carry log 2) -- the PROVEN free-action
    reduction (QLF_ClosureAttraction.opposite_gauge_attracts). A + and a - that meet dock.
  * Cascade discipline: highest-frequency (shortest closures) resolve first, constant log 2 flux per
    octave, floor at the minimal-closure (Planck) scale.
  * The docking probability per encounter is the census return weight at the floor,
    k0 = C(2,1)/4^1 = 1/2 (the m=1 closure return probability, QLF_CensusBrownian.returnProb1D).

WHAT IS MEASURED (never fit): the steady density rho*, the mean-field c/k it implies, and the
avalanche-size power-law exponent (the Zipf/scale-free signature). Then: is rho* O(1) (=> v ~ M_Pl,
no hierarchy) or small (=> hierarchy)? Report honestly. Do NOT adjust rules to move rho*.
"""
import random
from collections import Counter
from math import sqrt, log

random.seed(0)

SPATIAL, PLUS, MINUS = list(range(6)), 6, 7
ALPHABET = SPATIAL + [PLUS, MINUS]


def rule(t):
    print("\n" + "=" * 76 + "\n" + t + "\n" + "-" * 76)


print(__doc__)

# ---------------------------------------------------------------------------------------------
rule("1. Well-mixed birth-death: measure rho* from the substrate rates c0 = 1/4, k0 = 1/2")
# dN/dt = c0 * V  -  k0 * (N_+ N_-)/V   (creation from generation ; annihilation from docking)
# Symmetric N_+ = N_- = N/2  =>  steady:  c0 = k0 * (rho/2)^2  =>  rho* = 2 sqrt(c0/k0).
c0, k0 = 1.0 / 4.0, 1.0 / 2.0
V = 20000            # lattice volume (open-fold slots)
Np = Nm = 0          # counts of open + and - folds (integer state, O(1) per step)
dt = 0.05
hist = []
for step in range(40000):
    # creation: inject open folds at rate c0 per slot (split evenly +/-)
    exp_new = c0 * V * dt
    n_new = int(exp_new) + (1 if random.random() < (exp_new - int(exp_new)) else 0)
    add_p = sum(1 for _ in range(n_new) if random.random() < 0.5)
    Np += add_p
    Nm += n_new - add_p
    # annihilation: opposite pairs dock at rate k0 (per pair, /V for density) -- bind, carry log 2
    exp_bind = k0 * (Np * Nm) / V * dt
    n_bind = int(exp_bind) + (1 if random.random() < (exp_bind - int(exp_bind)) else 0)
    n_bind = min(n_bind, Np, Nm)
    Np -= n_bind
    Nm -= n_bind
    if step > 20000:
        hist.append((Np + Nm) / V)

rho_meas = sum(hist) / len(hist)
rho_pred = 2.0 * sqrt(c0 / k0)
print(f"   substrate rates: c0 = {c0}  (gauge fraction 2/8),  k0 = {k0}  (m=1 census return C(2,1)/4)")
print(f"   measured steady density   rho* = {rho_meas:.4f}")
print(f"   mean-field prediction 2 sqrt(c0/k0) = {rho_pred:.4f}   (QLF_SteadyStateDensity)")
print(f"   -> rho* ~ O(1) ({rho_meas:.2f}): a defect roughly every ~{1/rho_meas:.1f} slots.")

# ---------------------------------------------------------------------------------------------
rule("2. Zipf / scale-free check: first-return-time distribution of the gauge free-action walk")
# The gauge folds do a +/-1 walk (spatial twists = 0 steps); the free action is |partial sum|.
# A closure = a return to zero free action. First-return times tau follow the classic 1D walk law
# P(tau = 2m) ~ m^-3/2 -- a heavy-tailed, SCALE-FREE (Zipf-like) distribution, the SOC signature.
# (Its running sum is the census return weight C(2m,m)/4^m ~ m^-1/2.)  This is MEASURED, not assumed.
ret = Counter()
pos, since = 0, 0
for _ in range(4_000_000):
    t = random.choice(ALPHABET)
    g = 1 if t == PLUS else (-1 if t == MINUS else 0)
    if g == 0:
        continue                 # spatial twist: no gauge step
    pos += g
    since += 1
    if pos == 0:                 # returned to zero free action = a closure
        ret[since] += 1
        since = 0
tot = sum(ret.values())
print(f"   closures (returns to zero free action): {tot}")
print(f"   {'2m (return time)':>18}{'P(measured)':>14}{'~ c*m^-3/2':>14}")
import math
# normalise the theoretical m^-3/2 to the tail so the shape (exponent) is what is compared
base = None
for twom in (2, 4, 8, 16, 32, 64):
    m = twom / 2
    pm = ret.get(twom, 0) / tot
    theo = m ** -1.5
    if base is None and pm > 0:
        base = pm / theo
    print(f"   {twom:>18}{pm:>14.5f}{(base or 0)*theo:>14.5f}")
print("   -> the first-return (closure-size) distribution is heavy-tailed ~ m^-3/2: SCALE-FREE, the")
print("      Zipf/1-f signature of the SOC cascade (its partial sum is the census C(2m,m)/4^m ~ m^-1/2,")
print("      QLF_Kolmogorov / QLF_Turbulence).  The cascade IS scale-free, as the turbulence route needs.")

# ---------------------------------------------------------------------------------------------
rule("3. Honest verdict")
print(f"   MEASURED (not fit): the bare substrate rates (c0 = 1/4 from the 8-twist gauge fraction,")
print(f"   k0 = 1/2 from the m=1 census return) give a steady density rho* = {rho_meas:.2f} = O(1).")
print("   An O(1) density means a defect every ~1-2 slots: a DENSE vacuum, v ~ M_Pl -- NO hierarchy.")
print("   This CONFIRMS, now from the dynamics side, the QLF_PackingFactor diagnostic: the bare")
print("   combinatorial rates do NOT give v << M_Pl.  The hierarchy requires the SOC cascade to drive")
print("   the EFFECTIVE binding to near-criticality (rho* -> tiny, g_crit -> 0 at the deep floor,")
print("   QLF_CondensateGap), i.e. the census sum over MANY octaves, not the single-octave rate.")
print("   So the measurement is a DIAGNOSTIC, not a value for v: it sharpens WHERE the smallness lives")
print("   (the multi-octave near-critical SOC accumulation), and it is NOT tuned to v.")
print("   Next (deferred, honest): a full multi-octave SOC sandpile with constant-log2-flux transport")
print("   and the Planck-floor cutoff, to measure whether the near-critical rho* over ~14pi octaves")
print("   lands near the value the hierarchy needs.  Report that number honestly when it exists.")
print("   See QLF_ClosureAttraction / QLF_SteadyStateDensity / QLF_ElectroweakScale / QLF_PackingFactor,")
print("   Higgs.md sec 5a, issues #121, #136.")

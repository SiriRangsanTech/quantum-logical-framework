#!/usr/bin/env python3
"""
closure_binding.py -- the interacting closure-binding as an NJL gap equation with the census loop.

Issue #121: the electroweak sector's one open number is the interacting closure-binding strength g
(equivalently the four-fermion coupling G / the stable fold depth R_stable = v). The binding STRUCTURE is
formalized (QLF_ClosureBinding: t-tbar binds to a real scalar condensate, tt Pauli-blocked, log 2/bind).
What was open: the MAGNITUDE -- does the many-closure density reach the NJL critical point, and at what scale?

This demo answers the *condensation* question (steps 1 + 3 of the roadmap), leaving g's VALUE (step 2) as
the irreducible open number.

MODEL. The NJL gap equation for a fermion-antifermion condensate is  1 = G * (loop over intermediate
states).  QLF reading: the intermediate states ARE the closed histories; the "loop integral" is the closure
census.  The 1-D return weight is  w(m) = C(2m,m)/4^m  (= QLF_CensusBrownian.returnProb1D ~ 1/sqrt(pi m)),
so the census loop up to cutoff depth N is
        S(N) = sum_{m=1}^N w(m)  ~  2 sqrt(N/pi).
Condensation (a non-trivial gap) requires
        g * S(N) >= 1   <=>   g >= g_crit(N) = 1 / S(N).

RESULT.  S(N) diverges (~ sqrt(N)), so g_crit(N) -> 0 as the cutoff grows: condensation is GENERIC -- any
fixed coupling g > 0 is supercritical beyond depth  N* ~ pi/(4 g^2).  Smaller g => exponentially deeper
condensation (dimensional transmutation), i.e. v << M_Planck by discreteness, matching the QLF_AlphaS
hierarchy.  So the interacting closure-binding DOES condense; the electroweak scale is the transmutation
depth set by g.

HONEST SCOPE.  This establishes condensation + the transmutation form (previously open).  It does NOT derive
g's value: g = (log 2 per bind) x (allowed-channel factor) x (many-closure packing factor); the packing
factor is the one dimensionless number the interacting theory must fix (issue #121).  The gravitational
(Einstein-Cartan) part is g_grav ~ 0.1-0.4 (subcritical, higgs_running_demo.py sec E); the closure-binding
packing must supply the rest.  No electroweak input is fit here -- and per the roadmap, an unconstrained fit
would not answer #121; only a derived g (or a single named continuum-bridge factor) would.
"""
from math import sqrt, pi, log


def census_gap_sum(N):
    """S(N) = sum_{m=1}^N C(2m,m)/4^m via the stable recurrence w(m) = w(m-1)*(2m-1)/(2m)."""
    s = 0.0
    w = 1.0
    for m in range(1, N + 1):
        w *= (2 * m - 1) / (2 * m)
        s += w
    return s


def rule(t):
    print("\n" + "=" * 74 + "\n" + t + "\n" + "-" * 74)


print(__doc__)

rule("1. The census loop S(N) and the critical coupling g_crit = 1/S(N)")
print("   The NJL loop is the closure census; condensation needs g*S(N) >= 1.")
print(f"   {'cutoff N':>10}{'S(N)':>12}{'2sqrt(N/pi)':>13}{'g_crit=1/S':>12}")
for N in (1, 10, 100, 1_000, 10_000, 100_000, 1_000_000):
    S = census_gap_sum(N)
    print(f"   {N:>10}{S:>12.3f}{2*sqrt(N/pi):>13.3f}{1.0/S:>12.6f}")
print("   -> S(N) ~ 2 sqrt(N/pi) DIVERGES, so g_crit(N) -> 0 as the cutoff deepens.")
print("      Condensation is GENERIC: every fixed g > 0 becomes supercritical at large enough depth.")

rule("2. Dimensional transmutation: the condensation depth N* where g*S(N*) = 1")
print("   With S ~ 2 sqrt(N/pi), criticality g*S(N*)=1 gives  N* = pi/(4 g^2).")
print(f"   {'coupling g':>12}{'N* = pi/(4g^2)':>18}{'ln N* (hierarchy)':>20}")
for g in (1.0, 0.3, 0.1, 0.03, 0.01):
    Nstar = pi / (4 * g * g)
    print(f"   {g:>12.3f}{Nstar:>18.1f}{log(Nstar):>20.3f}")
print("   -> smaller g => exponentially deeper N* (v << M_Planck), the same transmutation as ln R_p=14pi")
print("      (QLF_AlphaS). The electroweak scale is the condensate depth; g is the one number that sets it.")

rule("3. Without the interaction there is NO condensation (the free census is monotone)")
print("   Free-census free energy F(n) = -log(C(2n,n)/4^n) is monotone increasing (-> +inf): no minimum,")
print("   so free closures never condense. The BINDING term is essential; that is what g measures.")
w = 1.0
print(f"   {'depth n':>10}{'F(n)=-log w(n)':>18}")
for n in range(1, 9):
    w *= (2 * n - 1) / (2 * n)
    print(f"   {2**0*n if False else n:>10}{-log(w):>18.4f}")
print("   -> monotone, no interior minimum: condensation requires g > 0 (the interacting closure-binding).")

rule("SCOPE (honest) -- what this answers of #121, and what stays open")
print("   ANSWERED (steps 1 + 3): the interacting closure-binding IS an NJL gap equation with the census")
print("     loop; it CONDENSES GENERICALLY (g_crit -> 0 at the Planck floor); the electroweak scale is the")
print("     transmutation depth N* ~ pi/(4 g^2). So 'does it condense?' is settled: yes.")
print("   OPEN (step 2, the irreducible number): the VALUE of g -- g = log2 x channel-factor x packing")
print("     factor; the many-closure packing factor is the one dimensionless number still to be derived")
print("     from the 8-twist combinatorics. Gravity gives ~0.1-0.4 (subcritical); the packing supplies the")
print("     rest. Until g is derived (not fit), the electroweak scale v = R_stable stays calibrated, not")
print("     predicted -- but now localized to a single gap-equation coupling, not a free scatter.")
print("   See QLF_CondensateGap.lean, QLF_ClosureBinding.lean, Higgs.md sec 5a, issue #121.")

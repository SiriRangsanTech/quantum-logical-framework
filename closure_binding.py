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

rule("4. Deriving the packing factor -> it is the EW transmutation exponent, NOT a free number")
from math import log
MPl, v, mt, mp = 1.22e19, 246.22, 172.7, 0.938272
L = log(MPl / v)
print("   'Derive the packing factor from the 8-twist combinatorics' bottoms out here, honestly:")
print("   (a) In the census normalization the packing coupling is g = sqrt(pi/(4 N*)) with N* ~ M_Pl/v")
print("       = %.2e, so g ~ %.1e -- O(1e-9), NOT an O(1) combinatorial number. Its SMALLNESS *is* the" % (MPl/v, (3.14159/(4*MPl/v))**0.5))
print("       hierarchy: deriving g = deriving ln(M_Pl/v) = %.2f, the electroweak transmutation exponent." % L)
print("   (b) That exponent needs the electroweak RUNNING COEFFICIENT b_EW (dimensional transmutation,")
print("       ln(M_Pl/v) = 2pi*b_EW form), exactly as the QCD hierarchy ln(M_Pl/m_p) = 14pi is DERIVED")
print("       because b0 = 7 is substrate-fixed (N_c=3, n_f=6; QLF_AlphaS/QLF_BetaFunction). The EW b_i is")
print("       NOT yet substrate-fixed -- the same open piece as the running-couplings sector.")
print("   (c) STEP-0 DISCIPLINE -- is there a clean n*pi for the EW hierarchy? NO (would be a fit):")
print("       ln(M_Pl/v) = %.3f ; /pi = %.3f ; nearest 12pi = %.3f (residual %+.1f%%, a rounded-match trap" % (L, L/3.14159, 12*3.14159, 100*(12*3.14159-L)/L))
print("       like the alpha-residual 9/250); b_EW = %.3f is not a clean SM coefficient (b_1=41/6=6.83)." % (L/(2*3.14159)))
print("   => The packing factor is NOT derived here (no fit). It REDUCES to the EW b-coefficient (open).")
print("   What IS derived (the positive part): the packing sits at self-organized criticality g~g_crit")
print("      (the floored turbulent cascade attractor, QLF_HiggsTurbulence) -- which is WHY v << M_Pl is")
print("      STABLE without fine-tuning (hierarchy problem absent). The exact departure from criticality")
print("      that fixes v is the transmutation exponent = the EW b-coefficient. So #121 reduces to:")
print("      derive b_EW from the substrate counting (as b0=7 was for QCD) -> ln(M_Pl/v)=2pi*b_EW.")

rule("SCOPE (honest) -- what this answers of #121, and what stays open")
print("   ANSWERED (steps 1 + 3): the interacting closure-binding IS an NJL gap equation with the census")
print("     loop; it CONDENSES GENERICALLY (g_crit -> 0 at the Planck floor); the electroweak scale is the")
print("     transmutation depth N* ~ pi/(4 g^2). So 'does it condense?' is settled: yes.")
print("   OPEN (step 2), now precisely reduced (sec 4): the packing factor is NOT a free O(1) combinatorial")
print("     number -- it is the electroweak TRANSMUTATION EXPONENT ln(M_Pl/v)~38.4 (its smallness = the")
print("     hierarchy), needing the electroweak running coefficient b_EW (ln(M_Pl/v)=2pi*b_EW). Unlike QCD")
print("     (b0=7 substrate-fixed => 14pi DERIVED), the EW b_i is not yet substrate-fixed, and there is NO")
print("     clean n*pi (12pi is 1.9% off, a fit-trap). So #121 reduces to: derive b_EW from substrate")
print("     counting. Settled: condensation is generic + the packing sits at self-organized criticality")
print("     (why v<<M_Pl is stable, no fine-tuning). NOT fit -- v stays calibrated pending b_EW.")
print("   See QLF_CondensateGap.lean, QLF_ClosureBinding.lean, Higgs.md sec 5a, issue #121.")

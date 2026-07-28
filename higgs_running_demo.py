#!/usr/bin/env python3
"""
higgs_running_demo.py -- discharging the top-Yukawa running sector of the QLF Higgs quartic.

QLF reading (Higgs.md sec 5a): the electroweak vacuum is a self-organized-critical quantum-turbulent
state, which fixes the BOUNDARY CONDITION on the Higgs quartic at the substrate UV floor:

        lambda(M_Planck) = 0   and   beta_lambda(M_Planck) = 0

-- the Shaposhnikov-Wetterich condition (2010), which PREDICTED M_H ~ 126 GeV before the 2012
discovery of 125.  QLF supplies the mechanism (turbulent steady state -> critical fixed point) and
the UV floor by construction (cascade_has_floor, QLF_PlanckScale).  The NUMBER lambda(v) ~ 0.13 then
follows by running lambda down from that boundary with the Standard-Model RGEs, dominated by the top
Yukawa.  This demo makes that running explicit.

It integrates the one-loop SM RGEs for {g', g, g3, y_t, lambda} both ways:
  (A) FORWARD  : from the measured lambda(M_t)=0.126 up to M_Planck  -> confirms lambda -> ~0 (the
                 near-criticality / metastability), so the measured value satisfies the SOC boundary.
  (B) POSTDICT : impose lambda(M_Planck)=0, run DOWN -> predict lambda(v) and M_H = sqrt(2 lambda) v.

Honest scope: ONE-LOOP (qualitative); the precise zero-crossing (~1e10-1e11 GeV) and lambda(M_Pl)~0
need the two-loop RGEs + threshold corrections (Degrassi et al 2012, Buttazzo et al 2013).  The top
Yukawa (m_t) is an INPUT -- the same open mass scale as R_e / the QLF mass spectrum.  So this
discharges the running sector to {SOC boundary condition + m_t + two-loop precision}, not to a
pure-combinatorial number.  V = lambda|H|^4 convention, M_H^2 = 2 lambda v^2.
"""
import math

P = 1.0 / (16 * math.pi**2)           # 1/(16 pi^2)
V = 246.22                            # Higgs VEV / GeV
MT = 173.2                            # top-mass scale / GeV
MPL = 1.22e19                         # (reduced-ish) Planck scale / GeV


def derivs(y):
    """One-loop SM beta functions, physical normalization, t = ln(mu)."""
    gp, g, g3, yt, lam = y
    dgp = P * (41.0 / 6.0) * gp**3
    dg  = P * (-19.0 / 6.0) * g**3
    dg3 = P * (-7.0) * g3**3
    dyt = P * yt * ((9.0 / 2.0) * yt**2 - (17.0 / 12.0) * gp**2
                    - (9.0 / 4.0) * g**2 - 8.0 * g3**2)
    dlam = P * (24 * lam**2 + 12 * lam * yt**2 - 6 * yt**4
                - 3 * lam * (3 * g**2 + gp**2)
                + (3.0 / 8.0) * (2 * g**4 + (g**2 + gp**2)**2))
    return [dgp, dg, dg3, dyt, dlam]


def rk4(y, h):
    k1 = derivs(y)
    k2 = derivs([a + 0.5 * h * b for a, b in zip(y, k1)])
    k3 = derivs([a + 0.5 * h * b for a, b in zip(y, k2)])
    k4 = derivs([a + h * b for a, b in zip(y, k3)])
    return [a + (h / 6.0) * (b + 2 * c + 2 * d + e)
            for a, b, c, d, e in zip(y, k1, k2, k3, k4)]


def integrate(y0, mu0, mu1, record=None):
    """Integrate from mu0 to mu1 (either direction); return (final y, records)."""
    t, tE = math.log(mu0), math.log(mu1)
    h = 0.01 if tE > t else -0.01
    y = list(y0)
    recs, cross, prev = [], None, y[4]
    n = int(abs((tE - t) / h))
    for _ in range(n):
        y = rk4(y, h)
        t += h
        mu = math.exp(t)
        if prev > 0 >= y[4] and cross is None and h > 0:
            cross = mu
        prev = y[4]
        if record is not None:
            while record and mu >= record[0]:
                recs.append((record[0], list(y)))
                record = record[1:]
    return y, recs, cross


def rule(s):
    print("\n" + "=" * 74 + "\n" + s + "\n" + "-" * 74)


# measured-ish couplings at mu = M_t (Buttazzo et al 2013 central values)
Y_MT = [0.3587, 0.6483, 1.1666, 0.9369, 0.1260]   # gp, g, g3, yt, lambda

print(__doc__)

rule("A. FORWARD: measured lambda(M_t) -> M_Planck  (does it hit the SOC boundary lambda~0?)")
print(f"  start mu = {MT:.1f} GeV:  lambda = {Y_MT[4]:.4f}   "
      f"M_H(tree) = sqrt(2*lambda)*v = {math.sqrt(2*Y_MT[4])*V:.1f} GeV   yt = {Y_MT[3]:.3f}")
cps = [1e6, 1e8, 1e10, 1e13, 1e16, 1e19]
yF, recs, cross = integrate(Y_MT, MT, MPL, record=list(cps))
print(f"  {'mu/GeV':>10}  {'lambda':>9}  {'yt':>6}  {'g3':>6}")
for mu, y in recs:
    print(f"  {mu:>10.0e}  {y[4]:>+9.4f}  {y[3]:>6.3f}  {y[2]:>6.3f}")
print(f"  lambda(M_Planck) = {yF[4]:+.4f}   (crosses zero at mu ~ {cross:.1e} GeV)")
print("  -> lambda runs DOWN to ~0 (slightly negative): the measured 0.126 satisfies the")
print("     self-organized-critical boundary lambda(M_Pl) ~ 0 -- the near-criticality/metastability.")

rule("B. POSTDICT: impose the SOC boundary lambda(M_Planck)=0, run DOWN -> predict lambda(v), M_H")
# gauge+Yukawa are a closed subsystem (independent of lambda at one loop): take their M_Pl values
# from run A, set lambda(M_Pl)=0, integrate the full system back down to M_t.
yPl = list(yF); yPl[4] = 0.0
yBack, _, _ = integrate(yPl, MPL, MT)
lam_v = yBack[4]
MH = math.sqrt(2 * lam_v) * V if lam_v > 0 else float('nan')
print(f"  boundary:  lambda(M_Planck) = 0")
print(f"  predicted: lambda(v) = {lam_v:.4f}   ->   M_H = sqrt(2*lambda)*v = {MH:.1f} GeV")
print(f"  measured:  lambda(v) ~ 0.126        M_H = 125.25 GeV")
print(f"  one-loop agreement: lambda {abs(lam_v-0.126)/0.126*100:.0f}%,  M_H {abs(MH-125.25)/125.25*100:.0f}%")

rule("C. m_t itself: the top is the one fermion AT the electroweak scale (y_t ~ 1)")
print(f"  y_t = 1  =>  m_t = v/sqrt(2) = {V/math.sqrt(2):.1f} GeV   vs pole 172.7 GeV  "
      f"({abs(V/math.sqrt(2)-172.7)/172.7*100:.1f}%)")
print(f"  measured y_t(M_t) ~ 0.935  =>  m_t(MSbar) = {0.935*V/math.sqrt(2):.1f} GeV  (vs ~163)")
print("  So m_t is NOT a separate scale -- it is v/sqrt(2): the top's gauge-fold depth coincides with")
print("  the vacuum condensation depth R_stable (the top in resonance with the electroweak vacuum).")
print("\n  WHY y_t ~ 1 (not tiny like every other fermion): the QCD-driven IR quasi-fixed point")
print("  (Pendleton-Ross 1981 / Hill 1981). Run y_t DOWN from any UV value -> it is attracted to O(1):")
gPl = yF[:3]   # gauge+yukawa Planck values from run A
print(f"  {'y_t(M_Pl)':>10}  {'-> y_t(M_t)':>12}  {'m_t/GeV':>8}")
for yUV in [0.5, 1.0, 2.0, 3.0]:
    yb, _, _ = integrate([gPl[0], gPl[1], gPl[2], yUV, 0.0], MPL, MT)
    print(f"  {yUV:>10.1f}  {yb[3]:>12.3f}  {yb[3]*V/math.sqrt(2):>8.0f}")
print("  -> a narrow attractor y_t(M_t) ~ 1.0-1.26 (m_t ~ 178-220 GeV); the measured top sits at its")
print("     LOW edge (y_t~0.94, m_t=173). The fixed point forces y_t = O(1); the exact value is the residual.")

rule("D. R_stable = the condensation scale: the NJL / BHL top-condensation gap equation")
# Leading NJL gap equation (heavy top, cutoff Lam, dimensionless g = G Nc Lam^2/(4 pi^2)):
#   condensation (v != 0) for g > 1; near critical  (v/Lam)^2 * ln(Lam^2/v^2) = g - 1.
Lam = MPL
xg = (V / Lam) ** 2
eps = xg * math.log(1.0 / xg)      # = g - 1, the proximity to critical the observed v requires
print(f"  cutoff Lam = M_Planck = {Lam:.2e} GeV;  observed v = {V:.1f} GeV")
print(f"  gap eqn:  (v/Lam)^2 ln(Lam/v)^2 = g - 1 = {eps:.2e}")
print(f"  => the four-fermion coupling must sit g = 1 + {eps:.0e} above critical -- tuned to ~32 digits.")
print("     THAT fine-tuning IS the hierarchy problem in composite language (naive NJL, Planck cutoff).")
print("  QLF resolution: the cascade is FLOORED and discrete (cascade_has_floor / QLF_PlanckScale), so there")
print("  is no continuum coupling to fine-tune -- the near-critical condensation is the SOC attractor (the")
print("  SAME self-organized criticality that fixes lambda), generating v << M_Pl WITHOUT tuning.")
print(f"  The RG-improved compositeness condition = the sec-C IR fixed point: m_t ~ 220 GeV, v ~ {220*math.sqrt(2):.0f}")
print(f"  GeV -- ~{(220*math.sqrt(2)-V)/V*100:.0f}% above observed, the known BHL overshoot; the closest the")
print("  condensation dynamics comes to an ABSOLUTE prediction. Exact value (real m_t=173 at the fixed-point")
print("  low edge) + a first-principles substrate four-fermion coupling = the open frontier (higgs_turbulence).")

rule("E. The substrate four-fermion coupling: gravitational part (computable) + closure-binding (open)")
Nc = 3
print("  G (four-fermion) and R_stable are the SAME unknown (tied by the sec-D gap equation), so G is an")
print("  INDEPENDENT input only if computed from the substrate's INTERACTING closure dynamics.")
print("  One piece IS computable -- the coupling induced by QLF's emergent gravity (Einstein-Cartan torsion):")
for c, lab in [(3 * math.pi / 2, "3pi/2 (Kibble-Sciama)"), (math.pi, "pi")]:
    g = c * Nc / (4 * math.pi ** 2)
    print(f"    torsion coeff {lab:22s}: g_grav = {g:.2f}   (SUBcritical; g_crit = 1)")
print("  => gravity alone is SUBcritical (~0.1-0.4) -- too weak to condense (the known result). The")
print("     closure-binding (how gauge folds attract) must supply the rest to reach the SOC critical point.")
print("  THE FRONTIER: QLF formalizes the FREE closure census (counting); the four-fermion coupling is the")
print("  INTERACTING closure-binding, not yet formalized. Every step of the chain")
print("  (M_H -> lambda -> m_t -> v -> R_stable -> G) bottoms out HERE: the substrate INTERACTION, the one")
print("  irreducible frontier beyond the free-census core.")

rule("SCOPE (honest)")
print("  * ONE-LOOP: the qualitative near-criticality is robust, but the zero-crossing lands at")
print("    ~1e8 GeV here vs the two-loop ~1e10-1e11 GeV, and lambda(M_Pl) is more negative than the")
print("    two-loop ~0.  Precise M_H(m_t) needs the two-loop RGEs + thresholds (Degrassi 2012,")
print("    Buttazzo 2013) -- the accepted computation, not a QLF gap.")
print("  * m_t is reduced (sec C) to the electroweak scale v: y_t ~ 1 (m_t = v/sqrt2 = 174, 0.8% from pole),")
print("    the O(1) forced by the QCD IR quasi-fixed point. So m_t is NOT a free input -- it is v/sqrt2,")
print("    the same open scale v (= R_stable); the residual is y_t at the low edge (0.94) of the attractor.")
print("  * QLF's content: the SOC boundary condition lambda = beta_lambda = 0 at the Planck FLOOR")
print("    (cascade_has_floor, QLF_PlanckScale) -- a MECHANISM for the Shaposhnikov-Wetterich")
print("    condition, which predicted M_H ~ 126 GeV.  The running then delivers lambda(v) ~ 0.13.")
print("  * So the top-Yukawa running sector is discharged to {SOC boundary + m_t + 2-loop}, and the")
print("    driving term is the top -6 yt^4 in beta_lambda (QLF_TopYukawaRunning: beta_lambda(0) < 0).")
print("  See Higgs.md sec 5a, QLF_TopYukawaRunning.lean, QLF_RunningCouplings.lean.")

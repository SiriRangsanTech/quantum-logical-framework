#!/usr/bin/env python3
"""
gw_density_wave.py — numerical companion to QLF_GravitationalWaves.lean.

A gravitational wave in QLF is a propagating modulation delta-rho of the ZFA
closure-density field around the self-organized-critical equilibrium rho*.  This
demo exercises the same facts the Lean module proves:

  1. the discrete d'Alembertian  box_d = d2t - d2x  annihilates every
     traveling-wave profile  delta-rho(t,x) = f(x-t) + g(x+t)   (boxD_dAlembert);
  2. the metric perturbation  h = delta-rho / rho*  obeys the same equation;
  3. leapfrog evolution of the discrete wave equation propagates a pulse at
     exactly one lattice cell per tick = L_Planck / tau_Planck = c;
  4. the quadrupole is the leading radiative multipole: the monopole (conserved
     mass) and dipole (conserved momentum) have vanishing radiative source, the
     quadrupole does not (quadrupole_is_leading_radiative).

Pure-numpy, no plotting dependencies.
"""

import numpy as np

# ----------------------------------------------------------------------
# 1. the discrete d'Alembertian and the d'Alembert solution (boxD_dAlembert)
# ----------------------------------------------------------------------

def d2t(h, t, x):
    return h(t + 1, x) - 2 * h(t, x) + h(t - 1, x)

def d2x(h, t, x):
    return h(t, x + 1) - 2 * h(t, x) + h(t, x - 1)

def box_d(h, t, x):
    """Discrete d'Alembertian, characteristic speed 1 cell/tick = c."""
    return d2t(h, t, x) - d2x(h, t, x)

def d_alembert(f, g):
    """delta-rho(t,x) = f(x - t) + g(x + t): a right-mover + a left-mover."""
    return lambda t, x: f(x - t) + g(x + t)

def check_box_annihilates_traveling_waves(trials=2000, seed=0):
    rng = np.random.default_rng(seed)
    # random integer profiles f, g realized as dictionaries (arbitrary functions)
    fvals, gvals = {}, {}
    f = lambda k: fvals.setdefault(k, rng.standard_normal())
    g = lambda k: gvals.setdefault(k, rng.standard_normal())
    h = d_alembert(f, g)
    worst = 0.0
    for _ in range(trials):
        t = int(rng.integers(-50, 50))
        x = int(rng.integers(-50, 50))
        worst = max(worst, abs(box_d(h, t, x)))
    return worst

def check_metric_perturbation(rho_star=3.7, trials=2000, seed=1):
    rng = np.random.default_rng(seed)
    fvals, gvals = {}, {}
    f = lambda k: fvals.setdefault(k, rng.standard_normal())
    g = lambda k: gvals.setdefault(k, rng.standard_normal())
    dr = d_alembert(f, g)
    h = lambda t, x: dr(t, x) / rho_star      # metric perturbation h = delta-rho / rho*
    worst = 0.0
    for _ in range(trials):
        t = int(rng.integers(-50, 50))
        x = int(rng.integers(-50, 50))
        worst = max(worst, abs(box_d(h, t, x)))
    return worst

# ----------------------------------------------------------------------
# 2. leapfrog evolution: a pulse propagates at exactly c (1 cell / tick)
# ----------------------------------------------------------------------

def leapfrog_speed(N=400, steps=120, width=6.0):
    """Evolve the discrete wave equation u_tt = u_xx (c=1) for a right-moving
       Gaussian and confirm the peak advances one cell per tick."""
    x = np.arange(N)
    x0 = N // 4
    # right-mover initial data: u(0,x)=G(x-x0), u(1,x)=G(x-x0-1)  (shifted by +1)
    G = lambda s: np.exp(-((s) ** 2) / (2 * width ** 2))
    u_prev = G(x - x0)          # t = 0
    u_curr = G(x - x0 - 1)      # t = 1  (already advanced one cell)
    peaks = [int(np.argmax(u_prev)), int(np.argmax(u_curr))]
    for _ in range(steps):
        # discrete wave update (c=1): u_next = 2u - u_prev + (u_{x+1}-2u+u_{x-1})
        lap = np.roll(u_curr, -1) - 2 * u_curr + np.roll(u_curr, 1)
        u_next = 2 * u_curr - u_prev + lap
        u_next[0] = u_next[-1] = 0.0     # absorbing-ish edges (kept away from pulse)
        u_prev, u_curr = u_curr, u_next
        peaks.append(int(np.argmax(u_curr)))
    # speed = mean forward step of the peak over the clean interior window
    interior = [p for p in peaks if 5 < p < N - 5]
    steps_used = len(interior) - 1
    speed = (interior[-1] - interior[0]) / steps_used
    return speed, steps_used

# ----------------------------------------------------------------------
# 3. multipole selection: quadrupole is the leading radiative multipole
# ----------------------------------------------------------------------

def ddt2(Q, t):
    return Q(t + 1) - 2 * Q(t) + Q(t - 1)

def ddt3(Q, t):
    """Third discrete time-difference — the quadrupole-luminosity source d3Q/dt3."""
    return Q(t + 2) - 2 * Q(t + 1) + 2 * Q(t - 1) - Q(t - 2)

def multipole_report():
    ts = range(-10, 11)
    # (a) matches the Lean statement: ddt2 nonvanishing only for the quadrupole
    monopole = lambda t: 5.0                       # conserved mass     -> ddt2 = 0
    dipole = lambda t: 1.3 + 0.7 * t               # conserved momentum -> ddt2 = 0
    quad_min = lambda t: float(t) ** 2             # minimal quadrupole -> ddt2 = 2
    # (b) radiation source d3Q/dt3: for a *time-varying* (e.g. orbiting) source, only the
    #     quadrupole moment oscillates; mass and momentum stay conserved -> no radiation.
    quad_osc = lambda t: np.cos(0.6 * t)           # oscillating mass quadrupole -> radiates
    return {
        "monopole  ddt2 (max abs)": max(abs(ddt2(monopole, t)) for t in ts),
        "dipole    ddt2 (max abs)": max(abs(ddt2(dipole, t)) for t in ts),
        "quadrupole ddt2 (t=0)   ": ddt2(quad_min, 0),                       # == 2 (matches Lean)
        "monopole  ddt3 (max abs)": max(abs(ddt3(monopole, t)) for t in ts),
        "dipole    ddt3 (max abs)": max(abs(ddt3(dipole, t)) for t in ts),
        "quadrupole ddt3 (osc)   ": max(abs(ddt3(quad_osc, t)) for t in ts),  # != 0 -> radiates
    }

# ----------------------------------------------------------------------

if __name__ == "__main__":
    print("=" * 70)
    print(" QLF gravitational waves — closure-density wave equation (demo)")
    print("=" * 70)

    w1 = check_box_annihilates_traveling_waves()
    print(f"\n1. box_d(dAlembert f g) over 2000 random points: max |residual| = {w1:.2e}")
    print("   -> the discrete wave equation box_d delta-rho = 0 holds exactly (boxD_dAlembert).")

    w2 = check_metric_perturbation()
    print(f"\n2. box_d(h = delta-rho / rho*): max |residual| = {w2:.2e}")
    print("   -> the metric perturbation obeys the same equation (boxD_metricPerturbation).")

    speed, n = leapfrog_speed()
    print(f"\n3. leapfrog pulse peak speed over {n} ticks: {speed:.4f} cell/tick")
    print("   -> propagation at 1 cell/tick = L_Planck/tau_Planck = c (gw_speed_eq_planck_ratio).")

    print("\n4. multipole selection (quadrupole is the leading radiative multipole):")
    for k, v in multipole_report().items():
        print(f"     {k:26s} = {v:.3f}")
    print("   -> monopole & dipole: ddt2 = ddt3 = 0 (conserved mass & momentum, non-radiative);")
    print("      quadrupole: ddt2 = 2, ddt3 != 0 (radiates) -- quadrupole_is_leading_radiative.")

    print("\nOpen (dynamical-metric step): deriving box_d from the SOC rate equations")
    print("(QLF_ClosureAttraction/QLF_SteadyStateDensity), and the luminosity coefficient G/(5c^5).")

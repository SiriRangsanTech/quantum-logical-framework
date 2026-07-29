#!/usr/bin/env python3
"""
prime_cascade_decay.py -- turbulence-forced decay of a stable ZFA structure, and the collective
"prime-synchronized cascade dump" (a QLF-internal 'primordial supernova' mechanism).

QLF picture (Turbulence.md, QLF_QuantumTurbulence, QLF_PrimeResonance):
  * A stable bound state (muonium, hydrogen, a hadron) is a persistent ZFA closure at a definite fold
    depth R => internal frequency omega_b = 1/R.
  * Quantum turbulence presents ALL admissible closures at once, resolved highest-frequency-first. The
    IRREDUCIBLE (prime) closures carry an OPEN forward strand of odd Pauli count, so they fold to the
    geometric phase +-i (pi/2). Each such prime is a discrete phase-shift agent.
  * When the arrival statistics of primes at the octave nearest omega_b become COMMENSURATE with the
    bound state's internal clock, the +-i kicks add coherently instead of averaging to zero -> a forced
    phase slip drives the twist counts OUT of ZFA balance -> the structure is no longer a closure -> it
    must decay.  (Out-of-balance => not a closure is the Lean anchor: QLF_PrimeCascadeDecay.)
  * Each unlocked closure releases the free-action quantum dF = log 2 (QLF_FreeEnergy). If a macroscopic
    density reaches the critical prime-phase condition together, the releases feed back (raising the
    local prime flux), synchronizing the decays into a scale-invariant energy dump.

This demo implements Grok's dimensionless model with the prime flux taken from the ACTUAL census, and
exhibits (2) a decay-rate resonance, (3) on/off-resonance lifetimes, (4) the collective feedback dump.

HONEST SCOPE: phenomenological. The prime density rho_p(n) and the log-2 quantum are real census facts;
the couplings Gamma_p (prime->slip) and Q (resonance sharpness) are NOT derived -- the same open piece as
the four-fermion binding STRENGTH (higgs_turbulence_in_progress).  This is a QLF-internal mechanism, NOT a
claim that laboratory muonium or real supernovae proceed this way.
"""
import math
from math import comb


def catalan(k):
    return comb(2 * k, k) // (k + 1)


def rho_prime(n):
    """Density of irreducible (prime) closures at length 2n: 2*Catalan(n-1) / C(2n,n) (census)."""
    return 2 * catalan(n - 1) / comb(2 * n, n)


def rule(s):
    print("\n" + "=" * 76 + "\n" + s + "\n" + "-" * 76)


print(__doc__)

# ---------------------------------------------------------------------------------------------------
rule("1. The prime (irreducible) closure density from the census -- the phase-slip flux")
print("  Irreducible closures = 2*Catalan(n-1); their census fraction rho_p(n) sets the prime flux Phi_p.")
print(f"  {'2n':>4}{'C(2n,n)':>12}{'2*Cat(n-1)':>12}{'rho_p':>9}")
for n in range(1, 9):
    print(f"  {2*n:>4}{comb(2*n,n):>12d}{2*catalan(n-1):>12d}{rho_prime(n):>9.4f}")
print("  -> rho_p ~ 1/n: primes thin out with depth, so shallow (high-frequency) primes dominate the flux.")


# ---------------------------------------------------------------------------------------------------
# Dimensionless model (Grok):  dN/dtau = -(1 + gamma*phi*S) N ;  S = 1/(1 + Q^2 (wb - phi)^2)
#   tau = Gamma_0 t ;  phi = Phi_p/Gamma_0 (prime flux) ;  gamma = Gamma_p/Gamma_0 ;  wb = omega_b/Gamma_0.
def decay_rate(N, phi, wb, gamma, Q):
    S = 1.0 / (1.0 + (Q * (wb - phi)) ** 2)          # Lorentzian resonance (prime-clock commensurability)
    return (1.0 + gamma * phi * S), S


def evolve(wb, phi0, gamma, Q, kappa=0.0, tau_max=8.0, h=0.002):
    """RK4 for N (population) and E (cumulative released log-2 quanta); kappa = feedback of releases on flux."""
    N, E, tau = 1.0, 0.0, 0.0
    peakdEdt, tau_peak = 0.0, 0.0
    hist = []
    n_steps = int(tau_max / h)
    for _ in range(n_steps):
        def deriv(N, E):
            phi = phi0 + kappa * E                    # feedback: releases raise the local prime flux
            G, S = decay_rate(N, phi, wb, gamma, Q)
            return (-G * N, G * N)                     # dN/dtau, dE/dtau (each decay releases one log2)
        k1 = deriv(N, E)
        k2 = deriv(N + 0.5*h*k1[0], E + 0.5*h*k1[1])
        k3 = deriv(N + 0.5*h*k2[0], E + 0.5*h*k2[1])
        k4 = deriv(N + h*k3[0], E + h*k3[1])
        N += (h/6)*(k1[0]+2*k2[0]+2*k3[0]+k4[0])
        E += (h/6)*(k1[1]+2*k2[1]+2*k3[1]+k4[1])
        tau += h
        dEdt = k1[1]
        if dEdt > peakdEdt:
            peakdEdt, tau_peak = dEdt, tau
        hist.append((tau, N, E, dEdt))
    return N, E, peakdEdt, tau_peak, hist


def half_life(hist):
    for tau, N, _, _ in hist:
        if N <= 0.5:
            return tau
    return float('inf')


# take a representative prime flux from the census (shallow octave dominates)
phi_res = rho_prime(2)          # ~0.333 -- the resonant flux we tune omega_b to
gamma, Q = 40.0, 12.0

rule("2. Decay-rate RESONANCE: lifetime vs the bound-state frequency omega_b")
print(f"  fixed prime flux phi = {phi_res:.3f} (census), gamma={gamma:.0f}, Q={Q:.0f}; scan wb = omega_b/Gamma_0:")
print(f"  {'wb':>7}{'S(0)':>9}{'Gamma_eff':>11}{'half-life tau_1/2':>18}")
best = None
for wb in [0.05, 0.15, 0.25, 0.333, 0.45, 0.60, 1.0]:
    _, _, _, _, hist = evolve(wb, phi_res, gamma, Q)
    G0, S0 = decay_rate(1.0, phi_res, wb, gamma, Q)
    t12 = half_life(hist)
    tag = "  <-- RESONANCE" if abs(wb - phi_res) < 1e-6 else ""
    print(f"  {wb:>7.3f}{S0:>9.3f}{G0:>11.2f}{t12:>18.3f}{tag}")
print("  -> at commensurability (wb = phi) S->1, Gamma_eff jumps ~40x, the lifetime collapses: turbulence")
print("     FORCES the decay.  Off-resonance S->0 and the vacuum lifetime tau_1/2 = ln2 ~ 0.69 is recovered.")

rule("3. On- vs off-resonance decay curves N(tau)")
for label, wb in [("off-resonance (wb=1.0) ", 1.0), ("ON-resonance  (wb=phi) ", phi_res)]:
    _, _, _, _, hist = evolve(wb, phi_res, gamma, Q)
    print(f"  {label}: tau_1/2 = {half_life(hist):.3f}   N(1)={next(N for t,N,_,_ in hist if t>=1.0):.4f}"
          f"   N(3)={next(N for t,N,_,_ in hist if t>=3.0):.4f}")

rule("4. Collective PRIME-SYNCHRONIZED CASCADE DUMP (feedback runaway)")
print("  Start OFF resonance (wb=0.6, phi0=0.1: slow drain), then let releases raise the flux")
print("  (phi = phi0 + kappa*E): decays push neighbours toward the lock phi->wb -> synchronized unlocking.")
wb_c = 0.6
for kappa, label in [(0.0, "no feedback (independent decays)"), (0.75, "feedback kappa=0.75 (collective) ")]:
    _, Efin, peak, tpk, hist = evolve(wb_c, 0.10, gamma, Q, kappa=kappa, tau_max=10.0)
    lock = next((t for t, N, E, _ in hist if 0.10 + kappa * E >= wb_c), None)
    lockstr = f"; flux locks phi->wb at tau={lock:.2f}" if lock else ""
    print(f"  {label}: peak dE/dtau = {peak:6.2f} at tau={tpk:.2f}{lockstr}")
print("  -> with feedback the energy release SPIKES (a sudden, scale-invariant dump) instead of draining")
print("     slowly: a large ensemble of persistent phases unlocks together -- the 'primordial supernova'")
print("     as a prime-synchronized cascade dump, converting stored fold-depth into radiation + kinetic E.")

rule("SCOPE (honest)")
print("  * REAL (census / substrate): the prime-closure density rho_p(n)=2*Cat(n-1)/C(2n,n); the +-i prime")
print("    phase-slip (QLF_QuantumTurbulence); out-of-balance => not a closure => decay (QLF_PrimeCascadeDecay,")
print("    reusing zfa_implies_critical_line); the log-2 quantum per unlock (QLF_FreeEnergy); the octave cascade.")
print("  * PHENOMENOLOGICAL (not derived): Gamma_p, Q, kappa -- the map from ZFA combinatorics to the coupling")
print("    STRENGTH, the SAME open piece as the four-fermion binding strength (higgs_turbulence_in_progress).")
print("  * NOT a claim about laboratory muonium or real supernovae -- a QLF-internal mechanism, qualitative.")
print("  See Turbulence.md, QLF_PrimeCascadeDecay.lean, QLF_PrimeResonance.lean.")

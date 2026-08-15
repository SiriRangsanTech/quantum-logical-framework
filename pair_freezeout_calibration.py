#!/usr/bin/env python3
"""
pair_freezeout_calibration.py — calibrate the census freeze-out to the measured onsets.

A step toward issue #141. `pair_production_demo.py` models pair CREATION as a
deterministic census cascade (species = census multiplicity, lightest dominate)
and TEMPERATURE as a single *global* freeze-out fraction `min(0.97, 1.05·s)`. That
global fraction reproduces "how much is real" but NOT the onset *ordering*
(e⁺e⁻ appear ~10¹⁰ K, then μ⁺μ⁻ ~10¹², then p p̄ ~10¹³): every species goes real at
the same rate. This tool supplies the missing calibration.

Physics (standard thermodynamics): a pair species of rest energy m turns on at
    T_onset ≈ m c² / k_B .
QLF adds the reading that makes this a *census* statement: mass is frequency /
fold depth (`m = ℏf/R`), so `m_i / m_e` is the census frequency index of species i
(m_μ/m_e ≈ 207, m_p/m_e ≈ 1836). Hence the onset temperatures are the census
frequencies rescaled by `K_e = m_e c²/k_B` (the constructor's own constant), and
the census's "lightest = lowest-frequency = most numerous" ordering **is** the
observed e→μ→p onset ordering. Replacing the single global freeze-out with a
per-species threshold `real_i(T)` gated at `T_onset,i` reproduces the sequence.

HONEST SCOPE: `T_onset = m c²/k` is standard thermodynamics; QLF's content is that
`m` is the census frequency, so the *ordering* is the census's. What remains open
(#141) is deriving the freeze-out functional form and normalisation from the
census itself (not calibrating the onsets to the measured masses). No deps.
Run:  python3 pair_freezeout_calibration.py
"""
import math

# --- constructor constants (spacetime_constructor.html) ---
K_e = 5.93e9        # K   = m_e c² / k_B  (electron rest energy as a temperature)
T_CMB = 2.725
T_P = 1.416784e32
T_FLOOR = 1e-3

# measured rest energies as census frequency indices m/m_e (= f/f_e):
SPECIES = [
    ("e+e-", 1.0),        # electron
    ("mu+mu-", 206.768),  # muon
    ("p pbar", 1836.15),  # proton
]


def T_onset(freq: float) -> float:
    """Onset temperature of a species of frequency index freq = m/m_e."""
    return K_e * freq


def s_for_T(T: float) -> float:
    """Constructor slider position s∈[0,1] for temperature T (K)."""
    if T <= T_FLOOR:
        return 0.0
    return min(1.0, math.log(T / T_FLOOR) / math.log(T_P / T_FLOOR))


def real_frac_per_species(T: float, freq: float, width: float = 0.6) -> float:
    """Per-species freeze-out: a logistic in log-T centred at the species onset
    T_onset = K_e·freq. 0 far below, 0.5 at onset, →1 (cap 0.97) far above."""
    x = math.log10(max(T, 1e-30) / T_onset(freq))
    return 0.97 / (1.0 + math.exp(-x / width))


def real_frac_global(s: float) -> float:
    """The constructor's current single, species-independent freeze-out fraction."""
    return min(0.97, 1.05 * max(0.0, s))


def main() -> None:
    print(__doc__.strip().split("\n\n")[0])
    print()

    print("1. Onset temperatures = census frequency × K_e  (K_e = m_e c²/k_B):")
    print(f"   {'species':8} {'freq m/m_e':>11} {'T_onset (K)':>13} {'slider s':>9}")
    for name, f in SPECIES:
        Ton = T_onset(f)
        print(f"   {name:8} {f:>11.2f} {Ton:>13.3e} {s_for_T(Ton):>9.3f}")
    print("   → lightest = lowest frequency = lowest onset: the census ordering e→μ→p,")
    print("     and the values match the textbook thresholds (~1e10, ~1e12, ~1e13 K).\n")

    print("2. Per-species freeze-out reproduces the ordering (real fraction vs T):")
    print(f"   {'T (K)':>11} {'e+e-':>7} {'mu+mu-':>7} {'p pbar':>7}   {'global':>7}")
    for T in (1e9, 1e10, 1e11, 1e12, 1e13, 1e14, 2.5e30):
        rf = [real_frac_per_species(T, f) for _, f in SPECIES]
        print(f"   {T:>11.1e} {rf[0]:>7.2f} {rf[1]:>7.2f} {rf[2]:>7.2f}   {real_frac_global(s_for_T(T)):>7.2f}")
    print("   → per-species thresholds turn e on first, then μ, then p (correct sequence);")
    print("     the constructor's single 'global' column cannot distinguish them.\n")

    print("Calibration: gate species i's census freeze-out at T_onset,i = K_e·(m_i/m_e).")
    print("The census supplies the ORDERING (lightest dominate); the measured masses fix")
    print("the onset temperatures. OPEN (#141): derive the freeze-out form + normalisation")
    print("from the census itself, not by matching the onsets to the masses.")


if __name__ == "__main__":
    main()

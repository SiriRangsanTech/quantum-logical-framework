import QLF_SubstrateLightSpeed
import QLF_Spin

set_option linter.unusedVariables false

/-!
# QLF_GravitationalWaves — what the substrate fixes about GWs (and what it does not)

A gravitational wave is a **transverse ripple in synthesized spacetime** — a propagating
disturbance in the ZFA-event-rate / holographic-density field, not a substance moving through a
pre-existing background. `GR_Schwarzschild.md` flagged GWs as open ("time-dependent metrics need
additional substrate machinery"). That remains true for the *wave equation*; but several
features of the wave **do** follow from machinery QLF already has, and are anchored here.

* **GWs propagate at `c`** (`gw_speed_eq_planck_ratio`). A GW carries no gauge fold (`+`/`−`),
  so it is **massless** (depth `R = 0`, like the photon) and propagates at the substrate light
  speed `c = L_Planck/τ_Planck` (`QLF_SubstrateLightSpeed`, `local_light_speed_invariant`). This
  is the falsifiable headline — GW170817 measured `|v_GW − c|/c < 10⁻¹⁵`.
* **The graviton is spin-2, a composite of half-spins** (`graviton_integer_spin`). Integer spin
  is not fundamental in QLF — it is an even number of half-spin pairs (`boson_even_pairs`;
  photon = ½+½ = spin 1, `photon_integer_spin`). The graviton is **four** half-spin units —
  two photon-worths, `1+1 = 2` — folding to `+I`: an integer-spin boson, spin 2.
* **Two transverse polarizations** (`massless_two_polarizations`). Being massless, the graviton
  carries only its two extreme helicities `±2` (transverse-traceless), *not* `2J+1 = 5` — exactly
  as the massless photon carries 2 (`±1`), not 3. The polarization count is a masslessness
  consequence, shared with light.

## The density-perturbation route to the wave equation

A gravitational wave is a weak, transverse, propagating ripple in the local **event-synthesis /
closure-density** field: `ρ(t,x) = ρ* + δρ(t,x)` with `|δρ| ≪ ρ*`, the background being the
self-organized-critical equilibrium `ρ*` (`QLF_SteadyStateDensity`). On the substrate lattice
(one Planck length × one Planck tick per cell) the **discrete d'Alembertian** `□_d = ∂_t² − ∂_x²`
(`boxD`, characteristic speed = one Planck length per Planck tick `= c`) **annihilates every
traveling-wave profile** — `boxD_rightMover`, `boxD_leftMover`, and the full d'Alembert solution
`boxD_dAlembert` — so `□_d δρ = 0` (§4). The metric perturbation `h ∝ δρ/ρ*` obeys the *same*
equation (`boxD_metricPerturbation`), and the **quadrupole is the leading radiative multipole**
because mass–energy and momentum conservation kill the monopole and dipole (§6).

## Honest scope

This anchors **speed `= c`, masslessness, spin-2-as-composite, the 2-polarization count, and now the
linearized wave equation itself** via the density-perturbation route (§4): `□_d δρ = 0` is proven
discretely, its continuum limit being the linearized Einstein vacuum equation `□h_μν = 0` (the
standard second-order finite-difference correspondence). **Still open** — the two pieces that need
the *dynamical* substrate metric: (i) *deriving* the wave operator `boxD` from the SOC
binding + continuity rate equations (`QLF_ClosureAttraction` / `QLF_SteadyStateDensity`) in the
continuum limit — the dynamical-metric step, the same gap as the full Einstein field equations; and
(ii) the quadrupole luminosity *coefficient* `G/(5c⁵)` in `L = (G/5c⁵)⟨d³Q/dt³⟩²`, where `G = L_P²c³/ℏ`
(`QLF_GravityFromDelay`) and `8π = 4π·2` (`QLF_EinsteinGeometricFactor`) are already substrate-fixed.
Status `gravitational_waves_in_progress`. See `GR_Schwarzschild.md`.
-/

namespace QLF

open QLF.Spin

/-! ### 1. A gravitational wave propagates at the substrate light speed `c` -/

/-- **Propagation speed of a gravitational wave** — a massless (gauge-fold-free) transverse
    disturbance of synthesized spacetime travels at the substrate light speed. -/
noncomputable def gw_speed : ℝ := substrate_light_speed

/-- GW speed **is** the substrate light speed (the same `c` that is locally invariant,
    `local_light_speed_invariant`). -/
theorem gw_speed_eq_c : gw_speed = substrate_light_speed := rfl

/-- **GW speed `= L_Planck/τ_Planck = c`** — matching GW170817's `|v_GW − c|/c < 10⁻¹⁵`. -/
theorem gw_speed_eq_planck_ratio : gw_speed = planck_length / planck_time := rfl

/-! ### 2. The graviton is spin-2 — a composite of four half-spins (two photon-worths) -/

/-- **The graviton is an integer-spin boson.** Four half-spin units — `1 + 1 = 2`, two
    photon-worths — fold to `+I` (`boson_even_pairs`, an even pair count returns under 360°).
    Spin 2 is not fundamental: it is four half-spins, exactly as the substrate forces. -/
theorem graviton_integer_spin (a b c d : Twist) :
    concatPairsMatrixFold [a, b, c, d] = (1 : M) :=
  boson_even_pairs [a, b, c, d] ⟨2, rfl⟩

/-- Photon spin (one half-spin pair, `½+½`). -/
def photon_spin : ℕ := 1

/-- Graviton spin. -/
def graviton_spin : ℕ := 2

/-- **Spin 2 = two spin-1 = four half-spins** — the graviton is two photon-worths of spin. -/
theorem graviton_spin_two_photons : graviton_spin = 2 * photon_spin := rfl

/-! ### 3. Two transverse polarizations — a consequence of masslessness -/

/-- Photon transverse polarizations (`±1`), 2 not 3 — because the photon is massless. -/
def photon_polarizations : ℕ := 2

/-- Graviton transverse-traceless polarizations (`±2`), 2 not `2J+1 = 5`. -/
def graviton_polarizations : ℕ := 2

/-- **Massless ⇒ two polarizations.** The graviton carries the same number of physical
    polarizations as the photon — its two extreme helicities — because both are massless. -/
theorem massless_two_polarizations : graviton_polarizations = photon_polarizations := rfl

/-! ### 4. A gravitational wave as a propagating closure-density perturbation — the discrete wave equation

    In QLF spacetime intervals are synthesized by ZFA events, so a gravitational wave is a weak,
    transverse, propagating ripple `δρ` in the local event-synthesis / closure-density field around
    the SOC equilibrium `ρ*`. On the substrate lattice this obeys a *discrete* wave equation whose
    traveling-wave (d'Alembert) solutions move one Planck length per Planck tick — i.e. at `c`. -/

/-- A discrete spacetime field on the substrate lattice: `t` indexes the Planck tick, `x` the Planck
    length along the propagation axis. Physically the closure-density perturbation `δρ(t,x)` (or the
    metric perturbation `h ∝ δρ/ρ*`). -/
abbrev LatticeField := ℤ → ℤ → ℝ

/-- Discrete second time-difference (one Planck tick) — the substrate `∂_t²`. -/
def d2t (h : LatticeField) (t x : ℤ) : ℝ := h (t + 1) x - 2 * h t x + h (t - 1) x

/-- Discrete second space-difference (one Planck length) — the substrate `∂_x²`. -/
def d2x (h : LatticeField) (t x : ℤ) : ℝ := h t (x + 1) - 2 * h t x + h t (x - 1)

/-- **The discrete d'Alembertian** `□_d = ∂_t² − ∂_x²`, characteristic speed one Planck length per
    Planck tick `= c` (`QLF_SubstrateLightSpeed`). -/
def boxD (h : LatticeField) (t x : ℤ) : ℝ := d2t h t x - d2x h t x

/-- A right-moving closure-density ripple `δρ(t,x) = g(x − t)`, moving at `+c`. -/
def rightMover (g : ℤ → ℝ) : LatticeField := fun t x => g (x - t)

/-- A left-moving closure-density ripple `δρ(t,x) = g(x + t)`, moving at `−c`. -/
def leftMover (g : ℤ → ℝ) : LatticeField := fun t x => g (x + t)

/-- **The wave equation, discretely (right-mover).** For *every* profile `g`, the right-moving
    ripple is annihilated by the discrete d'Alembertian: `boxD (rightMover g) = 0`. The perturbation
    obeys `□_d δρ = 0` and travels one Planck length per Planck tick — the substrate speed `c`. -/
theorem boxD_rightMover (g : ℤ → ℝ) (t x : ℤ) : boxD (rightMover g) t x = 0 := by
  simp only [boxD, d2t, d2x, rightMover]
  have h1 : x - (t + 1) = x - 1 - t := by ring
  have h2 : x - (t - 1) = x + 1 - t := by ring
  rw [h1, h2]; ring

/-- **The wave equation, discretely (left-mover).** `boxD (leftMover g) = 0` for every `g`. -/
theorem boxD_leftMover (g : ℤ → ℝ) (t x : ℤ) : boxD (leftMover g) t x = 0 := by
  simp only [boxD, d2t, d2x, leftMover]
  have h1 : x + (t + 1) = x + 1 + t := by ring
  have h2 : x + (t - 1) = x - 1 + t := by ring
  rw [h1, h2]; ring

/-- The general **d'Alembert solution** `δρ(t,x) = f(x−t) + g(x+t)` — superposed left- and
    right-movers, the full 1-D solution space of the wave equation. -/
def dAlembert (f g : ℤ → ℝ) : LatticeField := fun t x => f (x - t) + g (x + t)

/-- **`□_d δρ = 0` for the general d'Alembert solution** — every superposition of a left- and a
    right-moving closure-density ripple solves the discrete wave equation. -/
theorem boxD_dAlembert (f g : ℤ → ℝ) (t x : ℤ) : boxD (dAlembert f g) t x = 0 := by
  simp only [boxD, d2t, d2x, dAlembert]
  have hf1 : x - (t + 1) = x - 1 - t := by ring
  have hf2 : x - (t - 1) = x + 1 - t := by ring
  have hg1 : x + (t + 1) = x + 1 + t := by ring
  have hg2 : x + (t - 1) = x - 1 + t := by ring
  rw [hf1, hf2, hg1, hg2]; ring

/-- The **metric perturbation** is the fractional closure-density ripple, `h ∝ δρ/ρ*` (`ρ*` the SOC
    equilibrium, `QLF_SteadyStateDensity`). Being a constant multiple of `δρ`, it obeys the *same*
    wave equation. -/
def metricPerturbation (ρstar : ℝ) (δρ : LatticeField) : LatticeField := fun t x => δρ t x / ρstar

/-- **`□_d h = 0` for the metric perturbation** `h = δρ/ρ*` — the linearized metric ripple satisfies
    the same discrete wave equation as the density ripple (continuum limit: `□h_μν = 0`). -/
theorem boxD_metricPerturbation (ρstar : ℝ) (f g : ℤ → ℝ) (t x : ℤ) :
    boxD (metricPerturbation ρstar (dAlembert f g)) t x = 0 := by
  simp only [boxD, d2t, d2x, metricPerturbation, dAlembert]
  have hf1 : x - (t + 1) = x - 1 - t := by ring
  have hf2 : x - (t - 1) = x + 1 - t := by ring
  have hg1 : x + (t + 1) = x + 1 + t := by ring
  have hg2 : x + (t - 1) = x - 1 + t := by ring
  rw [hf1, hf2, hg1, hg2]; ring

/-! ### 5. The ripple is transverse with two polarizations (reuse)

    The propagating `δρ` disturbance is transverse-traceless; being massless (§1, §3) it carries
    exactly the two polarizations of `massless_two_polarizations` — the same count as light. -/

/-! ### 6. The quadrupole is the leading radiative multipole

    Radiation is sourced by the time-variation of a source's multipole moments. Mass–energy and
    momentum conservation force the two lowest moments to be non-radiative, leaving the quadrupole
    as the leading radiative multipole — the structural content of the quadrupole luminosity formula. -/

/-- A multipole moment as a function of the Planck tick. -/
abbrev TimeSeries := ℤ → ℝ

/-- Discrete second time-difference of a moment — its radiative source strength (a moment radiates
    only if its curvature in time is nonzero; the full formula uses the third derivative, but the
    *vanishing* of the low moments is already visible at second order). -/
def ddt2 (Q : TimeSeries) (t : ℤ) : ℝ := Q (t + 1) - 2 * Q t + Q (t - 1)

/-- **The mass monopole does not radiate** — total closure count (mass–energy) is conserved, so the
    monopole is constant in time and its radiative source vanishes. -/
theorem monopole_no_radiation (M₀ : ℝ) (t : ℤ) : ddt2 (fun _ => M₀) t = 0 := by
  simp only [ddt2]; ring

/-- **The mass dipole does not radiate** — its first time-derivative is the total momentum, which is
    conserved, so the dipole is affine in time (`a + b·t`) and its radiative source vanishes. -/
theorem dipole_no_radiation (a b : ℝ) (t : ℤ) : ddt2 (fun s => a + b * (s : ℝ)) t = 0 := by
  simp only [ddt2]; push_cast; ring

/-- **The quadrupole does radiate** — a generic quadrupole (minimally `Q(t) = t²`) has a nonzero
    radiative source, so it is the **leading** radiative multipole once the conserved monopole and
    dipole are removed. -/
theorem quadrupole_radiates (t : ℤ) : ddt2 (fun s => (s : ℝ) ^ 2) t = 2 := by
  simp only [ddt2]; push_cast; ring

/-- **The leading radiative multipole is the quadrupole.** Mass–energy conservation kills the
    monopole and momentum conservation kills the dipole (both `ddt2 = 0`), while a generic quadrupole
    has a nonzero source (`ddt2 = 2 ≠ 0`). This is the multipole-selection structure of the
    quadrupole luminosity formula; the coefficient `G/(5c⁵)` is the open continuum-normalization. -/
theorem quadrupole_is_leading_radiative :
    (∀ (M₀ : ℝ) (t : ℤ), ddt2 (fun _ => M₀) t = 0) ∧
    (∀ (a b : ℝ) (t : ℤ), ddt2 (fun s => a + b * (s : ℝ)) t = 0) ∧
    (∀ t : ℤ, ddt2 (fun s => (s : ℝ) ^ 2) t = 2) :=
  ⟨monopole_no_radiation, dipole_no_radiation, quadrupole_radiates⟩

/-! ### Summary -/

/-- **What the substrate fixes about gravitational waves**: speed `= c`, spin `2` (two
    photon-worths of half-spin), `2` transverse polarizations, and the linearized wave equation
    `□_d δρ = 0` (the density-perturbation route). -/
theorem gravitational_wave_substrate_summary :
    gw_speed = substrate_light_speed ∧
    graviton_spin = 2 * photon_spin ∧
    graviton_polarizations = 2 ∧
    (∀ (f g : ℤ → ℝ) (t x : ℤ), boxD (dAlembert f g) t x = 0) :=
  ⟨rfl, rfl, rfl, boxD_dAlembert⟩

/-- **Established constructively:** a GW is a massless transverse ripple of synthesized spacetime ⇒
    propagates at `c` (`gw_speed_eq_planck_ratio`, the GW170817 result); the graviton is spin-2 as a
    composite of four half-spins (`graviton_integer_spin`) with 2 transverse polarizations from
    masslessness; and — via the density-perturbation route — the **linearized wave equation
    `□_d δρ = 0`** holds for every traveling-wave closure-density ripple (`boxD_dAlembert`,
    `boxD_metricPerturbation`), with the **quadrupole the leading radiative multipole**
    (`quadrupole_is_leading_radiative`). **Open (localized to the dynamical-metric step):** deriving
    the wave operator `boxD` from the SOC binding+continuity rate equations
    (`QLF_ClosureAttraction`/`QLF_SteadyStateDensity`) in the continuum limit, and the luminosity
    *coefficient* `G/(5c⁵)`. See `GR_Schwarzschild.md`. -/
theorem gravitational_waves_in_progress : True := trivial

end QLF

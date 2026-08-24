/-
  QLF_Inertia.lean — Route A: an accelerated null circulation weighs exactly `E/c²`.

  Every step on the substrate runs at `c` — one Planck length per Planck tick, and the
  ρ-cancellation `(ρ·L_P)/(ρ·τ_P) = L_P/τ_P` holds that at every Markov-blanket depth
  (Kitada_Local_Time_GR.md, Tier 1). So a *massive* particle cannot be something moving slower: it
  must be a **closed circulation of light-speed steps**, and its rest mass is the loop not going
  anywhere. "The light-speed energy in every direction sums to zero" is then not a new posit — it is
  the signed action vector vanishing, which is ZFA count balance itself (`calculate_action` in
  twist_core.py; `ClosedLoop` in QLF_Folding; `countBalanced` in QLF_TwistAlphabet).

  This module does the two-leg case — an Einstein light clock, the minimal such circulation — and
  computes what accelerating it costs.

  **The result.** Let the two legs differ in energy by a fractional shift `δ` (the leg traversed
  against the acceleration blueshifted, the one with it redshifted). Each reflection transfers
  `2E/c`; a round trip takes `2L/c`. Then

      netForce = −E·δ / L          (`netForce_eq`)

  and **the circulation speed `c` cancels out of the force entirely** — only the shift per unit
  length survives. Feed in the equivalence-principle shift `δ = aL/c²` (GR_Schwarzschild.md §2a, the
  JILA/NIST millimetre-scale redshift, itself read off Cross_Frequency_Lorentz.md as a
  Markov-blanket frequency ratio) and

      netForce = −(E/c²)·a = −m·a   (`inertial_reaction`, `inertial_reaction_mass`)

  with **`L` cancelling too** (`independent_of_circulation_size`): the internal size of the
  circulation does not appear, so it does not matter how the mass is built. This is the
  photon-in-a-box argument, which is standard and correct; the QLF claim is that it is not special to
  boxes of light, because *every* rest mass is such a circulation.

  **The shift is forced, not fitted** (`force_scales_with_shift`): the force is exactly proportional
  to `δ`, so scaling the shift law by `k` scales the inertia by `k`. Only `δ = aL/c²` returns `ma`.
  A different redshift law would give a *different* inertial mass for the same energy — which is the
  sense in which the equivalence-principle shift is exactly the shift that makes a null circulation
  weigh what it weighs.

  **What is input and what is derived.** The shift `δ = aL/c²` is the input; it is the repo's
  existing gravitational-redshift account, not established here. What is derived is that this shift,
  and no other, converts a balanced null circulation into `F = −ma` with both `c` and `L` cancelling.
  So this is a **bridge reused plus an exact computation**, not inertia from nothing — and the
  computation could have failed (a surviving `L`, or a factor of 2, would have killed the picture).

  **Not claimed:** that the circulation whose period gives `m = 1/R` (Per_Qubit_Mass_Quantum.md) is
  *the same object* as the gauge-fold depth Higgs.md calls inertial mass — that identification is
  Inertia.md kill condition 3 and is open. Nor the rotational sector (frame dragging). No axioms.
-/

import Mathlib

namespace QLF.Inertia

/-! ## The two legs of an accelerated light clock -/

/-- The leg traversed *against* the acceleration — lower in the equivalent field, so blueshifted. -/
noncomputable def legRear (E delta : ℝ) : ℝ := E * (1 + delta / 2)

/-- The leg traversed *with* the acceleration — higher in the equivalent field, so redshifted. -/
noncomputable def legFront (E delta : ℝ) : ℝ := E * (1 - delta / 2)

/-- **The circulation is balanced when the legs are.** With no shift the two legs carry equal
    energy — the directional sums cancel, which is ZFA closure and is what "rest mass" means. -/
theorem legs_balanced_iff_no_shift (E delta : ℝ) (hE : E ≠ 0) :
    legRear E delta = legFront E delta ↔ delta = 0 := by
  unfold legRear legFront
  constructor
  · intro h
    have h' : E * delta = 0 := by linarith [h]
    rcases mul_eq_zero.mp h' with h'' | h''
    · exact absurd h'' hE
    · exact h''
  · intro h; rw [h]; ring

/-- Each reflection transfers `2E/c`; the rear leg pushes backwards, the front leg forwards. -/
noncomputable def netImpulse (E delta c : ℝ) : ℝ :=
  2 * legFront E delta / c - 2 * legRear E delta / c

/-- A round trip of a circulation of size `L` takes `2L/c`. -/
noncomputable def roundTripTime (L c : ℝ) : ℝ := 2 * L / c

/-- The net force on the circulation: impulse per round trip. -/
noncomputable def netForce (E delta L c : ℝ) : ℝ :=
  netImpulse E delta c / roundTripTime L c

/-! ## The computation -/

/-- **The circulation speed cancels.** `netForce = −Eδ/L` — the force depends only on the shift per
    unit length, not on how fast the loop runs. -/
theorem netForce_eq (E delta L c : ℝ) (hL : L ≠ 0) (hc : c ≠ 0) :
    netForce E delta L c = -(E * delta) / L := by
  unfold netForce netImpulse roundTripTime legFront legRear
  field_simp
  ring

/-- **Route A's result: an accelerated null circulation resists with exactly `−(E/c²)a`.**
    Feed the equivalence-principle shift `δ = aL/c²` into `netForce_eq` and the size `L` cancels as
    well, leaving the inertial reaction. -/
theorem inertial_reaction (E a L c : ℝ) (hL : L ≠ 0) (hc : c ≠ 0) :
    netForce E (a * L / c ^ 2) L c = -(E / c ^ 2) * a := by
  rw [netForce_eq E _ L c hL hc]
  field_simp

/-- **`F = −ma`**, once `E = mc²` is used. -/
theorem inertial_reaction_mass (E m a L c : ℝ) (hL : L ≠ 0) (hc : c ≠ 0)
    (hm : E = m * c ^ 2) :
    netForce E (a * L / c ^ 2) L c = -m * a := by
  rw [inertial_reaction E a L c hL hc, hm]
  field_simp

/-- **The internal size of the circulation does not appear.** Two circulations of different size but
    equal energy resist identically — so it does not matter how the mass is built. -/
theorem independent_of_circulation_size (E a L₁ L₂ c : ℝ)
    (hL₁ : L₁ ≠ 0) (hL₂ : L₂ ≠ 0) (hc : c ≠ 0) :
    netForce E (a * L₁ / c ^ 2) L₁ c = netForce E (a * L₂ / c ^ 2) L₂ c := by
  rw [inertial_reaction E a L₁ c hL₁ hc, inertial_reaction E a L₂ c hL₂ hc]

/-- **Uniform motion is free, at any speed.** No acceleration, no shift, no imbalance, no force —
    the directional sums still cancel. This is Galileo's ship, and Inertia.md kill condition 2. -/
theorem no_force_without_acceleration (E L c : ℝ) (hL : L ≠ 0) (hc : c ≠ 0) :
    netForce E (0 * L / c ^ 2) L c = 0 := by
  rw [inertial_reaction E 0 L c hL hc]
  ring

/-- **The shift law is forced, not fitted.** The force is exactly proportional to the shift, so a
    redshift law scaled by `k` yields an inertia scaled by `k`: only `δ = aL/c²` returns `ma`. A
    different shift would make the same energy weigh a different amount. -/
theorem force_scales_with_shift (E a L c k : ℝ) (hL : L ≠ 0) (hc : c ≠ 0) :
    netForce E (k * (a * L / c ^ 2)) L c = k * (-(E / c ^ 2) * a) := by
  rw [netForce_eq E _ L c hL hc]
  field_simp

/-- **What Route A establishes**, as a conjunction rather than a `True` summary: the legs balance
    exactly when there is no shift (rest), and the equivalence-principle shift makes an accelerated
    circulation of energy `E` resist with exactly `−(E/c²)a`, independent of its size. -/
theorem route_A_established (E a L c : ℝ) (hE : E ≠ 0) (hL : L ≠ 0) (hc : c ≠ 0) :
    (legRear E 0 = legFront E 0) ∧ netForce E (a * L / c ^ 2) L c = -(E / c ^ 2) * a :=
  ⟨(legs_balanced_iff_no_shift E 0 hE).mpr rfl, inertial_reaction E a L c hL hc⟩

end QLF.Inertia

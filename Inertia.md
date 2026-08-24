# Inertia in QLF — a plan, not a result

**Epistemic status: scoping document.** Nothing here is claimed as derived. This is the proof plan
for demystifying inertia in the [Quantum Logical Framework](README.md) (QLF), the order the work
should be attempted in, and — first — the conditions under which it should be abandoned.

> **The hypothesis.** A mass is a region of elevated logical density — gauge-folded ZFA closures
> constructing delay ([`Higgs.md`](Higgs.md) §51, [`Gravity_From_Delay.md`](Gravity_From_Delay.md)).
> Around it sits an **active frequency window**: the vacuum modes its local Markov blanket can still
> exchange with the surrounding census. At **constant velocity the window is isotropic** at any
> speed, so there is no net free-action gradient and no force. Under **acceleration** the window is
> compressed on one side and expanded on the other; the imbalance costs free action, and that cost
> **is** inertia.

---

## 0. What is already answered — do not re-derive it

grok's plan proposes five phases. Three of them are substantially built already, and the plan below
is short because of it. Checked against the repo, not assumed:

| piece | status | where |
|---|---|---|
| Mass = constructing delay (gauge-fold depth) | built | [`Higgs.md`](Higgs.md), [`Per_Qubit_Mass_Quantum.md`](Per_Qubit_Mass_Quantum.md) |
| **Equivalence principle** — one delay, read as inertia at the vertex and curvature in the geometry | **already claimed structurally** | [`Forces_From_Three_Axes.md`](Forces_From_Three_Axes.md) §144, [`UniversalRelativity.md`](UniversalRelativity.md) §436 |
| Casimir as a **finite census**, not a subtracted infinity; `1/a⁴` parameter-free | **Lean-anchored** | [`QLF_Casimir`](lean/QLF_Casimir.lean) (`casimir_vacuum_quantum`, `casimir_scaling`) |
| **Accelerated boundary = Unruh** (the dynamical-Casimir link grok proposes building) | **NOT anchored — the theorem is `rfl`** (audited after this plan was first written; see §0a) | `accelerated_boundary_is_unruh` |
| **Unruh master relation** `T = ℏa/(2πck_B)`, with Hawking and de Sitter as instances | **Lean-anchored** | [`QLF_HorizonTemperature`](lean/QLF_HorizonTemperature.lean) |
| Holographic entropy `S(R)` | **Lean-anchored** | `holographic_entropy_eq` |
| Lorentz boost = ratio of Markov-blanket internal ZFA event rates | built, boosts only | [`Cross_Frequency_Lorentz.md`](Cross_Frequency_Lorentz.md) |
| Vacuum spectrum, per-event `log 2`, scale-free `ρ(ω)` | built | [`VacuumEnergy.md`](VacuumEnergy.md) |

So **Phase 4 (equivalence) is mostly done, and Phase 3 (Casimir/Unruh) is less done than it looks** —
see §0a immediately below. What is genuinely missing is the middle: the step from *acceleration* to a
*force*, and its rotational counterpart. Two more facts matter for where to start:

- [`Cross_Frequency_Lorentz.md`](Cross_Frequency_Lorentz.md) §6 says in as many words that
  **accelerations are out of scope** there — *"accelerations require a frequency-derivative term"* —
  and §7 already names *"Generalisation to acceleration"* as the open successor. That is the home for
  Phase 1; it should be **extended**, not duplicated.
- There is **no** inertia, Mach, or frame-dragging entry in
  [`Mysteries_Of_Physics.md`](Mysteries_Of_Physics.md). That is a gap in the registry independent of
  whether this programme succeeds.

### 0a. An audit correction — the Casimir/Unruh tie is not anchored

The first draft of this plan listed `accelerated_boundary_is_unruh` among the Lean-anchored assets.
Reading the module rather than its name shows that is wrong, and the correction matters for where
the work starts.

**The theorem is `rfl`.** Its statement is `unruh_temperature ℏ a c k_B = ℏa/(2πc k_B)` — and that is
the *definition* of `unruh_temperature`. No boundary appears in it. It records the identification QLF
makes and is not evidence for it. Upstream [`QLF_HorizonTemperature`](lean/QLF_HorizonTemperature.lean)
is scrupulous about exactly this — `hawking_is_unruh` and `desitter_is_unruh` both carry
"(definitional)" in their docstrings — and it also carries two genuinely non-trivial theorems
(`hawking_temperature_eq`, `desitter_temperature_eq`). [`QLF_Casimir`](lean/QLF_Casimir.lean) had
inherited the relation without inheriting the label; it now carries it, and three statements that are
**not** `rfl` have been added there:

- **`boundary_unruh_zero_iff_inertial`** — a boundary reads a thermal vacuum **exactly when it
  accelerates**, and at no constant velocity however large. This is the formal content of Galileo's
  ship and the isotropy premise this programme needs; it is the first piece of Phase 1 that exists.
- **`boundary_unruh_linear_in_acceleration`** — the response is exactly linear in `a`, with no
  threshold. Inertia is linear in `a`, which is why any derivation must route through this.
- **`static_boundary_no_unruh`** — a static boundary has no bath, so the **static Casimir force is not
  thermal in origin**. The two effects are separate, and conflating them is the easy error.

**Why this strengthens rather than weakens the plan.** The step the programme most wants to lean
on — *accelerating mass as its own dynamical-Casimir boundary* — turns out to be the step that is
asserted rather than established. That is now Phase 2's actual work rather than a free inheritance.
It is also the second time in two sessions that reading a module instead of its name changed the
picture, which is the argument for R6a being applied *before* the derivation, not after.

---

## 1. Kill conditions — stated first

Per [`ScientificApproach.md`](ScientificApproach.md) R7, before any derivation. Two of these are
sharp enough to end the programme on their own.

1. **Inertial-mass anisotropy (Hughes–Drever).** Clock-comparison experiments bound any directional
   dependence of inertial mass to better than one part in 10²⁰, and modern versions far tighter. A
   mechanism in which inertia *is* a directional vacuum-mode imbalance must explain why a laboratory
   on an accelerating, rotating, orbiting Earth sees an isotropic inertial mass to that precision.
   **This is the hardest constraint in the programme and it must be faced in Phase 0, not deferred to
   a discussion section.**
2. **Exact Lorentz invariance at constant velocity.** The window must be isotropic at *every* speed
   exactly, not approximately. QLF has the right shape for this (a statistically uniform, stateless
   ether — [`UniversalRelativity.md`](UniversalRelativity.md)), but "the census looks the same in
   every frame" has to be proven, not asserted.
3. **One mass, not two.** The `m` in `F = ma` must be *identically* the `m` of
   [`Per_Qubit_Mass_Quantum.md`](Per_Qubit_Mass_Quantum.md) and
   [`E_mc2_derivation.md`](E_mc2_derivation.md). A vacuum-window mechanism that produces its own mass
   term, even a proportional one, has produced a **contradiction**, not a derivation.
4. **Frame dragging must land on the measurement.** Gravity Probe B: geodetic precession to 0.3%,
   frame-dragging ≈ 39 mas/yr to ≈ 19%; LAGEOS/LARES ≈ 10%. A rotational sector that cannot hit
   these is wrong, and one that "hits" them with a fitted coefficient has not derived anything.
5. **The rule-4 gate, applied per phase.** A phase earns its place only if it changes a **count of
   ways** — if "the window compresses" does not alter a census multiplicity, it is bookkeeping
   ([`Philosophy.md`](Philosophy.md) §3a rule 4). This session already lost a folding bridge that
   failed exactly here ([`Protein_Folding.md`](Protein_Folding.md) §5e): a substrate theorem was
   read as licensing a factorization it did not license, and the regression found it. Assume the same
   trap is present until each step is tested.

---

## 2. The named prior attempt — say how this differs, or inherit its fate

**Haisch, Rueda & Puthoff (1994), *Inertia as a zero-point-field Lorentz force*** is this hypothesis,
in continuum language: inertia as the reaction to an asymmetric zero-point field seen by an
accelerating body. It did not converge — the derivation was contested on covariance grounds and the
programme did not produce an accepted account of `F = ma`.

QLF does not get to ignore this. Before Phase 2 is written, the plan owes an explicit statement of
**what is structurally different here** — the honest candidates being that QLF's vacuum is a *finite
discrete census* rather than a divergent field (so no regularization is smuggled in, per
[`VacuumEnergy.md`](VacuumEnergy.md) §4.0), and that the delay is already the mass rather than being
generated by the interaction. If neither difference does real work, this is the same route and it
should be recorded as **rejected**, not re-run.

## 3. The problem with the front/rear picture

The proposed mechanism says the window is *compressed in front and expanded behind*. The standard
result is that an accelerated observer sees a **thermal bath at temperature `T = ℏa/(2πck_B)` that
is isotropic in their own frame** — not a front/rear gradient. These are not obviously the same
statement, and they may not be compatible.

**Phase 1's first job is to decide which it is**: whether the asymmetry is a real feature of the
census or an artifact of describing the accelerated frame in inertial coordinates. If it is an
artifact, the window picture is a narrative and the derivation must go through the thermodynamic
route below instead. This should be settled before any Lean is written.

## 4. The shorter path the plan misses

Because `unruh_temperature` and `holographic_entropy_eq` are **both already Lean-anchored**, there is
a two-step route to `F = ma` that needs no new mechanism — Verlinde's (2011) entropic argument, whose
ingredients QLF already has:

```
    ΔS = 2π k_B (mc/ℏ) Δx        holographic entropy gradient across a screen
    T  = ℏa / (2π c k_B)         the Unruh relation                (QLF_HorizonTemperature)
    F  = T ΔS/Δx = m a           the 2π cancels; the force is the entropy gradient
```

This should be attempted **first**, because it reuses proven machinery instead of asserting a new
mechanism — and it is the same Jacobson-style move the repo already used to get the Einstein
coefficient (`einstein_coupling_from_thermodynamics`).

**But apply R6a before writing a line of it.** Bundle the entropy gradient into a structure and try
to satisfy it trivially. If `ΔS ∝ m Δx` is *definitional* — if the screen's entropy is defined so
that the gradient comes out proportional to the mass — then `F = ma` is a **restatement of its own
premise**, which is precisely the failure mode measured in `yang_mills_gap` (`continuumGap_nonempty`
builds a realization by `rfl`, so the boundary is definitional in Lean). A derivation that cannot
fail has derived nothing. Record the outcome either way; that measurement *is* the result of Phase 2,
whichever way it goes.

---

## 5. The phases

Each phase names its deliverable, its owning doc, and the count that would falsify it.

**Phase 0 — definitions, and the anisotropy bound.**
Define the **active frequency window** of a ZFA-closed subsystem: the set of twist-history
frequencies that can still achieve closure with the local blanket inside its capacity `R`
([`QLF_HorizonClosure`](lean/QLF_HorizonClosure.lean), `closedAtHorizon`). Define isotropy as a
statement about *census multiplicity* on opposite sides, so it is a count and not a picture.
**Then immediately confront kill condition 1**: compute what anisotropy the mechanism predicts for a
lab on Earth and compare to the Hughes–Drever bound. *If the predicted anisotropy exceeds the bound,
stop here.* Owner: extend [`Cross_Frequency_Lorentz.md`](Cross_Frequency_Lorentz.md) §7.

**Phase 1 — uniform motion is isotropic, exactly.**
Prove the window census is invariant under a boost — the constant-velocity half, and the formal
content of **Galileo's ship** (*Dialogue*, 1632): below decks, no experiment reveals uniform motion.
Deliverable: the `lorentz_boost_from_zfa_frequencies` theorem that
[`Cross_Frequency_Lorentz.md`](Cross_Frequency_Lorentz.md) §7 already names as open, plus a demo
boosting a dense closure through a simulated ZFA vacuum and showing front/rear mode counts stay
equal. Falsifier: any speed at which the counts differ.

**Phase 2 — acceleration to force.**
Run the thermodynamic route (§4) *with the R6a check first*. Only if it is definitional, fall back to
deriving the window asymmetry directly — and only after §3 has established the asymmetry is real.
Target theorems: `accelerating_window_imbalance`, `inertial_force_from_frequency_asymmetry`.
Falsifier: a force that is not exactly `ma`, or an `m` that is not the substrate's `m`.
**Do not add a `True` summary theorem.** `casimir_summary` used to be `True := trivial` and has been
replaced with the conjunction of what that module actually proves;
`gravity_from_delay_proven_constructively` is still `True := trivial` and carries nothing. A summary
every possible module satisfies reports no content.

**Phase 3 — the rotational sector: Newton's bucket and frame dragging.**
The two touchstone experiments are the two halves of this programme, and they pair exactly:

- **Galileo's ship** — uniform motion is undetectable → Phase 1's isotropy.
- **Newton's bucket** (*Principia*, 1689) — the water climbs the wall, so *rotation is detectable*
  → the window shears azimuthally. Newton read this as proof of absolute space; Mach (1883) read it
  as the distant stars. QLF's answer is neither: the reference is the **global census of ZFA
  histories**, which is Machian in effect without being a force at a distance.

Then frame dragging as the same shear sourced by a *rotating mass*: co-rotating directions see a
compressed window, counter-rotating an expanded one, so the local zero-torque frame is dragged.
Target: recover Lense–Thirring precession with the `1/r³` falloff and hit kill condition 4. Owner: a
new section in [`Gravity.md`](Gravity.md) or [`Curvature.md`](Curvature.md) — the azimuthal
counterpart of the radial delay bias, not a separate mechanism.

**Phase 4 — the write-up.**
Fold the results back into this document, converting it from a plan into an account: the hypothesis,
the two experiments, the derivation, why it is the same mass that sources gravity, and — with equal
prominence — whichever kill conditions fired. Demos: `inertia_window_demo.py` (accelerate a dense
closure, plot front/rear spectra and net force) extending the existing
[`gravity_delay_demo.py`](gravity_delay_demo.py).

---

## 6. What would make this worth having

Inertia currently sits in physics as a primitive: matter resists acceleration, and that is where the
explanation stops. If this programme works, inertia becomes a **local consequence of a mass
re-balancing its own active vacuum-frequency window**, and the equivalence principle stops being a
coincidence to be honoured and becomes an identity — one constructing delay, read radially as
gravity, longitudinally as inertia, azimuthally as frame dragging.

That is worth attempting. But the honest prior is set by §2: this exact idea has been tried in
continuum language and did not converge, and the anisotropy bound in §1 is brutal. **The most likely
outcome is that Phase 0 or Phase 2's R6a check ends it** — and a clean, recorded negative on a
mechanism this attractive would itself be worth the work.

---

**See also:** [`VacuumEnergy.md`](VacuumEnergy.md) (the vacuum census and the Casimir section) ·
[`Cross_Frequency_Lorentz.md`](Cross_Frequency_Lorentz.md) (boosts as frequency ratios; acceleration
named open) · [`Gravity_From_Delay.md`](Gravity_From_Delay.md) · [`Higgs.md`](Higgs.md) (mass as
gauge-fold delay) · [`UniversalRelativity.md`](UniversalRelativity.md) (the uniform-ether framing) ·
[`ScientificApproach.md`](ScientificApproach.md) (R6a, R7, and the correction protocol).

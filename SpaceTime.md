# SpaceTime Dynamics in the Quantum Logical Framework

**Author:** Jim Whitescarver  
**Repository:** [quantum-logical-framework](https://github.com/jimscarver/quantum-logical-framework)

*(Note: This document provides a tutorial on the spatial and gravitational network dynamics of [QLF](README.md). For the foundational derivation of how the clock ticks via gauge folds and Planck action, start with [`Time.md`](Time.md).)*

## The Exhaust of Computation

In standard physics, spacetime is treated as a continuous background manifold where events happen. In the Quantum Logical Framework (QLF), **spacetime is the emergent topological boundary of QuCalc resolving logical closures.** It is not the container of reality; it is the "exhaust" of the universal NAND-DAG computation.

Space and time do not exist at the fundamental level. Reality is composed entirely of binary distinctions (twists) from the 8-twist QuCalc alphabet. `RhoQuCalc` acts as the concurrent operating system that pipes the output of one Zero Free Action (ZFA) closure into the context of another.

This tutorial bridges the theoretical concepts of emergent spacetime with their formal machine-verified proofs and executable Python simulations.

---

## 1. The Substrate: Universality and ZFA

Before spacetime can emerge, the system must guarantee that logical structures can persistently form. 

Every terminating logical computation can be unrolled into a finite, acyclic NAND-delay graph. In QLF, these graphs are built from ZFA closures (e.g., `^+ + v^- = 0`). The `zeno_prune` operation actively destroys any topological string that fails to balance, meaning only logically consistent histories survive to construct reality.

* **Formal Proof:** See [`lean/QLF_Universality.lean`](lean/QLF_Universality.lean). This file contains the machine-verified Lean 4 proof that QLF generates all terminating finitely-encoded logical computations. It proves that any valid system annihilates completely under `full_zeno_prune` and achieves ZFA.
* **Core Engine:** See [`twist_core.py`](twist_core.py) to observe the raw twist operations and ZFA closures in action.
* **Variational physics:** The connection between ZFA closures and the Lagrangian principle S=∫ℒ dΩ — including the continuous limit via `EventSynthesisField → Λ_eff` (SpacetimeDynamics.lean:57) — is formalized in [`Lagrangian_Formulation.md`](Lagrangian_Formulation.md).

## 2. Time as Logical Latency

Time is a discrete resource synthesized by gauge folds. One tick of the universal clock corresponds to the resolution of one logical bit (a single ZFA closure) per unit of Planck action. 

The time delay ($\Delta t$) required to resolve an event is inversely proportional to its ZFA degeneracy ($W_{ZFA}$), defined as the number of possible ZFA closures available. 

$$\Delta t \propto \frac{1}{W_{ZFA}}$$

In highly constrained environments (like near massive objects), the Markov blankets limit the number of possible ways to achieve ZFA. As $W_{ZFA}$ decreases, the latency per logical step increases. This is the physical mechanism behind **Time Dilation**.

There is no universal clock: **each mass runs its own independent time thread**, and this latency is the tick rate of that one thread. Dilation is therefore never absolute — it is the *ratio* of one thread's synthesis rate to another's, a point made precise in §4.

* **Formal Proof:** See [`SpacetimeDynamics.lean`](lean/SpacetimeDynamics.lean). This file formally proves `time_dilation_in_constrained_space`, mathematically guaranteeing that logic nodes with lower $W_{ZFA}$ have strictly greater logical latency.
* **Empirical Demo:** Run [`muon_lifetime_demo.py`](muon_lifetime_demo.py). This script demonstrates how particle lifetime depends on the internal logical bit synthesis rate. As velocity shifts the reference frame, the internal synthesis rate drops, matching empirical observations of high-velocity muons living longer in the lab frame.

## 3. Space as Logical Distance

If time is the *delay* in computing ZFA closures, space is the *network* of those closures.

Physical distance is a macro-scale illusion masking **logical distance**.  Two nodes in the QuCalc tree that require millions of intermediate resolutions to interact are "far apart." Nodes sharing a direct logical dependency are "adjacent." 

Constant velocity is simply a continuous shift in logical perspective relative to the ZFA network. Approaching the speed of light ($c$) exhausts the available degrees of freedom for internal ZFA cycles. With no internal cycles, the event rate drops to zero, halting the local experience of time. Faster-than-light travel is strictly forbidden because the engine cannot compute "negative events."

This ZFA network is not a passive backdrop — it is the *uniform ether* against which every thread's motion is measured, and §4 shows why its uniformity is what makes $c$ the same for all observers.

### 3a. Why exactly three spatial dimensions — the graph-rendering necessity

Space being the *network of closures* answers a question usually deferred as an input: **why three
dimensions?** The substrate is a **relational graph** — events are ZFA closures, edges are
closure-reachability (the pre-geometric causal network of [`lean/QLF_ReachableEvent.lean`](lean/QLF_ReachableEvent.lean)).
Space is the **faithful rendering** of that graph, and the rendering dimension is *determined* by a
theorem of graph embedding:

- **Every finite graph embeds in ℝ³ without crossings.** Place the vertices on the moment curve
  `(t, t², t³)`; no four are coplanar, so no two edges cross — for *any* graph, `Kₙ` included.
- **Three is the minimum.** In ℝ² only *planar* graphs embed; `K₅` and `K₃,₃` cannot (Kuratowski).
  One and two dimensions cannot faithfully render an arbitrary relational structure.

So three dimensions is **necessary** (a general closure graph contains non-planar substructure, so
fewer than three would force distinct relations to cross or coincide — spurious identifications, an
incoherent world), **sufficient** (every graph fits in 3D; none needs more), and **selected** (the
minimal faithful rendering is the most economical — the MRE / minimal-description optimum — and the
only *comprehensible* one; more dimensions render nothing 3D cannot, at extra descriptive cost). In
one line:

> **Three is the minimal dimension in which any relational structure can be faithfully and
> comprehensibly rendered at all — so *that there is anything (any rendered world) at all* entails
> three spatial dimensions.**

This is a derivation of `substrate_spatial_dimension = 3`, not an assumption of it. The other QLF
3-signatures — Newton's `1/r²` (Gauss's law in 3D), the nuclear magic numbers, and `α = N = 3²`
([`Magic_numbers.md`](Magic_numbers.md), [`QLF_FineStructureSubstrate`](lean/QLF_FineStructureSubstrate.lean)) —
are then *consequences and cross-checks* of the 3D rendering, not independent posits of it; and the
three fermion generations inherit it (`num_generations = substrate_spatial_dimension = 3`,
[`QLF_Generations`](lean/QLF_Generations.lean)). Because `α = N = 3²` is a consequence of the 3D
rendering, the derived `α = 1/137` is the value of **fully-rendered 3D space** (the IR / `q²→0` anchor),
and its Standard-Model "running" reads as the effective-dimension flow `3→2` toward the UV — see
[**Alpha.md**](Alpha.md), which also proves `α(0)` carries no cosmological-time drift (it is a function
of the rendering dimension alone, `α(d) = 1/(128 + d²)`). **Honest scope:** the embedding theorem is exact; the
premises it rests on — that the substrate *is* a relational graph and space *is* its minimal faithful
rendering — are QLF's own load-bearing ontology (the synthesis claim + `QLF_ReachableEvent`), not
extra assumptions, so this derives 3D *within QLF*, not from nothing external.

The above is the *counting* layer (why the rendering dimension is 3). The *mechanism* layer — how the
pre-geometric pointer-swap dynamics of the substrate becomes sparse operational 3D *for an embedded
observer* — is specified and made falsifiable in [`Pointer_Swap_Fuzz.md`](Pointer_Swap_Fuzz.md): geometry
is built only from swap-orbit invariants, and "sees 3D" gets exact content as swap-graph ball growth
`~ r³`. A first computation ([`pointer_swap_fuzz.py`](pointer_swap_fuzz.py)) finds growth dimension near 3
for the two substrate-natural closure lengths (the minimal 4-twist chiral loop and the length-8
four-complement-pair balanced closure), with the decisive substrate-fixed swap generating set still open.

## 4. The Uniform Ether and Lorentz Invariance

The ZFA network of §3 is more than a relational graph — it is **Einstein's stateless ether**. In his 1920 Leiden address Einstein rehabilitated the ether as something with real physical and metric properties but **no state of motion**: a medium you cannot ride, with no preferred rest frame. The QuCalc substrate is exactly this. It is structured — it supplies the degeneracy $W_{ZFA}$ that sets each thread's tick rate — yet statistically **homogeneous**: away from mass clusters, every node of the network offers the same $W_{ZFA}$. Because the ether has no mechanical state, no thread can measure absolute motion through it.

This homogeneity is what ties the two dilations of §2–3 into one mechanism. Both are the *same* effect — fewer ZFA closures synthesized per unit of some *other* thread's clock:

* **Gravitational dilation** (§2, §5): a mass cluster lowers the *local availability* of closures, raising latency $1/W_{ZFA}$ and slowing the thread.
* **Kinematic dilation** (§3): motion spends degrees of freedom on translation, leaving fewer DOF for internal ZFA cycles, so the thread completes fewer closures.

Because the ether is uniform, **no thread is privileged**. Two threads in relative motion each measure the *other* as slow, reciprocally and symmetrically — there is no fact of the matter as to which "really" runs slow, because there is no preferred frame to anchor the claim. That reciprocal symmetry **is** the content of Lorentz invariance. The frame-independence of $c$ then follows: $c$ is the ceiling on local event-synthesis rate (§3), and a *uniform* substrate imposes the *same* ceiling on every thread. Einstein assumed the constancy of $c$; QLF derives it from the homogeneity of the ZFA ether.

> Independent time threads (no shared clock) + a stateless uniform ether (no preferred frame) ⟹ time dilation is reciprocal ⟹ Lorentz invariance is emergent, not postulated.

* **Further Reading:** This is the spatial-network view of the argument developed thread-first in the [`Time.md`](Time.md) section *Time Dilation as Thread Desynchronization* (§4). The two sections are the same claim seen from the time side and the space side.

## 5. Gravity as a Possibilist Gradient

QLF derives gravity strictly from computational probability, avoiding the need for curved spacetime geometry. 

Mass is a dense cluster of localized, stable ZFA closures. These clusters restrict the possibilist space around them, acting as Markov blankets that lower $W_{ZFA}$ for nearby events. Because standard events naturally resolve along the paths of least resistance (highest degeneracy), a particle will statistically drift toward regions where it requires fewer local cycles to resolve its history. 

Gravity is simply the statistical gradient of ZFA resolution latency.

* **Formal Proof:** See the `gravity_is_time_dilation` theorem in [`SpacetimeDynamics.lean`](lean/SpacetimeDynamics.lean). This verifies that a shift in the gravitational gradient strictly implies a shift in time dilation, linking the two phenomena computationally.
* **Empirical Demo:** Run [`SpaceTime.py`](SpaceTime.py). 
  * *Tutorial Step:* When you execute this file, a simulated QuCalc grid is generated with a "massive" ZFA cluster at the center. Watch as the test particle's random walk is statistically biased toward the mass, moving from regions of high $W_{ZFA}$ (empty space) into the high-latency gravity well, perfectly modeling the possibilist gradient descent.

## 6. Universal Expansion (The Cosmological Computation)

The universe is not expanding into an empty void; the QuCalc engine is simply synthesizing more bits.

The total accumulated period of the universe grows with every successful ZFA closure. **The Cosmological Horizon** is the physical boundary reached by the very first synthesized bits of the QuCalc engine. The continuous unrolling of the finite NAND-DAG computation manifests physically as the metric expansion of space.

* **Further Reading:** For the exact mathematical relationship linking the Cosmological Horizon to the Planck Length ($R_H / l_P = T_U / \Delta t_P$), refer back to the Cosmological Clock section in [`Time.md`](Time.md).

## 7. Interactive: the Spectral Spacetime Constructor

Everything in this document is one picture when you can turn it in your hands. [`spacetime_constructor.html`](spacetime_constructor.html) is a dependency-free, self-contained tool (open it in any browser; also live on GitHub Pages: [spacetime_constructor.html](https://jimscarver.github.io/quantum-logical-framework/spacetime_constructor.html)) that renders the substrate as a field of discrete QuCalc nodes and lets you *construct* space, time, and matter from frequency.

**The one mapping — frequency is space, time, and colour at once.** A node's local clock rate is `f = 1/latency = 1/R` (§2, [`QLF_LocalClock`](lean/QLF_LocalClock.lean)). Space is *where* the nodes are; time is *how fast they tick* (the pulse); colour is that same frequency read off the visible spectrum (low f → red, high f → violet). Nothing is added to carry "time" or "colour" separately — they are the one quantity.

**Mass, redshift, and time dilation are one phenomenon.** Mass is not placed by hand — it *arises* from the closures: any particle or atom lowers the local ZFA degeneracy `w_ZFA` (§5, the possibilist gradient; [`SpaceTime.py`](SpaceTime.py)). Near a mass, clocks tick *slower* **and** redden together; far away they run fast and blue. Gravitational time dilation and gravitational redshift are not two effects — they are the single frequency drop, shown as one colour shift. Live telemetry reads the deepest-well clock ratio and the redshift `z`.

**The vacuum is never dead — closures cascade from the single distinction, by frequency.** The generator is not thermal: it is a **deterministic frequency cascade**. The one first distinction (phase 0) unfolds the census *by frequency* — the logical bang ([`Creation.md`](Creation.md) §8a; [`QLF_HarmonicClosure`](lean/QLF_HarmonicClosure.lean), [`QLF_PrimeResonance`](lean/QLF_PrimeResonance.lean)) — so the lightest, lowest-frequency closures dominate and the heavier ones appear as the cascade reaches them. This runs at **every** setting, *independent of the vacuum energy*: even at absolute zero the substrate keeps closing balanced pairs that flicker straight back to possibility — the quantum foam, the log-2 dark-energy floor (`Ω_Λ = log 2 ≠ 0`, [`QLF_CosmologicalConstant`](lean/QLF_CosmologicalConstant.lean)). Because a lone net charge cannot close ([`QLF_Confinement.charged_not_closed`](lean/QLF_Confinement.lean)), it is always **count-balanced matter–antimatter pairs**, each coloured by its **rest-mass frequency** (`m = 1/R`, [`QLF_HiggsMechanism`](lean/QLF_HiggsMechanism.lean)) — light electron low/red, heavy proton high/violet.

**Temperature only decides what freezes out as real.** A temperature slider runs (log-scaled) from **absolute zero** through the **CMB (2.7 K, the default)** up to the **Planck temperature (~10³² K)**. It does *not* create the closures — it sets how many freeze out as **real (persistent) matter** versus flicker back as **virtual foam**: cold ⇒ almost all foam (a seething vacuum, no persistent matter); hot ⇒ matter freezes out, then — near the Planck top — black holes. So heating walks the vacuum forward through cosmic history rather than switching a Boltzmann gate.

**One relative perspective — the observer at the centre.** The whole model is drawn from *one* observer's frame: a stick figure stands at the origin — a Markov blanket at the centre of its own horizon ([`QLF_HorizonClosure`](lean/QLF_HorizonClosure.lean)), with everything seen relative to here. There is no god's-eye spin: the view holds a fixed orientation unless *you* drag it (auto-spin is opt-in). This is why the thermal glow arrives **from the sky inward**: the CMB is the Gibbons–Hawking radiation of the de Sitter **horizon** ([`QLF_HorizonTemperature`](lean/QLF_HorizonTemperature.lean)), emitted on the outer shell and travelling in, not from a source inside.

**The vacuum's energy density — dark energy is the floor, not a constant.** The **Vacuum ρ** readout gives the physical energy density of the vacuum, and it is *temperature-driven* (real physical `T`, scale-independent). Its regimes, named on hover:
- **dark energy** — the cold floor, the cosmological-constant term (constant in `T`). QLF derives it, `ρ_Λ = (3 log 2 / 8π)·c⁴/(G R_H²) ≈ 3.35 GeV/m³`, matching the measured dark-energy density to ~1% ([`Cosmological_Constant.md`](Cosmological_Constant.md) §3).
- **dark matter** — scales as `(T/T_CMB)³` (matter-like, `∝ a⁻³`), overtaking the floor just above the CMB.
- **vacuum energy** — the thermal term `∝ T⁴`, dominating when hot and reaching the **Planck density (~5×10¹¹³ J/m³)** at the Planck temperature.

So the famous **10¹²² "vacuum catastrophe" is just the ratio of the two ends of this one axis** — dark energy the floor, the Planck density the ceiling — the surface-vs-volume, de Sitter-vs-Planck counting of [`Cosmological_Constant.md`](Cosmological_Constant.md) §4, walked live by the slider.

**Photons interact along their path, and are received.** A photon is not a straight streak that vanishes at a wall. It **bends in the latency field** — the `w_ZFA` gradient acts as a refractive index, so light lenses toward mass (the interaction is the geometry), running dead straight only in flat vacuum, always at speed `c` (the gradient turns the direction, never the magnitude — the uniform stateless ether ⇒ local Lorentz invariance). The thermal sky is emitted on the horizon as a **hierarchical cascade** — twice as many photons at half the energy (`1 : 2 : 4`), so the sky is red-dominated with a few blue, the vacuum spectrum. Termination obeys the ZFA transaction: a photon **ends when a local observer receives it** (a real particle, atom, or black hole — a measurement, marked by a flash); otherwise the **vacuum is the ultimate absorber**. Energy is conserved — an absorbed photon's energy returns to the vacuum account, never vanishing. Click a photon and it reads its **frequency** (`E = ℏω`: e.g. 438 THz red … 769 THz violet, or a γ-ray from annihilation).

**Unstable closures decay — deterministically.** The muon and the free neutron are not the deepest closure, so they decay to lighter products (`n → p + e⁻ + ν̄`; `μ⁻ → e⁻ ν̄_e ν_μ` — charge, baryon **and** lepton number conserved; [`QLF_Fusion`](lean/QLF_Fusion.lean), [`Beta_Decay_Neutrino_Nature.md`](Beta_Decay_Neutrino_Nature.md)), while the proton and electron persist. Decay is **not a random timer**: each closure's lifetime is the census inverse-CDF of the exponential, so the *population* decays exponentially — deterministic ensemble statistics of the prime bath ([`Decay.md`](Decay.md) §1a). A particle meeting its antiparticle annihilates in a photon burst, and decays/annihilation throw off **photon streaks** (massless, straight, coloured by their energy).

**At the Planck energy, black holes form — and evaporate into hadrons.** Near the top of the temperature slider the vacuum's per-quantum energy reaches the **Planck mass**, and a closure crosses the **Compton = Schwarzschild** point ([`QLF_QuantumBlackHole`](lean/QLF_QuantumBlackHole.lean), [`QLF_PlanckScale`](lean/QLF_PlanckScale.lean); confirmed exactly, `μ² = 1/2`, in [`genesis.py`](genesis.py) §7 / [`Genesis.md`](Genesis.md)): a micro **black hole** forms — a dark event horizon with a glowing ring, the deepest well of all. It **Hawking-evaporates** (`dM/dt ∝ −1/M²`, bluer as it heats, [`QLF_HorizonTemperature`](lean/QLF_HorizonTemperature.lean)), radiating the full thermal spectrum — photons **and balanced pairs of leptons and hadrons**. Since a **hadron *is* a quantum black hole** ([`QLF_QuantumBlackHole`](lean/QLF_QuantumBlackHole.lean)), the Planck black hole cascades down into hadron-scale quantum black holes — a Planck quantum has energy far above any hadron's rest mass, so the closure is admissible and, *possibilist*, what can close does.

**This is the Big Bang, seen from the inside.** The hottest setting is the earliest instant — QLF's *logical bang* ([`Creation.md`](Creation.md) §8a, [`QLF_LogicalBang`](lean/QLF_LogicalBang.lean)). Turn the temperature down from the Planck top and the constructor walks that doc's phases outward on its own: a plasma of **tiny (Planck-mass) black holes** → **hadrons** emerging as they Hawking-cascade (the nucleon ring `p`, `n`) → recombination into atoms as the vacuum cools. None of it is scripted — it falls out of ZFA and the closure census alone, so the tool independently reproduces **primordial black holes** and the **hadron epoch** as *consequences* of the substrate, not inputs. (Legacy pictures like "recombination at ~3000 K" are one rendering of the same closure dynamics; we obey ZFA and let them emerge, never hardcode them.)

**Interaction is the geometry, not a force — and bound states assemble themselves.** There are no forces in QLF; a body simply moves *down the local `w_ZFA` latency gradient* — the possibilist gradient of §5, `−∇w`, mass-independent (the equivalence principle; the well *depth* already carries the mass, so a light electron falls onto a near-stationary proton). Every body sources that field, so they interact automatically. There is also no wall: a body that drifts far out simply free-streams into the vacuum (the ultimate absorber) — nothing bounces off an invisible sphere. Nothing is placed: a free proton and electron drift together and **recombine into a hydrogen atom** (emitting a photon), two hydrogen atoms **bond into an H₂ molecule** (a covalent shared closure — the bond line), and a matter atom meeting **antihydrogen H̄ annihilates**. Atoms are the real QLF observables (free leptons are not stable closures; [`Bound_States_QLF.md`](Bound_States_QLF.md)) — rendered as a proton nucleus with an electron on a tilted orbital shell. So **hydrogen assembles itself from the vacuum**: a pair-produced proton and electron drift together and close, no hand placing them.

**What holds matter apart is Pauli exclusion, not a fudge.** Attraction alone would collapse everything into the wells. Matter keeps its size because **identical fermions cannot occupy the same state** ([`QLF_PauliExclusion`](lean/QLF_PauliExclusion.lean)): same-kind fermions repel at short range, and that degeneracy pressure balances the latency infall — the outward half of every stable structure. It is why a **crystal** holds: seed a lattice of atoms and Pauli pressure vs the wells settles it into a self-bound solid (a *macroscopic resonant lattice*, [`Geometry_Of_Space.md`](Geometry_Of_Space.md)), breathing at finite temperature rather than freezing dead — no pinning, no external force. (A proton repels a proton, but *not* an antiproton, which it annihilates with — exclusion is between identical fermions, not particle and antiparticle.)

**QuCalc — read the live display, or write your own configuration.** The scene is not just watched; it is *editable as QuCalc*. **Capture** serialises the live display to text — one ZFA closure per line (`kind twist @ x,y,z`), with the verified folds (electron `^<v>`, positron `<^>v` = its adjoint, [`QLF_PhaseInformation`](lean/QLF_PhaseInformation.lean)). Type or paste closures and **Replace** (clears first) or **Inject** (adds) to instantiate them through the same engine, so the live dynamics keep running. **Macros** expand named composites: `positronium`, `muonium`, light nuclei (`deuteron`, `helium3`, `alpha`), and hadrons shown as their **confined quark content** (`proton_uud`, `pion+`) — a **free quark is rejected**, since a colour-singlet obstruction forbids it from closing ([`QLF_Confinement`](lean/QLF_Confinement.lean)). And **crystals**: `lattice sc|bcc|fcc n spacing motif @ x,y,z` seeds a lattice that Pauli pressure then holds together. New closures never stack — Pauli exclusion places each in the nearest free spot.

**Click to identify; the field readout.** Pause the action and click anything — it names itself *by frequency* (`m = 1/R`): a particle by its rest-mass frequency and **spin** (↑↓←→, the twist itself, [`QLF_Spin`](lean/QLF_Spin.lean)); an atom by its constituents; a field node by *its own* spin (read from the census walk that placed it); a photon by its frequency; a black hole by its mass, charge `Q` and spin `J`; a hadron *as a quantum black hole*; a virtual flicker *as a vacuum fluctuation*. The collapsible **field readout** counts atoms, molecules, particles and black holes (hover any count for a per-type breakdown), and gives the **total energy** as `E = m = 1/R = frequency`. Hover it for both books: the **gross** content/activity (matter + vacuum foam + radiation), and the **net free energy** — matter(+) minus antimatter(−) — which for a balanced vacuum is **0 = Zero Free Action**, the framework's founding principle shown directly on the telemetry. The telemetry also tracks **matter vs antimatter**: because every vacuum process makes balanced pairs and every decay conserves, the balance `M − M̄` holds at **0** — a genuine matter excess would require the Sakharov conditions ([`QLF_Baryogenesis`](lean/QLF_Baryogenesis.lean)), which this vacuum does not provide.

**No probability — the closure census *draws the space*.** The constructor uses **no randomness**. Genesis ([`Genesis.md`](Genesis.md), [`genesis.py`](genesis.py)) starts from the *first distinction* (`+g/−g`) and builds the exact closure census; a ZFA-balanced ±1 history is a **closed walk** ([`QLF_CensusBrownian`](lean/QLF_CensusBrownian.lean)), and three of them — one per spatial axis, `#^=#v ∧ #<=#> ∧ #/=#\` — interleave into a **3-axis closure** (Genesis's three spatial pairs, the `−3/2` census exponent). **Each node is placed by such a closure's own walk** — its maximal excursion in 3-space — so the field is literally *drawn out by the closures*, realizing Genesis's thesis that *each closure renders its own continuum: the continuum one closure at a time*. (Scalar needs — orbit planes, phases, emission directions — read the same closures as base-2 fractions.) Probability is not a primitive (Born statistics are integer count ratios, [`QLF_BornProbability`](lean/QLF_BornProbability.lean); even decay is deterministic ensemble logic, [`Decay.md`](Decay.md) §1a), and the same census that yields `π` (`QLF_PhysicalPi`) here yields the geometry.

**Honest scope.** The constructor is a *qualitative* visualization: a latency field (`f ∝ w_ZFA`) with illustrative particle dynamics, not the ZFA engine of [`twist_core.py`](twist_core.py) or a solved metric. Lifetimes encode ordering (muon short, neutron longer, proton/electron stable), not literal ratios — real μ (2.2 µs) and free n (~880 s) differ by 10⁸, impossible to show on one timescale. It is the companion picture to the numerical engine in [`MultiParticle.py`](MultiParticle.py) / [`MultiParticle.md`](MultiParticle.md), where the same shared-closure entanglement is computed rather than drawn.

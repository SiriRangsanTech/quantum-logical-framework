# Electron in the Quantum Logical Framework (QLF)

**Repository:** [`quantum-logical-framework`](https://github.com/jimscarver/quantum-logical-framework)
**Document:** `Electron.md`
**Document version:** 3.0 — the core claim sharpened and machine-verified ([`lean/QLF_ElectronClosure.lean`](lean/QLF_ElectronClosure.lean), zero axioms): the electron is a **closed periodic mode**, not an unfinished fragment; **charge is the residue of non-closure**, and it is blind to spin and energy. Resolves the standing inconsistency between "open Hermitian deficit" and the engine's own `ZFA closed: True`. Earlier: 2.1 — run-commands regenerated against the current `particles.py`; ½-spin-information and two-axis-content findings. Aligned with [`Bound_States_QLF.md`](Bound_States_QLF.md)
**Author:** Jim/Grok (synthesized from QLF core axioms, QuCalc engine, `particles.py` v2.2, gauge-folding rule, and the bound-state framing)

## Abstract

> **An electron is a closed half-spin periodic mode, not a point carrying a localized charge.** Its internal cycle `^<v>` *is* Zero-Free-Action closed and folds to `−I`. What is **not** closed is its **gauge** twist — and that unmatched gauge count *is* the charge. So the electron is closed on the spatial axes and open on the gauge axis, and the two are different axes of the same alphabet. A **manifest physical event** — preparation, binding, detection — is the larger joint closure in which the gauge deficit is matched. The electron's intrinsic scale is therefore the **period of its closed mode**, never a radius.

In QLF **the electron is not an independent stable observable**, but not because it is an unfinished fragment. It is a completed half-spin cycle carrying one unmatched gauge distinction, which is why it must join a Hermitian-conjugate partner (positron → positronium), a heavier lepton (antimuon → muonium), or a baryon (proton → hydrogen) before the *whole* event closes. The "electron's mass" reported by experiment, `m_e ≈ 0.511 MeV`, is the electron's **gauge-fold-depth contribution** to the bound-state mass — half of `m(positronium)`, the analogous contribution to `m(hydrogen)`, and so on.

*(This supersedes the "free electron is an open Hermitian deficit" reading of version 2.1, which contradicted the engine's own `ZFA closed: True` for `^<v>`. Both statements were right about different levels; §1 separates them.)*

This is the same structural move that [`Delayed_Choice_Eraser.md`](Delayed_Choice_Eraser.md) makes for photons (joint emitter-absorber closure, not free projectile) and that [`Hadrons_Markov_Blankets.md`](Hadrons_Markov_Blankets.md) makes for quarks (no asymptotic free quarks, only bound hadrons). Applied to electrons: an electron is one half of a joint closure, not an isolated particle whose mass can be extracted in isolation. The QLF observables are atomic systems; the "electron" is the gauge-fold contribution of one constituent.

The remainder of this document is a hands-on tutorial. We give the electron's QuCalc topology (the half it contributes to a joint closure), the photon and antiphoton (which jointly satisfy ZFA), and the electron–proton hydrogen formation (a joint-ZFA bound state). Everything runs live in `particles.py` — and every bound state runs *visually* in the [**Spectral Spacetime Constructor**](https://jimscarver.github.io/quantum-logical-framework/spacetime_constructor.html) (the `▶ live` links in the table below open positronium, hydrogen, and muonium; [`Spacetime_Constructor.md`](Spacetime_Constructor.md)).

## Why the Electron Matters

Most everything we experience is due to electrons participating in joint closures — chemistry, light emission, electric currents, biological membranes. The "electron" of standard physics is shorthand for "the leptonic half of a joint-ZFA closure event." Understanding the electron in QLF means understanding which joint closures it can participate in and how its gauge-fold depth contributes to the bound-state mass and binding.

In QLF the electron is not an abstract point particle with mysterious properties. It is a **gauge-folded topological half-loop** — a partial twist sequence containing at least one `+` or `-` fold along the LOCAL gauge axis. By itself the half-loop has not closed; it carries an open Hermitian deficit. When it intersects a Hermitian-conjugate partner's causal frontier, the joint ZFA closure completes, and the gauge-fold depth of the electron's half contributes its share of the bound system's constructing delay and rest energy.

Its **spin is not mysterious either** — it is literally the twists. The electron loop `^<v>` folds to `−I` (a half-spin fermion needing 720° to return, the SU(2)→SO(3) double cover), and the electron is **Dirac** (not its own antiparticle), all machine-verified in [`Spin_QLF.md`](Spin_QLF.md) / [`lean/QLF_Spin.lean`](lean/QLF_Spin.lean) (`fold_electron`, `rotation_360_eq_negI`, `electron_not_majorana`). Charge conjugation = view-from-behind: the positron is the electron's loop read in reverse. Two further facts sharpen this. First, **the electron loop is one bit of information**: the two-valued ½-spin closure carries exactly `log 2` (`spin_half_is_information_atom`, [`lean/QLF_SpinorInformation.lean`](lean/QLF_SpinorInformation.lean)) — Wheeler's *it from bit* at the electron ([`Information_Physics.md`](Information_Physics.md)). Second, **the loop engages two of the three spatial axes** — `^<v>` folds as `σ_y·(−σ_x)·(−σ_y)·σ_x = −I`, i.e. the x (`<>`) and y (`^v`) axes, not z (`interleaved_xlvr_folds_to_negI`, [`lean/QLF_TwistAlphabet.lean`](lean/QLF_TwistAlphabet.lean)); this `{x,y}` content is the verified anchor for what distinguishes the muon and tau (colour *content* vs colour *charge*, [`Particle_Ladder.md`](Particle_Ladder.md) § *Colour content vs colour charge*).

**Lepton flavors.** The electron is the first of the **three lepton flavors** — *e, μ, τ* — the same chiral closure at successive generations, which QLF ties to the three spatial axes (`num_generations_eq_three`, [`QLF_Generations`](lean/QLF_Generations.lean)). A bound state carries whichever flavor its leptonic half is: an electron in positronium/hydrogen, a **muon** in muonium (a deeper-blanket gauge half), a **tau** in the heaviest systems. So "the electron" of this document is *flavor-1*; the μ and τ are its deeper / other-axis versions, and the flavor→mass map (`m_e : m_μ : m_τ`) is the open target ([`Standard_Model.md`](Standard_Model.md) §3.3, [`Weak_Force.md`](Weak_Force.md) §5, [`Bound_States_QLF.md`](Bound_States_QLF.md)).

## 1. The Electron's Two Closures

**The single most important structural fact about the electron is that it closes on one set of axes and not on the other.** Version 2.1 of this document said the free electron was "an open Hermitian deficit" while printing `ZFA closed: True` beside it. Both were right, about different things, and separating them is what the rest of this document rests on.

| Level | Object | Status |
|---|---|---|
| **Internal cycle** (spatial axes) | `^<v>` — the half-spin mode | **Closed.** `#^ = #v`, `#< = #>`, free action `F = 0`, fold `−I` |
| **Charge** (gauge axis) | one unmatched `+` | **Open.** This deficit *is* the electric charge |
| **Manifest event** | the joint closure with a partner | **Closed.** Gauge matched, total neutral |

Machine-verified, zero axioms, in [`lean/QLF_ElectronClosure.lean`](lean/QLF_ElectronClosure.lean):

- `electronCycle_countBalanced` — `^<v>` achieves ZFA;
- `electronCycle_folds_negI` — and folds to `−I`, the half-spin fermion sign (reusing `interleaved_xlvr_folds_to_negI`);
- `electronCharged_charge` — `^<v>+` carries `chiralCharge = 1`;
- `electronCharged_not_countBalanced` — …and is therefore *not* closed. **The charge is exactly the part that did not close.**
- `positronium_countBalanced` / `positronium_neutral` — the joint event closes, and is neutral.

So the electron is not an unfinished particle fragment. It is a **completed periodic mode carrying one open gauge distinction**, and that distinction is what makes it seek a partner.

$$
\boxed{\text{electron} = \text{closed periodic mode} + \text{one unmatched gauge twist}}
$$

Minimal electron topology (spatial cycle + gauge):

`^<v>` + `+` → written `^<v>^+` in the engine's fuller form

- `^` = forward-time seed
- `<` `>` = spatial folds (transverse area) — the **closed** part
- `+` = gauge fold → the **open** part: the charge, and the gauge-fold-depth contribution to bound-state mass

The gauge deficit accumulates a **constructing delay** $\Delta t = R/f$ (topological depth $R$ at vacuum frequency $f$) only when it is matched by a partner. In a positronium binding it joins the positron's mirror gauge twist and the joint closure creates a finite local time at depth $2R$, with rest energy `m(Ps) ≈ 1.022 MeV`. Half of this — `0.511 MeV` — is what conventional physics attributes to the "free electron mass."

### 1a. Hermitian is not the same as ZFA-closed

This deserves its own statement because the two are routinely conflated, and conflating them is what produced the version-2.1 contradiction.

The prefix `^<v` folds to `σ_y·(−σ_x)·(−σ_y) = −σ_x`, which is **Hermitian**. Its history nevertheless has free action `F = 1` — the `<` is unmatched. Adding `>` gives `^<v>`, with `F = 0` and fold `−I`.

$$
\boxed{\text{Hermitian} \;\not\Rightarrow\; \text{ZFA closed}}
$$

Verified as `hermitian_not_implies_zfa` (`electronPrefix_fold`, `neg_sigmax_hermitian`, `electronPrefix_not_countBalanced`). Self-adjointness is a property of the **operator**; closure is a property of the **history**. An intermediate prefix can be a perfectly good mathematical state and still not be a manifest electron event — which is the precise content of *"the electron is manifest only at full cycles."*

### 1b. Charge is emergent — it is the residue of non-closure

`twistCharge` assigns `+1` to `+`, `−1` to `−`, and **zero to all six spatial twists**. Charge is therefore the signed gauge count and nothing else (`chiralCharge_eq_gauge_counts`). The consequence is immediate and sharp:

$$
\boxed{\text{ZFA-closed} \;\Longrightarrow\; \text{electrically neutral}} \qquad \texttt{zfa\_closure\_is\_neutral}
$$

**Charge is not a fundamental property carried by an object.** It is a *count of what has not yet closed*. There is no charge field, no charged point, no charge substance: a history that closes has charge zero, necessarily, and a history that carries charge is by that fact incomplete. This is why charge is conserved (counts of conjugate twists cannot be created singly), why it is quantized (it is an integer count), and why an electron cannot be isolated as a completed event.

### 1c. There is no charge *between* electrons of different energy or spin

This is the sharpest consequence, and it is a theorem rather than a stance.

Spin and energy are **spatial** content — the axis word and its depth. Charge lives on the **gauge** axis. Since `twistCharge` vanishes on every spatial twist, no amount of spatial content changes the charge:

$$
\boxed{\Gamma_{\text{charge}}\big[(m,s),(n,s')\big] \;\text{is independent of } m, n, s, s'}
$$

- `twistCharge_eq_zero_of_spatial` — every spatial twist is charge-neutral;
- `chiralCharge_determined_by_gauge` — charge is a function of the gauge counts alone;
- **`no_charge_between_spatial_modes`** — two electron modes carrying the same gauge deficit and *any* spatial content whatever (different harmonics, opposite spins) have **exactly zero** charge difference.

**The electromagnetic weight cannot see a spin or an energy.** There is no charge between two electrons of different energy, and none between opposite spins — the differential is identically zero, by construction of the alphabet, not by cancellation.

Two independent confirmations of the same structure, in the coherent channel rather than the charge count:

- **Distinct full-cycle harmonics have zero coherent overlap** — `cycleOverlap_distinct` / `harmonics_orthogonal`: a root of unity other than `1` sums to zero over a full period, because the cycle closes. This is *why* a quantity is invariant only at a completed cycle: over anything less, the cross terms survive.
- **The two spin channels are orthogonal projectors** — `spin_projectors_orthogonal` (`P↑P↓ = 0`, with `projUp_eq_half`/`projDown_eq_half` identifying them as the spectral projectors of `σ_z`).

Together: `channelKernel_diagonal` gives `Γ[(m,s),(n,s')] = δ_mn δ_ss'`. **Different harmonics or orthogonal spin channels carry no persistent coherent cross term.**

> **Scope, stated once and precisely.** What is proven is that the charge *difference* between modes is exactly zero and the coherent cross term vanishes — so no Coulomb channel is opened or closed by a difference of spin or energy, and the electromagnetic coupling is **spin-blind and energy-blind**. What is *not* claimed is that the shared gauge deficit disappears: both electrons carry the same unmatched `+`, that common residue is the ordinary charge, and it is exactly why an electron must still find a partner. Two electrons of different energies therefore still enter a joint event (§1e) — QLF's content is that nothing in that event depends on their spins or energies *through the charge*.
>
> **This is a prediction, not a retreat.** Standard QED agrees and QLF *derives* it: the direct Coulomb term is exactly spin-independent, and all spin dependence of two-electron energies (the singlet–triplet splitting) comes from exchange — which is closure blocking, not charge. QLF says that had to be so, because charge and spin do not live on the same axes.

### 1d. Manifest only at full cycles

Putting §1a and §1c together gives the manifestation rule:

> **A quantity becomes physically invariant only at a completed closure.**

Below a full cycle the cross terms between harmonics do not vanish, the free action is non-zero, and there is no invariant to read. At the completed cycle `F = 0`, the fold is a Pauli scalar (`count_balanced_pauli_closed`), the harmonic cross terms vanish exactly, and the mode has a definite phase. Manifestation is not an observer acting; it is a cycle closing.

### 1e. Different energies and spins *do* enter one event

The reading to avoid is that non-matching modes cannot interact. They can — what cannot happen is a completed event with unmatched conserved distinctions. Verified directly as **`joint_closure_allows_unequal_components`**: two open halves, neither balanced, **of different lengths**, whose joint history closes.

$$
\boxed{\text{individual modes need not match; the complete event must close}}
$$

For two electrons, the joint closure condition is the ordinary one —

$$
E_1 + E_2 = E_3 + E_4, \qquad \mathbf{p}_1 + \mathbf{p}_2 = \mathbf{p}_3 + \mathbf{p}_4, \qquad Q_{\rm in} = Q_{\rm out}
$$

— with `E₁ ≠ E₂` allowed, opposite spins allowed, and the interaction operator Hermitian throughout. Ordinary electron–electron scattering is therefore **not** a counterexample to ZFA; it is an instance of it. The QLF statement with teeth is the negative one:

> Every physically completed electron–electron process admits a globally closed representation. Candidate histories with unmatched residual action do not occur as completed events.

### 1f. The electron has no radius — its scale is its wavelength

QLF assigns the electron **no hard intrinsic radius**, and the honest form of that claim is an *absence*: no length parameter occurs anywhere in the closure predicate. `countBalanced` and the fold are functions of the word alone. There is nothing in the theory for a radius to be.

What the closure *does* fix is a **period**. From `E = hν`:

$$
T = \frac{h}{E}, \qquad\text{at rest}\quad E = m_ec^2 \;\Rightarrow\; T_C = \frac{h}{m_ec^2}, \qquad
\boxed{\lambda_C = c\,T_C = \frac{h}{m_ec}}
$$

verified as `rest_period_times_c`. And the **full cycle is `2π` radians**, which is why the Compton wavelength rather than the reduced one is the manifest scale:

$$
\lambda_C = 2\pi\,\bar\lambda_C, \qquad \bar\lambda_C = \frac{\hbar}{m_ec} \;\;(\text{one radian})
$$

verified as `compton_full_cycle`. Four distinct scales, kept distinct:

| Scale | What it is |
|---|---|
| **Compton** `λ_C = h/m_ec` | the rest/internal closure scale — one full cycle |
| **reduced Compton** `ƛ_C = ħ/m_ec` | one radian of that cycle, not a manifest length |
| **de Broglie** `λ_dB = h/p` | the translational spatial phase scale (`closureWavelength`) |
| **localization width** | a context-dependent wavepacket property, not intrinsic |
| ~~radius~~ | **no such quantity** — nothing in the closure predicate carries a length |

### 1g. Claim and evidence

Statuses on the two axes of [`ScientificApproach.md`](ScientificApproach.md) §3 — mathematical (what is established about the formal object) and physical (what is established about the world).

| Claim | Mathematical | Physical | Anchor |
|---|---|---|---|
| The electron's internal cycle is ZFA-closed and folds to `−I` | **Proved** | **Internal** | `electronCycle_countBalanced`, `electronCycle_folds_negI` |
| Hermitian ⇏ ZFA-closed | **Proved** | **Internal** | `hermitian_not_implies_zfa` |
| Charge = unmatched gauge count; closed ⟹ neutral | **Proved** | **Consistency** — reproduces conservation and quantization of charge | `chiralCharge_eq_gauge_counts`, `zfa_closure_is_neutral` |
| **No charge difference between modes of different energy or spin** | **Proved** | **Consistency** — the direct Coulomb term *is* spin-independent in QED; here it is derived rather than computed | `no_charge_between_spatial_modes`, `chiralCharge_determined_by_gauge` |
| Distinct harmonics / opposite spins carry no coherent cross term | **Proved** | **Internal** | `channelKernel_diagonal`, `harmonics_orthogonal`, `spin_projectors_orthogonal` |
| Unequal components can enter one closed event | **Proved** | **Consistency** — Møller scattering at unequal energies | `joint_closure_allows_unequal_components` |
| `λ_C = c·T_C = h/m_ec`; full cycle is `2π` | **Proved** | **Consistency** — standard kinematics, no new content claimed | `rest_period_times_c`, `compton_full_cycle` |
| The electron has no hard radius | **Absence, not a theorem** | **Open** — a null that experiment can only bound | no length parameter in the closure predicate |
| `m_e = 0.511 MeV` as gauge-fold-depth share | **Not derived** | **Open bridge** — the flavor→mass map | [`Bound_States_QLF.md`](Bound_States_QLF.md) |

### Bound systems the electron half-loop completes

| Joint closure | Partner | Bound-state mass | Joint topology (schematic) |
|---|---|---|---|
| **Positronium** ([▶ live](https://jimscarver.github.io/quantum-logical-framework/spacetime_constructor.html#qc=positronium%20%40%200%2C0%2C0)) | Positron `v>v-` | 1.022 MeV | `^<v>^+ · v<v>v-` (electron half + positron half) |
| **Hydrogen** ([▶ live](https://jimscarver.github.io/quantum-logical-framework/spacetime_constructor.html#qc=H%20%40%200%2C0%2C0)) | Proton (three-quark composite) | 938.78 MeV | electron half + proton internal closure |
| **Muonium** ([▶ live](https://jimscarver.github.io/quantum-logical-framework/spacetime_constructor.html#qc=muonium%20%40%200%2C0%2C0)) | Antimuon (deeper-blanket gauge half) | 106.17 MeV | electron half + antimuon half (asymmetric blanket depths) |

In each case the "electron" of this document contributes the same gauge-fold-depth `R_e` to the joint closure. The bound-state mass is `R_e + R_partner` (modulo joint-closure binding corrections), not `R_e` alone. See [`Bound_States_QLF.md`](Bound_States_QLF.md) for the spectrum.

### Run the electron half-loop yourself

```bash
python particles.py --particle electron
```

**Sample output (electron half-loop, awaiting joint closure):**
```text
=== ELECTRON ===
open prefix         : ^<v>
constituents        : one fluxoid (^<v>)
engine closure      : ^<v>
final history       : ^<v>
fold depth (pairs)  : 2
ZFA closed          : True
hermitian conjugate : <^>v
```

Note `ZFA closed: True` — and it is not a bug. The engine is reporting the **internal cycle** `^<v>`, which genuinely closes (§1). The open part is the *gauge* twist, which this history does not contain; add it (`^<v>+`) and the same engine reports the deficit. The electron becomes a manifest physical event when a partner matches that gauge twist.

## 2. Photon Folds Forward in Time — Antiphoton Satisfies ZFA

A photon is a **massless joint closure** that requires no gauge fold. It is a pure forward-time spatial closure between an emitter and an absorber — see [`Delayed_Choice_Eraser.md`](Delayed_Choice_Eraser.md) and [`Collective_Electrodynamics.md`](Collective_Electrodynamics.md).

The two halves of the joint photon closure:

- Photon half (forward-time): `^>`
- Antiphoton half (conjugate, backward-time): `v<`

When they meet they form the joint closure with exactly Zero Free Action:

`^>` ∘ `v<`  ⟹  net action = 0  (the joint photon closure)

This is the **same structural move** as for the electron — both photons and electrons are halves of joint closures. The difference: the photon's halves have no gauge fold, so the joint closure has zero constructing delay and the photon is massless; the electron's halves have a gauge fold, so the joint closure has finite delay and finite rest energy.

### Run the photon–antiphoton pair

```bash
# The photon's gauge loop (the engine's minimal massless closure)
python particles.py --particle photon
```

**Sample photon output:**
```text
=== PHOTON ===
open prefix         : +-
constituents        : one gauge loop (+-)
engine closure      : +-
final history       : +-
fold depth (pairs)  : 1
ZFA closed          : True
hermitian conjugate : +-
```

The two halves together close with zero free action — this is the QLF reading of every "photon" we ever detect: a joint emitter-absorber event, not a free projectile.

## 3. Electron–Proton Joint Closure (Hydrogen)

The proton is a composite Markov blanket with three-quark internal closures and gauge folds ([`Hadrons_Markov_Blankets.md`](Hadrons_Markov_Blankets.md), [`HadronicDepth.md`](HadronicDepth.md)). The electron half-loop joins the proton in a joint-ZFA bound state — **hydrogen**.

Hydrogen is the natural QLF observable: a charge-balanced, ZFA-closed joint event with mass `m(H) ≈ 938.78 MeV` and binding `E_bind ≈ 13.6 eV`. The electron's gauge-fold-depth contribution to the bound state is `m_e ≈ 0.511 MeV`; the proton contributes the rest. The binding energy is the residual joint-closure correction after the constituent rest energies.

Electron–proton **scattering** (rather than binding) is a transient joint closure that does not stabilise. Excess distinctions are emitted as photon joint closures (per §2). Hydrogen formation is the stable case. Note that the scattering partners need not match in energy or depth — §1e proves unequal components can enter one closed event — and that nothing in the closure depends on their spins or energies *through the charge* (§1c).

### Run the hydrogen joint closure

```bash
python particles.py --particle atom
```

**Sample interaction output:**
```text
=== ATOM ===   (hydrogen — electron ++ proton)
open prefix         : ^<v>^>v</\+-
constituents        : electron ++ proton (+ diagonal + gauge axes)
engine closure      : ^<v>^>v</\+-
final history       : ^<v>^>v</\+-
fold depth (pairs)  : 6
ZFA closed          : True
```

The output describes the **joint** closure, not the electron alone. The "electron's mass" of `m_e ≈ 0.511 MeV` is its share of the constructing delay distributed across the bound system.

## 4. Quick Reference Commands

| Demonstration | Command | What you see |
|---|---|---|
| Electron half-loop (gauge-folded, awaiting joint closure) | `python particles.py --particle electron` | Gauge fold → contribution to bound-state mass and local time |
| Photon half (massless) | `python particles.py --particle photon` | Pure forward-time spatial half-closure |
| Photon gauge loop (massless) | `python particles.py --particle photon` | Net action = 0 (joint event) |
| Hydrogen joint closure (e⁻ + p) | `python particles.py --particle atom` | Gauge handshake + photon emission; joint hydrogen bound state |

## 5. Links to More Advanced Reading

- [`lean/QLF_ElectronClosure.lean`](lean/QLF_ElectronClosure.lean) — **the machine-verified core of §1**: the two closures, Hermitian ⇏ ZFA, charge as the gauge residue, no charge between spatial modes, harmonic and spin orthogonality, the closure period. Zero axioms.
- [`lean/QLF_Spin.lean`](lean/QLF_Spin.lean) — `fold_electron`, `chiralCharge`, `chiralCharge_conj` (charge conjugation = view from behind), `electron_not_majorana`.
- [`Bound_States_QLF.md`](Bound_States_QLF.md) — **the framing of this doc**: free leptons are not QLF observables; atomic systems are. Positronium, muonium, hydrogen as the natural mass observables. Reduced-mass Bohr binding structure.
- [`Delayed_Choice_Eraser.md`](Delayed_Choice_Eraser.md) — the same joint-closure framing applied to photons; the canonical "retrocausality" experiment dissolves once the photon is a Hermitian-pair handshake with no free-projectile interpretation.
- [`Collective_Electrodynamics.md`](Collective_Electrodynamics.md) — joint ZFA closures as the unit of EM interaction; vector potential as unresolved free action.
- [`HALF-SPIN-ZFA-EMBEDDING.md`](HALF-SPIN-ZFA-EMBEDDING.md) — the half-spin ZFA atom (Hermitian pair) as the minimal joint closure; the QLF unit of physical existence.
- [`Particles.md`](Particles.md) — full particle zoo and gauge-folding rule.
- [`Standard_Model.md`](Standard_Model.md) §3.3 — the three **lepton flavors** (e, μ, τ) as the three generations; colour *content* vs *charge*.
- [`Particle_Ladder.md`](Particle_Ladder.md) — where the electron sits on the vacuum↔atoms↔black-holes ladder; the flavor / colour-content question.
- [`Information_Physics.md`](Information_Physics.md) — the electron loop as one bit (½-spin = the atom of information, *it from bit*).
- [`Hadrons_Markov_Blankets.md`](Hadrons_Markov_Blankets.md) — proton as composite Markov blanket; bound-state framing at the hadronic scale.
- [`Frequency_Synchronization.md`](Frequency_Synchronization.md) — constructing delay $\Delta t = R/f$.
- [`Hydrogen.md`](Hydrogen.md) — existing Bohr derivation of hydrogen levels in QLF language.
- [`Annihilation.md`](Annihilation.md) — the photon `^>` + antiphoton `v<` joint closure; electron–positron annihilation as a positronium-class joint event.
- [`Higgs.md`](Higgs.md) — gauge-fold-depth as the QLF mechanism for the gauge-fold contribution to bound-state mass.
- [`Entropy.md`](Entropy.md) — entropy conservation in joint closures.

## Conclusion

In QLF the electron is **not a free particle with mass `m_e ≈ 0.511 MeV`**, and it is **not an unfinished fragment either**. It is a **closed half-spin periodic mode carrying one unmatched gauge twist** — and that twist is its charge. It binds with a positron to form positronium, with an antimuon to form muonium, or with a proton to form hydrogen, because a manifest event is the larger closure in which the gauge deficit is matched. The "electron mass" of conventional physics is the gauge-fold-depth contribution to that joint closure, half of `m(positronium)` and the analogous contribution to `m(hydrogen)`.

Three things follow, each machine-verified:

$$
\boxed{\text{electron} = \text{closed periodic mode}}, \qquad
\boxed{\text{charge} = \text{residue of non-closure}}, \qquad
\boxed{\text{scale} = \text{closure wavelength},\; \text{not a radius}}
$$

And the sharp one: **charge is blind to spin and energy**, because charge lives on the gauge axis and spin and energy live on the spatial axes. There is no charge *between* two electrons of different energy or different spin — the difference is exactly zero (`no_charge_between_spatial_modes`), and the coherent cross term between distinct harmonics or opposite spin channels is exactly zero as well (`channelKernel_diagonal`). What remains is the common gauge deficit both carry, which is the ordinary charge and the reason an electron seeks a partner at all.

Photons are the same structural class: joint emitter-absorber closures, not free projectiles. The difference is the gauge fold — present in the electron half-loop, absent in the photon half-loop. Hence electrons contribute mass to their joint closures and photons do not.

Most everything we experience is the chemistry, light, and electric current of these joint closures. Understanding the electron in QLF means understanding which joint closures it can participate in — and the QLF observables are those joint closures, not the constituent halves.

**Don't shut up and calculate. Run it.**

Clone the repo, run the commands above, and watch the joint closures emerge from the same QuCalc engine.

See also: [`Bound_States_QLF.md`](Bound_States_QLF.md) — the framing of this doc, made explicit and scoped across positronium, muonium, hydrogen, and the τ-decay-vertex closure.

*Aligned with `Bound_States_QLF.md` — free leptons are not QLF observables; atomic systems are.*

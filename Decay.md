# Decay in QLF — from one closure to a supernova

*How decay works in the [Quantum Logical Framework](README.md) (QLF): a stable structure is a balanced
ZFA closure; turbulence rains **prime phase‑slips** on it; when their statistics lock to the structure's
internal clock the slips drive its twist counts **out of balance**, the closure loses its receipt, and it
decays — releasing the `log 2` free‑action quantum. Scale that up and a whole ensemble unlocks together:
a **prime‑synchronized cascade dump**. This doc builds that mechanism from a single closure up through
the neutrino → muon → neutron chain to the collective core‑collapse release.*

The Lean skeleton is [`QLF_PrimeCascadeDecay`](lean/QLF_PrimeCascadeDecay.lean) (reuse‑only, no new
axioms); the dynamics are the numerical model [`prime_cascade_decay.py`](prime_cascade_decay.py). See
[`Turbulence.md`](Turbulence.md) for the cascade it rides on.

---

## 1. The one mechanism — a phase slip out of balance ends a closure

Everything below is a single idea applied four times. A **stable structure** — muonium, a hadron, a
bound neutron — is a *persistent ZFA closure*: a count‑**balanced**, symmetric twist history that keeps
its receipt (`achieves_ZFA`). Quantum turbulence presents *all* admissible closures at once
([`QLF_QuantumTurbulence`](lean/QLF_QuantumTurbulence.lean)); the **irreducible (prime)** ones carry an
open forward strand with the geometric phase `±i` (`π/2`) — the **phase‑slip agents**.

- **The agent is an irreducible `±i` kick.** `prime_slip_is_quarter_turn` (`i, i², i³ ≠ 1` — a primitive
  quarter‑turn) and `prime_slip_irreducible` (a prime‑period slip has only divisors `1` and itself, so
  the bath cannot factor it into a repeat of a shorter, cancelling closure). At *commensurability* the
  kicks add **coherently** instead of averaging to zero.
- **The decay condition.** A slip that drives the counts out of balance makes the history a
  *contradiction* (`IsContradiction = ¬ is_symmetric`), and **a contradiction receives no ZFA receipt**:
  `slip_out_of_balance_ends_closure` (= `contradiction_no_receipt`). The structure is no longer a
  closure, so it is no longer a physical persistent event — it must decay. Conversely a persistent
  structure *is* balanced (`stable_structure_is_balanced`), so *any* unbalancing slip ends it.
- **The release.** Each unlocked closure dumps the free‑action quantum `ΔF = log 2`
  (`unlock_releases_log_two`, [`QLF_FreeEnergy`](lean/QLF_FreeEnergy.lean)); an ensemble of `n` releases
  `n · log 2 > 0` (`collective_dump_positive`).

**The rate.** Turning the structure into a rate is the phenomenological model
([`prime_cascade_decay.py`](prime_cascade_decay.py)). With `ω_b = 1/R` the bound‑state frequency and
`Φ_p(t)` the prime flux at the nearest octave (taken from the *actual* census density
`ρ_p(n) = 2·Catalan(n−1)/C(2n,n)`),

```
Γ(t) = Γ₀ + Γ_p · Φ_p(t) · S(t),      S(t) = 1 / (1 + Q²(ω_b − Φ_p)²)
```

`S` is the **synchronization factor** — a Lorentzian resonance that peaks when the prime flux is
commensurate with the internal clock. Off‑resonance `S → 0` and the vacuum lifetime `1/Γ₀` is recovered;
on‑resonance `S → 1` and the rate jumps. The demo measures the jump: the half‑life collapses from
`τ₁/₂ ≈ 0.58` (off) to `≈ 0.05` (on‑resonance) — a ~40× acceleration purely from the turbulent prime
flux. **Honest scope:** the *structure* (agent, decay condition, quantum) is Lean‑anchored; the couplings
`Γ_p, Q` — the map from ZFA combinatorics to the coupling *strength* — are **not** derived, the same open
piece as the four‑fermion binding strength (`higgs_turbulence_in_progress`).

### 1a. Decay is deterministic, not random — a QLF finding

The standard picture treats an individual decay as **fundamentally random**: a nucleus or particle has a
probability per unit time to decay, and *which* instant it decays is irreducibly indeterminate
(Copenhagen). **QLF says the opposite: each individual decay is a *determined* event.** A structure decays
at the precise moment its internal clock reaches the coherent‑lock condition with the surrounding prime
cascade — a definite ZFA event (`slip_out_of_balance_ends_closure` is an *implication*, not a dice roll;
the underlying `full_zeno_prune` filter is deterministic). Given the full phase of the turbulent prime
flux, the decay time is **fixed**.

The apparent randomness is *epistemic*, not *ontic*: we do not — and in a finite‑information region
*cannot* — track the phase of every prime closure in the cascade, so we observe only the **ensemble
statistics** of an incoherent bath. Poisson‑distributed (uncorrelated) prime‑slip arrivals give a constant
hazard rate `Γ₀`, and a constant hazard rate is *exactly* the exponential decay law `N(t)=N₀e^{−Γ₀t}` — so
the textbook "random" exponential is the **statistics of a deterministic substrate**, not fundamental
indeterminism. The Born‑rule side of this is already anchored: QLF probabilities are **count‑ratios** over
a deterministic closure ensemble (`QLF_BornProbability`, [`The_QLF_State_Space.md`](The_QLF_State_Space.md)),
not primitive reals.

This is **not** a Bell‑excluded local hidden variable. The determinism is the *global, relational* ZFA
substrate — the deterministic cascade phase is non‑local and perspectival (each observer's finite
information defines its own consistent relative world, `QLF_HorizonClosure`), consistent with Bell/KS/PBR
(which exclude *added* local, non‑contextual, ψ‑epistemic ingredients, not an exact deterministic
reconstruction). So QLF joins the deterministic‑substrate lineage while keeping quantum statistics exactly:
decay *looks* random because the prime bath is incoherent, but every unlocking is a determined event. The
same statement runs through the whole chain below — collective flavor conversion, muon unlocking, and the
supernova dump are **synchronized deterministic** events, which is precisely why they can spike coherently
rather than smearing into a random average.

---

## 2. The chain, stage by stage

Each stage is a ZFA object whose balance the same prime‑slip mechanism can break. Deeper into a stellar
core the prime flux `Φ_p` and the density rise, so structures that live essentially forever in vacuum are
driven out of balance on a dynamical timescale.

### 2.1 Neutrino flavor — locking the slow phase

The neutrino is **Majorana** in QLF — self‑conjugate, neutral, a pure three‑axis twist structure with no
residual gauge‑fold depth (`neutrino_majorana`, [`QLF_Majorana`](lean/QLF_Majorana.lean),
[`Beta_Decay_Neutrino_Nature.md`](Beta_Decay_Neutrino_Nature.md)). The flavor eigenstates `ν_e, ν_μ, ν_τ`
are different *orientations* of the same closure combinatorics, and PMNS mixing counts those orientations
(`QLF_PMNS`, [`Standard_Model.md`](Standard_Model.md) §4.2). Flavor **oscillation** is already a slow
phase evolution of the closure; a dense rain of prime `±i` kicks can **lock or accelerate** it —
the discrete analogue of supernova *collective flavor conversion* / the collisional flavor instability:

```
dP/dt = ω_vac × P  +  Γ_p Φ_p(t) S(t) · n̂_prime × P
```

with `P` the flavor polarization vector and the second term the prime‑driven kick. **Both terms are cross
products**, so the evolution is a *precession* `dP/dt = Ω × P` (`Ω = ω_vac + Γ_p Φ_p S·n̂_prime`), which
**conserves neutrino number** (`‖P‖²` constant, since `P·(Ω×P)=0`) — now machine‑verified
([`QLF_NeutrinoOscillation`](lean/QLF_NeutrinoOscillation.lean): `flavor_precession_conserves_number`,
`prime_kick_conserves_number`). So the prime bath *converts and accelerates* flavor without creating or
destroying neutrinos. Locked flavor conversion reshapes the local lepton chemistry and heating — the
*seed* of the collective event — while conserving total number ([`Beta_Decay_Neutrino_Nature.md`](Beta_Decay_Neutrino_Nature.md) §3).

### 2.2 Muonium / muon — resonant unlocking of a gauge fold

Muonium (`μ⁺e⁻`) is a hydrogen‑like ZFA bound state — a gauge‑folded closure of moderate depth (the muon
is a deeper fold than the electron; **mass = gauge‑fold depth** `m = 1/R`, so the internal frequency is
`ω_b = 1/R_μ`, `mass_is_gauge_fold_delay`, [`QLF_HiggsMechanism`](lean/QLF_HiggsMechanism.lean); the lepton
ratios of [`Experimental_Consistency.md`](Experimental_Consistency.md) §5.5).

**This is where the mechanism drives a *true* decay — not a rotation.** The sharp contrast with §2.1: the
neutrino's flavor evolution is a norm‑preserving precession (neutrino number conserved,
`flavor_precession_conserves_number`). The muon is different — it is a *gauge‑folded, massive* closure of
finite depth `R_μ`, and when a synchronized prime slip drives its twist counts out of ZFA balance the
closure **ends** — it receives no receipt (`slip_out_of_balance_ends_closure`, [`Decay.md`](Decay.md) §1)
and resolves into decay products (`μ → e ν̄ ν`). So here the prime kick **changes particle number**; the
same turbulent bath that merely *rotates* the neutral neutrino *destroys* the charged muon fold.

The rate is the resonant form ([`QLF_PrimeCascadeDecay`](lean/QLF_PrimeCascadeDecay.lean),
`resonantRate`):

```
Γ_μ(t) = Γ₀^μ + Γ_p · Φ_p(t) · S(ω_b, Φ_p)
```

with two machine‑verified limits:

- **Vacuum limit.** `Φ_p → 0 ⟹ Γ_μ = Γ₀^μ` (`vacuum_limit_constant_hazard`) — away from the turbulent
  bath the ordinary constant‑hazard muon lifetime is recovered, hence the ordinary exponential decay
  `N(t)=N₀e^{−Γ₀t}` (`exponential_decay_from_constant_hazard`, §1a).
- **Enhancement only.** For non‑negative flux the rate is `≥ Γ₀^μ` (`resonant_enhances`): turbulence can
  only *shorten* the lifetime, never lengthen it, jumping when `S → 1` at commensurability.

In a supernova core the high density and the already‑present *muonization* amplify `Φ_p`, so muon‑like
closures are driven out of balance far faster than in vacuum — softening the equation of state and
injecting energy that feeds the next stage. **Honest scope:** exactly as the neutrino mixing *angles* and
absolute `Δm²` are left open, the muon couplings `Γ_p` and the precise form of `S` are named open
parameters (the phenomenological [`prime_cascade_decay.py`](prime_cascade_decay.py), the coupling‑strength
residual `higgs_turbulence_in_progress`); what is *anchored* is the vacuum limit, the enhancement‑only
monotonicity, and the number‑changing decay condition.

### 2.3 Neutron — disrupting the Pauli block

*Bridge from §2.2:* the same resonant form `Γ_n = Γ₀^n + Γ_p Φ_p S_n` (`resonantRate`) carries to the free
neutron — a number‑changing decay like the muon — once its in‑medium stabilization is expressed as a **ZFA
stability condition** (the Pauli block); the sketch below stays at that structural level and is not yet
expanded.

The free neutron is a weakly‑unstable ZFA closure (`n → p e⁻ ν̄_e`). Inside a nucleus or the dense core it
is *stabilized* by additional binding closures — `pn` pairing and **Pauli blocking** of the identical
channel (`diproton_pauli_blocked` / the no‑free‑duplication principle,
[`QLF_NoFreeDuplication`](lean/QLF_NoFreeDuplication.lean); the `p♂n♀` complementarity of
[`Fusion.md`](Fusion.md) §3a). The same prime‑slip mechanism unlocks the neutron's weak vertex once the
local cascade supplies commensurate `±i` kicks: it **disrupts the phase coherence of the Fermi sea**,
suddenly releasing previously Pauli‑blocked decays — accelerated neutronization, or a decay burst:

```
dn_n/dt = −Γ_n(t) n_n + (capture),      Γ_n(t) = Γ₀^n (1 + γ_n Φ_p S_n)
```

The mass window it works in is the tiny `m_n − m_p` splitting (`QLF_QuarkMass`,
[`Weak_Force.md`](Weak_Force.md) §5); the three Sakharov conditions that make the winding decay generic
are already anchored (`QLF_Baryogenesis`).

### 2.4 Supernova — the three windows overlap

When the three sectors lock **together** inside a collapsing core the releases stop being independent:

1. Prime‑driven **flavor conversion** (§2.1) changes the heating and lepton chemistry.
2. Accelerated **muon unlocking** (§2.2) softens the core and injects energy.
3. Synchronized **neutron unlocking** (§2.3) releases a burst that cascades down the remaining octaves.

Because the flux is already organized in octaves at constant `log 2` per octave
([`QLF_Kolmogorov`](lean/QLF_Kolmogorov.lean)), the simultaneous unlocking of a macroscopic ensemble is a
**coherent, scale‑invariant energy dump**:

```
dE/dt  ∝  n_ν Γ_ν S_ν  +  n_μ Γ_μ S_μ  +  n_n Γ_n S_n
```

When the synchronization windows overlap, `dE/dt` **spikes** on a dynamical timescale — stored fold‑depth
(binding) converts into the outgoing neutrino burst and the kinetic energy of the shock. The demo makes
this concrete with a feedback model (`prime_cascade_decay.py` §4): letting the released `log 2` quanta
raise the local flux (`Φ_p → Φ_p + κ·E`, decays pushing neighbours toward the lock), the peak release
jumps from `dE/dτ ≈ 1.1` (independent drain) to `≈ 8.4`, **spiking exactly when the flux crosses into
resonance** (`Φ_p → ω_b`) — the prime‑synchronized cascade dump.

---

### 2.4a The remnant — how a neutron star is made

The supernova above is the *event*; this is what it leaves, and it is the one place in physics
where QLF's capacity ladder is run to completion by nature at macroscopic scale.

**The chain, as capacity.** Fusion stops at iron — past it, binding energy no longer rises, so the
core has no further exothermic closure to make ([`Fusion.md`](Fusion.md)). Support fails, the core
contracts, and **compression takes over from heat as the capacity knob**. Electrons are fermions,
so squeezing them raises their Fermi energy (Pauli exclusion read spatially,
[`Magnetism_Spatial_Dynamics.md`](Magnetism_Spatial_Dynamics.md)). Once that energy clears the
`0.782 MeV` a neutron costs, the deeper closure of the neutral `B = 1` content becomes affordable
and electron capture switches on ([`Weak_Force.md`](Weak_Force.md) §4b,
[`Law_Of_Exceptions.md`](Law_Of_Exceptions.md) §4a.1):

```
    p + e⁻ → n + ν_e
```

**And it is self-accelerating, which is the whole mechanism.** The electrons being captured are
the same electrons whose degeneracy pressure was holding the core up. Capture removes the support
that resists the compression that drives the capture. That is a positive feedback of exactly the
form §2.4's cascade model already carries (`Φ_p → Φ_p + κ·E`, releases pushing neighbours toward
the lock) — here the feedback runs on density rather than flux, and it runs away. The core
**neutronizes**: the census of ways the matter can close shifts wholesale from the shallow
hydrogen-class closure to the deep neutron one, because at that capacity the neutron ways are the
ways that close.

**What stops it.** Neutrons are fermions too. When neutron degeneracy — the same spatial-exclusion
principle one rung deeper — plus the repulsive core of the nuclear closure takes over, the collapse
halts and bounces. The gravitational binding energy released is carried off almost entirely by
neutrinos, which is §2.4's coherent `log 2`-per-octave dump seen from outside: the burst is not
incidental to the collapse, it *is* the collapse's receipt.

**The ladder, end to end.** Each rung is a capacity, and each opens a closure the rung below cannot
reach:

| Capacity | How the `B = 1` content closes | Held up by |
|---|---|---|
| ordinary | `uud` + electron **outside** — hydrogen | electron shells |
| white-dwarf density | still electron-outside, compressed | **electron** degeneracy |
| `E_F ≳ 0.782 MeV` | `udd` — the `−1` folded **in**, `ν_e` away | (support removed — runaway) |
| neutron-star density | neutron closures packed | **neutron** degeneracy + nuclear repulsion |
| `T ≳ 155 MeV` | no baryon closure at all — quarks roam | nothing (deconfined) |

Two rungs are the *same* Pauli exclusion at different depths, which is why
[`Magnetism_Spatial_Dynamics.md`](Magnetism_Spatial_Dynamics.md) lists white dwarfs and neutron
stars in one breath: degeneracy pressure is spatial exclusion, and the substrate reading is that
identical same-orientation closures must occupy distinct events.

**Magnetars, briefly.** Circulation is a winding quantity on the substrate
([`Navier_Stokes_Geometry.md`](Navier_Stokes_Geometry.md): vorticity is the discrete curl,
quantized per cell), so compressing a magnetized core concentrates the flux it already carries
rather than manufacturing new field. Collapse by a large factor in radius therefore amplifies the
surface field enormously — which is the structural reason a neutron star can carry the strongest
magnetic fields known, and the point at which this chain hands over to
[`Magnetism_Spatial_Dynamics.md`](Magnetism_Spatial_Dynamics.md).

**And one rung further — where black holes come from.** Neutron degeneracy is not unlimited either.
Above a maximum mass no static neutron-star solution exists (the Tolman–Oppenheimer–Volkoff limit;
measured constraints put it near `2.2–2.3 M_☉`, NICER-era), and collapse continues with nothing left
to halt it. That is the rung the ladder above stops one short of, and it is where the capacity
reading hands over to [`BLACK-HOLES.md`](BLACK-HOLES.md):

```
    neutron degeneracy exhausted  →  collapse continues  →  horizon forms
```

Read as capacity, the pattern is the same one the whole ladder follows, one level higher. Electron
capture *replaced* a closure; deconfinement *dissolved* one; here the entire externally accessible
matter organization is replaced by a **horizon-level closure** — and what changes is which system is
the relevant object. The old closure was not wrong; a larger enclosing one became the thing there is
to describe, which is the Law of Exceptions in its most extreme physical form
([`Law_Of_Exceptions.md`](Law_Of_Exceptions.md) §4a.1).

**Two things this rung does not do.** QLF derives no TOV limit — the `2.2–2.3 M_☉` is measured
input, exactly as the `0.782 MeV` above is. And forming a horizon is not the same as forming a child
domain: whether a sealed interior re-closes with a history of its own is explicitly the open
question of [`BLACK-HOLES.md`](BLACK-HOLES.md) §4a, tagged there as a structural reading rather than
a result. What the collapse ladder supplies is the *candidate*, not the conclusion.

**Honest scope.** This is *structure*, and the numbers are not QLF's. What the substrate supplies
is the ladder — that compression is a capacity, that a deeper closure of the same neutral content
becomes available at a threshold, that capture is self-accelerating because it eats its own
support, that degeneracy is exclusion one rung down, and that the neutrino burst is the closure
receipt. What it does **not** supply: no derived Chandrasekhar mass, no mass–radius relation, no
neutronization threshold computed from the census rather than taken from measured masses, no
equation of state, and no TOV limit. The `0.782 MeV` above is measured input, not a QLF output. Treat this as the
capacity reading of known astrophysics, not a derivation of it.

---

## 3. Summary of the decay chain

| Stage | ZFA object | Turbulent trigger | Effect in the core |
|---|---|---|---|
| **Neutrino flavor** | Majorana three‑axis closure (`QLF_Majorana`) | prime `±i` slips lock the flavor phase | collective flavor conversion, altered heating |
| **Muonium / muon** | moderate‑depth gauge fold (`QLF_HiggsMechanism`) | resonant `Φ_p` at `ω_b` (`S → 1`) | rapid unlocking, EOS softening, energy injection |
| **Neutron** | weakly‑unstable closure; Pauli‑blocked in‑medium | phase disruption of the Fermi‑sea block | accelerated neutronization / decay burst |
| **Supernova** | macroscopic ensemble | overlap of the three `S → 1` windows | coherent `log 2` cascade dump = the explosion |

The whole sequence is *one* continuous prime‑synchronized turbulent cascade: flavor conversion seeds the
lepton chemistry, muon unlocking softens the core and adds energy, neutron unlocking releases the final
burst, and the collective ZFA unlocking appears observationally as a core‑collapse event.

---

## 4. Honest scope

- **Anchored (Lean, reuse‑only, no new axioms):** the prime `±i` phase‑slip agent, the decay *condition*
  (out‑of‑balance ⟹ no receipt ⟹ not a closure), the `log 2` release quantum, the collective additivity,
  and the octave bath — all in [`QLF_PrimeCascadeDecay`](lean/QLF_PrimeCascadeDecay.lean), reusing
  `QLF_QuantumTurbulence` + `QLF_ContradictionReceipt` + `QLF_FreeEnergy`. Every per‑stage object
  (Majorana neutrino, gauge‑fold mass, Pauli block, `m_n−m_p` window, Sakharov conditions) is an
  *already‑verified* QLF result, cited above.
- **Phenomenological (numerical, not derived):** the decay *dynamics* — the couplings `Γ_p, γ_n`, the
  resonance sharpness `Q`, the synchronization `S`, the feedback `κ` — live in
  [`prime_cascade_decay.py`](prime_cascade_decay.py). Their map from ZFA combinatorics to the coupling
  *strength* is the **same one open piece** as the four‑fermion binding strength
  (`higgs_turbulence_in_progress`, [`Higgs.md`](Higgs.md) §5a).
- **Not a claim about the astrophysics.** This is a QLF‑*internal* mechanism showing that the existing
  ingredients (Majorana neutrino, gauge‑fold mass, prime phase shifts, the constant‑`log 2` cascade, the
  resonant decay rate) *compose* into a coherent decay chain. It is **not** asserted that laboratory
  muonium, in‑medium neutrons, or real core‑collapse supernovae proceed by this mechanism — that would
  need the derived couplings and a genuine astrophysical comparison, neither of which is claimed. A
  tightly‑constrained qualitative model, every step reusing already‑established pieces.

See also: [`Turbulence.md`](Turbulence.md) (the cascade), [`Geometry_Of_Space.md`](Geometry_Of_Space.md)
(prime‑topology stability), [`Reversibility.md`](Reversibility.md) (why the forward closure is the arrow),
[`Conservation.md`](Conservation.md) (energy created per event, half lent to the future).

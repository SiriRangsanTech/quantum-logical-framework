# The Mpemba effect — anomalous relaxation as a closure census

**Module:** [`lean/QLF_Mpemba.lean`](lean/QLF_Mpemba.lean) — machine-verified, no axioms
**Blind test:** [`mpemba_census.py`](mpemba_census.py)
**Companions:** [`lean/QLF_ClosureDepthLaw.lean`](lean/QLF_ClosureDepthLaw.lean) (relaxation time *is* the maximum excursion) · [`Law_Of_Exceptions.md`](Law_Of_Exceptions.md) (capacity) · [`Philosophy.md`](Philosophy.md) §3a (the method) · [`Entropy.md`](Entropy.md) · [`Mysteries_Of_Physics.md`](Mysteries_Of_Physics.md)

---

## §1 The effect, and what it is now understood to be

Hot water, under some conditions, freezes before cold. The naïve reading — that a state farther from
equilibrium relaxes faster — sounds paradoxical, and for a long time the discussion was about which
mundane mechanism (evaporation, convection, dissolved gas, supercooling, container coupling) was *the*
cause.

Modern work reframed it as **relaxation-mode geometry** rather than thermal bookkeeping. Write the
approach to equilibrium as a sum over modes,

$$
\delta p(t) \;=\; \sum_n a_n(X_0)\, e^{-\lambda_n t}\, v_n ,
$$

and the late-time behaviour is governed by the slowest surviving mode. A hotter preparation can arrive
first if its amplitude `a_slow` on that mode is smaller — and in the **strong Mpemba effect** that
amplitude vanishes outright, removing the slow channel and giving exponential speed-up (Lu–Raz;
Klich–Raz–Hirschberg–Vucelja). The effect has been realised in controlled systems, including colloidal
and trapped-ion experiments, precisely by engineering the initial state's overlap with the slow mode.

**The lesson is not about heat.** It is that *distance from equilibrium does not determine relaxation
time*. Something finer does.

---

## §2 The substrate translation

On the substrate, relaxation to equilibrium is not modelled — it *is* closure. And its time is not a
free parameter: [`QLF_ClosureDepthLaw`](lean/QLF_ClosureDepthLaw.lean) proves

> `closedAtHorizon R s ↔ maxExcursion s ≤ R`

so **relaxation time = closure depth = the maximum excursion of the phase walk**. Every question about
anomalous relaxation therefore becomes a question about a *census of excursions* — decidable, not
interpretive.

Following the mode picture, define for a preparation `X` the **closure-depth census**

$$
W_X(d) \;=\; \#\{\text{real histories from } X \text{ that first close at depth } d\},
$$

the cumulative fraction closed by capacity `R`,

$$
F_X(R) \;=\; \frac{\sum_{d\le R} W_X(d)}{\sum_d W_X(d)},
$$

and a **closure latency** `τ_X = min{R : F_X(R) ≥ ½}`. `F_X` is exactly a **listening** in this
repository's sense ([`Philosophy.md`](Philosophy.md) §3a rule 2): the capacity-relative count, what a
horizon of capacity `R` actually receives. A **QLF Mpemba effect** is then `τ_H < τ_C` while `H` is the
farther preparation by some macro measure. A useful companion quantity is the discrete **closure hazard**
`Γ_X(R) = W_X(R)/∑_{d≥R} W_X(d)` — of the histories still unresolved at `R`, what fraction close now.

---

## §3 What is proven

Three statements, machine-verified in [`QLF_Mpemba`](lean/QLF_Mpemba.lean). They do **not** all point the
same way, which is why they are worth having.

### (a) A no-go — no Mpemba for the imbalance measure

**`relaxation_ge_distance`**: `|level s| ≤ maxExcursion s`. If "distance from equilibrium" means the
history's own imbalance, then relaxation is bounded **below** by the distance — the walk must reach its
final level, and the excursion is a maximum over prefixes (`level_le_hmax`). A farther state can never
relax faster by that measure: the effect is **impossible**, not merely unobserved.

That is a real constraint, and it disciplines the rest: *any* Mpemba claim on the substrate must name a
distance measure that is not the imbalance.

### (b) The enabler — no scalar determines the relaxation time

**`equal_length_unequal_relaxation`**: at one length `2n`, with identical (zero) imbalance, the pair
matching `[+−][+−]…` closes in **one** pass while the nested singlet `[+ⁿ −ⁿ]` needs **`n`**
(`nested_relaxes_slower`). Same energy, same distance-from-balance, relaxation differing by a factor of
`n`.

So the macrostate scalar provably underdetermines the relaxation time. **That is the room an anomalous
ordering needs** — and it is a theorem about the substrate, not a story about water.

### (c) Strong Mpemba, translated — sector emptiness, not a vanishing eigenmode

**`strong_mpemba`**: if every history of preparation `H` satisfies `maxExcursion ≤ R` while some history
of `C` exceeds `R`, then at capacity `R` the `H` preparation has **fully closed** and `C` has not. The
spectral condition `a_slow = 0` becomes the census condition

$$
W_H(\text{deep sector}) \;=\; 0 ,
$$

with no appeal to eigenmodes — the deep sector being exactly the large-excursion histories the depth law
identifies.

---

## §4 The blind test — and it does **not** produce the effect

The criterion is sharp: if an anomalous ordering appears only after the multiplicities are arranged to
produce one, this is an interpretation of Mpemba, not a derivation. So
[`mpemba_census.py`](mpemba_census.py) draws preparations **uniformly** at a fixed macro parameter, with
nothing tuned about their depth distribution:

| length (energy) | 8 | 16 | 24 | 32 | 48 | 64 |
|---|---|---|---|---|---|---|
| median relaxation | 2 | 3 | 4 | 4 | 5 | 6 |

**No crossings.** Relaxation is monotone in the macro parameter, so the effect does *not* fall out of a
scalar energy with uniform preparations. Stated plainly because it is the honest result.

What the same test does show is that the room is real: at length 32 the depth ranges **1 … 13** over
20,000 uniform draws, and the constructible extremes are **1** (pair matching) and **16** (nested
singlet).

### §4a And instances *do* occur — including from unbiased draws

The monotone medians say the *ensemble* shows no effect. Individual preparations are a different
question, and there the answer is yes.

**Proven, and unbounded** (`mpemba_instance`, `mpemba_ordering`): for every `d > 1` and `n > d`, two
balanced preparations closing to the *same* equilibrium, where the one with **more energy** closes
**faster** —

| | preparation | energy (length) | relaxation |
|---|---|---|---|
| hot | pair matching of `n` pairs | `2n` | **1** pass |
| cold | nested fold `[+^d −^d]` | `2d < 2n` | **`d`** passes |

so e.g. 10× the energy closing 10× faster, with the ratio arbitrary.

**And not only for constructed extremes.** Drawing both preparations *uniformly*, a higher-energy history
closes strictly faster with substantial probability:

| energy ratio | 2× (32 vs 16) | 2× (64 vs 32) | 2× (128 vs 64) | 4× (64 vs 16) | 4× (128 vs 32) |
|---|---|---|---|---|---|
| P(hot closes strictly faster) | 0.131 | 0.146 | 0.165 | 0.027 | 0.030 |

A witness found by unbiased search — four times the energy, closing two passes sooner:

```
hot  (length 64, depth 3): +--+--+++----+++---+-+-++-+++---++-+-++-++---+-++++-+-----++++--
cold (length 16, depth 5): ---+-+---+++-+++
```

So the honest position is finer than "no effect": **the crossing is a property of individual preparations,
not of the uniform ensemble.** Which is also how the laboratory effect is reported — Mpemba experiments
compare specific preparations, never ensemble medians.

---

## §5 A methodological trap the substrate makes explicit

An earlier version of the test compared time-to-fixpoint across preparations of *differing* imbalance,
and produced a striking crossing: median relaxation fell from 4 to 1 as the imbalance rose. It was an
**artifact**, and the substrate says exactly why.

An unbalanced history **never closes**. It stalls at an irreducible core of `|imbalance|` same-sign
twists. So comparing "time until nothing further happens" across preparations of different imbalance
compares arrival at *different destinations* — the fast ones were not reaching equilibrium at all, they
were reaching their own dead ends sooner.

This is the substrate form of the experimental literature's hardest methodological problem: **what does
"freezes first" mean?** Results there depend heavily on the chosen observable and on preparation, and a
2024 experiment attributed much of the apparent variation to differing cooling rates from uncontrolled
convection. QLF's contribution here is not a new mechanism but a sharp statement of the trap: *a
relaxation comparison is only meaningful between preparations that close to the same equilibrium* — on
the substrate, between balanced histories.

---

## §6 Laser cooling — engineered multiplicity bias

Laser cooling is the clean counterpart, and it is not the same mechanism as Mpemba: it *engineers* the
relaxation pathways rather than exploiting an accident of preparation. Red-detuned light makes an ion
preferentially scatter in ways that remove motional energy; in sideband cooling the cycle
`|g,n⟩ → |e,n−1⟩ → |g,n−1⟩` walks the vibrational ladder down. The rate depends on which states the field
couples — transition structure, resonance, selection rules — not on stored energy alone.

In this framework that reads as **engineered multiplicity bias**: the field reorganises the census so that

$$
W(\text{energy-lowering histories}) \;\gg\; W(\text{energy-raising histories}),
$$

and then the method's rule applies unchanged — *what happens in the most ways happens first*
([`Philosophy.md`](Philosophy.md) §3a). Resonance is already a ways-count in this repository:
[`QLF_LineSpectra`](lean/QLF_LineSpectra.lean) shows the joint closure completes in many ways on
resonance and few off it.

**And it suggests the better experiment.** A trapped-ion ladder is an explicitly controllable transition
network, so its multiplicities can be *written down* rather than guessed — unlike freezing water, where
convection, evaporation, dissolved gas and nucleation are all in play at once. The decisive test of §3(c)
would be a laser-cooled ladder prepared so that the slowest closure class has multiplicity **zero**, and
checking whether the strong-Mpemba point sits where the census says it must.

---

## §7 Why water may have no single cause

Heating changes convection, evaporation and hence mass, dissolved-gas content, nucleation structure,
molecular correlations, and boundary coupling — all at once. The long search for *the* mechanism assumes
these compete.

On the possibilist reading they need not: they are **different ways of altering the same closure-depth
census**. Nothing happens one way; every generable way is real, and what happens in the most ways happens
first. So "what causes the Mpemba effect?" may be the wrong question, with different preparations
realising the crossing through different mechanisms while one condition stays invariant:

> the hotter preparation carries **more multiplicity in fast-closing sectors**, and/or **less in the
> slowest**.

This is offered as a *reading*, not a result. It is consistent with the experimental messiness rather than
explanatory of it, and it makes no quantitative prediction about water.

---

## §8 Honest scope — and what would make this a result

**What is proven** (no axioms): the imbalance no-go (`relaxation_ge_distance`), the scalar
underdetermination that makes anomalous ordering possible at all
(`equal_length_unequal_relaxation`), and the sector translation of the strong effect (`strong_mpemba`).

**Also proven:** an *instance*, and an unbounded family of them, with energy as the distance
(`mpemba_instance`) — plus the measured fact that uniform draws cross 13–17% of the time at a 2× energy
ratio (§4a). So the effect is exhibited on the substrate, not merely permitted.

**What is not:** the *ensemble* effect, and the water effect. Median relaxation is monotone in energy, so
the crossing lives between individual preparations; whether energy is an admissible distance measure is
what thermomajorization asks of the ordinary effect; and no quantitative claim about water is made.
QLF here supplies an **ontology, proven scaffolding, and exhibited instances** — not a derivation of the
laboratory phenomenon. Calling it a solved mystery would be exactly the overclaim this repository's
method forbids.

**What would make it a result** — a concrete, falsifiable target:

1. Compute an actual `W_X(d)` census for a *physically specified* preparation (the trapped-ion ladder of
   §6 is the tractable candidate) and show the conventional slow-mode amplitudes **emerge** from it —
   ideally `a_n ∝ Σ_{h ∈ mode n} W(h)·φ(h)`, with `φ` the `μ₂` phase that
   [`QLF_BalancedPhaseReal`](lean/QLF_BalancedPhaseReal.lean) proves closures carry.
2. Show that a preparation with suppressed deep-closure multiplicity is *precisely* the one with a
   suppressed slow eigenmode — not merely analogous to it.

If that works, the claim becomes strong and specific: **relaxation eigenmodes are the continuum rendering
of multiplicity classes of real histories.** If it does not, QLF has supplied an ontology for anomalous
relaxation and a proven no-go, which is worth having and is less than a solution.

---

## References

Confident: R. Lu & O. Raz, *PNAS* **114**, 5083 (2017) — Markovian Mpemba and its inverse.
I. Klich, O. Raz, O. Hirschberg & M. Vucelja, *Phys. Rev. X* **9**, 021060 (2019) — the Mpemba index and
anomalous relaxation. A. Kumar & J. Bechhoefer, *Nature* **584**, 64 (2020) — Mpemba in a colloidal
system.

Reported in the survey that prompted this document, and **not independently verified here** — treat the
locators as provisional: a trapped-ion *inverse* Mpemba demonstration (*PRL* **133**, 010403); a
thermomajorization formulation removing the arbitrary distance measure (*PRL* **134**, 107101); a
non-Markovian quantum Mpemba mechanism at exceptional points (*PRL*, 2026); and a 2024 APS March Meeting
water experiment attributing much apparent variation to convection-driven cooling-rate differences.

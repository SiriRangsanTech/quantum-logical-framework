# Protein folding in QLF — a fold is a closure inventory

How a chain finds its shape in the [Quantum Logical Framework](README.md) (QLF). This is the
next rung above [`Chemistry.md`](Chemistry.md), which gets molecules from one rule — *a bond is a
shared closure* — and stops at stoichiometry, because a small molecule has no shape to speak of.
A polymer does.

> **The one idea, continued.** A **contact** is a shared closure, exactly as a bond is. What is new
> at polymer scale is that the two partners are already tied together by the backbone, so the closure
> is a **loop** — and a loop is a twist history that returns. Folding is therefore not a search
> through shapes. It is a **census of loops that close**, and what closes in the most ways happens
> first.

Machine-verified core: [`lean/QLF_Folding.lean`](lean/QLF_Folding.lean) (no axioms).
Runtime census: [`protein_census.py`](protein_census.py) → [`data/folding_census.json`](data/folding_census.json).

---

## 1. The step is already in the alphabet

A backbone on the cubic lattice moves by one of **six signed axis displacements**. The 8-twist
alphabet **is** the signed axis frame ([`QLF_AlphabetNecessity`](lean/QLF_AlphabetNecessity.lean)):
six spatial twists plus the gauge pair `+`/`−`, which carries phase and no displacement. So

$$\text{a conformation} \;=\; \text{a twist history}$$

with nothing to choose and nothing to defend. `>` `<` `^` `v` `/` `\` are the six steps; a chain is
the word they spell, and `Step.toTwist` in Lean is the identification, not an encoding. The gauge
counts of a backbone vanish identically (`count_encode_plus` / `count_encode_minus`) — a chain
never spends phase on going somewhere.

This is the representation [`Chemistry.md`](Chemistry.md) was missing, and it was in the alphabet
the whole time.

## 2. A contact is a ZFA closure

Residues *i* and *j* touch when the backbone segment between them displaces by **exactly one lattice
step**. Add the contact edge and the segment returns to its start: net displacement zero. Then, with
no further argument,

| step | why | Lean |
|---|---|---|
| net displacement zero ⟹ **count-balanced** | the signed step counts *are* the displacement | `closedLoop_countBalanced` |
| count-balanced ⟹ **Pauli-closed** | the keystone, cross-axis interleavings included | `count_balanced_pauli_closed` |
| hence **ZFA — both conjuncts** | the second comes free from the first | `contact_is_closure` |

A native contact does not have to be *checked* for admissibility. Closing is what admissibility
means. This is the same move [`QLF_Fredkin`](lean/QLF_Fredkin.lean) makes for a conservative gate:
the model's own conservation law turns out to be ZFA's — and the smallest thing that closes here,
the unit plaquette `[xp, yp, xn, yn]`, is literally Fredkin's billiard ball (`minimal_loop_closed`).

**Verified, not assumed.** [`protein_census.py`](protein_census.py) rebuilds every contact loop it
enumerates as a twist string and runs it through `twist_core.is_zfa` — the runtime `count balance ∧
Pauli closure` check. Zero failures across every walk census in the database.

### 2a. The parity rule, for free

A closed loop has **even** length (`closedLoop_even_length`) — balance pairs every step with its
reverse. A segment plus its one contact edge is therefore even, so the segment is odd:

> **Contacts occur only at odd sequence separation** (`contact_separation_odd`).

Lattice-protein models know this as the bipartite parity rule and note it as a lattice artefact.
Here it is a corollary of count balance, and it halves the contact census before any energetics is
considered. The enumeration confirms it: **every** closure recorded in the database sits at odd `ℓ`.

## 3. The contact quantum is `log 2` — the energy scale is derived

A closure is a many-to-one recognition event, and QLF prices one at exactly one bit:
`ΔF = −log 2` nats ([`QLF_FreeEnergy`](lean/QLF_FreeEnergy.lean)). So a fold's free energy is

$$F(\text{fold}) \;=\; -\,(\text{contacts}) \times \log 2 \quad\text{nats}$$

(`foldFreeEnergy`, strictly decreasing in the contact count, `foldFreeEnergy_lt`). The contact energy
of a lattice-protein model is normally a fitted `ε`; here there is nothing to fit. `log 2` nats is
`0.69 kT`, inside the `0.5–2 kT` band coarse-grained models use — **consistency**, in the sense of
[`ScientificApproach.md`](ScientificApproach.md), not a derivation of any measured number.

**And only H–H contacts pay — that is derived too.** A polar residue closes with the solvent whether
it is buried or not, so burying it releases no *differential* free energy; only a closure unavailable
from water can. That is the standard HP energy function (`ε_HH = −1`, `ε_HP = ε_PP = 0`), which is
normally posited.

## 4. Levinthal: `ways` is a coefficient, never a list

Levinthal's paradox assumes a searcher. QLF has none — but the combinatorics is real and has to be
handled, so here is how the framework actually pays for it.

**First, closures compose.** Two closed loops concatenate to a closed loop (`closedLoop_append`), so
a fold's contacts are **independent closures that add**, not a joint condition on the whole chain.
There is no product space to search because the closures are not competing for one global solution.

**Second, the multiplicity is a number, not an enumeration.** The census is stored in the shared
inventory schema — the same `closures` layer as [`data/census_inventory.json`](data/census_inventory.json),
read by the Rust `qucalc` crate ([rchain-rust `qucalc/src/lib.rs`](https://github.com/rchain-community/rchain-rust/blob/dev/qucalc/src/main.rs)),
whose load-bearing invariant is *ways as a coefficient*: a class reachable `N` ways is **one**
`WeightedClass`, not `N` terms. The exponential lives in a field, never in a list.

That is not a storage trick, it is the ontology: what happens in the most ways happens first, so the
count *is* the physical quantity and the enumeration was only ever how we learned it. And it means
`qucalc::most_ways_first` — one existing function, no new code — reads three different results off
this census:

| entry | `most_ways_first` returns | which is |
|---|---|---|
| `loopclosure\|dim=2,n=12` | class 3 (98,944 ways), then 5, 7, 9 | the **folding order** — short loops first |
| `fold\|seq=…` | class 0 (19,573 ways) | the **coil** — correct at high temperature |
| `foldweighted\|seq=…` | class 0 (19,573), class 1 (16,540) — nearly level | the **folding transition** |
| `designability\|4x4` | structure 56 (521 ways) | the **most designable structure** |

## 5. What the census actually says

### 5a. Loop closure falls steeply with span — contact order, counted

Exhaustive enumeration of every self-avoiding walk (the counts reproduce the published lattice
series, OEIS A001411 / A001412 — an external check that the enumerator is right):

| span `ℓ` | 3 | 5 | 7 | 9 |
|---|---|---|---|---|
| closure probability, 2-D, 13 residues | 0.1218 | 0.0334 | 0.0185 | 0.0134 |
| closure probability, 3-D, 9 residues | 0.1162 | 0.0502 | 0.0308 | — |

A short loop closes in roughly **nine times more ways** than a span-9 loop. Since what happens in
the most ways happens first, local structure closes first and long-range packing follows — the
folding funnel's observed order, as a count rather than a landscape metaphor. Fitted power law
`p(ℓ) ∝ ℓ^{-θ}`: **θ ≈ 2.03** (2-D), **θ ≈ 1.64** (3-D, two points only).

*Epistemic status: exact computational, finite-size limited.* These are 9–13 residue chains; the
exponents are short-chain values, not asymptotic ones, and are quoted for the trend and the sign,
not as measurements of the SAW cyclization exponent. The `ℓ = 11` point in 2-D rises again
(0.0143) — a free-chain-end effect, and it is excluded from the fit.

**A distinguishable prediction.** If the ways multiply across independent closures
(`closedLoop_append`), the multiplicity of a whole contact set is `∏_c p(ℓ_c)`, so

$$\ln(\text{ways}) \;=\; -\,\theta \sum_c \ln \ell_c$$

— the folding rate should track the **log-mean** of contact separations, not the arithmetic mean
that relative contact order uses (Plaxco, Simons & Baker 1998). **Kill condition:** take a published
two-state folder set, regress `ln k_f` on both; if arithmetic CO wins consistently, the multiplicative
composition here is wrong. Not yet run — see §8.

### 5b. Designability: the structure that happens in the most ways

All **69** distinct contact sets on the 4×4 compact lattice (552 Hamiltonian paths, 8 per structure —
the lattice symmetry group, and reducing a structure to its contact set quotients it for free,
because *an apparatus is a closure inventory*). Every compact structure has exactly 9 contacts, so
they are all equally deep; what separates them is how many **sequences** they are the unique answer
for. Scoring all 2¹⁶ sequences:

- **14,273 of 65,536 sequences (21.8%) fold** — a unique maximum-contact structure.
- Designability ranges from **21 to 521**, mean 207 — a **25-fold spread** across structures that
  are *identical* in depth.
- The top designabilities come in equal pairs (521, 521 · 428, 428 · 403, 403 …) — chain-reversal
  partners, which must have equal designability, and do.

This reproduces Li, Helling, Tang & Wingreen (1996) in 2-D, and it is QLF's own principle in
someone else's vocabulary: **designability is a multiplicity**, and the structure that happens in
the most ways is the one nature uses.

### 5c. The folding transition, with the coil winning at high temperature

Counting conformations alone, the **coil wins** — the unfolded state has the most shapes. That is not
a defect in *most ways first*; it is the denatured state, and it is what the principle should say
above the transition. The closure's own multiplicity is what changes it: a closure resolves a binary
distinction and is worth exactly one bit, so it carries **multiplicity 2**, and a conformation with
`c` contacts is realized `g(c)·2^c` ways at `T = 1`. Still an exact integer. Still a count of ways.

Two 12-residue sequences, same rule, opposite outcomes:

| sequence | max H–H contacts | ground state | verdict |
|---|---|---|---|
| `HPPHPHPHPPHH` | 5 | **1** contact set, 2 conformations | **folds** |
| `HHHHHHHHHHHH` | 6 | **31** contact sets, 62 conformations | does not fold |

The all-H control is *deeper* and still fails, because depth is not the criterion — uniqueness is.
Specific-heat peaks land at `T* ≈ 0.20–0.47` nats across chain lengths 5–13, i.e. **well below the
closure quantum** `T = 1`. Read plainly: **a 12-mer does not fold at the closure temperature**, which
is right — cooperative folding needs a few dozen residues. The `T*` sequence oscillates with chain
parity and is not monotone at these sizes, so no trend is claimed; see §8.

## 6. Hydrophobic and polar, from the valence rule

The H/P split that drives everything above is not an extra rule. It is
[`Chemistry.md`](Chemistry.md) §6 — the helium argument, one scale up: a **saturated hydrocarbon
side chain has no free valence**, so like a valence-0 species it cannot share a closure with water
and can only scatter off it; a side chain carrying an N, O or S with an unshared hydrogen, or a
charge, **has** a free valence and shares. That derivation lives there. Two things it settles here:

- **Why only H–H contacts pay** (§3). A polar residue closes with the solvent whether it is buried
  or not, so burying it releases no *differential* free energy.
- **How well the one-bit rule does.** Against the sign of Kyte & Doolittle (1982) hydropathy it
  agrees **17 of 20**, missing on Gly, Pro and Cys — the three named and explained in
  [`Chemistry.md`](Chemistry.md) §6, and none of them an accident.

*Epistemic status: phenomenological match.* The classification is a one-bit rule read off the
valence model; it is not a derivation of hydropathy values.

## 7. A no-go: chirality is not a multiplicity effect

Mirroring an axis is an involution on backbones that preserves length and carries closures to
closures, so left- and right-handed folds are in **bijection** (`map_mirror_bijective`). Therefore:

> **Counting cannot prefer a handedness.** Homochirality is not derivable from the fold census,
> however deep it is pushed.

The census confirms it directly — the closure histogram is invariant under reflection (invariant
I9). This is worth stating because it saves the census from being asked a question it provably
cannot answer: the L-amino-acid preference needs the **substrate** handedness asymmetry
([`QLF_Handedness`](lean/QLF_Handedness.lean), [`CP-Violation-and-Chirality.md`](CP-Violation-and-Chirality.md) §3),
which is upstream of chemistry entirely.

## 8. Honest scope — and the staged path from here

What is **proven**: the identification of conformation with twist history, contact-as-closure, the
parity rule, composability, the mirror no-go, and the `log 2` contact quantum. What is **exact
computational**: everything in §5, over the stated finite lattices. What is **neither**: any claim
about a real protein.

Specifically **not** claimed: that this predicts a native structure from a sequence; that lattice
`T*` maps to a temperature in kelvin; that the exponents in §5a are asymptotic. The model is
coarse-grained at the residue level, has no backbone hydrogen bonding, no side-chain packing, no
explicit solvent, and no dynamics.

The staged path, with what each stage needs:

| stage | status | what it needs |
|---|---|---|
| 1. Backbone as twist history; contact = closure | **done**, proven | — |
| 2. Contact quantum, HP energy function | **done**, derived | — |
| 3. Loop multiplicity → folding order | **done**, exact computational | larger `N` for asymptotics |
| 4. Designability → native selection | **done**, exact computational | 3-D 3×3×3 (27-mer) census |
| 5. Contact-order regression vs experiment | **open**, kill condition stated (§5a) | a published two-state folder set |
| 6. Peptide bond and the 20 residues as explicit closures | **open** | §6 is a one-bit rule, not a derivation |
| 7. Secondary structure (helix, sheet) as named motifs | **open** | needs off-lattice geometry or a finer alphabet |
| 8. Cooperative folding at realistic `N` | **open** | exhaustive enumeration ends near `N ≈ 16` — needs the inventory to be *composed* from catalogued motifs rather than re-enumerated, which is exactly what *ways as a coefficient* is for |

Stage 8 is the real frontier and the schema is already the right shape for it: a catalogued motif is
a `WeightedClass`, and composing two of them is `merge`, not a re-enumeration.

## 9. Kill conditions

Stated first, per [`ScientificApproach.md`](ScientificApproach.md) R7:

1. **A contact loop that fails ZFA.** Would falsify §2 outright. Checked on every loop enumerated;
   zero failures.
2. **A contact at even sequence separation.** Would falsify the parity corollary. Zero found.
3. **A count-balanced fold that is `±iI`.** Would falsify `balanced_phase_is_real` at polymer scale.
   Zero found.
4. **Arithmetic contact order beating log contact order** on a published folder set (§5a).
5. **A handedness preference emerging from a pure fold census.** Would contradict §7 — and would be
   a *finding*, since the bijection is proven; it would mean the census was mis-specified.

---

**See also:** [`Chemistry.md`](Chemistry.md) (the rung below) ·
[`lean/QLF_Folding.lean`](lean/QLF_Folding.lean) · [`protein_census.py`](protein_census.py) ·
[`Fredkin_QLF.md`](Fredkin_QLF.md) (the same plaquette, as a billiard ball) ·
[`Evolution.md`](Evolution.md) (why a possible fold can stay unreached) ·
[`Philosophy.md`](Philosophy.md) §3a (most ways first) ·
[`ScientificApproach.md`](ScientificApproach.md) (the labels used here).

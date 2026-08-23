# Chemistry in the Quantum Logical Framework

How atoms, molecules, crystals, and condensates arise in the [Quantum Logical Framework](README.md) (QLF) — and
how to watch each one form live in the [Spacetime Constructor](Spacetime_Constructor.md). Every **(▶ see)** link
opens the visualizer with that scene already loaded in its QuCalc box.

> **The one idea.** A chemical bond is not a force — it is a **shared closure**. Two atoms complete each other's
> unclosed twist history by sharing it, exactly as a hydrogen atom is a proton+electron shared closure
> ([`Bound_States_QLF.md`](Bound_States_QLF.md)). Chemistry is ZFA closure at the molecular scale, and it runs on a
> single rule.

---

## 1. Valence — the count of closures an atom can share

Every element has a **valence**: how many closures it still needs to complete its shell.

| Element | H | He | C | N | O | Fe |
|---|---|----|---|---|---|----|
| valence | 1 | **0** | 4 | 3 | 2 | 3 |

Helium's is **0** — its shell is closed, so it shares nothing and never bonds (a noble gas). That rule
does work elsewhere: a valence-0 species has no unshared closure to offer, so two helium atoms can only
*scatter*, which is exactly what a billiard ball has to do. [`Fredkin_QLF.md`](Fredkin_QLF.md) builds
Fredkin & Toffoli's billiard-ball computer on that — the idealization they had to impose on their balls
falls out of the valence rule here. Iron is a **metal**:
it shares with non-metals (oxides) but not with other iron atoms (metals lattice, they don't form discrete `Fe₂`).

## 2. The one rule

> Two **isolated** closures with **free valence** that drift within range **share a closure** (bond) — each
> spending one unit of valence — and keep bonding until saturated.

There are **no forces** and nothing per-molecule is hardcoded. Atoms find each other by drifting down the
`w_ZFA` latency gradient (the same pull behind gravity and p+e→H recombination), and the valence rule does the
rest. Everything below is that one rule playing out.

## 3. Molecules — shared closures

- **Hydrogen, H₂** — H(1)+H(1), valence-saturated. The canonical covalent shared closure.
  [▶ see](https://rchain-community.github.io/quantum-logical-framework/spacetime_constructor.html#qc=H%20%40%20-2%2C0%2C0%0AH%20%40%202%2C0%2C0)
- **Water, H₂O** — O(2) shares one closure with each of two H (via the OH intermediate).
  [▶ see](https://rchain-community.github.io/quantum-logical-framework/spacetime_constructor.html#qc=O%20%40%200%2C0%2C0%0AH%20%40%20-2.5%2C0%2C0%0AH%20%40%202.5%2C0%2C0)
- **Carbon dioxide, CO₂** — C(4) saturates against two O(2).
  [▶ see](https://rchain-community.github.io/quantum-logical-framework/spacetime_constructor.html#qc=C%20%40%200%2C0%2C0%0AO%20%40%20-2.5%2C0%2C0%0AO%20%40%202.5%2C0%2C0)
- **Methane-ish, CHₓ** — C grabs H, but H atoms competing nearby may pair off as H₂ first (real kinetics).
  [▶ see](https://rchain-community.github.io/quantum-logical-framework/spacetime_constructor.html#qc=C%20%40%200%2C0%2C0%0AH%20%40%20-2.2%2C0%2C0%0AH%20%40%202.2%2C0%2C0%0AH%20%40%200%2C2.2%2C0%0AH%20%40%200%2C-2.2%2C0)

## 4. Carbon — one atom, many allotropes

Carbon is a **non-metal that self-bonds**: with valence 4 it forms C–C networks. But the *same* valence-4 carbon
makes very different structures depending on the **bonding geometry** — this is why carbon has so many allotropes.
The constructor builds each as a distinct form:

- **Ring / loop** (cyclocarbon) — 2 bonds per C, carbons in a closed ring.
  [▶ see](https://rchain-community.github.io/quantum-logical-framework/spacetime_constructor.html#qc=ring%20%40%200%2C0%2C0)
- **Graphene** — sp², **3 bonds per C** in a flat honeycomb sheet.
  [▶ see](https://rchain-community.github.io/quantum-logical-framework/spacetime_constructor.html#qc=graphene%20%40%200%2C0%2C0)
- **Graphite** — stacked graphene sheets.
  [▶ see](https://rchain-community.github.io/quantum-logical-framework/spacetime_constructor.html#qc=graphite%20%40%200%2C0%2C0)
- **Diamond** — sp³, **4 bonds per C** in a tetrahedral 3-D network.
  [▶ see](https://rchain-community.github.io/quantum-logical-framework/spacetime_constructor.html#qc=diamond%20%40%200%2C0%2C0)
- **Nanotube** — graphene rolled into a honeycomb cylinder.
  [▶ see](https://rchain-community.github.io/quantum-logical-framework/spacetime_constructor.html#qc=nanotube%20%40%200%2C0%2C0)
- **Buckyball, C₆₀** — buckminsterfullerene, a truncated-icosahedron carbon cage (60 atoms, exactly 3 bonds each).
  [▶ see](https://rchain-community.github.io/quantum-logical-framework/spacetime_constructor.html#qc=buckyball%20%40%200%2C0%2C0)

Drop loose carbons and they still knit into a generic Cₙ cluster by the one valence rule; the named forms above
lay the carbons out in the recognisable allotrope geometry (`ring` / `graphene` / `graphite` / `diamond`, or the
buttons in the QuCalc panel). The bond count per atom (2 → 3 → 4) *is* the allotrope.

## 5. Metals, oxides & rust

A **metal** (iron) doesn't form discrete metal molecules — its atoms **lattice**, held apart by Pauli exclusion
([§7](#7-crystals-pauli-holds-them-up)). But iron **does** share closures with oxygen: Fe(3) + O(2) → **iron
oxide (rust, ~Fe₂O₃)**. Metal–metal bonds are forbidden (so crystals stay intact); metal–non-metal bonds oxidise.
[▶ see rust](https://rchain-community.github.io/quantum-logical-framework/spacetime_constructor.html#qc=Fe%20%40%20-3%2C0%2C0%0AFe%20%40%203%2C0%2C0%0AO%20%40%200%2C-2%2C0%0AO%20%40%200%2C2%2C0%0AO%20%40%200%2C0%2C2)

## 6. Noble gases — inert

Helium (valence 0) never bonds — its closure is already complete. It is chemically inert.

## 7. Crystals — Pauli holds them up

A crystal is not a molecule: it is a lattice of atoms held apart by **Pauli exclusion**
([`PauliExclusion`](lean/PauliExclusion.lean)) balancing the latency infall — the outward degeneracy
pressure, no bonds needed. Seed a lattice and it self-binds (`lattice sc|bcc|fcc`,
[`Geometry_Of_Space.md`](Geometry_Of_Space.md)).
[▶ see an iron BCC crystal](https://rchain-community.github.io/quantum-logical-framework/spacetime_constructor.html#qc=lattice%20bcc%203%203%20Fe%20%40%200%2C0%2C0)

## 8. Superfluids & Cooper pairs — condensation

The proven fact `boson_even_pairs`/`cooper_pair_boson` ([`QLF_CondensedMatter`](lean/QLF_CondensedMatter.lean),
[`QLF_Spin`](lean/QLF_Spin.lean)): an **even fermion count folds to `+I` ⇒ a boson that condenses**.

- **Superfluid helium** — a helium-4 atom is itself a boson (6 fermions, even), so cold He Bose-condenses into a
  superfluid: it overlaps its neighbours, exempt from Pauli exclusion. Heavy atoms crystallise instead.
  [▶ see (cool helium)](https://rchain-community.github.io/quantum-logical-framework/spacetime_constructor.html#qc=lattice%20sc%203%203%20He%20%40%200%2C0%2C0)
- **Cooper pairs** — two opposite-spin electrons pair onto one channel (even count ⇒ boson) at low temperature;
  the bosonic pairs condense. Cool a handful of free electrons and watch them pair.
  [▶ see](https://rchain-community.github.io/quantum-logical-framework/spacetime_constructor.html#qc=electron%20%40%20-1%2C0%2C0%0Aelectron%20%40%201%2C0%2C0%0Aelectron%20%40%200%2C1%2C0%0Aelectron%20%40%200%2C-1%2C0)

## 9. Polymers — when the shared closure becomes a loop

The one rule already makes a **chain**. A monomer with free valence at two distinct sites cannot
saturate against a single partner, so it bonds at both ends and the bonds propagate: **valence 2 at
two sites ⟹ a linear chain, valence 3+ ⟹ a crosslinked network, valence 1 ⟹ a cap that terminates
one.** Nothing new is needed for polymerisation; it is saturation with nowhere to stop.

What *is* new at chain scale is that the two partners of a shared closure may already be tied
together by the backbone. Then the closure is a **loop** — and a loop of the backbone's twist history
is a ZFA closure in the literal sense: zero net displacement, count-balanced, Pauli-closed.
That is protein folding, and it is [`Protein_Folding.md`](Protein_Folding.md): a fold is a **closure
inventory**, folding order is loop multiplicity, and the contact energy is the substrate's own
`log 2` rather than a fitted parameter. The **hydrophobic/polar** split that drives it is this
section's valence rule applied to side chains — a saturated hydrocarbon has no free valence, so it
cannot share a closure with water, which is the helium argument of §1 one scale up.

## 10. Double bonds and rings — the same thing, counted

Of the gaps [§11](#11-honest-scope) names, one is really a counting question, and counting settles it.

Organic chemistry teaches a formula to memorise — the **degree of unsaturation** —

> `DoU = (2C + 2 + N − H − X) / 2`

with a rider that oxygen and sulphur are left out, and no reason given. Read the molecule the way
this page reads everything, as a graph whose vertex degrees are the **valences** of §1. The
handshake lemma gives `2E = Σ vᵢ`, so the number of independent closures in a connected molecular
graph — its cycle rank — is

> `b₁ = E − V + 1 = Σ (vᵢ − 2)/2 + 1`

which **is** that formula, with every element's coefficient revealed as `(valence − 2)/2`:

| element | C | N | O, S | H, halogen |
|---|---|---|---|---|
| valence | 4 | 3 | **2** | 1 |
| DoU coefficient | +1 | +½ | **0** | −½ |

**Oxygen is absent from the textbook formula because its coefficient is zero.** A divalent atom
adds one vertex and one edge, so it cannot change a cycle rank. Nothing was omitted by convention;
it cancels ([`divalent_neutral`](lean/QLF_Unsaturation.lean)).

Three things follow, and they are the reason this is worth stating in QLF rather than in a
chemistry textbook:

- **A double bond and a ring are the same phenomenon — one closure.** Both contribute exactly 1 to
  `b₁`. Chemistry files them in separate chapters; on the substrate there is one object, a loop
  that returns, which is the same object as a protein contact ([`Protein_Folding.md`](Protein_Folding.md) §2)
  and as any ZFA-closed twist history. So **`C₆H₁₂` is one census class**, holding cyclohexane and
  every hexene together — as it must, since they share a formula and therefore a closure count.
- **"Saturated" means zero closures.** A saturated molecule is a *tree*, and `CₙH₂ₙ₊₂` follows
  rather than being stipulated (`saturated_iff_alkane`). Each further closure costs two hydrogens,
  whether it is drawn as a ring or as a double bond.
- **Valence 2 is the neutral element of closure counting**, which is why [§9](#9-polymers--when-the-shared-closure-becomes-a-loop)'s
  divalent monomer makes a **chain**: the backbone carries no closure of its own, so every closure
  a polymer has is a contact. That was asserted in §9; here it is derived.

**The census** ([`hydrocarbon_census.py`](hydrocarbon_census.py)) checks that the one valence rule
is chemistry's own generator. Growing carbon skeletons a leaf at a time with **max degree 4 as the
only rule applied**, the alkane isomer counts come out

| n | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| skeletons | 1 | 1 | 1 | 2 | 3 | 5 | 9 | 18 | 35 | 75 | 159 | 355 | 802 | 1858 |

— the published series (OEIS A000602) exactly, through C₁₄. Enumerating the *merged* closure class
as multigraphs, with edge multiplicity as bond order so rings and double bonds come out of the same
machine: **C₄H₈ → 5**, **C₅H₁₀ → 10**, **C₆H₁₂ → 25**, each the textbook constitutional-isomer
total. Machine-verified core: [`lean/QLF_Unsaturation.lean`](lean/QLF_Unsaturation.lean), no axioms.

**What is *not* closed by this.** The closure **count** is derived; **which** pairs of atoms carry
the extra closure is not — so resonance, regiochemistry and bond placement remain open, and
"not double bonds" narrows to "not *where* the double bonds are." And the enumeration counts
**constitutional** isomers only: it cannot see *cis*/*trans* or a stereocentre, for exactly the
reason [`Protein_Folding.md`](Protein_Folding.md) §7 proves the fold census cannot pick a
handedness — a valence graph is mirror-symmetric, so counting alone never distinguishes a molecule
from its reflection.

## 11. Honest scope

The **shared-closure bond** is the QLF principle (proven for H₂/atoms; `Bound_States_QLF.md`,
[`QLF_Confinement`](lean/QLF_Confinement.lean) for what *can't* close). The rest is an **illustrative** model:
a single-bond, valence-saturation rule that gets **stoichiometry and formulas** right (H₂O, CO₂, Fe₂O₃) — and,
since [§10](#10-double-bonds-and-rings--the-same-thing-counted), the **number** of extra closures a formula
carries — but not *where* those closures sit (resonance, regiochemistry), nor bond angles, stereochemistry,
or reaction rates; iron is fixed at +3 (→ Fe₂O₃). The specific valences and
thresholds are chosen for illustration, not derived. It is chemistry *seen through the ZFA lens*, live and
self-assembling — not a quantum-chemistry solver.

---

**See also:** [`Protein_Folding.md`](Protein_Folding.md) (the rung above — folding as a closure census) ·
[`Spacetime_Constructor.md`](Spacetime_Constructor.md) (the visualizer) · [`Bound_States_QLF.md`](Bound_States_QLF.md)
(why atoms, not free leptons, are the observables) · [`Geometry_Of_Space.md`](Geometry_Of_Space.md) (crystals as
resonant lattices) · [`SpaceTime.md`](SpaceTime.md) · [`Philosophy.md`](Philosophy.md).

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

## 9. Honest scope

The **shared-closure bond** is the QLF principle (proven for H₂/atoms; `Bound_States_QLF.md`,
[`QLF_Confinement`](lean/QLF_Confinement.lean) for what *can't* close). The rest is an **illustrative** model:
a single-bond, valence-saturation rule that gets **stoichiometry and formulas** right (H₂O, CO₂, Fe₂O₃) but not
double bonds, bond angles, resonance, or reaction rates; iron is fixed at +3 (→ Fe₂O₃). The specific valences and
thresholds are chosen for illustration, not derived. It is chemistry *seen through the ZFA lens*, live and
self-assembling — not a quantum-chemistry solver.

---

**See also:** [`Spacetime_Constructor.md`](Spacetime_Constructor.md) (the visualizer) · [`Bound_States_QLF.md`](Bound_States_QLF.md)
(why atoms, not free leptons, are the observables) · [`Geometry_Of_Space.md`](Geometry_Of_Space.md) (crystals as
resonant lattices) · [`SpaceTime.md`](SpaceTime.md) · [`Philosophy.md`](Philosophy.md).

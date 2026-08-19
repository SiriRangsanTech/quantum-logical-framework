# The Scientific Method of the Quantum Logical Framework

**How conjectures are generated, tested, rejected, and promoted to results.**

This document is about *method*, not results. It states the rules by which the
[Quantum Logical Framework](README.md) decides what it knows, what it merely suspects, and what it
has ruled out. The evidence ledger lives in
[`Experimental_Consistency.md`](Experimental_Consistency.md), the unresolved questions in
[`Open_Problems.md`](Open_Problems.md), the ontology in [`Philosophy.md`](Philosophy.md), and the
domain derivations in their own documents. Keeping those separate is itself part of the method: a
file that mixes protocol with claims will always end up grading its own work.

> **The point of this file:** QLF should document not merely why it might be right, but exactly how
> it permits itself to be wrong.

---

## 1. The ontological floor

Three commitments are load-bearing for everything below. They are stated once here, in the form the
method actually uses; the full case is in [`Philosophy.md`](Philosophy.md).

**Generable ⟹ real; ZFA decides closure, not existence.**

$$
\text{generable history} \;\Longrightarrow\; \text{real way} \;\xrightarrow{\;\text{ZFA}\;}\;
\text{closed, persistent physical event}
$$

Every history the substrate can generate is a real way. ZFA closure does not decide which histories
*exist* — it decides which ones **persist as events**. This is why census methods are legitimate at
all: counting ways is counting something real, not tallying hypotheticals.

**Information physics is primary.** The substrate is informational; matter, geometry, and duration
are *readings* of closure structure, not additional ingredients. When a question can be posed as a
question about information — how many ways, carrying what phase, closing at what depth — that is the
level at which it should be answered, and any answer that needs an extra physical postulate has
probably been posed at the wrong level.

**An apparatus is a closure inventory; an observer is a perspective.** There is no observer potency
in QLF, and the method must not smuggle any in. A measurement is a **joint closure** between
histories — nothing causes it, and nothing about it requires an agent. What we call an *apparatus*
just **is** an inventory of closures: the set of histories that can close jointly with the system,
which is precisely what [`census_inventory.py`](census_inventory.py) and
[`contextual_census.py`](contextual_census.py) enumerate. An **observer** adds only a *perspective* —
a finite closure capacity, a listening ([`Philosophy.md`](Philosophy.md) §3a rule 2) — and that
perspective may simply *be* the apparatus. Nothing in a derivation may depend on an observer beyond
the capacity that fixes which closures are received.

**Consequences for wording.** Never write that a measurement happens "when an observer looks", that
possibilities are "merely potential until observed", or that an apparatus "chooses" an outcome.
Write instead: which histories close jointly, at what capacity, in how many ways.

---

## 2. Epistemic status labels

Every claim in this repository should carry one of these, and the labels are not decorative — they
determine what may be built on top of a result.

| Status | Meaning | May be built on? |
|---|---|---|
| **Proved** | Machine-checked Lean theorem, assumptions explicit, axioms named | Yes, freely |
| **Exact computational result** | Exhaustive enumeration or exact rational/integer computation over a stated finite domain | Yes, within that domain |
| **Numerical evidence** | Finite computation suggesting a pattern, no convergence guarantee | Only as motivation |
| **Conjecture** | A proposed generalisation, stated so it can fail | No — state it as an open item |
| **Phenomenological match** | Agrees with known physics, but mechanism or uniqueness not established | Cite as consistency, never as derivation |
| **Open bridge** | A connection the argument needs and does not have (the named axioms) | Only with the bridge named at each use |
| **Rejected route** | A candidate tested against its kill condition and failed | Keep — it constrains the next attempt |
| **Superseded** | An earlier conclusion overturned by a better computation | Keep, with what failed and why |

Two rules govern the labels:

> **Numerical agreement is not a proof.**
> **Construction proves possibility, not uniqueness** — exhibiting a way something *can* happen never
> shows it is the only way ([`Law_Of_Exceptions.md`](Law_Of_Exceptions.md)).

---

## 3. Core methodological rules

**R1 — Inventory before interpretation.** When a question reduces to the finite substrate census,
ask the complete accessible inventory before proposing a mechanism. Constructed examples demonstrate
*possibility*; census statistics test *generality*. The inventory has repeatedly caught claims that
would otherwise have become documentation — including an incorrect `μ₂` phase-factorization claim
that the enumeration rejected on sight.

**R2 — No free fitted kernels.** A contribution rule, weighting, or partition chosen to make the
answer come out is a fitted parameter, however natural it looks. Weightings must be *derived* (the
cylinder measure `8^{−|h|}` is forced by prefix-freeness and Kraft) or the result is bookkeeping
([`Philosophy.md`](Philosophy.md) §3a rule 4).

**R3 — Symmetry-locked agreement is not evidence.** If a proven symmetry forces the number, obtaining
that number tests implementation consistency and nothing else.

> A prediction forced by an already-imposed symmetry does not independently confirm the theory.

`P(+) = P(−) = ½` under an exact branch-exchange symmetry is a regression check, not a Born-rule
result. Every agreement must be checked for this before it is counted.

**R4 — Exact arithmetic before float inference.** Signed censuses run in exact integers or rationals
wherever practical. Floating-point asymptotics need an independent check: a signed transfer-matrix
census is contaminated past `k* ≈ 16 ln 10 / ln(λ₁/λ₂)`, where roundoff — which overlaps the dominant
subspace — is what the answer reports. That failure mode is not hypothetical; it produced a confident
wrong conclusion in this repository.

**R5 — Transient behaviour is not an asymptotic law.** Do not read a limiting constant off a
finite-depth plateau. A growth-rate claim needs at least one of: stability under increasing depth,
term-ratio stabilisation in the tail, a recurrence, the transfer-operator spectrum, an exact
characteristic polynomial, or rigorous bounds. Measured example: the same geometry reads `8.16` at
depth 90 and `0.19` at depth 200.

**R6 — When a model fails, identify *which layer* failed.** A census model has at least three
independent layers — the **measure** over ways, the **phase/amplitude** rule, and the **context
geometry** (how a physical arrangement is encoded). Changing all three at once until the answer
appears is fitting. Establish them separately, and when something breaks, name the layer.

**R7 — State the kill condition first.** See §5.

---

## 4. The hypothesis lifecycle

$$
\text{conjecture} \;\to\; \text{census} \;\to\; \text{falsification attempt} \;\to\;
\text{invariant} \;\to\; \text{Lean theorem}
$$

1. **Conjecture** a mechanism, in substrate terms, with its kill condition.
2. **Query the inventory** — does the complete census already refute it?
3. **Compute exactly** over a stated finite domain; assert every relevant proven invariant against
   the fresh data.
4. **Reject** if the census disagrees. Record the rejection; it constrains the next attempt.
5. **Promote surviving patterns** to invariants asserted in the checker, then to Lean theorems with
   explicit assumptions.

A pattern that survives steps 1–4 is *numerical evidence*. Only step 5 makes it **proved**.

---

## 5. Kill conditions and blind tests

Every substantial conjecture states, **in advance**:

> **Candidate** — the proposed mechanism.
> **Prediction** — what it should produce.
> **Kill condition** — what result would reject it.

And where a battery of cases is run, it is run **blind**: all geometries printed together, no
per-case tuning, with the symmetry-lock check of R3 applied to every agreement before it counts.

---

## 6. The role of the inventory — the apparatus itself

[`census_inventory.py`](census_inventory.py) and [`data/census_inventory.json`](data/census_inventory.json)
hold what enumeration actually discovers: how many ways close, graded by length and depth; which
Pauli phase each carries; what a horizon of capacity `R` receives; and the first-closure event
classes of canonical contexts. It **accumulates** — each run keeps what is stored and computes only
what is missing — and it is a **checker**: every proven invariant is asserted against freshly
enumerated data, so a change that breaks one is caught rather than documented.

By §1 this is not a convenience. **The inventory is what an apparatus is** — the closure structure a
system can jointly close with — so querying it is not simulating an experiment, it is reading the
experiment's own definition. An observer contributes only capacity, and capacity is one of the
inventory's own axes.

---

## 7. The role of formal proof

Lean is where a pattern becomes knowledge. The standard is:

- **zero `sorry`**, repository-wide;
- where a genuinely unprovable step is needed, an **explicit `axiom`** with a name, a home, and an
  entry in the axiom inventory — never a silent assumption;
- assumptions visible in the statement, so a theorem cannot quietly require more than it says;
- CI is the arbiter: a Lean claim is not a result until the build is green.

Proof does not settle physics on its own. It settles what follows from what, which is the part that
should never be in doubt while the physics is argued.

---

## 8. The role of numerical simulation

Simulation generates candidates and kills them. It does not establish laws. Its outputs are labelled
*exact computational result* (exhaustive/exact over a stated domain) or *numerical evidence*
(suggestive), never *proved*. Every script that claims an invariant asserts it against freshly
computed data, so the claim and its check ship together.

---

## 9. A worked example — attempting to derive quantum weights

The Born-weight investigation is the clearest illustration of this method, because **most of the
proposals failed**, and the failures are what produced the constraints.

| Candidate | Kill condition | Outcome |
|---|---|---|
| Substrate relabeling *is* the quantum basis change | relabeling must mix amplitude classes | **Rejected** — `QLF_BasisIndependence`: relabeling permutes ways without mixing them |
| Flattening system and apparatus into one algebra caused the wash-out | indexed factors must change the weights | **Rejected** — identical probabilities at every horizon (`QLF_IndexedFactors`) |
| Read the weight at an infinite horizon | a horizon-independent value must exist | **Rejected** — both limits degenerate |
| Finite closure capacity rescues it | capacity must change the limit | **Rejected** — capacity changes only the *rate*; direction is erased at every capacity |
| Continue histories past closure | — | **Rejected as physics** — a closure *is* an event; continuing describes a different, longer history |
| **First joint closure** (absorbing census) | direction must survive | **Survived** — direction restored; the run chooses its own stopping depth |
| The depth weighting must be chosen | a derived measure must exist | **Resolved** — first closures are prefix-free, so Kraft forces `μ(h) = 8^{−|h|}` (`QLF_KraftMeasure`) |
| Normalized event weight (multiplicity × squared mean phase) | must reproduce interference | **Rejected** — provably sub-additive (`merge_le_sum`), so no constructive interference |
| Unnormalized amplitude | must converge | **Partial** — converges for 1.4% of geometries, where interference is exact in both directions |

Two corrections belong to the record as much as the results: a `μ₂` phase-factorization claim caught
by the inventory before it became documentation, and two growth-rate readings withdrawn after R4 and
R5 were applied properly. The current question is no longer *which probability formula to choose* —
it is **what invariant distinguishes the amplitude-summable contexts**, which is a sharper question
than the one the investigation started with.

---

## 10. Negative results and the correction protocol

> **Corrections remain part of the scientific record.**

When a better computation overturns an earlier conclusion: update the owning document, state plainly
what failed and why, name the new constraint, and leave the commit history intact. Do not quietly
replace a wrong conclusion with a right one — the audit trail *is* the evidence that the method
works. A rejected route is a result: it removes a possibility, which is exactly what a finite search
needs.

---

## 11. Reproducibility requirements

Every quantitative claim in this repository must be reproducible from the repository:

- the command that produces it, with its arguments, named in the document that makes the claim;
- exact arithmetic where the result is exact, and the tolerance stated where it is not;
- the domain of the computation stated (which lengths, which capacities, which geometries);
- the proven invariants asserted in the same run that produces the numbers;
- Lean claims green in CI before they are cited.

---

## 12. The current frontier

What the method says is *open* right now, stated as it should be stated:

- the amplitude layer — which contexts carry a convergent unnormalized weight, and why the threshold
  is realized rather than straddled ([`Born_Rule.md`](Born_Rule.md) §8);
- the **context geometry** layer — what substrate object represents a physical orientation, given
  that a word is a history and not a direction;
- the named bridge axioms of the Millennium reformulations, each an *open bridge* by §2.

---

## 13. Where the evidence lives

- [`Experimental_Consistency.md`](Experimental_Consistency.md) — the empirical ledger: matches,
  precisions, and the falsifier classes
- [`Open_Problems.md`](Open_Problems.md) — the status registry, closed / bounded / open
- [`Philosophy.md`](Philosophy.md) — the ontology and the multiplicity method
- [`Mysteries_Of_Physics.md`](Mysteries_Of_Physics.md) — physics-facing triage, including what QLF
  predicts is **absent** (the falsifiable nulls)
- [`lean/README.md`](lean/README.md) — every module and its theorems
- [`census_inventory.py`](census_inventory.py) · [`contextual_census.py`](contextual_census.py) — the
  inventory and the contextual layer

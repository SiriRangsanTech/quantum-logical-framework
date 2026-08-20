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

## 1. The premise, and the ontological floor

### 1a. ZFA — what it is, where it came from, and why it is still on trial

**Zero Free Action (ZFA)** is the framework's single premise. *Free action* is the unbound part of a
history: on the 8-twist alphabet each conjugate pair (`^`/`v`, `>`/`<`, `/`/`\`, `+`/`−`) carries a
running imbalance, and the free action is their total magnitude,

$$
F(h) \;=\; |n_{\uparrow} - n_{\downarrow}| \;+\; |n_{\rightarrow} - n_{\leftarrow}| \;+\;
|n_{\nearrow} - n_{\swarrow}| \;+\; |n_{+} - n_{-}|
$$

writing $n_x$ for how many times twist $x$ occurs, one term per conjugate pair.

A history **achieves ZFA** when `F(h) = 0` — every distinction it opened has been matched by its
conjugate, so nothing is left outstanding. That is count balance, and count balance *entails* the
order-sensitive condition too: `count_balanced_pauli_closed` proves every count-balanced history
folds to a Pauli scalar. Operationally, `full_zeno_prune s = []`.

**Where the premise comes from.** It is the substrate reading of **least action**. Physical systems
select histories that extremise action; the substrate's version is sharper and simpler — a history
persists as an event exactly when its *free* action is zero, `S = ∫ℒ dΩ` with `ℒ = 0`
([`Lagrangian_Formulation.md`](Lagrangian_Formulation.md)). Least action is the evidence that
suggested ZFA; ZFA is the discrete condition proposed to underlie it.

**Its epistemic status, by this document's own labels: a standing premise under continuous test —
and it stands uncontradicted so far.** It is not an axiom held beyond question. Every invariant
asserted against fresh enumeration, every Lean theorem built on closure, every empirical match in
[`Experimental_Consistency.md`](Experimental_Consistency.md) is a test of it, and the
**predicted-absent list** ([`Mysteries_Of_Physics.md`](Mysteries_Of_Physics.md) §6) is where it is
most exposed: proton decay, a magnetic monopole, a light sterile neutrino, or any persistent state
requiring an unmatched history would contradict it directly. That the premise has survived every
such test to date is a result about the premise, not a licence to stop testing it.

> **Kill condition for the premise itself:** a persistent physical event that requires a history with
> non-zero free action.

### 1b. The floor that follows

Three further commitments are load-bearing for everything below. They are stated once here, in the
form the method actually uses; the full case is in [`Philosophy.md`](Philosophy.md).

**Generable ⟹ real; ZFA decides closure, not existence.**

$$
\text{generable history} \;\Longrightarrow\; \text{real way} \;\xrightarrow{\;\text{ZFA}\;}\;
\text{closed, persistent physical event}
$$

Every history the substrate can generate is a real way. ZFA closure does not decide which histories
*exist* — it decides which ones **persist as events**. This is why census methods are legitimate at
all: counting ways is counting something real, not tallying hypotheticals.

**Information physics is primary** ([`Information_Physics.md`](Information_Physics.md)). The
substrate is informational; matter, geometry, and duration are *readings* of closure structure, not
additional ingredients. This is Wheeler's "it from bit" made constructive [W90], with the classical
notions — Shannon count [Sh48], Landauer's erasure cost [La61], the Bekenstein bound [Be81] —
sitting on the substrate as *inherited*, *derived*, or *rendering-layer* objects, each classified
there rather than assumed here. When a question can be posed as a
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

## 2. A new kind of science — on a pruned ruliad

The method here is recognisably in the lineage of *A New Kind of Science* [Wo02]: study a computational
substrate by **enumerating what it does**, rather than by writing down equations and solving them.
Wolfram's ruliad — the entangled limit of all possible rules, all possible computations — is the
right object to have identified. QLF's disagreement is not with the object but with the claim that
the object is already physics.

**The ruliad is unpruned. Physics is not.** By §1, every generable history is a real way, so the
ruliad is real in full; but only histories that reach zero free action **persist as events**. What
QLF studies is therefore the ruliad **filtered by ZFA** — and `qlf_universality` proves the filter
discards no computable physics: every *terminating* computation is already a ZFA string, so what is
pruned is the non-terminating, undecidable, Busy-Beaver tail that could never have been an event
anyway.

$$
\text{ruliad} \;\xrightarrow{\;\text{ZFA}\;}\; \text{the pruned ruliad} \;=\; \text{the physical census}
$$

**Pruning is what makes the science tractable, and it is a methodological point, not a
philosophical one.** Three things become available on the pruned side that do not exist on the
unpruned one:

1. **A measure.** The full ruliad has no canonical measure over its histories — which is why
   "typical rule behaviour" arguments there stay qualitative. Prune to *first closures* and the
   surviving set is prefix-free, so Kraft's inequality [Kr49, McM56] hands over the cylinder measure `8^{−|h|}`
   with nothing chosen ([`QLF_KraftMeasure`](lean/QLF_KraftMeasure.lean)). **Selection is what buys
   probability.**
2. **Finiteness at each capacity.** A closure horizon of capacity `R` receives a *finite, decidable*
   set of histories (`closedAtHorizon_iff_maxExcursion_le`), so a claim about the census can be
   settled by exhaustive enumeration rather than by exhibiting a suggestive picture.
3. **A falsifier.** Because the census is complete at each length and capacity, a conjecture can be
   *killed* by the inventory — as most of them have been (§10).

**What QLF inherits from NKS, and must guard against.** The characteristic failure mode of
computational exploration is mistaking a suggestive computation for a law: a picture that looks like
a pattern, a plateau that looks like a limit. Rules **R4** and **R5** exist for exactly this reason,
and both were written after that failure mode bit — a growth constant read at depth 90 that
evaporated by depth 200, and a float census whose roundoff was reporting itself as the answer.
Enumeration is a *generator* of candidates here, never a certifier; certification is Lean.

**Where the observer goes.** NKS makes the observer's computational boundedness central to how the
ruliad is sampled. QLF keeps the boundedness and drops the anthropic framing: by §1 an observer
contributes only a **capacity**, and capacity is an axis of the inventory itself, not a fact about
minds. The apparatus is a closure inventory; the observer is a perspective on it; sampling the
pruned ruliad is a physical relation between histories, not an act of observation.

---

## 3. Epistemic status labels

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

A programme that keeps producing *rejected routes* while its proved core grows is progressive in
Lakatos's sense [La78]; one that keeps rescuing a claim by adjusting what it means is degenerating.
The labels exist so the difference is visible from the outside.

Two rules govern the labels:

> **Numerical agreement is not a proof.**
> **Construction proves possibility, not uniqueness** — exhibiting a way something *can* happen never
> shows it is the only way ([`Law_Of_Exceptions.md`](Law_Of_Exceptions.md)).

---

## 4. Core methodological rules

**R1 — Inventory before interpretation** (Chamberlin's multiple working hypotheses [Ch1890]). When a question reduces to the finite substrate census,
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

**R6a — Measure an assumption's strength; do not describe it.** Zero `sorry` says every goal was
closed and nothing about *what* closed it, so an assumption has to be tested the way a hypothesis is.
The test is one question: **is the interface satisfied by a trivial reading?** Bundle the assumption
into a structure and try to build an instance out of nothing.

The answers sort into kinds that had previously been run together, and the sorting is the point:

| the toy model | reading | what to do |
|---|---|---|
| builds, and the assumption was already superseded | it excludes nothing and something else does the work | **delete it** — an axiom that assumes nothing is not a boundary, it inflates the count while carrying none of the weight |
| builds, but the claim is a real theorem the formalisation cannot state | **cited, not posited** — vacuous *in Lean*, not *in the world*; discharge is labour with a known answer | keep, and label |
| builds, and the intended reading is what nobody has established | the assumption's force is entirely interpretive | keep, and record the measurement beside it so it stops looking like it does work |
| **does not build, because nothing is left to choose** | every object is concrete; the gap is labour, not knowledge | **the standard** — compare new boundaries against it |

Two supporting rules. *Merging assumptions is legitimate only with a proved equivalence* — otherwise
it is a smaller number and the same commitment. And *"construct an inhabitant" does not always
discharge*: a satisfiable interface is evidence only when its instances are hard to come by, so
building the toy is what tells you which case you are in, and there is no way to know in advance.

Read the dependency footprint afterwards rather than trusting the source: an absent `propext` in a
`#print axioms` report is the signature of a pure application — the "theorem" restates its axiom.
Machinery: [`scripts/axiom_audit.sh`](scripts/axiom_audit.sh) pins what exists to be assumed,
[`lean/QLF_AxiomAudit.lean`](lean/QLF_AxiomAudit.lean) reports what the proofs actually consume.

**The rule applies to new work, not only to inherited work** — and that is the part that is easy to
skip. The same pass that removed a vacuous colour claim from the axiom inventory saw one written
back in hours later (`3 = 3` by `rfl`, with prose beside it claiming something the theorem never
touched). The failure mode is always the same shape: **a true statement adjacent to the one you
wanted, asserted as if it were the one you wanted.**

**R7 — State the kill condition first** (Popper's falsifiability [Po59] in Platt's operational
form, strong inference [Pl64]). See §6.

---

## 5. The hypothesis lifecycle

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

## 6. Kill conditions and blind tests

Every substantial conjecture states, **in advance**:

> **Candidate** — the proposed mechanism.
> **Prediction** — what it should produce.
> **Kill condition** — what result would reject it.

And where a battery of cases is run, it is run **blind**: all geometries printed together, no
per-case tuning, with the symmetry-lock check of R3 applied to every agreement before it counts.

---

## 7. The role of the inventory — the apparatus itself

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

## 8. The role of formal proof

Lean is where a pattern becomes knowledge. The standard is:

- **zero `sorry`**, repository-wide;
- where a genuinely unprovable step is needed, an **explicit `axiom`** with a name, a home, and an
  entry in the axiom inventory — never a silent assumption;
- assumptions visible in the statement, so a theorem cannot quietly require more than it says;
- CI is the arbiter: a Lean claim is not a result until the build is green.

Proof does not settle physics on its own. It settles what follows from what, which is the part that
should never be in doubt while the physics is argued.

---

## 9. The role of numerical simulation

Simulation generates candidates and kills them. It does not establish laws. Its outputs are labelled
*exact computational result* (exhaustive/exact over a stated domain) or *numerical evidence*
(suggestive), never *proved*. Every script that claims an invariant asserts it against freshly
computed data, so the claim and its check ship together.

---

## 10. A worked example — attempting to derive quantum weights

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

## 11. Negative results and the correction protocol

> **Corrections remain part of the scientific record.** — the discipline Feynman called the
> "utter honesty" of leaning over backwards to show how you may be wrong [Fe74].

When a better computation overturns an earlier conclusion: update the owning document, state plainly
what failed and why, name the new constraint, and leave the commit history intact. Do not quietly
replace a wrong conclusion with a right one — the audit trail *is* the evidence that the method
works. A rejected route is a result: it removes a possibility, which is exactly what a finite search
needs.

**Where a rejection goes.** A rejection earns a place in a narrative document only when it *changes
what is believed* — it retracts a published claim, or it closes a route the document was still
proposing. Everything else belongs in the commit message, where it stays searchable and dated
without interrupting the argument a reader is following. A tested-and-empty feature scan is a
result; it is not a section.

---

## 12. Reproducibility requirements

Every quantitative claim in this repository must be reproducible from the repository:

- the command that produces it, with its arguments, named in the document that makes the claim;
- exact arithmetic where the result is exact, and the tolerance stated where it is not;
- the domain of the computation stated (which lengths, which capacities, which geometries);
- the proven invariants asserted in the same run that produces the numbers;
- Lean claims green in CI before they are cited.

---

## 13. The current frontier

What the method says is *open* right now, stated as it should be stated:

- the amplitude layer — which contexts carry a convergent unnormalized weight, and why the threshold
  is realized rather than straddled ([`Born_Rule.md`](Born_Rule.md) §8);
- the **context geometry** layer — what substrate object represents a physical orientation, given
  that a word is a history and not a direction;
- the named bridge axioms of the Millennium reformulations, each an *open bridge* by §3.

---

## 14. Where the evidence lives

- [`Experimental_Consistency.md`](Experimental_Consistency.md) — the empirical ledger: matches,
  precisions, and the falsifier classes
- [`Open_Problems.md`](Open_Problems.md) — the status registry, closed / bounded / open
- [`Philosophy.md`](Philosophy.md) — the ontology and the multiplicity method
- [`Mysteries_Of_Physics.md`](Mysteries_Of_Physics.md) — physics-facing triage, including what QLF
  predicts is **absent** (the falsifiable nulls)
- [`lean/README.md`](lean/README.md) — every module and its theorems
- [`census_inventory.py`](census_inventory.py) · [`contextual_census.py`](contextual_census.py) — the
  inventory and the contextual layer

---

## References

**Method.**
[Ch1890] T. C. Chamberlin, *The Method of Multiple Working Hypotheses*, Science **15** (1890) 92 —
hold several hypotheses at once so none becomes a pet; the ancestor of R1.
[Po59] K. Popper, *The Logic of Scientific Discovery* (1959) — a claim earns its status from what
would refute it.
[Pl64] J. R. Platt, *Strong Inference*, Science **146** (1964) 347 — the operational form used here:
enumerate alternatives, design the step that excludes one, iterate.
[Fe74] R. P. Feynman, *Cargo Cult Science*, Caltech commencement address (1974) — leaning over
backwards to report what might be wrong; the correction protocol of §11.
[La78] I. Lakatos, *The Methodology of Scientific Research Programmes* (1978) — progressive versus
degenerating programmes, which is what the status labels of §3 make visible.

**Substrate and computation.**
[Wo02] S. Wolfram, *A New Kind of Science* (2002), and the ruliad program — the
computational-substrate commitment and the enumerate-first practice QLF adopts and then prunes by
ZFA (§2). The convergence table in [`README.md`](README.md) places it among the eighteen independent
programs arriving at an informational, computable, closure-bounded reality.
[Si09] S. G. Simpson, *Subsystems of Second Order Arithmetic* (2nd ed., 2009) — the reverse-math
stratification QLF's core works inside (`RCA₀`), and the conservativity results the continuum
argument cites.

**Information.**
[Sh48] C. E. Shannon, *A Mathematical Theory of Communication*, Bell Syst. Tech. J. **27** (1948)
379 — count/multiplicity information and the finite channel capacity.
[Kr49] L. G. Kraft, MSc thesis, MIT (1949); [McM56] B. McMillan, *Two inequalities implied by unique
decipherability*, IRE Trans. Inf. Theory **2** (1956) 115 — the prefix-free inequality that supplies
the closure-depth measure (`QLF_KraftMeasure`).
[La61] R. Landauer, *Irreversibility and heat generation in the computing process*, IBM J. Res. Dev.
**5** (1961) 183 — the `log 2` erasure quantum.
[Be81] J. D. Bekenstein, *Universal upper bound on the entropy-to-energy ratio*, Phys. Rev. D **23**
(1981) 287 — finite information in a finite region, the realizability bound.
[W90] J. A. Wheeler, *Information, Physics, Quantum: The Search for Links* (1990) — "it from bit",
made constructive in [`Information_Physics.md`](Information_Physics.md).

Sources for the *physics* claims live with the claims, in
[`Experimental_Consistency.md`](Experimental_Consistency.md) and the domain documents; this list
covers only the method and the notions it leans on.

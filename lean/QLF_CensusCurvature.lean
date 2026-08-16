-- QLF_CensusCurvature.lean
-- The census (possibility) graph is triangle-free — and therefore nowhere
-- positively curved.
--
-- QLF carries two graphs, and they are curved by different notions
-- (Curvature.md §1a–§1c):
--
--   * SPACE — the synthesized lattice. Its curvature is HOLONOMY: the
--     plaquette of the one-bit orthogonal axes, `σx σy σx σy = -I ≠ +I`
--     (QLF_GaugeHolonomy, `nonabelian_plaquette`). One bit per fold.
--   * The CENSUS / POSSIBILITY graph — ZFA closure classes joined by the
--     causal parent relation (delete one Hermitian-conjugate pair). Its
--     edges carry no σ at all, so holonomy says nothing about it. Its
--     curvature is TRANSPORT curvature — Ollivier-Ricci,
--     `κ(x,y) = 1 - W₁(mₓ,m_y)/d(x,y)`, a ratio of counts.
--
-- Measured (lepton_blind_classifier.py §K, census to L = 12): every one of
-- 162 interior edges has `κ < 0` — the possibility graph is hyperbolic, the
-- discrete AdS signature. That measurement is a finite truncation. THIS
-- module supplies what the truncation cannot: a structural reason, valid at
-- every length, for the sign never to be positive.
--
-- The core proven here, with no axiom:
--
--   the parent relation deletes exactly two twists
--     ⟹ adjacency changes the length by exactly 2
--     ⟹ the graph is layered (`length % 4` flips across every edge)
--     ⟹ NO TRIANGLES — three mutual neighbours would need three lengths
--        pairwise differing by 2, and no three naturals do.
--
-- One named bridge (`jost_liu_triangle_free`, cited not posited — Jost & Liu
-- 2014) turns triangle-freeness into `κ ≤ 0`, in the same
-- settled-mathematics-QLF-lacks-machinery-for role as `beale_kato_majda` in
-- QLF_NavierStokesBKM. Ollivier-Ricci needs discrete optimal transport,
-- which Mathlib does not carry; the combinatorial hypothesis it consumes is
-- proven here in full.
--
-- Also proven: the parent relation preserves count balance, so the census
-- graph really is a graph ON ZFA closures — every parent of a closure is a
-- closure (`countBalanced_of_isParent`).

import QLF_TwistAlphabet
import Mathlib.Data.Real.Basic

namespace QLF

/-! ## 1. The causal parent relation -/

/-- **`IsParent c p`** — `p` is a causal parent of `c`: `p` is obtained from
    `c` by deleting one Hermitian-conjugate pair `t … conj t`, preserving the
    causal order of everything else. This is exactly
    `conjugate_pair_deletions` in `lepton_blind_classifier.py`: choose
    positions `i < j` with `c[j] = conj c[i]` and drop both. -/
def IsParent (c p : List Twist) : Prop :=
  ∃ (l m r : List Twist) (t : Twist),
    c = l ++ t :: (m ++ Twist.conj t :: r) ∧ p = l ++ m ++ r

/-- Deleting a conjugate pair removes exactly two twists. -/
theorem isParent_length {c p : List Twist} (h : IsParent c p) :
    p.length + 2 = c.length := by
  obtain ⟨l, m, r, t, hc, hp⟩ := h
  subst hc
  subst hp
  simp only [List.length_append, List.length_cons]
  omega

/-! ## 2. Count balance is inherited by parents -/

/-- **The parent of a ZFA closure is a ZFA closure.** Deleting a
    Hermitian-conjugate pair `t … conj t` decrements the counts of `t` and of
    `conj t` by one each — and `t`, `conj t` are the two sides of exactly one
    of the four balance equations, so every equation survives. This is what
    makes the census graph a graph on ZFA closures at all. -/
theorem countBalanced_of_isParent {c p : List Twist}
    (hpar : IsParent c p) (h : countBalanced c) : countBalanced p := by
  obtain ⟨l, m, r, t, hc, hp⟩ := hpar
  subst hc
  subst hp
  cases t <;>
    simp only [countBalanced, Twist.conj, List.count_append,
      List.count_cons] at h ⊢ <;>
    obtain ⟨h1, h2, h3, h4⟩ := h <;>
    omega

/-! ## 3. Census adjacency, and the layering -/

/-- **Census adjacency** — the parent relation, forgotten to a graph. -/
def Adj (a b : List Twist) : Prop := IsParent a b ∨ IsParent b a

/-- Every edge changes the length by exactly two. -/
theorem adj_length {a b : List Twist} (h : Adj a b) :
    b.length + 2 = a.length ∨ a.length + 2 = b.length := by
  rcases h with h | h
  · exact Or.inl (isParent_length h)
  · exact Or.inr (isParent_length h)

/-- **The census graph is layered** — `length % 4` flips across every edge, so
    the graph is bipartite and carries no odd cycle. -/
theorem census_bipartite {a b : List Twist} (h : Adj a b) :
    a.length % 4 ≠ b.length % 4 := by
  have := adj_length h
  omega

/-- No closure is its own parent. -/
theorem adj_irrefl (a : List Twist) : ¬ Adj a a := by
  intro h
  have := adj_length h
  omega

/-! ## 4. Triangle-freeness — the structural core -/

/-- **The census graph is triangle-free.** Three mutually adjacent closures
    would need three lengths that pairwise differ by exactly two; from
    `la - lb = ±2` and `lb - lc = ±2` the difference `la - lc` is `-4`, `0`
    or `4`, never `±2`. No three naturals do it, at any length — so this is
    not a fact about the finite census that was enumerated, but about the
    parent relation itself. -/
theorem census_triangle_free {a b c : List Twist}
    (hab : Adj a b) (hbc : Adj b c) (hca : Adj c a) : False := by
  have h1 := adj_length hab
  have h2 := adj_length hbc
  have h3 := adj_length hca
  omega

/-- The same statement in the shape a curvature theorem consumes. -/
theorem census_no_triangles :
    ∀ a b c : List Twist, Adj a b → Adj b c → Adj c a → False :=
  fun _ _ _ hab hbc hca => census_triangle_free hab hbc hca

/-! ## 5. The transport curvature, and the one cited bridge -/

/-- The **Ollivier-Ricci curvature** of a census edge,
    `κ(x,y) = 1 - W₁(mₓ,m_y)/d(x,y)` — an optimal-transport cost over a graph
    distance, both pure step counts. Opaque here: `W₁` needs discrete optimal
    transport, which Mathlib does not carry. Computed numerically in
    `lepton_blind_classifier.py` §K. -/
axiom ollivierRicci : List Twist → List Twist → ℝ

/-- **Cited, not posited — Jost & Liu (2014).** In a graph with no triangle
    on an edge, the Ollivier-Ricci curvature of that edge is non-positive:
    the upper bound `κ(x,y) ≤ #triangles(x,y) / (dₓ ∨ d_y)` degenerates to
    `κ ≤ 0`. A real theorem of discrete geometry, named as a boundary because
    QLF's Lean carries no optimal-transport machinery — the same role as
    `beale_kato_majda` in `QLF_NavierStokesBKM`, or Wallis/Stirling for `π`.
    Its combinatorial hypothesis is *proven* above (`census_no_triangles`);
    nothing about the census is assumed here. -/
axiom jost_liu_triangle_free :
    (∀ a b c : List Twist, Adj a b → Adj b c → Adj c a → False) →
    ∀ a b : List Twist, Adj a b → ollivierRicci a b ≤ 0

/-- **The possibility graph is nowhere positively curved** — at every length,
    not merely on the finite census that was enumerated. A theorem, from the
    proven triangle-freeness plus the cited Jost-Liu bound.

    Note what this does and does not settle. The numerical result of
    `lepton_blind_classifier.py` §K is strictly stronger where it applies
    (`κ < 0`, strict, on all 162 interior edges) but is bounded by
    truncation; this is weaker (`κ ≤ 0`) and unbounded in scope. Strict
    negativity does **not** follow from triangle-freeness and remains
    numerical. -/
theorem census_nowhere_positively_curved {a b : List Twist} (h : Adj a b) :
    ollivierRicci a b ≤ 0 :=
  jost_liu_triangle_free census_no_triangles a b h

/-- **Summary.** The census graph is layered, triangle-free, irreflexive,
    closed under taking parents within the ZFA closures, and nowhere
    positively curved. -/
theorem census_curvature_summary :
    (∀ a b : List Twist, Adj a b → a.length % 4 ≠ b.length % 4) ∧
    (∀ a b c : List Twist, Adj a b → Adj b c → Adj c a → False) ∧
    (∀ a : List Twist, ¬ Adj a a) ∧
    (∀ c p : List Twist, IsParent c p → countBalanced c → countBalanced p) ∧
    (∀ a b : List Twist, Adj a b → ollivierRicci a b ≤ 0) :=
  ⟨fun _ _ h => census_bipartite h,
   census_no_triangles,
   adj_irrefl,
   fun _ _ hpar h => countBalanced_of_isParent hpar h,
   fun _ _ h => census_nowhere_positively_curved h⟩

end QLF

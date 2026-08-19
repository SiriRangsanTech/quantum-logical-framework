/-
  QLF_ToolchainProbe.lean — TEMPORARY. Checks CLAUDE.md's "Lean 4.30 gotchas" against the
  toolchain we actually build with (issue #146). Delete once the results are recorded.

  Deliberately NOT in the lakefile roots array: `lake build` ignores it, and CI runs it
  standalone with `|| true`, so the errors below ARE the report rather than a broken build.
  Each block states what CLAUDE.md claims; the log says whether the claim still holds.
-/

-- Wholesale, deliberately. The first attempt imported four specific modules and died on
-- `Mathlib.Algebra.BigOperators.Basic`, which no longer exists — so elaboration stopped at
-- the imports and not one gotcha was tested. A probe must not be blocked by the very kind
-- of staleness it exists to find. (That dead path is itself a result: another rule of the
-- same family as gotcha 10.)
import Mathlib

/-! ## Gotcha 1 — `private noncomputable def`, in that order.
    Claim: the reverse order is rejected, and `1/2 : ℝ` needs `noncomputable`. -/

private noncomputable def probe_order_ok : ℝ := 1 / 2
noncomputable private def probe_order_reversed : ℝ := 1 / 2
private def probe_half_without_noncomputable : ℝ := 1 / 2

/-! ## Gotcha 2 — `Matrix.conjTranspose`, not `Matrix.adjoint`. -/

#check @Matrix.conjTranspose
#check @Matrix.adjoint

/-! ## Gotcha 4 — `∑ k ∈ ...`, not `∑ k in ...`. -/

example : (∑ k ∈ Finset.range 3, k) = 3 := by decide
example : (∑ k in Finset.range 3, k) = 3 := by decide

/-! ## Gotcha 6 — `List.mem_cons_self` deprecated in favour of `List.Mem.head _`;
    `List.mem_cons_of_mem _ h` in favour of `List.Mem.tail _ h`.
    A deprecation warning in the log confirms the claim; silence means it was un-deprecated
    or never was; an error means the constant is gone. -/

#check @List.mem_cons_self
#check @List.mem_cons_of_mem
#check @List.Mem.head
#check @List.Mem.tail

/-! ## Gotcha 11 — `prefix` is a keyword, so it cannot be a parameter name. -/

def probe_prefix_as_name (prefix : Nat) : Nat := prefix

/-! ## Gotcha 12 — `Nat.toReal` does not exist; use `(↑n : ℝ)`. -/

#check @Nat.toReal
example (n : ℕ) : ℝ := (↑n : ℝ)

/-! ## Existence sweep — reports rather than fails, so nothing here can hide a result. -/

open Lean Elab Command in
run_cmd do
  let env ← getEnv
  for n in [`Matrix.conjTranspose, `Matrix.adjoint, `Nat.toReal, `List.mem_cons_self,
            `List.mem_cons_of_mem, `List.Mem.head, `List.Mem.tail,
            `Mathlib.LinearAlgebra.Matrix.Determinant] do
    logInfo m!"GOTCHA-PROBE {n} : {if env.contains n then "EXISTS" else "MISSING"}"

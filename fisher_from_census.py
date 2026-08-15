#!/usr/bin/env python3
"""
fisher_from_census.py — the Fisher–Rao metric as the curvature of the census KL.

A step toward issue #142 (Fisher information from the census). QLF does not
postulate an information geometry; it has the census **relative entropy**
`binary_kl` machine-checked (`QLF_FreeEnergy`, `binary_kl_delta_uniform`,
`binary_kl_uniform_lt_log_two`). The Fisher information metric is *by definition*
the second-order (local) form of a KL divergence:

    g(θ) = ∂²/∂θ'²  D_KL(θ' ‖ θ)  at θ' = θ  =  1 / (θ(1−θ))     (binary case)

So the Fisher–Rao metric of the census's Bernoulli(θ) step is **already present**
as the curvature of the KL divergence QLF uses — not an added structure. This
tool shows that numerically, three ways, and ties it to the balanced/MRE point
θ = ½ (the critical-line prior), where g(½) = 4.

It also shows the census WALK accumulating the metric: N Bernoulli steps carry
Fisher information N·g(θ) (exact binomial), and the Gaussian continuum limit
preserves the same leading metric — the "emerges in the n→∞ limit" claim, at the
level of the metric.

HONEST SCOPE: this demonstrates the *metric* is the census-KL curvature; the full
information-geometry manifold as the census continuum limit (and the distributional
`−Σ p log p` uniqueness beyond `QLF_EntropyUniqueness`) is the remaining open work
(#142). No deps.  Run:  python3 fisher_from_census.py
"""
import math
from math import comb


def binary_kl(q: float, p: float) -> float:
    """Census relative entropy D_KL((q,1−q) ‖ (p,1−p)), matching QLF_FreeEnergy
    (0·log 0 = 0 convention via the guarded terms)."""
    t1 = q * math.log(q / p) if q > 0 else 0.0
    t2 = (1 - q) * math.log((1 - q) / (1 - p)) if q < 1 else 0.0
    return t1 + t2


def fisher_analytic(theta: float) -> float:
    """Fisher–Rao metric of Bernoulli(θ)."""
    return 1.0 / (theta * (1 - theta))


def fisher_from_kl_curvature(theta: float, h: float = 1e-4) -> float:
    """g(θ) = ∂²/∂θ'² D_KL(θ'‖θ) at θ'=θ, by central finite difference —
    i.e. the curvature of the census KL divergence itself."""
    f = lambda x: binary_kl(x, theta)
    return (f(theta + h) - 2 * f(theta) + f(theta - h)) / h**2


def fisher_binomial_exact(theta: float, N: int) -> float:
    """Exact Fisher information about θ in N census steps (endpoint ~ Binomial(N,θ)):
    I_N(θ) = Σ_k p_k · (∂_θ log p_k)²  =  N / (θ(1−θ)). Computed from the sum."""
    tot = 0.0
    for k in range(N + 1):
        p = comb(N, k) * theta**k * (1 - theta) ** (N - k)
        if p <= 0:
            continue
        dlog = k / theta - (N - k) / (1 - theta)      # ∂_θ log p_k
        tot += p * dlog**2
    return tot


def main() -> None:
    print(__doc__.strip().split("\n\n")[0])
    print()

    print("1. The metric IS the census-KL curvature (g(θ) = Hessian of D_KL at θ):")
    print(f"   {'θ':>6}  {'analytic 1/(θ(1−θ))':>20}  {'∂²D_KL/∂θ² (census KL)':>24}")
    for theta in (0.1, 0.25, 0.5, 0.75, 0.9):
        print(f"   {theta:>6.2f}  {fisher_analytic(theta):>20.5f}  {fisher_from_kl_curvature(theta):>24.5f}")
    print("   → they match: the Fisher–Rao metric is the curvature of the KL QLF already has.\n")

    print("2. The balanced / MRE point θ = ½ (the critical-line prior):")
    g = fisher_analytic(0.5)
    print(f"   g(½) = 4;  and near ½ the census KL is locally quadratic:")
    for d in (0.05, 0.02, 0.01):
        approx = 0.5 * g * d * d                       # ½ g (Δθ)²
        exact = binary_kl(0.5 + d, 0.5)
        print(f"     Δθ={d:>4}:  D_KL(½+Δθ ‖ ½) = {exact:.6f}   ½·g·Δθ² = {approx:.6f}")
    print(f"   → D_KL(1 ‖ ½) = log 2 = {math.log(2):.5f} is the *global* MRE bound (QLF_FreeEnergy);")
    print("     g(½)=4 is its *local* curvature — the Fisher metric at the balanced prior.\n")

    print("3. The census WALK accumulates the metric: N steps carry Fisher info N·g(θ).")
    print(f"   {'N':>4}  {'exact I_N(½)':>14}  {'N·g(½)=4N':>10}")
    for N in (1, 4, 16, 64):
        print(f"   {N:>4}  {fisher_binomial_exact(0.5, N):>14.4f}  {4*N:>10}")
    print("   → exact binomial Fisher = N·g(θ); the continuum (Gaussian endpoint) limit")
    print("     preserves the same leading metric. Fisher geometry is the census's own,")
    print("     not postulated — the open piece (#142) is the full continuum manifold.")


if __name__ == "__main__":
    main()

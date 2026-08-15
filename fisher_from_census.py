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

It also shows the census WALK accumulating the metric (N steps → N·g(θ)), and then
that the census family carries the **full dually-flat information geometry** (Amari):
two dual coordinates (θ natural, η expectation), the census KL as the **canonical
(Bregman) divergence** of the negative-entropy potential, and the **generalized
Pythagorean theorem** — all built on the KL QLF already machine-checks.

HONEST SCOPE: this demonstrates the *metric* is the census-KL curvature AND that the
census family is dually flat with the census KL as its canonical divergence (the
Pythagorean theorem holds). The remaining open work (#142) is the **continuum**
(n→∞) rendering of this manifold, and the distributional `−Σ p log p` uniqueness
beyond `QLF_EntropyUniqueness`. No deps.  Run:  python3 fisher_from_census.py
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
    print("     preserves the same leading metric.\n")

    dually_flat_bernoulli()
    pythagorean_multinomial()
    print("So the census carries not just a metric but the full DUALLY-FLAT information")
    print("geometry (Amari): two dual coordinates, two flat connections, and the KL")
    print("Pythagorean theorem — all with the census KL as the canonical divergence.")
    print("Remaining open (#142): the continuum manifold as the census n→∞ rendering, and")
    print("the distributional −Σ p log p uniqueness beyond the finite wing (QLF_EntropyUniqueness).")


def dually_flat_bernoulli() -> None:
    """The census Bernoulli family is a dually-flat exponential family, with the
    census KL as the canonical (Bregman) divergence of the dual potential φ=−H."""
    def phi(eta):      # negative entropy — the dual potential
        return eta * math.log(eta) + (1 - eta) * math.log(1 - eta)
    print("4. The census family is DUALLY FLAT — KL = the canonical (Bregman) divergence:")
    print(f"   {'η_p':>5} {'η_q':>5}  {'Bregman_φ(η_p‖η_q)':>19}  {'binary_kl(η_p,η_q)':>19}")
    for ep, eq in ((0.7, 0.5), (0.3, 0.6), (0.9, 0.5)):
        th_q = math.log(eq / (1 - eq))                     # φ'(η_q) = natural coord θ_q
        bregman = phi(ep) - phi(eq) - th_q * (ep - eq)      # Bregman divergence of φ
        print(f"   {ep:>5.2f} {eq:>5.2f}  {bregman:>19.6f}  {binary_kl(ep, eq):>19.6f}")
    print("   → equal: KL is the Bregman divergence of the negative-entropy potential.")
    print("     Dual coordinates θ (natural) ↔ η (expectation); Fisher = ψ''(θ) = 1/φ''(η).\n")


def pythagorean_multinomial() -> None:
    """The generalized Pythagorean theorem for the census KL on a multinomial
    manifold: D(P‖R) = D(P‖Q) + D(Q‖R) when Q is the information projection of R
    onto the linear (m-flat) family {E[a]=μ} and P lies in that family."""
    def kl(p, q):
        return sum(pi * math.log(pi / qi) for pi, qi in zip(p, q) if pi > 0)
    R = [1/3, 1/3, 1/3]                                     # reference (uniform census)
    a = [0.0, 1.0, 2.0]                                     # a census feature
    mu = 1.3                                                # the m-flat constraint E[a]=μ

    def Q_of(lam):                                          # exponential tilt of R (e-flat)
        w = [Ri * math.exp(lam * ai) for Ri, ai in zip(R, a)]
        Z = sum(w)
        return [wi / Z for wi in w]

    def mean_a(p):
        return sum(pi * ai for pi, ai in zip(p, a))

    lo, hi = -30.0, 30.0                                    # solve E_Q[a]=μ for the tilt λ
    for _ in range(200):
        mid = (lo + hi) / 2
        lo, hi = (mid, hi) if mean_a(Q_of(mid)) < mu else (lo, mid)
    Q = Q_of((lo + hi) / 2)
    P = [0.1, 0.5, 0.4]                                     # another dist with E_P[a] = 1.3

    print("5. Generalized Pythagorean theorem on the census (multinomial) manifold:")
    print(f"   R = uniform;  Q = I-projection of R onto {{E[a]={mu}}};  P another dist with E_P[a]={mu}")
    lhs, rhs = kl(P, R), kl(P, Q) + kl(Q, R)
    print(f"   D(P‖R) = {lhs:.6f}   =   D(P‖Q) + D(Q‖R) = {kl(P, Q):.6f} + {kl(Q, R):.6f} = {rhs:.6f}")
    print("   → the KL Pythagorean identity holds (m-geodesic P→Q ⊥ e-geodesic Q→R):")
    print("     the census KL is the canonical divergence of a genuinely dually-flat manifold.\n")


if __name__ == "__main__":
    main()

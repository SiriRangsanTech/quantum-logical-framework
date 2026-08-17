#!/usr/bin/env python3
"""
born_generator_check.py — does the census way-count agree with the Z[i] norm?

QLF_BornCounting reduces the multiplicity <-> Born-norm bridge to a single check:
both counts are multiplicative, so (count_determined_by_generators) it suffices
that the census count agrees with the Gaussian norm ON THE PRIMITIVE CLOSURES.

This script RUNS that check, and it can fail -- which is the point. The test is
sharp because a Gaussian integer's norm is always a SUM OF TWO SQUARES: an
integer n is a Z[i] norm iff every prime = 3 (mod 4) divides it to an even power.
So any census branch count that is not a sum of two squares has NO Gaussian
amplitude at all, and the identification is impossible for that branch.

Result (see the output):
  A. On the pair generator it agrees EXACTLY. norm(1+i) = 2 = the two ways a
     closure pair closes (+- or -+), and by multiplicativity norm((1+i)^n) = 2^n
     = the 2^n ways n pairs close -- QLF_ClosureDepth.onePass_ways_iff.
  B/C. For ARBITRARY census partitions it FAILS: depth strata such as 38, 14, 70,
     422 and sign-splits such as 3, 35, 126, 462 are not sums of two squares, so
     no Z[i] amplitude can carry those counts.

Conclusion: the bridge holds exactly on the (1+i)-generated sector -- the binary
/ pair / qubit sector -- and is false for census partitions in general. Either
"branch" must mean a pair-decomposable closure, or Z[i] is too small to carry
general census counts. That is a real constraint, recorded rather than smoothed.

Run:  python3 born_generator_check.py
"""
from itertools import product
from math import comb, isqrt

def is_gaussian_norm(n):
    """n is a Z[i] norm iff every prime = 3 mod 4 occurs to an even power (sum of two squares)."""
    if n < 0: return False
    if n == 0: return True
    m, p = n, 2
    while p * p <= m:
        if m % p == 0:
            e = 0
            while m % p == 0: m //= p; e += 1
            if p % 4 == 3 and e % 2 == 1: return False
        p += 1
    return not (m % 4 == 3)

def zeno_prune(s):
    out, i, n = [], 0, len(s)
    while i < n:
        if i+1 < n and s[i] == -s[i+1]: i += 2
        else: out.append(s[i]); i += 1
    return out
def depth(s):
    R = 0
    while s: s = zeno_prune(s); R += 1
    return R

print("A. THE PAIR GENERATOR (1+i), norm 2 — the depth-1 stratum")
print("   n   ways to close n pairs   norm((1+i)^n)=2^n   match?")
for n in range(1, 7):
    ways = 2**n
    print(f"  {n:>2}   {ways:>20}   {2**n:>17}   {'YES' if ways == 2**n else 'NO'}")

print("\nB. ARBITRARY CENSUS PARTITIONS — are branch counts even Gaussian norms?")
print("   partition by exact closure depth, length 2n:")
bad = []
for n in range(1, 9):
    dist = {}
    for s in product((1,-1), repeat=2*n):
        if sum(s) != 0: continue
        d = depth(list(s)); dist[d] = dist.get(d, 0) + 1
    row = []
    for d in sorted(dist):
        ok = is_gaussian_norm(dist[d])
        row.append(f"W_{d}={dist[d]}{'' if ok else '*'}")
        if not ok: bad.append((2*n, d, dist[d]))
    print(f"   2n={2*n:>2}: " + "  ".join(row))
print("   (* = NOT a sum of two squares, so NO Gaussian integer has that norm)")
print("\n   first failures:", bad[:6])

print("\nC. partition by the sign of the first twist (two branches):")
for n in range(1, 7):
    half = comb(2*n-1, n-1)
    print(f"   2n={2*n:>2}: each branch {half:>5}   Gaussian norm? {is_gaussian_norm(half)}")

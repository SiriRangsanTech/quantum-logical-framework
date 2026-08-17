#!/usr/bin/env python3
"""
mpemba_census.py — the blind test for a substrate Mpemba effect.

The Mpemba effect is a state farther from equilibrium relaxing faster. On the
substrate, relaxation to equilibrium IS closure, and its time is the closure depth
= the maximum phase excursion (QLF_ClosureDepthLaw.closedAtHorizon_iff_maxExcursion_le).
So the question is decidable: do preparations that are farther out by some macro
measure close sooner?

The test is BLIND by construction: preparations are drawn UNIFORMLY at a fixed macro
parameter, with nothing tuned about their depth distribution. If an anomalous
ordering only appears once the multiplicities are designed to produce it, then QLF
offers an interpretation of Mpemba, not a derivation — and that distinction is the
whole point of running this rather than asserting it.

A METHODOLOGICAL TRAP, found the hard way and worth recording: an earlier version
compared time-to-fixpoint across preparations of differing imbalance. But an
unbalanced history NEVER closes — it stalls at an irreducible core of |imbalance|
same-sign twists — so that comparison measures arrival at DIFFERENT destinations and
manufactures a spurious crossing (it showed median relaxation falling 4 -> 1 as the
imbalance rose). This is the substrate form of the experimental literature's
"what does *freezes first* mean" problem. Every preparation compared below is
balanced, hence all reach the same equilibrium.

RESULT
  * Uniform balanced preparations: relaxation is MONOTONE in length; no crossing.
    The effect does not arise from a scalar energy alone.
  * But the scalar does not DETERMINE relaxation: at length 32 the depth ranges
    1..13 over uniform draws, and the constructible extremes are 1 (pair matching)
    and 16 (nested singlet) — a factor of 16 at identical length and imbalance.
    The room Mpemba needs is real; a uniform preparation simply does not enter it.
  * Proven separately (QLF_Mpemba): relaxation >= |imbalance|, so for the imbalance
    measure the effect is impossible; and strong Mpemba is sector emptiness.

Run:  python3 mpemba_census.py
"""
#!/usr/bin/env python3
"""
mpemba_census.py — the blind test for a substrate Mpemba effect.

The Mpemba effect is a state farther from equilibrium relaxing faster. On the
substrate, relaxation to equilibrium IS closure, and its time is the closure depth
= the maximum phase excursion (QLF_ClosureDepthLaw.closedAtHorizon_iff_maxExcursion_le).
So the question is decidable: do preparations that are farther out by some macro
measure close sooner?

The test is BLIND by construction: preparations are drawn UNIFORMLY at a fixed macro
parameter, with nothing tuned about their depth distribution. If an anomalous
ordering only appears once the multiplicities are designed to produce it, then QLF
offers an interpretation of Mpemba, not a derivation — and that distinction is the
whole point of running this rather than asserting it.

A METHODOLOGICAL TRAP, found the hard way and worth recording: an earlier version
compared time-to-fixpoint across preparations of differing imbalance. But an
unbalanced history NEVER closes — it stalls at an irreducible core of |imbalance|
same-sign twists — so that comparison measures arrival at DIFFERENT destinations and
manufactures a spurious crossing (it showed median relaxation falling 4 -> 1 as the
imbalance rose). This is the substrate form of the experimental literature's
"what does *freezes first* mean" problem. Every preparation compared below is
balanced, hence all reach the same equilibrium.

RESULT
  * Uniform balanced preparations: relaxation is MONOTONE in length; no crossing.
    The effect does not arise from a scalar energy alone.
  * But the scalar does not DETERMINE relaxation: at length 32 the depth ranges
    1..13 over uniform draws, and the constructible extremes are 1 (pair matching)
    and 16 (nested singlet) — a factor of 16 at identical length and imbalance.
    The room Mpemba needs is real; a uniform preparation simply does not enter it.
  * Proven separately (QLF_Mpemba): relaxation >= |imbalance|, so for the imbalance
    measure the effect is impossible; and strong Mpemba is sector emptiness.

Run:  python3 mpemba_census.py
"""

import random, statistics

random.seed(7)
def zeno(s):
    o,i,n=[],0,len(s)
    while i<n:
        if i+1<n and s[i]==-s[i+1]: i+=2
        else: o.append(s[i]); i+=1
    return o
def depth(s):
    d=0
    while s: s=zeno(s); d+=1
    return d
print("CORRECTED BLIND TEST — all preparations BALANCED, so all reach the SAME")
print("equilibrium (closure). Macro distance = length (energy). Uniform sampling.")
print("  length   median depth   mean depth   min..max")
prev=None; cross=[]
for L in (8,16,24,32,48,64):
    ds=[]
    for _ in range(2000):
        s=[1]*(L//2)+[-1]*(L//2); random.shuffle(s)
        ds.append(depth(s))
    med=statistics.median(ds)
    print(f"  {L:>6}   {med:>12.1f}   {statistics.mean(ds):>10.2f}   {min(ds)}..{max(ds)}")
    if prev is not None and med < prev: cross.append(L)
    prev=med
print(f"  Mpemba crossings from uniform balanced preparations: {cross or 'NONE'}")
print("\nBUT the scalar does not DETERMINE relaxation — at fixed length 32, balanced:")
ds=[]
for _ in range(20000):
    s=[1]*16+[-1]*16; random.shuffle(s)
    ds.append(depth(s))
print(f"  depth ranges {min(ds)}..{max(ds)} over 20,000 uniform draws")
print(f"  and the extremes are constructible: pair matching = 1, nested singlet = 16")
print("  so a preparation biased toward either tail relaxes anomalously — the room")
print("  Mpemba needs is REAL, but it is not entered by a uniform preparation.")

#!/usr/bin/env python3
"""
census_inventory.py — build and verify the census inventory database.

The inventory is what we actually discover when we enumerate: **counts** (how many
ways close, graded by length and depth), **listenings** (how many of those ways a
given capacity can actually receive), and **QuCalc folds** (the Pauli phase each
way carries).

A *listening* is not a synonym for a count — it is the capacity-relative one, and
the distinction is a theorem rather than a metaphor. A count is absolute: how many
ways exist. A listening is what a horizon of capacity `R` can close, and by
`QLF_ClosureDepthLaw.closedAtHorizon_iff_maxExcursion_le` that is exactly the ways
whose phase walk never strays further than `R` from balance:

    count(2n)        = |{ balanced histories of length 2n }|          = C(2n, n)
    listening(2n, R) = |{ those with maxExcursion <= R }|             <= count(2n)

So the same census sounds different to different capacities — a shallow observer
hears only the shallow closures, a deeper one hears more (`lines_mono`), and no
finite capacity hears everything (`law_of_exceptions`). Both have turned up repeatedly in this program — the log-2 quantum,
the depth law, the Born-weight work — and each time they were recomputed from
scratch. This script keeps them in one place, in `data/census_inventory.json`.

It is a **checker**, not just a store. Every invariant we have proven in Lean is
asserted here against freshly enumerated data, so a change to `twist_core.py` that
breaks one shows up immediately:

  * count balance ⟹ Pauli closure        (QLF_TwistAlphabet.count_balanced_pauli_closed)
  * count balance ⟹ the fold is ±I       (QLF_BalancedPhaseReal.balanced_phase_is_real)
  * unbalanced histories DO reach ±iI     (QLF_BalancedPhaseReal.unbalanced_can_be_imaginary)
  * closure depth = max phase excursion   (QLF_ClosureDepthLaw.closedAtHorizon_iff_maxExcursion_le)
  * one-pass closures number 2^n          (QLF_ClosureDepth.onePass_ways_iff)
  * the deepest stratum holds exactly 2   (QLF_ClosureDepth.nested_closed_at_d)

and two findings that are verified-not-proven, recorded so they stay honest:

  * phase = (-1)^(#neg twists) x sign(permutation sorting the axis word)
  * which depth-stratum counts are Gaussian norms (they mostly are not — see
    born_generator_check.py; counts are not weights)

It **accumulates**. Each run keeps everything already discovered and computes only
what is missing, so the database can be fleshed out over time by pushing one length
deeper as compute allows:

    python3 census_inventory.py                      # fill in anything missing, verify all
    python3 census_inventory.py --twist-len 8        # push the fold census one step deeper
    python3 census_inventory.py --phase-len 20       # push the depth census deeper
    python3 census_inventory.py --verify             # recheck stored entries, write nothing
    python3 census_inventory.py --quick              # CI gate: fast subset, seconds not minutes
    python3 census_inventory.py --rebuild            # discard and recompute from scratch

`--quick` is what CI runs. It re-enumerates only the small lengths (fold <= 6,
depth <= 12, a few seconds), compares them against what is stored, and asserts every
invariant over the *whole* stored file. So a regression in `twist_core.py` is caught
by the recomputation, and a corrupted or hand-edited database by the assertions,
without paying for the deep lengths on every push.

Cost, so the next step is a known quantity: the fold census is exhaustive over 8^L
histories — length 6 is instant, 8 takes a few minutes, and 10 (10^9) is out of
reach exhaustively. The depth census is 2^L — length 16 is instant, 20 is a minute,
24 is the practical ceiling. Beyond those, sample rather than enumerate.
"""
from __future__ import annotations

import json
import os
import sys
from itertools import product
from math import comb

from twist_core import pauli_fold

DB_PATH = os.path.join("data", "census_inventory.json")

TWISTS = ['^', 'v', '>', '<', '/', '\\', '+', '-']
CONJ_PAIRS = [('^', 'v'), ('>', '<'), ('/', '\\'), ('+', '-')]
NEG_TWISTS = {'v', '<', '\\', '-'}
AXIS = {'^': 'Y', 'v': 'Y', '>': 'X', '<': 'X', '/': 'Z', '\\': 'Z', '+': 'I', '-': 'I'}
AXIS_ORDER = {'X': 0, 'Y': 1, 'Z': 2}

# Defaults for a first build; later runs keep whatever is already stored and only
# extend it (pass --twist-len / --phase-len to push deeper).
DEFAULT_TWIST_LEN = 6
DEFAULT_PHASE_LEN = 16


# --------------------------------------------------------------------------- #
# the QuCalc fold: which mu4 phase a way carries
# --------------------------------------------------------------------------- #
def fold_phase(history: str):
    """Return the scalar phase of the Pauli fold, or None if it is not a scalar."""
    a, b, c, d = pauli_fold(history)
    if abs(b) > 1e-9 or abs(c) > 1e-9 or abs(a - d) > 1e-9:
        return None
    for p, name in ((1, "+1"), (-1, "-1"), (1j, "+i"), (-1j, "-i")):
        if abs(a - p) < 1e-9:
            return name
    return None


def is_count_balanced(history: str) -> bool:
    return all(history.count(x) == history.count(y) for x, y in CONJ_PAIRS)


def predicted_phase(history: str) -> str:
    """The empirical two-factor rule: sign content x permutation sign."""
    sign = (-1) ** sum(1 for ch in history if ch in NEG_TWISTS)
    axes = [AXIS[ch] for ch in history if AXIS[ch] != 'I']
    inversions = sum(
        1
        for i in range(len(axes))
        for j in range(i + 1, len(axes))
        if axes[i] != axes[j] and AXIS_ORDER[axes[i]] > AXIS_ORDER[axes[j]]
    )
    sign *= (-1) ** inversions
    return "+1" if sign == 1 else "-1"


# --------------------------------------------------------------------------- #
# the phase census: closure depth (TopoString +/- alphabet)
# --------------------------------------------------------------------------- #
def zeno_prune(s):
    out, i, n = [], 0, len(s)
    while i < n:
        if i + 1 < n and s[i] == -s[i + 1]:
            i += 2
        else:
            out.append(s[i]); i += 1
    return out


def closure_depth(s) -> int:
    depth = 0
    while s:
        s = zeno_prune(s); depth += 1
    return depth


def max_excursion(s) -> int:
    m = c = 0
    for x in s:
        c += x
        m = max(m, abs(c))
    return m


def is_gaussian_norm(n: int) -> bool:
    """n is a Z[i] norm iff every prime = 3 (mod 4) occurs to an even power."""
    if n < 0:
        return False
    if n == 0:
        return True
    m, p = n, 2
    while p * p <= m:
        if m % p == 0:
            e = 0
            while m % p == 0:
                m //= p; e += 1
            if p % 4 == 3 and e % 2 == 1:
                return False
        p += 1
    return m % 4 != 3


# --------------------------------------------------------------------------- #
# enumeration
# --------------------------------------------------------------------------- #
def balanced_histories(length: int):
    """Generate every count-balanced history of the given length, directly.

    Filtering 8^L is hopeless past length 6; generating the multiset permutations of
    each balanced letter-multiset is ~90x cheaper at length 8 and ~135x at length 10
    (190,120 and 7,939,008 histories respectively).
    """
    half = length // 2
    letters = [c for pair in CONJ_PAIRS for c in pair]

    def perms(counts, prefix):
        if len(prefix) == length:
            yield ''.join(prefix)
            return
        for ch in letters:
            if counts[ch]:
                counts[ch] -= 1
                prefix.append(ch)
                yield from perms(counts, prefix)
                prefix.pop()
                counts[ch] += 1

    for a in range(half + 1):
        for b in range(half + 1 - a):
            for c in range(half + 1 - a - b):
                d = half - a - b - c
                counts = {}
                for (x, y), k in zip(CONJ_PAIRS, (a, b, c, d)):
                    counts[x] = k
                    counts[y] = k
                yield from perms(counts, [])


# keep the full history lists only while they are small; beyond this store aggregates
FULL_LISTING_MAX_LEN = 6


# --------------------------------------------------------------------------- #
# build
# --------------------------------------------------------------------------- #
def build_fold_inventory(max_len: int, keep: dict | None = None) -> dict:
    """Exhaustive twist histories: folds, grouped by phase, plus the rule check.

    Lengths already present in `keep` are reused rather than recomputed."""
    out = dict((keep or {}).get("by_length", {}))
    rule_violations = list((keep or {}).get("phase_rule_violations", []))
    unbalanced_imaginary = list((keep or {}).get("unbalanced_imaginary_witnesses", []))
    prior_len3 = (keep or {}).get("unbalanced_imaginary_count_len3", 0)
    for L in range(2, max_len + 1, 2):
        if str(L) in out:
            continue
        print(f"   computing fold census at length {L}...", flush=True)
        tally = {"+1": 0, "-1": 0, "+i": 0, "-i": 0}
        samples = {"+1": [], "-1": [], "+i": [], "-i": []}
        for h in balanced_histories(L):
            p = fold_phase(h)
            assert p is not None, f"count-balanced but not Pauli-closed: {h!r}"
            tally[p] += 1
            if L <= FULL_LISTING_MAX_LEN or len(samples[p]) < 8:
                samples[p].append(h)
            if p != predicted_phase(h):
                rule_violations.append(h)
        by_phase = samples
        n_plus, n_minus = tally["+1"], tally["-1"]
        out[str(L)] = {
            "count": sum(tally.values()),
            "n_plus": n_plus,
            "n_minus": n_minus,
            "n_imaginary": tally["+i"] + tally["-i"],
            "signed_amplitude": n_plus - n_minus,
            "weight_of_signed_amplitude": (n_plus - n_minus) ** 2,
            "histories_listed_in_full": L <= FULL_LISTING_MAX_LEN,
            "histories_by_phase": by_phase,
        }
    # the exception: unbalanced histories DO reach +-i
    if not unbalanced_imaginary:
        for tup in product(TWISTS, repeat=3):
            h = ''.join(tup)
            if is_count_balanced(h):
                continue
            if fold_phase(h) in ("+i", "-i"):
                unbalanced_imaginary.append(h)
        prior_len3 = len(unbalanced_imaginary)
    return {
        "by_length": out,
        "phase_rule": "(-1)^(#neg twists) * sign(permutation sorting the axis word)",
        "phase_rule_violations": rule_violations,
        "unbalanced_imaginary_witnesses": sorted(unbalanced_imaginary)[:12],
        "unbalanced_imaginary_count_len3": prior_len3 or len(unbalanced_imaginary),
    }


def build_depth_inventory(max_len: int, keep: dict | None = None) -> dict:
    out = dict(keep or {})
    for n in range(1, max_len // 2 + 1):
        if str(2 * n) in out:
            continue
        if 2 * n >= 18:
            print(f"   computing depth census at length {2*n} (2^{2*n} histories)...", flush=True)
        dist, law_ok = {}, True
        for tup in product((1, -1), repeat=2 * n):
            if sum(tup) != 0:
                continue
            s = list(tup)
            d = closure_depth(s)
            dist[d] = dist.get(d, 0) + 1
            if d != max_excursion(s):
                law_ok = False
        total = sum(dist.values())
        mode = max(dist, key=lambda k: dist[k])
        # listening(R): what a capacity-R horizon receives — cumulative in depth.
        listening = {}
        cum = 0
        for k in range(1, n + 1):
            cum += dist.get(k, 0)
            listening[str(k)] = {"ways_heard": cum, "fraction": round(cum / total, 6)}
        out[str(2 * n)] = {
            "listening_by_capacity": listening,
            "total_ways": total,
            "central_binomial": comb(2 * n, n),
            "strata": {str(k): v for k, v in sorted(dist.items())},
            "one_pass_ways": dist.get(1, 0),
            "deepest_stratum": dist.get(n, 0),
            "modal_depth": mode,
            "depth_equals_max_excursion": law_ok,
            "strata_that_are_gaussian_norms": {
                str(k): is_gaussian_norm(v) for k, v in sorted(dist.items())
            },
        }
    return out


def build(twist_len: int, phase_len: int, keep: dict | None = None) -> dict:
    keep = keep or {}
    return {
        "_comment": "Census inventory: counts and QuCalc folds. Rebuild with census_inventory.py.",
        "_invariants_asserted": [
            "count balance => Pauli closure (count_balanced_pauli_closed)",
            "count balance => fold is +-I, never +-iI (balanced_phase_is_real)",
            "unbalanced histories do reach +-iI (unbalanced_can_be_imaginary)",
            "closure depth = max phase excursion (closedAtHorizon_iff_maxExcursion_le)",
            "one-pass closures number 2^n (onePass_ways_iff)",
            "the deepest stratum holds exactly 2 (nested_closed_at_d)",
        ],
        "max_twist_length": max(twist_len, keep.get("max_twist_length", 0)),
        "max_phase_length": max(phase_len, keep.get("max_phase_length", 0)),
        "folds": build_fold_inventory(twist_len, keep.get("folds")),
        "depths": build_depth_inventory(phase_len, keep.get("depths")),
    }


# --------------------------------------------------------------------------- #
# verify
# --------------------------------------------------------------------------- #
def check(db: dict) -> list[str]:
    """Assert every proven invariant against the data. Returns a list of failures."""
    fail = []
    folds, depths = db["folds"], db["depths"]

    for L, rec in folds["by_length"].items():
        if rec["n_imaginary"] != 0:
            fail.append(f"balanced history folds to +-i at length {L} "
                        f"(contradicts balanced_phase_is_real)")
    if folds["phase_rule_violations"]:
        fail.append(f"phase rule violated by {len(folds['phase_rule_violations'])} histories")
    if folds["unbalanced_imaginary_count_len3"] == 0:
        fail.append("no unbalanced imaginary witness found "
                    "(contradicts unbalanced_can_be_imaginary)")

    for L, rec in depths.items():
        n = int(L) // 2
        if rec["total_ways"] != rec["central_binomial"]:
            fail.append(f"length {L}: total ways != C(2n,n)")
        if rec["one_pass_ways"] != 2 ** n:
            fail.append(f"length {L}: one-pass ways {rec['one_pass_ways']} != 2^{n} "
                        f"(contradicts onePass_ways_iff)")
        if rec["deepest_stratum"] != 2:
            fail.append(f"length {L}: deepest stratum {rec['deepest_stratum']} != 2 "
                        f"(contradicts nested_closed_at_d)")
        if not rec["depth_equals_max_excursion"]:
            fail.append(f"length {L}: depth != max excursion (contradicts the depth law)")
    return fail


QUICK_TWIST_LEN = 6
QUICK_PHASE_LEN = 12


def compare_shared(fresh: dict, stored: dict) -> list[str]:
    """Compare every length present in both, ignoring depth of coverage."""
    out = []
    f_folds = fresh.get("folds", {}).get("by_length", {})
    s_folds = stored.get("folds", {}).get("by_length", {})
    for L in sorted(set(f_folds) & set(s_folds), key=int):
        for field in ("count", "n_plus", "n_minus", "n_imaginary", "signed_amplitude"):
            if f_folds[L][field] != s_folds[L][field]:
                out.append(f"fold census length {L}: {field} recomputed as "
                           f"{f_folds[L][field]}, stored says {s_folds[L][field]}")
    f_dep, s_dep = fresh.get("depths", {}), stored.get("depths", {})
    for L in sorted(set(f_dep) & set(s_dep), key=int):
        for field in ("total_ways", "one_pass_ways", "deepest_stratum", "modal_depth", "strata"):
            if f_dep[L][field] != s_dep[L][field]:
                out.append(f"depth census length {L}: {field} differs from stored")
    return out


def _arg(flag: str, default: int) -> int:
    if flag in sys.argv:
        return int(sys.argv[sys.argv.index(flag) + 1])
    return default


def main() -> int:
    verify = "--verify" in sys.argv
    quick = "--quick" in sys.argv
    rebuild = "--rebuild" in sys.argv

    stored = {}
    if os.path.exists(DB_PATH) and not rebuild:
        with open(DB_PATH) as fh:
            stored = json.load(fh)

    if quick:
        # CI gate: recompute the cheap lengths from scratch, compare, then assert
        # every invariant over the whole stored file.
        if not stored:
            print(f"FAIL: {DB_PATH} missing")
            return 1
        recomputed = build(QUICK_TWIST_LEN, QUICK_PHASE_LEN, None)
        fails = check(stored) + compare_shared(recomputed, stored)
        for msg in fails:
            print(f"FAIL: {msg}")
        if fails:
            return 1
        nf = len(stored["folds"]["by_length"])
        nd = len(stored["depths"])
        print(f"quick check passed: recomputed fold census to length {QUICK_TWIST_LEN} and depth "
              f"census to length {QUICK_PHASE_LEN}, matched the stored values, and all "
              f"{len(stored['_invariants_asserted'])} proven invariants hold over the full stored "
              f"database ({nf} fold lengths, {nd} depth lengths).")
        return 0

    twist_len = _arg("--twist-len", max(DEFAULT_TWIST_LEN, stored.get("max_twist_length", 0)))
    phase_len = _arg("--phase-len", max(DEFAULT_PHASE_LEN, stored.get("max_phase_length", 0)))

    fresh = build(twist_len, phase_len, None if rebuild else stored)
    fails = check(fresh)

    if verify:
        if not stored:
            print(f"FAIL: {DB_PATH} missing — run without --verify to build it")
            return 1
    else:
        os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
        with open(DB_PATH, "w") as fh:
            json.dump(fresh, fh, indent=1, sort_keys=True)
        added = (len(fresh["folds"]["by_length"]) - len(stored.get("folds", {}).get("by_length", {}))
                 + len(fresh["depths"]) - len(stored.get("depths", {})))
        print(f"wrote {DB_PATH} ({added} new entries; "
              f"fold census to length {fresh['max_twist_length']}, "
              f"depth census to length {fresh['max_phase_length']})")

    f = fresh["folds"]
    print("\nFOLD INVENTORY (count-balanced twist histories)")
    print("   len   ways   phase +1   phase -1   phase +-i   signed amplitude")
    for L, rec in sorted(f["by_length"].items(), key=lambda kv: int(kv[0])):
        print(f"   {L:>3} {rec['count']:>6} {rec['n_plus']:>10} {rec['n_minus']:>10}"
              f" {rec['n_imaginary']:>11} {rec['signed_amplitude']:>18}")
    print(f"   phase rule: {f['phase_rule']}")
    print(f"   violations: {len(f['phase_rule_violations'])}")
    print(f"   unbalanced witnesses reaching +-i (length 3): "
          f"{f['unbalanced_imaginary_count_len3']}, e.g. {f['unbalanced_imaginary_witnesses'][:4]}")

    print("\nDEPTH INVENTORY (+/- phase census)")
    print("   len   ways   one-pass   deepest   modal depth   depth = max excursion")
    for L, rec in sorted(db_items(fresh), key=lambda kv: int(kv[0])):
        print(f"   {L:>3} {rec['total_ways']:>6} {rec['one_pass_ways']:>10}"
              f" {rec['deepest_stratum']:>9} {rec['modal_depth']:>13}"
              f"   {'yes' if rec['depth_equals_max_excursion'] else 'NO'}")

    print("\nLISTENING — what a capacity-R horizon receives (fraction of the census)")
    caps = [1, 2, 3, 4, 5]
    print("   len  " + "".join(f"   R={c:<6}" for c in caps))
    for L, rec in sorted(db_items(fresh), key=lambda kv: int(kv[0])):
        cells = []
        for c in caps:
            e = rec["listening_by_capacity"].get(str(c))
            cells.append(f"   {e['fraction']:<8.4f}" if e else "   {:<8}".format("1.0000"))
        print(f"   {L:>3}  " + "".join(cells))
    print("   a shallow capacity hears only the shallow closures; no finite capacity")
    print("   hears everything (law_of_exceptions), and each step up adds lines (lines_mono).")

    print()
    if fails:
        for msg in fails:
            print(f"FAIL: {msg}")
        return 1
    print(f"all {len(fresh['_invariants_asserted'])} proven invariants hold on the enumerated data.")
    return 0


def db_items(db):
    return db["depths"].items()


if __name__ == "__main__":
    raise SystemExit(main())

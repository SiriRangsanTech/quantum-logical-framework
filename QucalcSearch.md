# QuCalc Search — the "what closes next" query service

[`qucalc_search.py`](qucalc_search.py) answers one question over the QLF substrate:

> From this QuCalc position, what are the admissible **next closures**?

Given a twist history `qc`, it enumerates the **continuations** — twist words you can
append so the whole history is a ZFA closure (count-balanced ∧ Pauli-closed) — shortest
first, and streams them. It is meant to be **exposed as a network service** for
[quantum-os](https://github.com/rchain-community/quantum-os) and other research operations
that need reachable-closure data without embedding the enumerator.

It is a **query, not a stored layer.** Nothing is cached, nothing is written, the answer
is always current with [`twist_core.py`](twist_core.py). Contrast
[`census_inventory.py`](census_inventory.py) (per-stratum summaries, committed, a Lean-invariant
regression checker) and [`contextual_census.py`](contextual_census.py) (the Born-question
experiment layer). This one is the interactive middle: the actual histories reachable from
one point.

## Why no precompute / no on-disk index

A depth-6 continuation search is ~260k raw candidates, count-prefiltered to a few thousand
before any Pauli fold runs — a few seconds on a small box, sub-second elsewhere. That is
cheaper than reading a ~1 MB cache entry back over a slow mount, and it never goes stale.
Run `python3 qucalc_search.py --time` for the numbers on the current host. If repeat-query
load is ever measured, the cache to add is one SQLite keyed by the state summary
`(imbalance vector, axis parity, depth)` — not a new census layer.

## How the search stays cheap

The seed's signed action vector `(v,h,d,l)` fixes what every continuation must supply:
exactly `−(v,h,d,l)`. So

1. **feasibility** — a length-`k` continuation can hit `need` only if `k ≥ Σ|need_i|` and
   `k ≡ Σ|need_i| (mod 2)`; infeasible depths are skipped whole;
2. **count prefilter** — each candidate tuple's own action vector is checked against `need`
   *before* any string is built;
3. **Pauli fold** — runs only on the ~2–5% that already count-balance, and by
   `QLF_TwistAlphabet.count_balanced_pauli_closed` those are *all* Pauli-closed, so the fold
   here only reads off **which** scalar (the phase), never gates admission.

## CLI

```
python3 qucalc_search.py "^<v>+-" --max-depth 6                 # closures, plain words
python3 qucalc_search.py "^<v>+-" --max-depth 6 --json          # NDJSON records
python3 qucalc_search.py "^<v>+-" --max-depth 6 --count-only    # just the count
python3 qucalc_search.py --time                                 # benchmark this host
```

## HTTP endpoint

```
python3 qucalc_search.py --serve --port 8765
# exposed, with a per-host ceiling and concurrent-search cap:
python3 qucalc_search.py --serve --host 0.0.0.0 --port 8765 --max-depth-cap 7 --max-concurrent 2
```

### Contract (stable — `version` field; consumers depend on it)

| route | response |
|---|---|
| `GET /` | `{service, version, usage, alphabet, caps}` |
| `GET /health` | `{ok: true}` |
| `GET /search?qc=<hist>&max_depth=<int>&limit=<int>` | `200 application/x-ndjson`, streamed |
| | `400 {error}` — bad `qc` / non-integer params |
| | `429 {error}` — host at `--max-concurrent`, retry |

The `/search` stream, one JSON object per line, flushed as produced:

```
{"_meta": true, "qc": "...", "max_depth": D, "limit": L, "version": "1.0"}   ← params after clamping
{"cont": "vv>", "history": "^^<vv>", "len": 6, "depth": 3, "phase": "-1"}    ← one closure
 …                                                                            shortest depth first
{"_done": true, "found": K, "elapsed_s": F, "truncated": <hit limit?>}
```

`depth` = appended twists; `phase` = the Pauli scalar the whole history folds to
(`{"+1","-1","+i","-i"}`, per [`QLF_PhaseRule`](lean/QLF_PhaseRule.lean); a balanced history
is always real `±1`, per `QLF_BalancedPhaseReal`).

CORS `Access-Control-Allow-Origin: *` on every response; `OPTIONS` preflight answered. The
service is **read-only and stateless**. `max_depth` is clamped to the deployment's
`--max-depth-cap`; `limit` to 100 000.

### Deploying on a constrained host

Each concurrent `/search` holds only its generator (a few MB — `itertools.product` is lazy,
only the streamed line is materialised), so memory is dominated by `--max-concurrent`, not
result size. On a small box set `--max-depth-cap 6` (≈ 3 s worst case) and
`--max-concurrent 2`. Depth 7 is ~2 M candidates (tens of seconds on a slow CPU); depth 8
is disallowed by the hard cap.

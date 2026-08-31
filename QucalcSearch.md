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

## Client examples

The service is designed to be consumed by [quantum-os](https://github.com/rchain-community/quantum-os)
(Rust/WASM core + WebRTC browser peers). Both examples below consume the stream
incrementally — the first `_meta` line confirms the query, closures arrive shortest-first,
and the `_done` line carries the final count.

### TypeScript / browser peer (`fetch` + streaming NDJSON)

Works in the browser and in Node ≥ 18. `QUCALC_SEARCH_URL` is the deployed endpoint.

```ts
const QUCALC_SEARCH_URL = "http://qucalc.internal:8765";

export interface Closure {
  cont: string;      // twist word appended to qc
  history: string;   // the full closed history
  len: number;
  depth: number;     // appended twists
  phase: "+1" | "-1" | "+i" | "-i";
}

/** Stream the admissible next closures from a QuCalc position. */
export async function* qucalcSearch(
  qc: string,
  opts: { maxDepth?: number; limit?: number; signal?: AbortSignal } = {},
): AsyncGenerator<Closure, { found: number; elapsedS: number; truncated: boolean }> {
  const u = new URL("/search", QUCALC_SEARCH_URL);
  u.searchParams.set("qc", qc);
  if (opts.maxDepth != null) u.searchParams.set("max_depth", String(opts.maxDepth));
  if (opts.limit != null) u.searchParams.set("limit", String(opts.limit));

  const res = await fetch(u, { signal: opts.signal });
  if (!res.ok) throw new Error(`qucalc_search ${res.status}: ${(await res.json()).error}`);

  const reader = res.body!.pipeThrough(new TextDecoderStream()).getReader();
  let buf = "";
  let done = { found: 0, elapsedS: 0, truncated: false };
  for (;;) {
    const { value, done: end } = await reader.read();
    if (end) break;
    buf += value;
    let nl: number;
    while ((nl = buf.indexOf("\n")) >= 0) {
      const line = buf.slice(0, nl).trim();
      buf = buf.slice(nl + 1);
      if (!line) continue;
      const obj = JSON.parse(line);
      if (obj._meta) continue;                      // params echo, after clamping
      if (obj._done) { done = { found: obj.found, elapsedS: obj.elapsed_s, truncated: obj.truncated }; continue; }
      yield obj as Closure;
    }
  }
  return done;
}

// usage: offer the next closures at a room's current QuCalc state
const ctrl = new AbortController();
const byPhase: Record<string, string[]> = {};
for await (const c of qucalcSearch("^<v>+-", { maxDepth: 6, limit: 10_000, signal: ctrl.signal })) {
  (byPhase[c.phase] ??= []).push(c.cont);
  if (Object.values(byPhase).flat().length >= 200) ctrl.abort();   // stop early, server sees the hangup
}
```

### Rust peer / `zfa-core` (`ureq`, blocking, no async runtime needed)

```rust
// Cargo.toml:  ureq = { version = "2", features = ["json"] }  |  serde = { version = "1", features = ["derive"] }  |  serde_json = "1"
use std::io::{BufRead, BufReader};

#[derive(serde::Deserialize, Debug)]
pub struct Closure {
    pub cont: String,
    pub history: String,
    pub len: u32,
    pub depth: u32,
    pub phase: String, // "+1" | "-1" | "+i" | "-i"
}

/// Stream admissible next closures; `on_closure` is called per result as it arrives.
pub fn qucalc_search(
    base: &str, qc: &str, max_depth: u32, limit: u32,
    mut on_closure: impl FnMut(Closure),
) -> Result<(usize, f64), Box<dyn std::error::Error>> {
    let resp = ureq::get(&format!("{base}/search"))
        .query("qc", qc)
        .query("max_depth", &max_depth.to_string())
        .query("limit", &limit.to_string())
        .call()?;

    let (mut found, mut elapsed) = (0usize, 0.0);
    for line in BufReader::new(resp.into_reader()).lines() {
        let line = line?;
        if line.trim().is_empty() { continue; }
        let v: serde_json::Value = serde_json::from_str(&line)?;
        if v.get("_meta").is_some() { continue; }
        if v.get("_done").is_some() {
            found = v["found"].as_u64().unwrap_or(0) as usize;
            elapsed = v["elapsed_s"].as_f64().unwrap_or(0.0);
            continue;
        }
        on_closure(serde_json::from_value(v)?);
    }
    Ok((found, elapsed))
}

// usage
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let (found, secs) = qucalc_search("http://qucalc.internal:8765", "^<v>+-", 6, 10_000, |c| {
        println!("{:>8}  ->  {}  [{}]", c.cont, c.history, c.phase);
    })?;
    eprintln!("{found} closures in {secs:.3}s");
    Ok(())
}
```

### Notes for consumers

- **Abort to stop early.** Dropping the reader / aborting the fetch closes the socket; the
  server catches the hangup and stops enumerating. Don't rely on `limit` alone if you only
  want the first few — a small `limit` is still the cheaper signal.
- **`_meta` is the accepted-params echo.** If it shows a smaller `max_depth` than you asked,
  the deployment's `--max-depth-cap` clamped it.
- **`429`** means the host is at `--max-concurrent`; back off and retry, or run against a
  second instance.
- **Phase is always `±1` for a balanced history** (`QLF_BalancedPhaseReal`); `±i` only
  appears if you pass an already-unbalanced `qc` whose continuation cannot rebalance the
  gauge axis — which the search would not return as a closure anyway, so in practice
  consumers see only `+1` / `-1`.

#!/usr/bin/env python3
"""
qucalc_search.py — the "what closes next" query service over `twist_core`.

Given a QuCalc position (a twist history `qc`), enumerate the admissible
**continuations** — the twist words you can append so that the whole thing is a
ZFA closure (count-balanced ∧ Pauli-closed). Shortest continuations first.

This is a *query*, not a stored layer: nothing is cached, nothing is written,
the answer is always current with `twist_core.py`. The census inventory
(`census_inventory.py`) stores per-stratum summaries; this streams the actual
histories reachable from one point.

Why no precompute / no on-disk index: a depth-6 continuation search is ~260k
candidates (count-prefiltered to a few thousand before the Pauli fold ever
runs), which is a few seconds even on a slow machine and sub-second elsewhere —
cheaper than reading a ~1 MB cache entry back over a slow mount. See the
`--time` mode for the numbers on the current host.

    # CLI — print closures reachable from "^<v>+-" within 6 appended twists
    python3 qucalc_search.py "^<v>+-" --max-depth 6

    # CLI — just the count, and as NDJSON
    python3 qucalc_search.py "^<v>+-" --max-depth 6 --count-only
    python3 qucalc_search.py "^<v>+-" --max-depth 6 --json

    # HTTP endpoint — streams NDJSON, one closure per line, flushed as found
    python3 qucalc_search.py --serve --port 8765
    curl -N 'http://127.0.0.1:8765/search?qc=%5E%3Cv%3E%2B-&max_depth=6&limit=10000'

    # exposed for quantum-os / other research ops: bind all interfaces, set the
    # per-deployment ceiling and the concurrent-search cap for the host's RAM
    python3 qucalc_search.py --serve --host 0.0.0.0 --port 8765 \
            --max-depth-cap 7 --max-concurrent 2

HTTP contract (stable; consumers such as quantum-os depend on it):

    GET /                 -> {service, version, usage, alphabet, caps}
    GET /health           -> {ok: true}
    GET /search?qc=<hist>&max_depth=<int>&limit=<int>
        200 application/x-ndjson, streamed:
          line 1        {"_meta": true, "qc", "max_depth", "limit", "version"}
                        (params after clamping to the deployment caps)
          lines 2..k    {"cont", "history", "len", "depth", "phase"}
                        one ZFA closure each, shortest `depth` first;
                        `phase` is the Pauli scalar the whole history folds to
                        ({"+1","-1","+i","-i"}, per QLF_PhaseRule)
          last line     {"_done": true, "found": k, "elapsed_s": F,
                         "truncated": <hit limit?>}
        400  {"error": "..."}   bad qc / non-integer params
        429  {"error": "..."}   host at --max-concurrent, try later

CORS: `Access-Control-Allow-Origin: *` on every response; `OPTIONS` preflight
answered. The service is read-only and stateless — nothing is written, no
history is retained between requests.
"""

from __future__ import annotations

import argparse
import itertools
import json
import sys
import threading
import time
from collections import Counter
from typing import Iterator, Optional

from twist_core import (
    TWISTS,
    MIN_ZFA_LENGTH,
    calculate_action,
    pauli_fold,
    validate_history,
)

VERSION = "1.0"

# Guard rails. The HTTP endpoint clamps requests to these; the CLI does not
# (you asked for it explicitly there). `--serve` can tighten the depth cap and
# set the concurrent-search limit per host — depth 8 is ~minutes on a small box.
MAX_DEPTH_CAP = 7            # 8^7 ≈ 2.1M raw candidates, count-prefiltered
MAX_LIMIT_CAP = 100_000
DEFAULT_MAX_DEPTH = 6
DEFAULT_LIMIT = 10_000
DEFAULT_MAX_CONCURRENT = 3   # simultaneous /search enumerations

_PAULI_TOL = 1e-9


# --------------------------------------------------------------------------- #
# core search
# --------------------------------------------------------------------------- #
def _classify_phase(fold) -> Optional[str]:
    """Return '+1' / '-1' / '+i' / '-i' if `fold` is a Pauli scalar, else None."""
    a, b, c, d = fold
    if abs(b) > _PAULI_TOL or abs(c) > _PAULI_TOL or abs(a - d) > _PAULI_TOL:
        return None
    for scalar, name in ((1 + 0j, "+1"), (-1 + 0j, "-1"), (1j, "+i"), (-1j, "-i")):
        if abs(a - scalar) < _PAULI_TOL:
            return name
    return None


def _action_of(combo: tuple[str, ...]) -> tuple[int, int, int, int]:
    """Signed action vector (v, h, d, l) of a tuple of twist chars — no string build."""
    c = Counter(combo)
    return (c["^"] - c["v"], c[">"] - c["<"], c["/"] - c["\\"], c["+"] - c["-"])


def _feasible(need: tuple[int, int, int, int], depth: int) -> bool:
    """Can `depth` appended twists realise the action vector `need` at all?

    Each axis needs `#pos + #neg` twists with `#pos - #neg = need_i`, so
    `#axis_i ≥ |need_i|` and `#axis_i ≡ need_i (mod 2)`. Summing:
    `depth ≥ Σ|need_i|` and `depth ≡ Σ|need_i| (mod 2)`.
    """
    s = sum(abs(x) for x in need)
    return depth >= s and (depth - s) % 2 == 0


def search(
    qc: str,
    max_depth: int = DEFAULT_MAX_DEPTH,
    limit: Optional[int] = DEFAULT_LIMIT,
    min_total_len: int = MIN_ZFA_LENGTH,
) -> Iterator[dict]:
    """Yield ZFA closures reachable from `qc` by appending 1..`max_depth` twists.

    Shortest continuations first. Each result is a dict with keys
    `cont`, `history`, `len`, `depth`, `phase`. If the `limit` is reached the
    generator stops without a marker — callers that need to know should compare
    the count to `limit`.

    The count-balance constraint is applied to the continuation *before* any
    string is built or Pauli fold is run — the fold only touches the small
    fraction of candidates that already balance.
    """
    validate_history(qc)
    seed_action = calculate_action(qc)
    need = tuple(-x for x in seed_action)          # continuation must supply this
    n_found = 0

    for depth in range(1, max_depth + 1):
        if not _feasible(need, depth):
            continue
        if len(qc) + depth < min_total_len:
            continue
        for combo in itertools.product(TWISTS, repeat=depth):
            if _action_of(combo) != need:
                continue
            cont = "".join(combo)
            history = qc + cont
            phase = _classify_phase(pauli_fold(history))
            if phase is None:                      # count-balanced but not Pauli-closed
                continue
            yield {
                "cont": cont,
                "history": history,
                "len": len(history),
                "depth": depth,
                "phase": phase,
            }
            n_found += 1
            if limit is not None and n_found >= limit:
                return


# --------------------------------------------------------------------------- #
# HTTP endpoint
# --------------------------------------------------------------------------- #
def _make_handler(depth_cap: int, sem: threading.BoundedSemaphore):
    from http.server import BaseHTTPRequestHandler
    from urllib.parse import urlparse, parse_qs

    class Handler(BaseHTTPRequestHandler):
        # HTTP/1.0 so we can stream to EOF without chunked-encoding bookkeeping.
        protocol_version = "HTTP/1.0"
        server_version = "qucalc_search/" + VERSION

        def _cors(self) -> None:
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")

        def _send_json(self, code: int, obj: dict) -> None:
            body = json.dumps(obj).encode()
            self.send_response(code)
            self._cors()
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            try:
                self.wfile.write(body)
            except (BrokenPipeError, ConnectionResetError):
                pass

        def log_message(self, fmt, *args):  # quieter default logging
            sys.stderr.write("%s - %s\n" % (self.address_string(), fmt % args))

        def do_OPTIONS(self):
            self.send_response(204)
            self._cors()
            self.send_header("Content-Length", "0")
            self.end_headers()

        def do_GET(self):
            parsed = urlparse(self.path)
            route = parsed.path.rstrip("/") or "/"
            params = parse_qs(parsed.query)

            if route == "/":
                self._send_json(200, {
                    "service": "qucalc_search",
                    "version": VERSION,
                    "usage": "/search?qc=<history>&max_depth=<1..%d>&limit=<1..%d>"
                             % (depth_cap, MAX_LIMIT_CAP),
                    "alphabet": TWISTS,
                    "caps": {"max_depth": depth_cap, "max_limit": MAX_LIMIT_CAP},
                    "response": "application/x-ndjson; first line _meta, last line _done",
                })
                return
            if route == "/health":
                self._send_json(200, {"ok": True})
                return
            if route != "/search":
                self._send_json(404, {"error": "not found", "path": route})
                return

            qc = (params.get("qc") or [""])[0]
            try:
                validate_history(qc)
            except ValueError as e:
                self._send_json(400, {"error": str(e)})
                return
            try:
                max_depth = int((params.get("max_depth") or [DEFAULT_MAX_DEPTH])[0])
                limit = int((params.get("limit") or [DEFAULT_LIMIT])[0])
            except ValueError:
                self._send_json(400, {"error": "max_depth and limit must be integers"})
                return
            max_depth = max(1, min(max_depth, depth_cap))
            limit = max(1, min(limit, MAX_LIMIT_CAP))

            if not sem.acquire(blocking=False):
                self._send_json(429, {"error": "host at capacity (--max-concurrent); retry"})
                return
            try:
                self.send_response(200)
                self._cors()
                self.send_header("Content-Type", "application/x-ndjson")
                self.end_headers()
                self.wfile.write((json.dumps({
                    "_meta": True, "qc": qc, "max_depth": max_depth,
                    "limit": limit, "version": VERSION,
                }) + "\n").encode())
                self.wfile.flush()

                t0 = time.time()
                n = 0
                for rec in search(qc, max_depth=max_depth, limit=limit):
                    self.wfile.write((json.dumps(rec) + "\n").encode())
                    self.wfile.flush()
                    n += 1
                self.wfile.write((json.dumps({
                    "_done": True, "found": n, "elapsed_s": round(time.time() - t0, 3),
                    "truncated": n >= limit,
                }) + "\n").encode())
            except (BrokenPipeError, ConnectionResetError):
                pass  # client hung up mid-stream
            finally:
                sem.release()

    return Handler


def serve(host: str = "127.0.0.1", port: int = 8765,
          depth_cap: int = MAX_DEPTH_CAP,
          max_concurrent: int = DEFAULT_MAX_CONCURRENT) -> None:
    from http.server import ThreadingHTTPServer
    depth_cap = max(1, min(depth_cap, MAX_DEPTH_CAP))
    sem = threading.BoundedSemaphore(max(1, max_concurrent))
    httpd = ThreadingHTTPServer((host, port), _make_handler(depth_cap, sem))
    sys.stderr.write(
        "qucalc_search %s on http://%s:%d  (depth_cap=%d, max_concurrent=%d)\n"
        % (VERSION, host, port, depth_cap, max_concurrent)
    )
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        sys.stderr.write("\nstopped\n")
        httpd.server_close()


# --------------------------------------------------------------------------- #
# CLI
# --------------------------------------------------------------------------- #
def _time_mode() -> None:
    """Print the candidate/closure/latency numbers on the current host."""
    for seed in ("^<v>+-", "^v<>+-", "+-+-"):
        for md in (4, 6):
            t0 = time.time()
            n = sum(1 for _ in search(seed, max_depth=md, limit=None))
            print(f"  seed {seed!r:10s} max_depth {md}: {n:6d} closures  {time.time()-t0:6.2f}s")


def main(argv: Optional[list[str]] = None) -> int:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("qc", nargs="?", help="the QuCalc position (twist history) to search from")
    p.add_argument("--max-depth", type=int, default=DEFAULT_MAX_DEPTH,
                   help=f"max appended twists (default {DEFAULT_MAX_DEPTH})")
    p.add_argument("--limit", type=int, default=DEFAULT_LIMIT,
                   help=f"stop after this many closures (default {DEFAULT_LIMIT}; 0 = no limit)")
    p.add_argument("--json", action="store_true", help="emit NDJSON instead of plain words")
    p.add_argument("--count-only", action="store_true", help="print only the closure count")
    p.add_argument("--serve", action="store_true", help="run the HTTP endpoint instead")
    p.add_argument("--host", default="127.0.0.1",
                   help="bind address (default 127.0.0.1; use 0.0.0.0 to expose)")
    p.add_argument("--port", type=int, default=8765)
    p.add_argument("--max-depth-cap", type=int, default=MAX_DEPTH_CAP,
                   help=f"per-deployment /search depth ceiling (default {MAX_DEPTH_CAP})")
    p.add_argument("--max-concurrent", type=int, default=DEFAULT_MAX_CONCURRENT,
                   help=f"simultaneous /search enumerations (default {DEFAULT_MAX_CONCURRENT})")
    p.add_argument("--time", action="store_true", help="benchmark search on this host and exit")
    args = p.parse_args(argv)

    if args.serve:
        serve(args.host, args.port, args.max_depth_cap, args.max_concurrent)
        return 0
    if args.time:
        _time_mode()
        return 0
    if not args.qc:
        p.error("qc position required (or use --serve / --time)")
    try:
        validate_history(args.qc)
    except ValueError as e:
        p.error(str(e))

    limit = None if args.limit == 0 else args.limit
    t0 = time.time()
    n = 0
    for rec in search(args.qc, max_depth=args.max_depth, limit=limit):
        n += 1
        if args.count_only:
            continue
        if args.json:
            print(json.dumps(rec))
        else:
            print(f"{rec['cont']:<{args.max_depth}}  ->  {rec['history']}  [{rec['phase']}]")
    if args.count_only:
        print(n)
    sys.stderr.write(f"{n} closures from {args.qc!r} within {args.max_depth} twists "
                     f"in {time.time()-t0:.2f}s\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

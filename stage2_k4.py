#!/usr/bin/env python3
"""Stage 2 of the Kourovka 20.71 k=4 census.

Input: graph6 lines.
For each graph:
  1. compute per-card degree-multiset fingerprints; the number of distinct
     fingerprints lower-bounds the number of card types — skip if > 4;
  2. canonicalize the cards with pynauty within fingerprint groups to get the
     exact card-type count k;
  3. if k = 4, compute Aut(G) orbits; report a WITNESS if orbits > 4.

Fingerprint soundness: isomorphic cards have identical degree multisets, so
grouping by fingerprint refines no card class incorrectly; certificates are
only compared within groups, which is valid because cross-group cards are
already non-isomorphic.
"""
from __future__ import annotations

import sys
from pathlib import Path

_HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(_HERE / "vendor"))
_VV = _HERE / f"vendor{sys.version_info.major}{sys.version_info.minor}"
if _VV.is_dir():
    sys.path.insert(0, str(_VV))
import pynauty  # noqa: E402


def parse_g6(s: bytes):
    n = s[0] - 63
    adj = [[] for _ in range(n)]
    mask = [0] * n
    bitpos = 0
    data = s[1:]
    for j in range(1, n):
        for i in range(j):
            byte = bitpos // 6
            off = 5 - bitpos % 6
            if (data[byte] - 63) >> off & 1:
                adj[i].append(j)
                adj[j].append(i)
                mask[i] |= 1 << j
                mask[j] |= 1 << i
            bitpos += 1
    return n, adj, mask


def main() -> None:
    checked = kept_fp = certified = 0
    witnesses = []
    for raw in sys.stdin.buffer:
        raw = raw.strip()
        if not raw or raw.startswith(b">"):
            continue
        checked += 1
        n, adj, mask = parse_g6(raw)
        deg = [len(a) for a in adj]
        # triangles through v (each counted once per unordered neighbor pair)
        tri = [
            sum((mask[u] & mask[v]).bit_count() for u in adj[v]) // 2
            for v in range(n)
        ]
        # card fingerprint: degree multiset of G-v and tri[v]. Since
        # triangles(G-v) = triangles(G) - tri[v], both components are card
        # isomorphism invariants within this fixed graph.
        groups: dict[tuple, list[int]] = {}
        for v in range(n):
            dm = tuple(sorted(deg[u] - ((mask[v] >> u) & 1)
                              for u in range(n) if u != v))
            groups.setdefault((dm, tri[v]), []).append(v)
        if len(groups) > 4:
            continue
        kept_fp += 1
        # exact card classes: certificates within fingerprint groups
        k = 0
        for members in groups.values():
            certs = set()
            for v in members:
                vertices = [u for u in range(n) if u != v]
                relabel = {u: i for i, u in enumerate(vertices)}
                adjacency = {
                    relabel[u]: [relabel[w] for w in adj[u] if w != v]
                    for u in vertices
                }
                g = pynauty.Graph(number_of_vertices=n - 1, directed=False,
                                  adjacency_dict=adjacency)
                certs.add(pynauty.certificate(g))
            k += len(certs)
            if k > 4:
                break
        certified += 1
        if k not in (4,):
            continue
        g = pynauty.Graph(number_of_vertices=n, directed=False,
                          adjacency_dict={v: adj[v] for v in range(n)})
        orbit_count = pynauty.autgrp(g)[4]
        if orbit_count > k:
            witnesses.append((raw.decode(), k, orbit_count))
            print("WITNESS", raw.decode(), "card_types", k, "orbits",
                  orbit_count, flush=True)
    print(f"STATS checked={checked} fp_kept={kept_fp} certified={certified} "
          f"witnesses={len(witnesses)}", file=sys.stderr)


if __name__ == "__main__":
    main()

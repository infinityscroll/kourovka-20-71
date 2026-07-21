#!/usr/bin/env python3
"""Search Kourovka 20.71 over a graph6 stream.

For each connected graph, compare the number of isomorphism classes of
vertex-deleted cards with the number of vertex orbits under Aut(G).
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

_HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(_HERE / "vendor"))
_VERSIONED_VENDOR = _HERE / f"vendor{sys.version_info.major}{sys.version_info.minor}"
if _VERSIONED_VENDOR.is_dir():
    sys.path.insert(0, str(_VERSIONED_VENDOR))
import networkx as nx  # noqa: E402
import pynauty  # noqa: E402

if not hasattr(pynauty, "certificate"):
    raise ImportError(
        f"pynauty has no native extension for Python {sys.version_info.major}."
        f"{sys.version_info.minor} in {_VERSIONED_VENDOR}"
    )


def nauty_graph(graph: nx.Graph, omit: int | None = None) -> pynauty.Graph:
    vertices = [v for v in graph if v != omit]
    relabel = {v: i for i, v in enumerate(vertices)}
    adjacency = {
        relabel[v]: [relabel[w] for w in graph[v] if w != omit]
        for v in vertices
    }
    return pynauty.Graph(
        number_of_vertices=len(vertices), directed=False, adjacency_dict=adjacency
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--all-targets",
        action="store_true",
        help="continue until a witness has been found for each of k=2,3,4",
    )
    args = parser.parse_args()
    checked = 0
    found: dict[int, tuple[str, int]] = {}
    for raw in sys.stdin.buffer:
        raw = raw.strip()
        if not raw or raw.startswith(b">"):
            continue
        checked += 1
        graph = nx.from_graph6_bytes(raw)
        card_types = {
            pynauty.certificate(nauty_graph(graph, omit=v)) for v in graph
        }
        k = len(card_types)
        if k not in {2, 3, 4}:
            continue
        aut = pynauty.autgrp(nauty_graph(graph))
        orbit_count = aut[4]
        if orbit_count > k:
            if k not in found:
                found[k] = (raw.decode(), orbit_count)
                print(raw.decode(), "card_types", k, "orbits", orbit_count)
            if not args.all_targets or set(found) == {2, 3, 4}:
                return
    if args.all_targets:
        print("CHECKED", checked, "MISSING", sorted({2, 3, 4} - set(found)))
    else:
        print("NO_HIT", checked)


if __name__ == "__main__":
    main()

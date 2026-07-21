#!/usr/bin/env python3
"""Dependency-free exact verification of a counterexample to Kourovka 20.71.

The program exhausts all 9! vertex permutations to determine Aut(G), and all
8! orderings of each vertex-deleted graph to compute canonical adjacency codes.
It therefore does not trust graph-isomorphism or automorphism software.
"""

from itertools import combinations, permutations


N = 9
EDGES = frozenset(
    {
        (0, 3),
        (0, 4),
        (0, 7),
        (1, 4),
        (1, 5),
        (1, 6),
        (2, 5),
        (2, 6),
        (2, 7),
        (2, 8),
        (3, 6),
        (3, 7),
        (3, 8),
        (4, 8),
        (5, 7),
        (6, 8),
    }
)


def graph6() -> str:
    assert N <= 62
    bits = [int((i, j) in EDGES) for j in range(1, N) for i in range(j)]
    bits += [0] * (-len(bits) % 6)
    payload = "".join(
        chr(63 + sum(bits[k + t] << (5 - t) for t in range(6)))
        for k in range(0, len(bits), 6)
    )
    return chr(N + 63) + payload


def edge(u: int, v: int) -> tuple[int, int]:
    return (u, v) if u < v else (v, u)


def neighbors(v: int) -> set[int]:
    return {w for w in range(N) if w != v and edge(v, w) in EDGES}


def connected() -> bool:
    seen = {0}
    frontier = [0]
    while frontier:
        v = frontier.pop()
        for w in neighbors(v) - seen:
            seen.add(w)
            frontier.append(w)
    return len(seen) == N


def automorphisms() -> list[tuple[int, ...]]:
    result = []
    for perm in permutations(range(N)):
        image = frozenset(edge(perm[u], perm[v]) for u, v in EDGES)
        if image == EDGES:
            result.append(perm)
    return result


def card_code(deleted: int) -> tuple[int, ...]:
    """Canonical adjacency bit string of G-deleted over all 8! orders."""
    vertices = tuple(v for v in range(N) if v != deleted)
    best = None
    for order in permutations(vertices):
        code = tuple(
            int(edge(order[i], order[j]) in EDGES)
            for i, j in combinations(range(N - 1), 2)
        )
        if best is None or code < best:
            best = code
    assert best is not None
    return best


def deletion_degree_sequence(deleted: int) -> tuple[int, ...]:
    vertices = [v for v in range(N) if v != deleted]
    return tuple(
        sorted(sum(edge(v, w) in EDGES for w in vertices if w != v) for v in vertices)
    )


def check_card_isomorphism(
    deleted_source: int, deleted_target: int, mapping: dict[int, int]
) -> None:
    source = set(range(N)) - {deleted_source}
    target = set(range(N)) - {deleted_target}
    assert set(mapping) == source
    assert set(mapping.values()) == target
    for u, v in combinations(source, 2):
        assert (edge(u, v) in EDGES) == (edge(mapping[u], mapping[v]) in EDGES)


def refinement_cells() -> list[list[int]]:
    colors = {v: len(neighbors(v)) for v in range(N)}
    while True:
        signatures = {
            v: (colors[v], tuple(sorted(colors[w] for w in neighbors(v))))
            for v in range(N)
        }
        palette = {s: i for i, s in enumerate(sorted(set(signatures.values())))}
        new_colors = {v: palette[signatures[v]] for v in range(N)}
        old_partition = {(u, v): colors[u] == colors[v] for u in range(N) for v in range(N)}
        new_partition = {
            (u, v): new_colors[u] == new_colors[v]
            for u in range(N)
            for v in range(N)
        }
        colors = new_colors
        if old_partition == new_partition:
            break
    return sorted(
        (sorted(v for v in range(N) if colors[v] == c) for c in set(colors.values())),
        key=lambda cell: cell[0],
    )


def main() -> None:
    assert graph6() == "HCpbdgy"
    assert connected()
    autos = automorphisms()
    expected_nontrivial = (5, 4, 3, 2, 1, 0, 8, 7, 6)
    assert autos == [tuple(range(N)), expected_nontrivial]

    classes: dict[tuple[int, ...], list[int]] = {}
    for v in range(N):
        classes.setdefault(card_code(v), []).append(v)
    card_classes = sorted((sorted(vs) for vs in classes.values()), key=lambda c: c[0])
    assert card_classes == [[0, 5], [1, 4], [2, 3, 6, 8], [7]]

    # Explicit witnesses that the only card class crossing automorphism orbits
    # is {2,3,6,8}.  The first is the restriction of the graph involution.
    card_maps = {
        3: {0: 5, 1: 4, 3: 2, 4: 1, 5: 0, 6: 8, 7: 7, 8: 6},
        6: {0: 2, 1: 4, 3: 7, 4: 8, 5: 1, 6: 0, 7: 5, 8: 3},
        8: {0: 3, 1: 1, 3: 7, 4: 6, 5: 4, 6: 5, 7: 0, 8: 2},
    }
    for target, mapping in card_maps.items():
        check_card_isomorphism(2, target, mapping)

    degree_sequences = {tuple(vs): deletion_degree_sequence(vs[0]) for vs in card_classes}
    assert len(set(degree_sequences.values())) == 4
    assert refinement_cells() == [[0, 5], [1, 4], [2, 3], [6, 8], [7]]

    print("graph6:", graph6())
    print("connected: yes")
    print("automorphisms:")
    for perm in autos:
        print(" ", perm)
    print("automorphism orbits: [[0, 5], [1, 4], [2, 3], [6, 8], [7]]")
    print("vertex-deleted card classes:", card_classes)
    print("explicit isomorphisms from G-2:")
    for target, mapping in card_maps.items():
        print("  G-2 ~= G-%d:" % target, sorted(mapping.items()))
    print("deletion degree sequences:")
    for cls, seq in degree_sequences.items():
        print(" ", list(cls), seq)
    print("VERIFIED: 4 card types and 5 automorphism orbits")


if __name__ == "__main__":
    main()

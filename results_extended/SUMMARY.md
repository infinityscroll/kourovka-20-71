# Extended sweep results (orders 12-14)

Aggregated from 12-way parallel workers; regenerate with
`run_extended_k23.sh` / `run_extended_parallel.sh`.

| slice | graphs checked | fingerprint survivors | certified | witnesses |
|---|---|---|---|---|
| bideg_n12_23 | 4,566 | 353 | 353 | 0 |
| bideg_n12_34 | 327,041 | 2,047 | 2,047 | 0 |
| bideg_n12_45 | 4,455,824 | 6,181 | 6,181 | 0 |
| bideg_n12_56 | 10,622,073 | 9,229 | 9,229 | 0 |
| bideg_n13_23 | 15,530 | 651 | 651 | 0 |
| bideg_n13_34 | 3,325,439 | 9,684 | 9,684 | 0 |
| bideg_n13_45 | 120,527,362 | 9,061 | 9,061 | 0 |
| bideg_n13_56 | 713,053,821 | 100,546 | 100,546 | 0 |
| n11 | 27,219,751 | 60,536 | 60,536 | 0 |
| reg_n12_d2 | 1 | 1 | 1 | 0 |
| reg_n12_d3 | 85 | 85 | 85 | 0 |
| reg_n12_d4 | 1,544 | 1,152 | 1,152 | 0 |
| reg_n12_d5 | 7,848 | 3,812 | 3,812 | 0 |
| reg_n13_d2 | 1 | 1 | 1 | 0 |
| reg_n13_d4 | 10,778 | 7,580 | 7,580 | 0 |
| reg_n13_d6 | 367,860 | 99,014 | 99,014 | 0 |
| reg_n14_d2 | 1 | 1 | 1 | 0 |
| reg_n14_d3 | 509 | 509 | 509 | 0 |
| reg_n14_d4 | 88,168 | 61,360 | 61,360 | 0 |
| reg_n14_d5 | 3,459,383 | 937,338 | 937,338 | 0 |
| reg_n14_d6 | 21,609,300 | 3,332,933 | 3,332,933 | 0 |
| **total** | **905,096,885** | **4,642,074** | **4,642,074** | **0** |

## Complementation gap closure

Complementation preserves card types and orbit counts but not connectivity,
so the connected low-degree sweeps above do not by themselves cover
connected high-degree graphs with disconnected complements. Since the
complement of a disconnected graph is always connected, those are covered by
testing every disconnected graph in the low slices (disjoint unions of
connected low-slice components; `gapclose_disconnected.py`): 2,844 unions
across regular n=13,14 (d <= (n-1)/2) and windows {a,a+1}, a=2..5, n=13 —
**0 witnesses**.

## Order-12 full census

All 164,059,830,476 connected graphs on 12 vertices (matches OEIS A001349):
1,905,839,762 degree-filter survivors, 32,500 certified, **0 witnesses**.
Unconditional bound: any k=2 or k=3 example has at least 13 vertices.

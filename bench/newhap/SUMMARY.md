# HAP 1.70 against the GitHub HAP (1.79) — order 64, degree 5, 3 GB cap

Same protocol as the run in `../results/`: all 267 groups of order 64,
resolution to degree 5, one GAP process per group,
`timeout 600 gap -l "<root>;" -q -b -T -o 3g`, times are GAP's `Runtime()`
(CPU time). The installed package is HAP 1.70; the GitHub clone used here is
HAP 1.79 (`10b3d74`), loaded from a separate root so that the installed
package is untouched.

## The headline: 1.79 is a large improvement

| | HAP 1.70 | HAP 1.79 |
|---|---|---|
| `ResolutionFiniteGroup` completed | 193 | **246** |
| `ResolutionFiniteGroup` died at 3 GB | 74 | **21** |
| total over the 190 groups both complete | 1,446,696 ms | **485,024 ms** (0.34x) |

56 groups that 1.70 could not resolve under 3 GB are resolved by 1.79.
18 groups defeat both.

## Three regressions

Groups that 1.70 completes and 1.79 does not:

| group | HAP 1.70 | HAP 1.79 |
|---|---|---|
| G(64,113) | 43,639 ms | died at 3 GB after 15.1 s |
| G(64,160) | 92,944 ms | died at 3 GB after 17.2 s |
| G(64,241) | 233,602 ms | died at 3 GB after 17.2 s |

G(64,241) is the slowest group of the whole 1.70 run, by a factor of two over
the next.

### The memory ladder on G(64,241), HAP 1.79

| limit | outcome | wall to failure | peak RSS |
|---|---|---|---|
| 3 GB | died | — | — |
| 5 GB | died | 51 s | 3.50 GB |
| 8 GB | died | 129 s | 4.15 GB |

Raising the limit raises both the residency and the time to failure, but the
run still stops: at 4.15 GB resident it is issuing a request above 8 GB. On a
16 GB machine the ceiling was not reached.

## Large per-group changes among the groups both versions complete

Slower in 1.79:

| group | 1.70 | 1.79 | |
|---|---|---|---|
| G(64,10) | 103 ms | 10,945 ms | 106x |
| G(64,76) | 1,362 ms | 74,147 ms | 54x |
| G(64,117) | 212 ms | 8,957 ms | 42x |
| G(64,123) | 1,460 ms | 14,066 ms | 9.6x |
| G(64,207) | 3,096 ms | 17,388 ms | 5.6x |

Faster in 1.79:

| group | 1.70 | 1.79 |
|---|---|---|
| G(64,182) | 110,990 ms | 29 ms |
| G(64,181) | 58,927 ms | 9 ms |
| G(64,206) | 28,565 ms | 34 ms |
| G(64,150) | 23,701 ms | 25 ms |
| G(64,3) | 17,719 ms | 5 ms |

## The other two strategies

`ResolutionGenericGroup` and `ResolutionNormalSeries(LowerCentralSeries(G))`
complete on all 267 groups in both versions, including on the 21 groups where
1.79's `ResolutionFiniteGroup` dies (median about 70 ms there).

## Calibration — what these numbers will and will not carry

The 1.70 run was made on a loaded machine and the 1.79 run on a quiet one.
`Runtime()` is CPU time and so is fairly robust to that, but not immune, so
30 groups were re-run with 1.70 on the quiet machine and compared with their
original figures:

| method | 1.70 re-run / 1.70 original | 1.79 / 1.70 re-run |
|---|---|---|
| `ResolutionGenericGroup` | 1.03 | 0.52 |
| `ResolutionNormalSeries` | 1.52 | 0.44 |

So: which groups die, and the ratios from 5x to 106x above, are far outside
this spread and can be relied on. The roughly twofold gain of
`ResolutionGenericGroup` in 1.79 is also outside it. The gain of
`ResolutionNormalSeries` is the same size as the spread, and is **not**
claimed here.

## Files

`one_new.g`, `drive_new.sh` (the 267-group run), `pass2_new.g` (the other two
methods on the 21 that died), `one241.g` and `one241_new_*.log` (the memory
ladder), `control_old.g` and `results_control_old.txt` (the calibration),
`results_new.txt`, `results_new_pass2.txt`, `exits_new.txt` (raw logs) and
`table_old_vs_new.tsv` (the per-group table).

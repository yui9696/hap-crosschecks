# HAP resolution benchmark — order 64, degree 5, 3 GB cap (2026-09-25)

GAP 4.15.1, HAP 1.70, macOS (arm64). One GAP process per group,
`timeout 600 gap -q -b -T -o 3g`, times are GAP's `Runtime()` (CPU, not wall clock).
Pass 1 = all three methods in one process per group; pass 2 = the other two methods
re-run alone on the groups where `ResolutionFiniteGroup` died (in pass 1 they never
ran there, because GAP exited first).

## All 267 groups of order 64, resolution to degree 5

| method | completed | died at 3 GB | total ms (completed) | median | max |
|---|---|---|---|---|---|
| `ResolutionFiniteGroup` | 193 | **74 (27.7%)** | 1,816,881 | 1,130 | 233,602 |
| `ResolutionGenericGroup` | **267** | 0 | 19,985 | ~50 | 243 |
| `ResolutionNormalSeries(LowerCentralSeries(G))` | **267** | 0 | 21,393 | ~60 | 263 |

- On the **193** groups where all three completed:
  `ResolutionFiniteGroup` 1,816,881 ms vs `ResolutionGenericGroup` 11,362 ms (**160x**)
  and `ResolutionNormalSeries` 12,831 ms (**142x**).
- On the **74** groups where `ResolutionFiniteGroup` died:
  `ResolutionGenericGroup` 8,623 ms total (median 112 ms, max 243 ms),
  `ResolutionNormalSeries` 8,562 ms total (median 121 ms, max 183 ms) — **all 74 completed**.

## The 74 failing identifiers

18, 19, 25, 28, 36, 39, 43, 46, 63, 64, 68, 69, 72, 73, 75, 77, 78, 81, 82, 94, 100,
102, 111, 122, 125, 133, 135, 136, 137, 144, 145, 151, 156, 158, 159, 161, 162, 163,
164, 165, 166, 167, 168, 170, 171, 172, 176, 177, 178, 180, 190, 209, 215, 217, 219,
220, 221, 222, 223, 232, 233, 234, 236, 237, 238, 239, 240, 242, 243, 244, 245, 249,
256, 266

Confirmed cause (re-run of G(64,18) with output captured):

```
starting ResolutionFiniteGroup(G(64,18), 5)
Error, reached the pre-set memory limit
(change it with the -o command line option)
gap exit code: 0
```

## Practical note

GAP leaves with **exit status 0** after the pre-set memory limit under `-T` with stdin
from `/dev/null`: the error aborts the script, there is no break loop, EOF ends the
session normally. A benchmark driver that only inspects exit codes therefore records
these 74 deaths as successes. Detection here is by writing a START line before each
call and a DONE line after it.

## Files
`one.g`, `drive.sh` (pass 1), `pass2_one.g`, `drive2.sh`, `drive2b.sh` (pass 2),
`results.txt`, `results_pass2.txt`, `exits.txt`, `exits_pass2.txt`,
`analyze.py`, `table.tsv` (per-group table), `verify18.g`.

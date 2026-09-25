# bench

All 267 groups of order 64, resolution to degree 5, under a 3 GB cap, for
`ResolutionFiniteGroup`, `ResolutionGenericGroup` and
`ResolutionNormalSeries(LowerCentralSeries(G))`.

One GAP process per group, so that a death is attributable to one group and one
method. `one.g` writes a `START` line before each call and a `DONE` line after
it, because GAP leaves with exit status 0 when it hits the memory limit (see the
top-level README).

- `one.g` — the three methods on one group. `IDX` is substituted by the driver.
- `drive.sh` — pass 1: runs `one.g` on ids 1..267.
- `pass2_one.g`, `drive2.sh` — pass 2: the other two methods alone on the ids in
  `died_ids.txt`. In pass 1 they never ran on those groups, because
  `ResolutionFiniteGroup` had already ended the GAP session.
- `died_ids.txt` — the 74 groups where `ResolutionFiniteGroup` died.
- `verify18.g` — re-runs G(64,18) with output captured, to show the cause.
- `analyze.py` — turns `results.txt` and `results_pass2.txt` into the summary
  and `table.tsv`.
- `results/` — the recorded run: `SUMMARY.md`, `table.tsv`, and both raw logs.

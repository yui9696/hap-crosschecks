# hap-crosschecks

Independent implementations, calibrations and stress measurements around
[HAP](https://gap-packages.github.io/hap/), the homological algebra package for
[GAP](https://www.gap-system.org/).

Everything here came out of one computation — the degree three unramified
cohomology of the groups of order 128 — and is published separately because the
three pieces are useful on their own, and because real failing cases at a size
where a package is under strain are hard to come by.

**This is not part of HAP and is not endorsed by its authors. It contains no
HAP or GAP code.**

| directory | what it is |
|---|---|
| [`bench/`](bench/) | all 267 groups of order 64, resolution to degree 5, three HAP strategies, 3 GB cap: timings, failures, and the per-group table |
| [`bogomolov/`](bogomolov/) | a second implementation of the Bogomolov multiplier `B_0(G)`, following the original definition through a Schur cover, and its agreement with HAP's `BogomolovMultiplier` on 3326 groups |
| [`chern/`](chern/) | the second Chern class of a two-dimensional irreducible as an Euler class of the representation sphere — a route HAP does not provide — with its calibration |

Tested with GAP 4.15.1 and HAP 1.70 on macOS (arm64). `bogomolov/` additionally
needs the `polycyclic` package; it does **not** use HAP.

---

## bench — where `ResolutionFiniteGroup` stops

All 267 groups of order 64, resolution to degree 5, one GAP process per group,
`timeout 600 gap -q -b -T -o 3g`. Times are GAP's `Runtime()` (CPU time).

| method | completed | died at 3 GB | total ms (completed) | median | max |
|---|---|---|---|---|---|
| `ResolutionFiniteGroup` | 193 | **74 (27.7%)** | 1,816,881 | 1,130 | 233,602 |
| `ResolutionGenericGroup` | **267** | 0 | 19,985 | ~50 | 243 |
| `ResolutionNormalSeries(LowerCentralSeries(G))` | **267** | 0 | 21,393 | ~60 | 263 |

On the 193 groups where all three finish, `ResolutionFiniteGroup` takes 160
times as long as `ResolutionGenericGroup` and 142 times as long as
`ResolutionNormalSeries`. On the 74 groups where it dies, the other two finish
in a median of 0.12 s.

**This is a trade-off, not a defect.** The three strategies do not return
resolutions of the same size. Summing the ranks in degrees 0 to 5 over the 193
groups where all three finish:

| method | total rank | |
|---|---|---|
| `ResolutionFiniteGroup` | 17,232 | smallest |
| `ResolutionGenericGroup` | 45,245 | median 2.6x larger |
| `ResolutionNormalSeries` | 60,222 | |

Only 8 of the 193 groups get the same dimension vector from all three. So
`ResolutionFiniteGroup` is buying a much smaller resolution with the time and
the memory, and what a caller should weigh is the downstream cost of the larger
one — cup products, chain maps and cohomology all scale with these ranks.

### A trap worth knowing

Under `-T` with stdin from `/dev/null`, GAP leaves with **exit status 0** after
hitting the pre-set memory limit: the error aborts the script, there is no
break loop, and EOF then ends the session normally.

```
starting ResolutionFiniteGroup(G(64,18), 5)
Error, reached the pre-set memory limit
(change it with the -o command line option)
gap exit code: 0
```

A driver that only inspects exit codes records all 74 deaths here as successes.
`bench/one.g` writes a `START` line before each call and a `DONE` line after it,
and the deaths are the `START`s with no `DONE`.

See [`bench/results/SUMMARY.md`](bench/results/SUMMARY.md) for the failing
identifiers and [`bench/results/table.tsv`](bench/results/table.tsv) for the
per-group table.

### The same 267 groups against the HAP on GitHub

[`bench/newhap/`](bench/newhap/) repeats the run, under the same protocol,
against HAP 1.79 from the package's GitHub site. **1.79 is a large
improvement**: `ResolutionFiniteGroup` dies on 21 groups instead of 74, and
over the 190 groups both versions complete it takes 485,024 ms against
1,446,696 ms. Three groups regress — G(64,113), G(64,160) and G(64,241) are
resolved by 1.70 and die at 3 GB under 1.79 — and a handful of groups change
by one or two orders of magnitude in either direction.
[`bench/newhap/SUMMARY.md`](bench/newhap/SUMMARY.md) has the tables, the
memory ladder on G(64,241), and a calibration run that says which of these
numbers survive the difference in machine load between the two runs.

---

## bogomolov — a second opinion on `BogomolovMultiplier`

`B_0(G)` is the intersection, over the bicyclic subgroups `A <= G`, of the
kernels of the restrictions `H^2(G, Q/Z) -> H^2(A, Q/Z)` (Bogomolov 1987).

`bogomolov/b0_cocycle.g` computes it from that definition, dually, through a
Schur cover built with the `polycyclic` package — a code path that shares
nothing with HAP. On every group of orders 64, 128, 243, 729, 3125 and 16807
(267, 2328, 67, 504, 77 and 83 groups) it returns the same abelian invariants
as HAP's `BogomolovMultiplier`, with no disagreement.

Order 256 (56092 groups) has been run with HAP's function only, and is recorded
here for reference; it is **not** part of that agreement.

The file also produces and verifies a finite certificate for `B_0(G) != 0`.
The mathematics is in [`bogomolov/SPEC_ja.md`](bogomolov/SPEC_ja.md) (in
Japanese; the code comments in `b0_cocycle.g` are in English).

---

## chern — `c_2` as an Euler class

HAP has no Chern class function. For a two-dimensional complex representation
`W` of a finite group `H`, `c_2(W)` is the top Chern class, hence the Euler
class of the underlying oriented real bundle, and that class in
`H^4(H,Z) = Ext^4_{ZH}(Z,Z)` is the class of the exact sequence of cellular
chains of an `H`-CW structure on the unit sphere `S(W_R) = S^3`. Every
two-dimensional irreducible of a 2-group is monomial, so the sphere can be
taken as the join `S^1 * S^1` of the two coordinate circles.

`chern/c2_euler_lib.g` implements this. It uses neither Bocksteins nor cup
products, so it is independent of the usual route. `chern/calib.g` calibrates
it against `c_1 cup c_1` on abelian groups and against `Q_8`, `D_8`, `D_16`,
`SD_16`, `M_16` and `Q_16`; on some of these the agreement is modulo the
detection kernel, which the log records.

### The non-free case

The identification used here — for a cellular but **not free** action, the
Euler class as the class in `Ext^n_{ZG}(Z,Z)` of the cellular chain complex —
is classical for free actions (Swan's periodic resolutions). The non-free case
is Proposition 2.3 of A. Güçlükan and E. Yalçın, *The Euler class of a subset
complex*, Quart. J. Math. 61 (2010), 43–68, doi:10.1093/qmath/han025; why it
applies to the join structure used here is explained in
[chern/README.md](chern/README.md). The note this code comes from does not
depend on the identification: it proves separately that the conclusion is
unchanged without it.

---

## Running it

```
cd bench      && ./drive.sh          # the full 267-group benchmark (hours)
cd bench      && ./drive2.sh         # the other two methods on the 74 that died
cd bogomolov  && gap -q -b -T -o 2g crosscheck_example.g < /dev/null
cd chern      && gap -q -b -T -o 3g calib.g < /dev/null
```

Each directory's `results/` holds the recorded output of those runs.

## Author

Moe Tabei, independent researcher, Japan — <tabei@ryun.jp>

MIT licensed; see [LICENSE](LICENSE) and [NOTICE](NOTICE).

# bogomolov

A second implementation of the Bogomolov multiplier, independent of HAP.

`B_0(G)` is the intersection over the bicyclic subgroups `A = <a,b> <= G` of
the kernels of `res_A : H^2(G, Q/Z) -> H^2(A, Q/Z)` (Bogomolov 1987).
`b0_cocycle.g` computes it dually, as `M(G)/M_0(G)`, through a Schur cover
built as a pc group with the `polycyclic` package. It does not load HAP.

- `b0_cocycle.g` — `B0ViaSchurCover`, `B0CrossCheck`, and the certificate
  functions `B0Certificate` / `VerifyB0Certificate`.
- `b0_hap.g` — the reference run with HAP's `BogomolovMultiplier`.
- `crosscheck_example.g` — the driver that produced the logs in `results/`.
- `SPEC_ja.md` — the mathematics of the certificate (in Japanese).
- `results/` — `b0_order_<n>.txt` (HAP), `b0_cocycle_order_<n>_all.txt`
  (independent), and the comparison logs.

Agreement, with no disagreement anywhere:

| order | groups | with `B_0(G) != 0` | both implementations |
|---|---|---|---|
| 64 | 267 | 9 | yes |
| 128 | 2328 | 230 | yes |
| 243 | 67 | 3 | yes |
| 729 | 504 | 85 | yes |
| 3125 | 77 | 6 | yes |
| 16807 | 83 | 6 | yes |
| 256 | 56092 | 5953 | **HAP only** |

Orders 729 and 16807 were cross-checked with `B0_CHECK_AIM=false`, which skips
the sanity check of `|M(G)|` against `AbelianInvariantsMultiplier`; the
agreement of `B_0` itself is unaffected.

# chern

`c_2` of a two-dimensional irreducible representation as the Euler class of its
representation sphere. HAP provides no Chern class function; this route uses
only the cellular chain complex, and neither Bocksteins nor cup products, so it
is independent of the fitted route in `h3nr_phi13_lib.g`.

- `c2_euler_lib.g` — the Euler-class route.
- `h3nr_phi13_lib.g` — the supporting library (Bocksteins, `c_2` on abelian
  groups, restriction systems, negligible classes).
- `calib.g` — the calibration. Run it from this directory:
  `gap -q -b -T -o 3g calib.g < /dev/null`
- `results/calib.log` — the recorded run.

The calibration covers `c_1 cup c_1` on abelian groups and the groups `Q_8`,
`D_8`, `D_16`, `SD_16`, `M_16`, `Q_16`. On some of them the Euler value and the
fitted value agree only modulo the detection kernel; the log prints the kernel
order in each case.

See the top-level README for the one identification in this construction that
the author could not source in the literature.

# chern

`c_2` of a complex representation as an Euler class of its representation
sphere. HAP provides no Chern class function; this route uses only the cellular
chain complex, and neither Bocksteins nor cup products, so it is independent of
the usual one.

A worked example, with download instructions, is in
[TUTORIAL.md](TUTORIAL.md).

## `SecondChernClass.g` — the contributed function

Read it into GAP with HAP loaded:

```gap
gap> LoadPackage("HAP");;
gap> Read("SecondChernClass.g");
gap> G := SmallGroup(16,9);;                              # Q16
gap> R := ResolutionNormalSeries(LowerCentralSeries(G), 5);;
gap> chi := First(Irr(G), c -> Degree(c) = 2);;
gap> SecondChernClassOfCharacter(R, chi);
[ 12 ]
```

The answer is a vector of coordinates in `H^4(G,Z)`, in the basis and torsion
coefficients of `CR_CocyclesAndCoboundaries(R, 4, true)` (here `H^4(Q16,Z) =
Z/16`).

| function | |
|---|---|
| `SecondChernClassOfCharacter(R, chi)` | `c_2` of any character whose irreducible constituents have degree at most 2, by the Whitney formula |
| `EulerClassOfMonomialRepresentation(R, model)` | the Euler class of one monomial 2-dimensional representation, as a class |
| `EulerCocycleOfMonomialRepresentation(R, model)` | the same, as a 4-cocycle on the free generators of `R_4` — no cohomology presentation needed |
| `MonomialModelOfCharacter(G, chi)` | a monomial model of an irreducible `chi` of degree 2, as `Ind_K^G(lambda)` with `[G:K] = 2` |
| `MonomialModelOfLinearCharacterPair(G, mu1, mu2)` | the diagonal model of `mu1 (+) mu2` |
| `MonomialModelOfMatrixFunction(G, m, matfun[, full])` | a model from an explicit matrix function |
| `JoinComplexOfCyclicGroup(m)` | the cellular chain complex of `S^1 * S^1` with each circle an m-gon |

`R` must be a free resolution of length at least 4 for the cocycle and at least
5 for the class. Every irreducible representation of degree 2 of a nilpotent
group is monomial, so `MonomialModelOfCharacter` applies throughout the
nilpotent case; for other groups it reports that `chi` is not induced from a
subgroup of index 2.

The functions check themselves as they go: the chain complex is verified to be
exact with `H_3` of rank 1, the signs of the action are not assumed but are
determined by the chain-map property, the action is checked to be a left action
that preserves the fundamental cycle, and the image of each `d(e_{4,i})` is
checked to be an integral multiple of that cycle.

## The identification this rests on

> When a finite group `G` acts cellularly, but **not freely**, on the unit
> sphere `S(V)` of a real representation `V`, the Euler class `e(V)` in
> `H^n(G;Z)` is the class in `Ext^n_{ZG}(Z,Z)` of the exact sequence of
> cellular chains `0 -> Z -> C_{n-1}(S) -> ... -> C_0(S) -> Z -> 0`.

For **free** actions this is classical (Swan's periodic resolutions). The
non-free case is Proposition 2.3 of A. Güçlükan and E. Yalçın, *The Euler class
of a subset complex*, Quart. J. Math. 61 (2010), 43–68,
doi:10.1093/qmath/han025, stated there for any oriented real representation
with coefficients twisted by its sign; here `V` is complex, so the sign is
trivial and the coefficients are `Z`. The join structure on `S^1 * S^1` used
here is not a G-CW structure in the strict sense (some cells are mapped to
themselves with reversed orientation), but the class depends on the chain
complex only up to quasi-isomorphism, so it is the same class. Thanks to Graham
Ellis for the reference.

## Tests

`test_SecondChernClass.g` validates the function against routes that do **not**
use Euler classes:

- 200 pairs of linear characters on `C_4 x C_4`, `C_2 x C_4`, `C_2 x C_8` and
  `C_2 x C_2 x C_4`, against `c_1 cup c_1` computed with Bocksteins and cup
  products. This also fixes the universal sign, which is `+1`;
- `Q_8`, which acts freely on `S^3`, so that the identification above is the
  classical one: the Euler class must generate `H^4(Q_8,Z) = Z/8`, and it does;
- `D_8`, `D_16`, `Q_16`, `SD_16`, `M_16` and `G(64,206)`, against the class
  fitted from the restrictions to the maximal abelian subgroups, modulo the
  kernel of that detection — 24 irreducible representations of degree 2 in all;
- the error paths.

```
gap -q -b -T -o 3g test_SecondChernClass.g < /dev/null
```

`test_against_original.g` additionally checks that the contributed function
agrees, class for class, with the research prototype it was extracted from.

## The research prototype

- `c2_euler_lib.g` — the original code, kept for reference. It also contains
  the restriction machinery and a pc-group solver belonging to the larger
  computation rather than to the Chern class.
- `h3nr_phi13_lib.g` — the supporting library (Bocksteins, `c_2` on abelian
  groups, restriction systems, negligible classes). The tests use it for the
  independent routes.
- `calib.g`, `results/calib.log` — the original calibration.

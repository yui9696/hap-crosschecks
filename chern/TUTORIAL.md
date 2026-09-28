# Second Chern classes with HAP — a worked example

This example computes `c_2` of two-dimensional complex representations of
`Q_8` and `D_8` as Euler classes of representation spheres. The function is not
part of HAP; it is one file, `SecondChernClass.g`, read into GAP after HAP is
loaded.

## 1. Getting the file

Either download the single file:

```
curl -O https://raw.githubusercontent.com/yui9696/hap-crosschecks/main/chern/SecondChernClass.g
```

or clone the repository, which also gives the tests:

```
git clone https://github.com/yui9696/hap-crosschecks.git
cd hap-crosschecks/chern
```

Start GAP in the directory that holds `SecondChernClass.g`.

## 2. The quaternion group

`Q_8` acts freely on the unit sphere `S^3` of its two-dimensional irreducible
representation, so by Swan the second Chern class must generate
`H^4(Q_8,Z) = Z/8`.

```gap
gap> LoadPackage("HAP");;
gap> Read("SecondChernClass.g");
gap> G := SmallGroup(8,4);; StructureDescription(G);
"Q8"
gap> R := ResolutionFiniteGroup(G, 5);;
gap> CR_CocyclesAndCoboundaries(R, 4, true).torsionCoefficients;
[ 8 ]
gap> chi := First(Irr(G), c -> Degree(c) = 2);;
gap> SecondChernClassOfCharacter(R, chi);
[ 5 ]
```

The answer is the vector of coordinates of `c_2(chi)` in the generators of
`H^4(G,Z)` returned by `CR_CocyclesAndCoboundaries(R, 4, true)`. Here the class
is 5 in `Z/8`, a generator. The coordinates depend on the resolution, so
another resolution (or another version of HAP) may give a different generator;
the order of the class does not change.

## 3. The dihedral group

`D_8` does not act freely on `S^3`. Restricted to the cyclic subgroup of order
4 the representation splits as `lambda + lambda^-1`, where `c_2 = -c_1(lambda)^2`
has order 4, so `c_2(chi)` has order at least 4.

```gap
gap> G := SmallGroup(8,3);; StructureDescription(G);
"D8"
gap> R := ResolutionFiniteGroup(G, 5);;
gap> chi := First(Irr(G), c -> Degree(c) = 2);;
gap> CR_CocyclesAndCoboundaries(R, 4, true).torsionCoefficients;
[ 2, 2, 4 ]
gap> SecondChernClassOfCharacter(R, chi);
[ 1, 0, 1 ]
```

The class `[1,0,1]` in `Z/2 + Z/2 + Z/4` has order 4.

Any character whose irreducible constituents have degree at most 2 is accepted;
the Whitney formula is applied for you. For the sum `chi + chi` and for the
regular representation:

```gap
gap> SecondChernClassOfCharacter(R, chi + chi);
[ 1, 1, 2 ]
gap> SecondChernClassOfCharacter(R, Sum(Irr(G), c -> Degree(c) * c));
[ 0, 0, 2 ]
```

Both classes have order 2.

## 4. Checking the example

`tutorial_example.g` runs sections 2 and 3 and checks the orders of the
classes rather than their coordinates:

```
gap -q -b tutorial_example.g < /dev/null
```

It ends with `0 failures.` on GAP 4.15.1 with HAP 1.70 and with HAP 1.79 from
GitHub, in about 2 seconds.

## 5. What the computation rests on

For a two-dimensional monomial representation the unit sphere `S^3` is the
join of two circles, and the class computed is the extension class of its
cellular chain complex. That this class is the Euler class also when the
action is not free is Proposition 2.3 of

> A. Güçlükan and E. Yalçın, *The Euler class of a subset complex*,
> Quart. J. Math. 61 (2010), 43–68, doi:10.1093/qmath/han025.

The functions and their limits are described in [README.md](README.md), and
`test_SecondChernClass.g` compares them with routes that do not use Euler
classes.

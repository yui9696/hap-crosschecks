#############################################################################
##
##  tutorial_example.g
##
##  The worked example of TUTORIAL.md, as a script that checks its own
##  answers.  Run it from the directory that holds SecondChernClass.g:
##
##      gap -q -b tutorial_example.g < /dev/null
##
##  The coordinates of a class depend on the resolution, and so on the HAP
##  version; the ORDER of a class does not.  The checks are on orders.
##
#############################################################################

LoadPackage("HAP");;
Read("SecondChernClass.g");

# The order of the class with coordinates x in Z/t[1] + ... + Z/t[k].
OrderOfClass := function(x, t)
  return Lcm(List([1..Length(t)], i -> t[i] / Gcd(t[i], x[i])));
end;;

failures := 0;;
Check := function(name, got, want)
  if got = want then
    Print("  ok    ", name, " = ", got, "\n");
  else
    Print("  FAIL  ", name, " = ", got, ", expected ", want, "\n");
    failures := failures + 1;
  fi;
end;;

# Q8 acts freely on S^3, so c_2 of its 2-dimensional irreducible must
# generate H^4(Q8,Z) = Z/8 (Swan).
G := SmallGroup(8,4);;
R := ResolutionFiniteGroup(G, 5);;
t := CR_CocyclesAndCoboundaries(R, 4, true).torsionCoefficients;;
chi := First(Irr(G), c -> Degree(c) = 2);;
c2 := SecondChernClassOfCharacter(R, chi);;
Print("Q8:  H^4 = ", t, ",  c2(chi) = ", c2, "\n");
Check("H^4(Q8,Z)", t, [8]);
Check("order of c2(chi)", OrderOfClass(c2, t), 8);

# D8 does not act freely on S^3.  Restricted to the cyclic subgroup C4,
# chi = lambda + lambda^-1 and c2 = -c1(lambda)^2, of order 4.
G := SmallGroup(8,3);;
R := ResolutionFiniteGroup(G, 5);;
t := CR_CocyclesAndCoboundaries(R, 4, true).torsionCoefficients;;
chi := First(Irr(G), c -> Degree(c) = 2);;
Print("D8:  H^4 = ", t, "\n");
Check("H^4(D8,Z)", t, [2,2,4]);
Check("order of c2(chi)",
      OrderOfClass(SecondChernClassOfCharacter(R, chi), t), 4);
Check("order of c2(chi+chi)",
      OrderOfClass(SecondChernClassOfCharacter(R, chi + chi), t), 2);
Check("order of c2(regular)",
      OrderOfClass(SecondChernClassOfCharacter(R,
                     Sum(Irr(G), c -> Degree(c) * c)), t), 2);

Print("\n", failures, " failures.\n");
QUIT;

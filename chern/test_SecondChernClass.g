#############################################################################
##  Tests for SecondChernClass.g.
##
##  These do not compare against the research prototype; they compare against
##  routes that do not use the Euler class at all.
##
##    (i)   abelian groups: e(mu1 (+) mu2) against c1(mu1) cup c1(mu2),
##          computed with Bocksteins and cup products.  This also fixes the
##          universal sign.
##    (ii)  Q8 acts freely on S^3, where the identification is classical:
##          the Euler class must generate H^4(Q8,Z) = Z/8.
##    (iii) D8, D16, Q16, SD16, M16: against the class fitted from the
##          restrictions to the maximal abelian subgroups, modulo the kernel
##          of that detection.
##    (iv)  a group of order 64, for scale.
##    (v)   the error paths.
##
##  Run from this directory:  gap -q -b -T -o 3g test_SecondChernClass.g < /dev/null
#############################################################################
Read("h3nr_phi13_lib.g");          # C2OnAbelian, NegligibleClasses, VecToElt (no Euler classes)
Read("SecondChernClass.g");

fail_count := 0;;
Check := function(name, ok)
  if ok then Print("  ok    ", name, "\n");
  else Print("  FAIL  ", name, "\n"); fail_count := fail_count + 1; fi;
end;;
t0 := Runtime();;

Print("=== (i) abelian: Euler class of mu1 (+) mu2  vs  c1 cup c1 ===\n");
for A in [AbelianGroup([4,4]), AbelianGroup([2,4]), AbelianGroup([2,8]), AbelianGroup([2,2,4])] do
  RA := ResolutionFiniteGroup(A, 5);
  CR2 := CR_CocyclesAndCoboundaries(RA, 2, true);
  CR4 := CR_CocyclesAndCoboundaries(RA, 4, true);
  lin := Irr(A);
  n := 0; bad := 0;
  for i in [1..Minimum(4, Length(lin))] do
    for j in [i..Length(lin)] do
      cup := C2OnAbelian(RA, CR2, CR4, lin[i] + lin[j]);
      eu  := EulerClassOfMonomialRepresentation(RA,
               MonomialModelOfLinearCharacterPair(A, lin[i], lin[j]));
      n := n + 1;
      if eu <> cup then bad := bad + 1;
        Print("    MISMATCH ", AbelianInvariants(A), " ", [i,j], " euler ", eu, " cup ", cup, "\n");
      fi;
      # the Whitney assembly must agree too
      if SecondChernClassOfCharacter(RA, lin[i] + lin[j]) <> cup then
        bad := bad + 1;
        Print("    MISMATCH (Whitney) ", AbelianInvariants(A), " ", [i,j], "\n");
      fi;
    od;
  od;
  Check(Concatenation("A = ", String(AbelianInvariants(A)), "  ", String(n), " pairs"), bad = 0);
od;

Print("=== (ii) Q8: the Euler class generates H^4(Q8,Z) = Z/8 ===\n");
G := SmallGroup(8,4);;
RG := ResolutionNormalSeries(LowerCentralSeries(G), 5);;
CRG4 := CR_CocyclesAndCoboundaries(RG, 4, true);;
for s in Filtered(Irr(G), c -> Degree(c) = 2) do
  eu := EulerClassOfMonomialRepresentation(RG, MonomialModelOfCharacter(G, s));
  Check(Concatenation("Q8 faithful 2-dim: ", String(eu), " generates ",
                      String(CRG4.torsionCoefficients)),
        Gcd(eu[1], CRG4.torsionCoefficients[1]) = 1);
od;

Print("=== (iii) order 8 and 16: against the abelian-restriction fit ===\n");
for id in [[8,3],[16,7],[16,9],[16,8],[16,6]] do
  G := SmallGroup(id);
  RG := ResolutionNormalSeries(LowerCentralSeries(G), 5);
  CRG4 := CR_CocyclesAndCoboundaries(RG, 4, true);
  r := NegligibleClasses(G, RG, CRG4);
  two := Filtered(Irr(G), c -> Degree(c) = 2);
  bad := 0;
  for i in [1..Length(two)] do
    eu := EulerClassOfMonomialRepresentation(RG, MonomialModelOfCharacter(G, two[i]));
    if not (VecToElt(r.H4, eu) * VecToElt(r.H4, r.fits[i])^-1) in r.Ksub then
      bad := bad + 1;
      Print("    MISMATCH ", id, " irr ", i, " euler ", eu, " fit ", r.fits[i], "\n");
    fi;
  od;
  Check(Concatenation(String(id), " ", StructureDescription(G), "  ",
                      String(Length(two)), " irreducibles, |K| = ", String(Size(r.Ksub))),
        bad = 0);
od;

Print("=== (iv) a group of order 64, for scale ===\n");
G := SmallGroup(64,206);;
RG := ResolutionNormalSeries(LowerCentralSeries(G), 5);;
CRG4 := CR_CocyclesAndCoboundaries(RG, 4, true);;
r := NegligibleClasses(G, RG, CRG4);;
two := Filtered(Irr(G), c -> Degree(c) = 2);;
bad := 0;;
for i in [1..Length(two)] do
  eu := EulerClassOfMonomialRepresentation(RG, MonomialModelOfCharacter(G, two[i]));
  if not (VecToElt(r.H4, eu) * VecToElt(r.H4, r.fits[i])^-1) in r.Ksub then bad := bad + 1; fi;
od;
Check(Concatenation("G(64,206): ", String(Length(two)), " irreducibles of degree 2, H^4 = ",
                    String(CRG4.torsionCoefficients), ", |K| = ", String(Size(r.Ksub))), bad = 0);

Print("=== (v) error paths ===\n");
G := SmallGroup(16,7);;
RG := ResolutionNormalSeries(LowerCentralSeries(G), 5);;
res := CALL_WITH_CATCH(SecondChernClassOfCharacter, [RG, Irr(SmallGroup(16,7))[1]]);;
Check("a linear character is accepted", res[1] = true);
G2 := SymmetricGroup(4);;
R2 := ResolutionFiniteGroup(G2, 5);;
chi3 := First(Irr(G2), c -> Degree(c) = 3);;
res := CALL_WITH_CATCH(SecondChernClassOfCharacter, [R2, chi3]);;
Check("a degree 3 constituent is refused", res[1] = false);
res := CALL_WITH_CATCH(MonomialModelOfCharacter, [SmallGroup(21,1), First(Irr(SmallGroup(21,1)), c -> Degree(c) = 3)]);;
Check("a degree 3 character is refused by the model builder", res[1] = false);

Print("\n", fail_count, " failures.   total ", (Runtime()-t0)/1000.0, " s\n");
QUIT;

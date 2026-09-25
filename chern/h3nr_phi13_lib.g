# h3nr_phi13_lib.g  (2026-09-13)
# Negligible (Chern) classes in H^4(G,Z) via restriction to maximal abelian subgroups.
# Requires HAP.  Companion to Yamasaki's H3nr.gap (for H^4_p).
LoadPackage("HAP");

# ---- degree-4 Chern classes -------------------------------------------------

# value of a class function on an element
CFValue := function(chi, g)
  local cc;
  cc := ConjugacyClasses(UnderlyingGroup(chi));
  return chi[PositionProperty(cc, c -> g in c)];
end;

# a linear character chi of R!.group, as a homomorphism to Q/Z, lifted to Q:
# returns the 1-cochain ftilde on the degree-1 generators of R (values in Q).
LiftedH1Cochain := function(R, chi)
  local G, n1, v, i, w, j, d, val;
  G := R!.group;
  n1 := R!.dimension(1);
  v := List([1..n1], x -> 0);
  for i in [1..n1] do
    w := R!.boundary(1, i);          # list of [±1, j] : ± (elts[j]) * e_0
    for j in w do
      val := CFValue(chi, R!.elts[j[2]]);
      d := DescriptionOfRootOfUnity(val);   # val = E(d[1])^d[2]
      v[i] := v[i] + SignInt(j[1]) * (d[2] mod d[1]) / d[1];
    od;
  od;
  return v;
end;

# Bockstein delta: Hom(G,Q/Z) = H^1(G,Q/Z) -> H^2(G,Z), as a 2-cocycle vector on R
# (this is c_1(chi) up to a universal sign; the sign is irrelevant for c_2 = e_2(c_1's)).
BocksteinCocycle := function(R, chi)
  local v, M, i, l, w, j, u;
  v := LiftedH1Cochain(R, chi);
  M := [];
  for i in [1..R!.dimension(2)] do
    l := List([1..R!.dimension(1)], x -> 0);
    w := R!.boundary(2, i);
    for j in w do
      l[AbsInt(j[1])] := l[AbsInt(j[1])] + SignInt(j[1]);
    od;
    Add(M, l);
  od;
  M := TransposedMat(M);
  u := v * M;
  if not ForAll(u, IsInt) then Error("Bockstein: non-integral cocycle"); fi;
  return u;
end;

# c_1(chi) as an H^2 class vector (CR2 coordinates)
C1Class := function(R, CR2, chi)
  return CR2.cocycleToClass(BocksteinCocycle(R, chi));
end;

# c_2 of a (possibly reducible) character rho of the ABELIAN group A = R!.group,
# as an H^4(A,Z) class vector: rho = sum of linear lambda_i, c_2 = sum_{i<j} c1(lambda_i) c1(lambda_j).
C2OnAbelian := function(R, CR2, CR4, rho)
  local A, lin, lam, c1s, i, j, ans, n4, m, elts;
  A := R!.group;
  if not IsAbelian(A) then Error("C2OnAbelian: group not abelian"); fi;
  lin := Irr(A);
  elts := Elements(A);
  c1s := [];
  for lam in lin do
    # multiplicity by the orthogonality relation, evaluated elementwise
    m := Sum(elts, a -> CFValue(rho, a) * ComplexConjugate(CFValue(lam, a))) / Size(A);
    if not IsInt(m) or m < 0 then Error("bad multiplicity ", m); fi;
    for i in [1..m] do Add(c1s, C1Class(R, CR2, lam)); od;
  od;
  n4 := Length(CR4.torsionCoefficients);
  ans := List([1..n4], x -> 0);
  for i in [1..Length(c1s)] do
    for j in [i+1..Length(c1s)] do
      ans := ans + IntegralCupProduct(R, c1s[i], c1s[j], 2, 2, CR2, CR2, CR4);
    od;
  od;
  return List([1..n4], k -> ans[k] mod CR4.torsionCoefficients[k]);
end;

# ---- restriction to subgroups -----------------------------------------------

# maximal abelian subgroups up to conjugacy
MaximalAbelianSubgroupsUpToConjugacy := function(G)
  local abs, maxs, H, K;
  abs := Filtered(List(ConjugacyClassesSubgroups(G), Representative), IsAbelian);
  maxs := [];
  for H in abs do
    if not ForAny(abs, K -> Size(K) > Size(H) and
         ForAny(ConjugateSubgroups(G, K), c -> IsSubgroup(c, H))) then
      Add(maxs, H);
    fi;
  od;
  return maxs;
end;

# data for a subgroup A: resolution, CR2, CR4, restriction matrix of H^4(G) -> H^4(A)
SubgroupRestrictionData := function(RG, CRG4, A)
  local RA, CRA2, CRA4, incl, cm, mstar, n, M, e, u;
  RA := ResolutionFiniteGroup(A, 5);
  if RA!.group <> A then Error("ResolutionFiniteGroup changed the group"); fi;
  CRA2 := CR_CocyclesAndCoboundaries(RA, 2, true);
  CRA4 := CR_CocyclesAndCoboundaries(RA, 4, true);
  incl := GroupHomomorphismByFunction(A, RG!.group, x -> x);
  cm := EquivariantChainMap(RA, RG, incl);
  mstar := HomToIntegers(cm);
  n := Length(CRG4.torsionCoefficients);
  M := [];
  for e in IdentityMat(n) do
    u := CRG4.classToCocycle(e);
    u := Map(mstar)(u, 4);
    Add(M, CRA4.cocycleToClass(u));
  od;
  return rec(A := A, RA := RA, CR2 := CRA2, CR4 := CRA4, M := M,
             tor := CRA4.torsionCoefficients);
end;

# ---- linear algebra in H^4(G,Z) --------------------------------------------

VecToElt := function(H4, v)
  local gens;
  gens := GeneratorsOfGroup(H4);
  return Product([1..Length(gens)], i -> gens[i]^v[i]);
end;

# big matrix for the system  x * M_A == t_A  (mod tor_A) for all A
RestrictionSystem := function(tor, data)
  local n, rows, i, row, d, j, off, total;
  n := Length(tor);
  rows := [];
  for i in [1..n] do
    row := Concatenation(List(data, d -> d.M[i]));
    Add(rows, row);
  od;
  total := Sum(data, d -> Length(d.tor));
  off := 0;
  for d in data do
    for j in [1..Length(d.tor)] do
      row := List([1..total], x -> 0);
      row[off + j] := d.tor[j];
      Add(rows, row);
    od;
    off := off + Length(d.tor);
  od;
  return rows;
end;

# kernel of restriction to the family, as a list of vectors mod tor
RestrictionKernel := function(tor, data)
  local rows, N, n;
  n := Length(tor);
  rows := RestrictionSystem(tor, data);
  N := NullspaceIntMat(rows);
  return List(N, v -> List([1..n], i -> v[i] mod tor[i]));
end;

# solve for x with Res_A(x) = t_A for all A; returns x mod tor, or fail
FitClass := function(tor, data, targets)
  local rows, t, s, n;
  n := Length(tor);
  rows := RestrictionSystem(tor, data);
  t := Concatenation(targets);
  s := SolutionIntMat(rows, t);
  if s = fail then return fail; fi;
  return List([1..n], i -> s[i] mod tor[i]);
end;

# ---- main driver -------------------------------------------------------------

# returns a record with everything
NegligibleClasses := function(G, RG, CRG4)
  local tor, H4, gens, maxab, data, K, Ksub, irr, rho, targets, x, chern, fits,
        d, lin, chi, chi2, c1, c2, cup, direct, CRG2, cross, N0, sub2, i, j, t0;
  t0 := Runtime();
  tor := CRG4.torsionCoefficients;
  H4 := AbelianGroup(tor);
  maxab := MaximalAbelianSubgroupsUpToConjugacy(G);
  Print("maximal abelian subgroups (up to conj): ", List(maxab, A -> AbelianInvariants(A)), "\n");
  data := List(maxab, A -> SubgroupRestrictionData(RG, CRG4, A));
  Print("restriction data built, ", (Runtime()-t0)/1000.0, " s\n");
  K := RestrictionKernel(tor, data);
  Ksub := Subgroup(H4, List(K, v -> VecToElt(H4, v)));
  Print("Ker(Res to maximal abelian) has order ", Size(Ksub), "\n");
  irr := Irr(G);
  chern := [];
  fits := [];
  for rho in irr do
    if Degree(rho) = 1 then continue; fi;
    targets := List(data, d -> C2OnAbelian(d.RA, d.CR2, d.CR4, rho));
    x := FitClass(tor, data, targets);
    if x = fail then
      Print("!! no class restricts to the Chern data of an irreducible of degree ", Degree(rho), "\n");
      Add(fits, fail);
    else
      Add(fits, x);
      Add(chern, x);
      Print("c_2(irr deg ", Degree(rho), ") = ", x, "  (mod Ker)\n");
    fi;
  od;
  # cross-check: for linear chi, chi2 of G, c1 chi * c1 chi2 directly on G vs fitted
  CRG2 := CR_CocyclesAndCoboundaries(RG, 2, true);
  lin := Filtered(irr, c -> Degree(c) = 1);
  cross := true;
  cup := [];
  for i in [1..Length(lin)] do
    for j in [i..Length(lin)] do
      direct := IntegralCupProduct(RG, C1Class(RG, CRG2, lin[i]), C1Class(RG, CRG2, lin[j]), 2, 2, CRG2, CRG2, CRG4);
      direct := List([1..Length(tor)], k -> direct[k] mod tor[k]);
      Add(cup, direct);
      targets := List(data, d -> C2OnAbelian(d.RA, d.CR2, d.CR4, lin[i]+lin[j]));
      x := FitClass(tor, data, targets);
      if x = fail or not (VecToElt(H4, direct) * VecToElt(H4, x)^-1 in Ksub) then
        cross := false;
        Print("!! cross-check failed for linear pair ", [i,j], ": direct ", direct, " fitted ", x, "\n");
      fi;
    od;
  od;
  Print("cross-check (c1 c1 on G vs fitted through abelian subgroups): ", cross, "\n");
  N0 := Subgroup(H4, Concatenation(List(cup, v -> VecToElt(H4, v)), List(chern, v -> VecToElt(H4, v)), GeneratorsOfGroup(Ksub)));
  sub2 := Subgroup(H4, List(GeneratorsOfGroup(H4), g -> g^2));
  Print("H^4 = ", tor, " order ", Size(H4), "\n");
  Print("N0 := <c1c1 of G> + <c2(irr)> + Ker  has order ", Size(N0), "\n");
  Print("2*H^4 subset N0 ? ", IsSubgroup(N0, sub2), "\n");
  Print("time ", (Runtime()-t0)/1000.0, " s\n");
  return rec(tor := tor, H4 := H4, K := K, Ksub := Ksub, chern := chern, fits := fits,
             cup := cup, N0 := N0, cross := cross, maxab := maxab, data := data);
end;

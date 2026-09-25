# calib.g : calibration of the Euler-class (Yoneda) route against (i) c1 cup c1 on abelian groups
# (fixes the universal sign), (ii) Q8 (free action: Euler class must generate H^4 = Z/8),
# (iii) the order-16 groups of the original calibration table (fits via abelian restriction).
Read("h3nr_phi13_lib.g");
Read("c2_euler_lib.g");
t0 := Runtime();

# ---- (i) abelian groups: e(mu1 (+) mu2) vs c1(mu1) cup c1(mu2) ---------------------------
Print("=== (i) abelian calibration: Yoneda class of mu1(+)mu2 vs c1 cup c1 (original route)\n");
signs := [];
for A in [AbelianGroup([4,4]), AbelianGroup([2,4]), AbelianGroup([2,8]), AbelianGroup([2,2,4])] do
  RA := ResolutionFiniteGroup(A, 5);
  CR2 := CR_CocyclesAndCoboundaries(RA, 2, true);
  CR4 := CR_CocyclesAndCoboundaries(RA, 4, true);
  tor := CR4.torsionCoefficients;
  lin := Irr(A);
  nplus := 0; nminus := 0; nboth := 0; nnone := 0; neg := 0;
  for i in [1..Minimum(4, Length(lin))] do
    for j in [i..Length(lin)] do
      cup := C2OnAbelian(RA, CR2, CR4, lin[i] + lin[j]);        # original: sum_{a<b} c1 c1 = c1(mu_i) c1(mu_j)
      EULER_SIGN := 1;
      eu := EulerClass(RA, CR4, DiagonalModel(A, lin[i], lin[j]));
      neg := List([1..Length(tor)], k -> (-eu[k]) mod tor[k]);
      if eu = cup and neg = cup then nboth := nboth + 1;
      elif eu = cup then nplus := nplus + 1;
      elif neg = cup then nminus := nminus + 1;
      else nnone := nnone + 1; Print("  MISMATCH ", AbelianInvariants(A), " pair ", [i,j], " euler ", eu, " cup ", cup, "\n"); fi;
    od;
  od;
  Print("A = ", AbelianInvariants(A), " H^4 = ", tor, " pairs: sign+ ", nplus, " sign- ", nminus, " both(2-torsion) ", nboth, " none ", nnone, "\n");
  Add(signs, [nplus, nminus, nnone]);
od;
if ForAll(signs, s -> s[3] = 0) and ForAll(signs, s -> s[2] = 0) then EULER_SIGN := 1;
elif ForAll(signs, s -> s[3] = 0) and ForAll(signs, s -> s[1] = 0) then EULER_SIGN := -1;
else Error("calibration: no universal sign"); fi;
Print("==> universal sign EULER_SIGN = ", EULER_SIGN, "   (", (Runtime()-t0)/1000.0, " s)\n\n");

# ---- (ii) Q8 ----------------------------------------------------------------------------
Print("=== (ii) Q8: Euler class of the faithful 2-dim representation must generate H^4(Q8,Z) = Z/8\n");
G := SmallGroup(8,4);
RG := ResolutionNormalSeries(LowerCentralSeries(G), 5);
CRG4 := CR_CocyclesAndCoboundaries(RG, 4, true);
Print("H^4(Q8) = ", CRG4.torsionCoefficients, "\n");
r := NegligibleClasses(G, RG, CRG4);
for s in Filtered(Irr(G), c -> Degree(c) = 2) do
  eu := EulerClass(RG, CRG4, InducedModel(G, s));
  Print("  Euler class = ", eu, "  (generator? ", Gcd(eu[1], CRG4.torsionCoefficients[1]) = 1, ")",
        "  original fit mod K: ", r.fits[Position(Filtered(Irr(G), c -> Degree(c) = 2), s)], " K order ", Size(r.Ksub),
        "  agree mod K? ", (VecToElt(r.H4, eu) * VecToElt(r.H4, r.fits[Position(Filtered(Irr(G), c -> Degree(c) = 2), s)])^-1) in r.Ksub, "\n");
od;

# ---- (iii) D8, and the four groups of order 16 --------------------------------------------
Print("\n=== (iii) D8, D16, Q16, SD16, M16: Euler route vs abelian-restriction fit (original)\n");
for id in [[8,3],[16,7],[16,9],[16,8],[16,6]] do
  G := SmallGroup(id);
  Print("--- ", id, " ", StructureDescription(G), "\n");
  RG := ResolutionNormalSeries(LowerCentralSeries(G), 5);
  CRG4 := CR_CocyclesAndCoboundaries(RG, 4, true);
  r := NegligibleClasses(G, RG, CRG4);
  two := Filtered(Irr(G), c -> Degree(c) = 2);
  for i in [1..Length(two)] do
    eu := EulerClass(RG, CRG4, InducedModel(G, two[i]));
    Print("  deg-2 irr ", i, ": Euler c2 = ", eu, "   fit = ", r.fits[i], "   agree mod K (|K|=", Size(r.Ksub), ")? ",
          (VecToElt(r.H4, eu) * VecToElt(r.H4, r.fits[i])^-1) in r.Ksub, "\n");
  od;
  # also: c2 of the sum of all deg-2 irreducibles by C2ByEuler vs Whitney on fits (sanity of C2ByEuler)
od;
Print("\ncalibration total ", (Runtime()-t0)/1000.0, " s\n");
QUIT;

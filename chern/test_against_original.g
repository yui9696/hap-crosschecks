# Compare the contributed function against the original research code, class by class.
Read("h3nr_phi13_lib.g");
Read("c2_euler_lib.g");        # original: EulerClass, InducedModel, DiagonalModel, C2ByEuler
Read("SecondChernClass.g");    # new API

groups := [[8,4],[8,3],[16,7],[16,9],[16,8],[16,6]];;   # Q8, D8, D16, Q16, SD16, M16
names  := ["Q8","D8","D16","Q16","SD16","M16"];;
bad := 0;;
for t in [1..Length(groups)] do
  H := SmallGroup(groups[t][1], groups[t][2]);
  if IsAbelian(H) then R := ResolutionFiniteGroup(H,5);
  else R := ResolutionNormalSeries(LowerCentralSeries(H),5); fi;
  CR4 := CR_CocyclesAndCoboundaries(R, 4, true);
  Print("--- ", names[t], " ", groups[t], "  H^4 = ", CR4.torsionCoefficients, "\n");
  for chi in Filtered(Irr(H), c -> Degree(c) = 2) do
    old := EulerClass(R, CR4, InducedModel(H, chi));
    new := EulerClassOfMonomialRepresentation(R, MonomialModelOfCharacter(H, chi));
    Print("   deg-2 irr: old = ", old, "   new = ", new,
          "   equal ? ", old = new, "\n");
    if old <> new then bad := bad + 1; fi;
  od;
  # also compare the full Whitney assembly on a reducible character
  for chi in Filtered(Irr(H), c -> Degree(c) = 2) do
    W := chi + Irr(H)[1];                      # chi (+) trivial
    old := C2ByEuler(R, CR4, W);
    new := SecondChernClassOfCharacter(R, W);
    Print("   chi+1  : old = ", old, "   new = ", new, "   equal ? ", old = new, "\n");
    if old <> new then bad := bad + 1; fi;
  od;
  # a pair of linear characters
  lins := Filtered(Irr(H), c -> Degree(c) = 1);
  if Length(lins) >= 2 then
    old := EulerClass(R, CR4, DiagonalModel(H, lins[2], lins[3]));
    new := EulerClassOfMonomialRepresentation(R,
             MonomialModelOfLinearCharacterPair(H, lins[2], lins[3]));
    Print("   lin pair: old = ", old, "   new = ", new, "   equal ? ", old = new, "\n");
    if old <> new then bad := bad + 1; fi;
  fi;
od;
Print("\nTOTAL MISMATCHES: ", bad, "\n");
QUIT;

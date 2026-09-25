# B0 calibration via HAP BogomolovMultiplier (returns abelian invariants list)
LoadPackage("HAP", false);;
orders := [32, 64, 128, 243, 3125, 16807, 729, 256];;
for n in orders do
  t0 := Runtime(); cnt := 0; res := [];
  for i in [1..NrSmallGroups(n)] do
    B := BogomolovMultiplier(SmallGroup(n, i));
    if B <> [] then cnt := cnt + 1; Add(res, [i, B]); fi;
  od;
  Print("order ", n, ": ", NrSmallGroups(n), " groups, nontrivial B0: ", cnt, ", time ", (Runtime()-t0)/1000.0, " s\n");
  PrintTo(Concatenation("b0_order_", String(n), ".txt"), res, "\n");
od;
QUIT;

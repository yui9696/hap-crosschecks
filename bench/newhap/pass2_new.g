LoadPackage("HAP", false);;
i := IDX;;
G := SmallGroup(64, i);;
out := "results_new_pass2.txt";;
run := function(name, f)
  local t0, R, dt;
  AppendTo(out, i, " ", name, " START\n");
  t0 := Runtime(); R := f(G); dt := Runtime() - t0;
  AppendTo(out, i, " ", name, " DONE ", dt, " ms\n");
end;;
run("ResolutionGenericGroup", G -> ResolutionGenericGroup(G, 5));
run("ResolutionNormalSeries", G -> ResolutionNormalSeries(LowerCentralSeries(G), 5));
QUIT;

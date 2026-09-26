# Same protocol as ../one.g, but against the HAP on the GitHub site.
LoadPackage("HAP", false);;
i := IDX;;
G := SmallGroup(64, i);;
out := "results_new.txt";;
run := function(name, f)
  local t0, R, dt;
  AppendTo(out, i, " ", name, " START\n");
  t0 := Runtime();
  R := f(G);
  dt := Runtime() - t0;
  AppendTo(out, i, " ", name, " DONE ", dt, " ms  dims ",
           List([0..5], k -> R!.dimension(k)), "\n");
end;;
run("ResolutionFiniteGroup",  G -> ResolutionFiniteGroup(G, 5));
run("ResolutionGenericGroup", G -> ResolutionGenericGroup(G, 5));
run("ResolutionNormalSeries", G -> ResolutionNormalSeries(LowerCentralSeries(G), 5));
QUIT;

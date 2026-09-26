LoadPackage("HAP", false);;
Print("HAP ", PackageInfo("HAP")[1].Version, "\n");
G := SmallGroup(64, 241);;
t0 := Runtime();;
R := ResolutionFiniteGroup(G, 5);;
Print("ResolutionFiniteGroup(G(64,241),5) = ", Runtime()-t0, " ms   dims ",
      List([0..5], k -> R!.dimension(k)), "\n");
QUIT;

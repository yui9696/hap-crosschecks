LoadPackage("HAP", false);;
G := SmallGroup(64, 18);;
Print("starting ResolutionFiniteGroup(G(64,18), 5)\n");
R := ResolutionFiniteGroup(G, 5);;
Print("FINISHED dims ", List([0..5], k -> R!.dimension(k)), "\n");
QUIT;

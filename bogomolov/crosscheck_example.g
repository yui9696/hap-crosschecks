Read("b0_cocycle.g");
PrintTo("b0_cocycle_crosscheck.log", "# independent B0 (pc Schur cover via polycyclic Schur extension) vs HAP files b0_order_<n>.txt, 2026-09-06\n");
PrintTo("b0_cocycle_certs.log", "# certificate production (B0Certificate) + table-only verification (VerifyB0Certificate), 2026-09-06\n");
B0CrossCheckOrder(64, [1..NrSmallGroups(64)], "all");
B0CrossCheckOrder(243, [1..NrSmallGroups(243)], "all");
B0CrossCheckOrder(128, [1..NrSmallGroups(128)], "all");
for n in [64,243] do
  for x in ReadHAPResults(n) do
    D:=B0ViaSchurCoverData(SmallGroup(n,x[1]),true);
    AppendTo("b0_cocycle_crosscheck.log", "allpairs(literal |G|^2 commuting pairs) ", n, "#", x[1], ": ours=", D.inv, " hap=", x[2], "\n");
  od;
od;
B0CertifyOrder(64, List(ReadHAPResults(64), x->x[1]), true);
B0CertifyOrder(128, [36, 1544, 1988], false);
B0CertifyOrder(243, List(ReadHAPResults(243), x->x[1]), false);
for pair in [[64,149],[64,1],[128,1544],[243,28]] do
  cc:=NonB0ControlCertificate(SmallGroup(pair[1],pair[2]));
  if cc=fail then AppendTo("b0_cocycle_certs.log", "control ", pair, ": no non-B0 class available (M0(G)=0)\n");
  else v:=VerifyB0Certificate(cc,false);
    AppendTo("b0_cocycle_certs.log", "control(non-B0 class) ", pair, ": e=", cc.e, " cocycle=", v.cocycle, " nontriv_linalg=", v.nontrivial_linalg, " nontriv_group=", v.nontrivial_group, " bicyclic_sym=", v.bicyclic_symmetric, " OK=", v.ok, " (expected: true true true false false)\n");
  fi;
od;
B0CrossCheckOrder(3125, [1..NrSmallGroups(3125)], "all");
B0CrossCheckOrder(729, [1..NrSmallGroups(729)], "all");
B0CrossCheckOrder(16807, [1..NrSmallGroups(16807)], "all");
AppendTo("b0_cocycle_certs.log", "# done\n");
AppendTo("b0_cocycle_crosscheck.log", "# done\n");
QUIT;

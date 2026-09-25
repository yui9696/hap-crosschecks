# c2_euler_lib.g  (2026-09-13)  -- independent route to c_2 of representations
#
# Route: for a 2-dimensional complex representation W of a finite group H,
#   c_2(W) = e(W_R)   (top Chern class = Euler class of the underlying oriented real bundle),
# and e(W_R) in H^4(H,Z) = Ext^4_{ZH}(Z,Z) is (up to a universal sign) the Yoneda class of the
# exact sequence of ZH-modules
#   0 -> Z -> C_3(S) -> C_2(S) -> C_1(S) -> C_0(S) -> Z -> 0
# given by the cellular chains of an H-CW structure on the unit sphere S = S(W_R) = S^3.
# For a MONOMIAL 2-dimensional representation (entries in mu_m wr Sigma_2) we take
#   S^3 = S^1 * S^1  (join of the two coordinate circles, each with the m-gon structure),
# on which H acts cellularly.  The Yoneda class is computed by lifting the identity of Z to a
# chain map from a HAP free resolution R of H into C_*(S), i.e. the composite
#   R_4 --d--> R_3 --f_3--> C_3(S) --> ker(C_3 -> C_2) = Z.[S^3]
# is a 4-cocycle representing +-e(W_R).
#
# NOTHING here uses the Bockstein or the cup product.  Shared with the original computation:
# HAP resolutions (R!.boundary, R!.elts), CR_CocyclesAndCoboundaries (class coordinates),
# EquivariantChainMap/HomToIntegers (restriction maps), and GAP character theory.
#
# c_2 of a representation W = (+) W_j with rank(W_j) <= 2 is then
#   c_2(W) = sum_j c_2(W_j) + sum_{j<k} e( det W_j (+) det W_k ),
# (Whitney), again all terms being Euler classes of 2-dimensional representations.
LoadPackage("HAP");

# ---------- roots of unity as exponents ----------------------------------------------
# value x in mu_m  ->  a in [0..m-1] with x = E(m)^a
RootExponent := function(x, m)
  local d;
  d := DescriptionOfRootOfUnity(x);      # x = E(d[1])^d[2]
  if m mod d[1] <> 0 then Error("RootExponent: value not in mu_m"); fi;
  return (d[2] * (m / d[1])) mod m;
end;

CFValueLib := function(chi, g)
  local cc;
  cc := ConjugacyClasses(UnderlyingGroup(chi));
  return chi[PositionProperty(cc, c -> g in c)];
end;

# ---------- monomial 2x2 matrix models ------------------------------------------------
# A "monomial model" of a 2-dim representation of H is a record
#   rec(H, m, elts, mat := list of 2x2 cyclotomic matrices (column convention: image of e_j is column j),
#       perm := list of permutations of [1,2], expo := list of [a1,a2])
# with  sigma(h) e_j = E(m)^{a_j} e_{perm(j)}.

MonomialModelFromMatrices := function(H, m, matfun)
  local elts, mats, perm, expo, i, j, M, p, a, k, ok, g, h;
  elts := Elements(H);
  mats := List(elts, matfun);
  # homomorphism check (all pairs) -- matrices act on column vectors: M(gh) = M(g) M(h)
  ok := true;
  for i in [1..Length(elts)] do
    for j in [1..Length(elts)] do
      if mats[i] * mats[j] <> mats[Position(elts, elts[i]*elts[j])] then ok := false; fi;
    od;
  od;
  if not ok then Error("MonomialModel: not a homomorphism"); fi;
  perm := []; expo := [];
  for i in [1..Length(elts)] do
    M := mats[i];
    p := []; a := [];
    for j in [1..2] do
      k := PositionProperty([1..2], r -> M[r][j] <> 0);
      if k = fail or Number([1..2], r -> M[r][j] <> 0) <> 1 then Error("not monomial"); fi;
      p[j] := k;
      a[j] := RootExponent(M[k][j], m);
    od;
    if p[1] = p[2] then Error("not monomial"); fi;
    Add(perm, p); Add(expo, a);
  od;
  return rec(H := H, m := m, elts := elts, mat := mats, perm := perm, expo := expo);
end;

# diagonal model for a pair of linear characters (mu1, mu2) of H
DiagonalModel := function(H, mu1, mu2)
  local m;
  m := Exponent(H);
  return MonomialModelFromMatrices(H, m, h -> [[CFValueLib(mu1,h), 0],[0, CFValueLib(mu2,h)]]);
end;

# induced model for an irreducible 2-dim character sigma of H: find K of index 2, lambda linear
# with Ind lambda = sigma; basis (v, g v).  Returns the model; checks the trace.
InducedModel := function(H, sigma)
  local m, cands, K, lam, g, matfun, model, h, tr;
  m := Exponent(H);
  for K in Filtered(List(ConjugacyClassesSubgroups(H), Representative), S -> Index(H,S) = 2) do
    for lam in Filtered(Irr(K), c -> Degree(c) = 1) do
      if InducedClassFunction(lam, H) = sigma then
        g := First(Elements(H), x -> not x in K);
        matfun := function(h)
          if h in K then
            return [[CFValueLib(lam, h), 0], [0, CFValueLib(lam, g^-1*h*g)]];
          else
            # v -> lam(g^-1 h) w ,  w -> lam(h g) v
            return [[0, CFValueLib(lam, h*g)], [CFValueLib(lam, g^-1*h), 0]];
          fi;
        end;
        model := MonomialModelFromMatrices(H, m, matfun);
        # trace check
        for h in model.elts do
          tr := TraceMat(model.mat[Position(model.elts, h)]);
          if tr <> CFValueLib(sigma, h) then Error("InducedModel: trace mismatch"); fi;
        od;
        model.K := K; model.lambda := lam; model.g := g;
        return model;
      fi;
    od;
  od;
  Error("InducedModel: no inducing pair found");
end;

# ---------- the join complex S^1 * S^1 --------------------------------------------------
# circle cells: [d, k], d in {-1 (empty), 0 (vertex at E(m)^k), 1 (edge from E(m)^k to E(m)^{k+1})}
# join cells: [x, y] with x on circle 1, y on circle 2, not both empty; degree = d_x + d_y + 1.
JoinComplex := function(m)
  local circ, cells, n, x, y, deg, pos, bnd, i, c, terms, t, dx, dy, s, mat, res, addterm, dcirc;
  circ := Concatenation([[-1,0]], List([0..m-1], k -> [0,k]), List([0..m-1], k -> [1,k]));
  cells := List([0..3], n -> []);
  for x in circ do for y in circ do
    deg := x[1] + y[1] + 1;
    if deg >= 0 then Add(cells[deg+1], [x,y]); fi;
  od; od;
  pos := List([0..3], n -> (c -> Position(cells[n+1], c)));
  # augmented boundary of a circle cell: list of [coeff, cell]
  dcirc := function(x)
    if x[1] = -1 then return []; fi;
    if x[1] = 0 then return [[1, [-1,0]]]; fi;
    return [[1, [0, (x[2]+1) mod m]], [-1, [0, x[2]]]];
  end;
  # boundary matrices bnd[n+1] : rows = cells of degree n, columns = cells of degree n-1
  # (degree -1 = the single cell [empty,empty], handled as a vector of length 1)
  bnd := [];
  for n in [0..3] do
    mat := [];
    for c in cells[n+1] do
      x := c[1]; y := c[2];
      if n = 0 then res := [0]; else res := List(cells[n], z -> 0); fi;
      terms := [];
      for t in dcirc(x) do Add(terms, [t[1], [t[2], y]]); od;
      for t in dcirc(y) do Add(terms, [(-1)^(x[1]+1) * t[1], [x, t[2]]]); od;
      for t in terms do
        if n = 0 then res[1] := res[1] + t[1];
        else
          i := pos[n](t[2]);
          if i = fail then Error("JoinComplex: boundary cell not found"); fi;
          res[i] := res[i] + t[1];
        fi;
      od;
      Add(mat, res);
    od;
    Add(bnd, mat);
  od;
  # checks: d d = 0, exactness (reduced homology zero in degrees -1..2, Z in degree 3)
  for n in [1..3] do
    if not IsZero(bnd[n+1] * bnd[n]) then Error("JoinComplex: dd <> 0 in degree ", n); fi;
  od;
  # augmentation: every vertex maps to +1
  if ForAny(bnd[1], r -> r <> [1]) then Error("JoinComplex: augmentation"); fi;
  for n in [0..2] do
    # ker(bnd[n+1]) / im(bnd[n+2]) must vanish : compare ranks and SNF
    s := SmithNormalFormIntegerMat(bnd[n+2]);
    if Length(cells[n+1]) - RankMat(bnd[n+1]) <> RankMat(bnd[n+2]) then
      Error("JoinComplex: not exact in degree ", n); fi;
    if ForAny(DiagonalOfMat(s), d -> not d in [0,1,-1]) then Error("JoinComplex: torsion in degree ", n); fi;
  od;
  if Length(cells[4]) - RankMat(bnd[4]) <> 1 then Error("JoinComplex: H_3 not of rank 1"); fi;
  return rec(m := m, cells := cells, pos := pos, bnd := bnd);
end;

# action of a monomial element (perm p, exponents a) on the join complex: signed permutation
# matrices A[n+1] (rows = cells of degree n): (g.v) = v * A[n+1].
# Sign rule for a swap: Koszul sign (-1)^{d_x d_y} on x (x) y -> y' (x) x'; verified below by the
# chain-map property.
JoinAction := function(J, p, a)
  local m, A, n, c, x, y, xs, ys, img, sgn, i, mat, cimg, k, v, row;
  m := J.m;
  cimg := function(x, j)      # image of circle cell x on circle j: cell on circle p[j]
    if x[1] = -1 then return x; fi;
    return [x[1], (x[2] + a[j]) mod m];
  end;
  A := [];
  for n in [0..3] do
    mat := NullMat(Length(J.cells[n+1]), Length(J.cells[n+1]));
    for i in [1..Length(J.cells[n+1])] do
      c := J.cells[n+1][i]; x := c[1]; y := c[2];
      xs := cimg(x, 1); ys := cimg(y, 2);
      if p[1] = 1 then img := [xs, ys]; else img := [ys, xs]; fi;
      k := J.pos[n+1](img);
      if k = fail then Error("JoinAction: image cell not found"); fi;
      if n = 0 then sgn := 1;
      else
        # the sign is forced by the chain-map property: g.(d c) = sgn * d(c')
        v := J.bnd[n+1][i] * A[n];        # g.(d c) in C_{n-1}
        row := J.bnd[n+1][k];             # d(c')
        if v = row then sgn := 1;
        elif v = -row then sgn := -1;
        else Error("JoinAction: g.(dc) is not +-d(c')"); fi;
      fi;
      mat[i][k] := sgn;
    od;
    Add(A, mat);
  od;
  # chain-map check (row-vector convention: (g.v) = v*A)
  for n in [1..3] do
    if A[n+1] * J.bnd[n+1] <> J.bnd[n+1] * A[n] then Error("JoinAction: not a chain map"); fi;
  od;
  return A;
end;

# fundamental cycle of S^3, normalised so that the coefficient of edge(1,0) (x) edge(2,0) is +1
FundamentalCycle := function(J)
  local N, z, i;
  N := NullspaceIntMat(J.bnd[4]);
  if Length(N) <> 1 then Error("FundamentalCycle: rank"); fi;
  z := N[1];
  i := J.pos[4]([[1,0],[1,0]]);
  if AbsInt(z[i]) <> 1 then Error("FundamentalCycle: not primitive at the reference cell"); fi;
  return z * z[i];
end;

# ---------- the Yoneda / Euler class ---------------------------------------------------
# R: HAP free ZH-resolution (R!.group = model.H), model: monomial model, J: join complex.
# Returns the 4-cocycle (values on the free generators of R_4) representing the Yoneda class.
EulerCocycle := function(R, model, J)
  local H, elts, act, A, i, g, z, f, n, rhs, w, t, gi, x, coc, k, idx, dimn;
  H := model.H;
  if R!.group <> H then Error("EulerCocycle: resolution of a different group"); fi;
  elts := model.elts;
  # signed-permutation action for each element of R!.elts
  act := [];
  for i in [1..Length(R!.elts)] do
    g := R!.elts[i];
    gi := Position(elts, g);
    if gi = fail then Error("EulerCocycle: element outside H"); fi;
    act[i] := JoinAction(J, model.perm[gi], model.expo[gi]);
  od;
  # group-action check on a generating set (A(gh) = A(h) A(g) in row-vector convention... check both orders)
  for g in GeneratorsOfGroup(H) do
    i := Position(R!.elts, g);
    for k in [1..Length(R!.elts)] do
      idx := Position(R!.elts, R!.elts[i]*R!.elts[k]);
      if idx = fail then continue; fi;
      # left action: (gh).v = g.(h.v) = (v*A_h)*A_g = v*(A_h*A_g)
      if act[idx][4] <> act[k][4]*act[i][4] then Error("EulerCocycle: not a left action"); fi;
    od;
  od;
  z := FundamentalCycle(J);
  for i in [1..Length(R!.elts)] do
    if z * act[i][4] <> z then Error("EulerCocycle: orientation not preserved"); fi;
  od;
  # lift: f[n+1][i] = image in C_n of the i-th free generator of R_n
  f := [];
  if R!.dimension(0) <> 1 then Error("EulerCocycle: R_0 not of rank 1"); fi;
  f[1] := [ List(J.cells[1], c -> 0) ]; f[1][1][1] := 1;     # e_0 -> vertex 1
  for n in [1..3] do
    f[n+1] := [];
    for i in [1..R!.dimension(n)] do
      w := R!.boundary(n, i);                   # word: list of [+-i', j] = +- elts[j].e_{i'}
      rhs := List(J.cells[n], c -> 0);
      for t in w do
        rhs := rhs + SignInt(t[1]) * (f[n][AbsInt(t[1])] * act[t[2]][n]);
      od;
      x := SolutionIntMat(J.bnd[n+1], rhs);
      if x = fail then Error("EulerCocycle: lift failed in degree ", n); fi;
      Add(f[n+1], x);
    od;
  od;
  # degree 4: f_3(d e_{4,i}) is a multiple of z
  coc := [];
  for i in [1..R!.dimension(4)] do
    w := R!.boundary(4, i);
    rhs := List(J.cells[4], c -> 0);
    for t in w do
      rhs := rhs + SignInt(t[1]) * (f[4][AbsInt(t[1])] * act[t[2]][4]);
    od;
    if not IsZero(rhs * J.bnd[4]) then Error("EulerCocycle: not a cycle"); fi;
    k := rhs[J.pos[4]([[1,0],[1,0]])];
    if rhs <> k * z then Error("EulerCocycle: not a multiple of the fundamental cycle"); fi;
    Add(coc, k);
  od;
  return coc;
end;

# Euler class of a monomial model, as an H^4(H,Z) class vector (CR4 coordinates), times the
# universal sign EULER_SIGN (to be fixed by calibration; default +1).
EULER_SIGN := 1;
JOIN_CACHE := [];
CachedJoinComplex := function(m)
  if not IsBound(JOIN_CACHE[m]) then JOIN_CACHE[m] := JoinComplex(m); fi;
  return JOIN_CACHE[m];
end;
EulerClass := function(R, CR4, model)
  local J, coc, tor;
  J := CachedJoinComplex(model.m);
  coc := EulerCocycle(R, model, J);
  tor := CR4.torsionCoefficients;
  return List([1..Length(tor)], k -> (EULER_SIGN * CR4.cocycleToClass(coc)[k]) mod tor[k]);
end;

# ---------- c_2 of a representation W of H all of whose irreducible constituents have degree <= 2
# W given as a character. Returns H^4(H,Z) class vector.
C2ByEuler := function(R, CR4, W)
  local H, tor, cons, pieces, c, mult, i, j, ans, dets;
  H := R!.group;
  tor := CR4.torsionCoefficients;
  cons := ConstituentsOfCharacter(W);
  pieces := [];      # list of irreducible constituents with multiplicity
  for c in cons do
    if Degree(c) > 2 then Error("C2ByEuler: constituent of degree > 2"); fi;
    mult := ScalarProduct(W, c);
    for i in [1..mult] do Add(pieces, c); od;
  od;
  ans := List(tor, t -> 0);
  for c in pieces do
    if Degree(c) = 2 then
      ans := ans + EulerClass(R, CR4, InducedModel(H, c));
    fi;
  od;
  dets := List(pieces, DeterminantOfCharacter);
  for i in [1..Length(pieces)] do
    for j in [i+1..Length(pieces)] do
      ans := ans + EulerClass(R, CR4, DiagonalModel(H, dets[i], dets[j]));
    od;
  od;
  return List([1..Length(tor)], k -> ans[k] mod tor[k]);
end;

# ---------- restriction data (HAP chain maps; shared with the original) ----------------
ResData := function(RG, CRG4, H)
  local RH, CRH4, incl, cm, mstar, n, M, e, u;
  if IsAbelian(H) then RH := ResolutionFiniteGroup(H, 5);
  else RH := ResolutionNormalSeries(LowerCentralSeries(H), 5); fi;
  if RH!.group <> H then Error("ResData: resolution changed the group"); fi;
  CRH4 := CR_CocyclesAndCoboundaries(RH, 4, true);
  incl := GroupHomomorphismByFunction(H, RG!.group, x -> x);
  cm := EquivariantChainMap(RH, RG, incl);
  mstar := HomToIntegers(cm);
  n := Length(CRG4.torsionCoefficients);
  M := [];
  for e in IdentityMat(n) do
    u := CRG4.classToCocycle(e);
    u := Map(mstar)(u, 4);
    Add(M, CRH4.cocycleToClass(u));
  od;
  return rec(H := H, RH := RH, CR4 := CRH4, M := M, tor := CRH4.torsionCoefficients);
end;

# ---------- an independent solver: pc-group arithmetic instead of integer matrices ---------
# data: list of ResData records; targets: list of class vectors (one per H).  Returns
# rec(kernel := subgroup of H4G, solutions := list of all class vectors x with Res_H x = t_H, or
# [] if none).
ToElt := function(A, v)
  local gens;
  gens := GeneratorsOfGroup(A);
  return Product([1..Length(gens)], i -> gens[i]^v[i]);
end;
ToVec := function(A, tor, x)
  local v;
  for v in Cartesian(List(tor, t -> [0..t-1])) do
    if ToElt(A, v) = x then return v; fi;
  od;
  Error("ToVec: element not found");
end;

PcSolver := function(torG, data)
  local H4G, H4Hs, D, phi, imgs, i, d, g, emb;
  H4G := AbelianGroup(torG);
  H4Hs := List(data, d -> AbelianGroup(d.tor));
  D := DirectProduct(H4Hs);
  imgs := [];
  for g in GeneratorsOfGroup(H4G) do
    Add(imgs, Product([1..Length(data)], i ->
      Image(Embedding(D, i), ToElt(H4Hs[i], data[i].M[Position(GeneratorsOfGroup(H4G), g)]))));
  od;
  phi := GroupHomomorphismByImages(H4G, D, GeneratorsOfGroup(H4G), imgs);
  if phi = fail then Error("PcSolver: restriction is not a homomorphism"); fi;
  return rec(H4G := H4G, H4Hs := H4Hs, D := D, phi := phi, kernel := Kernel(phi),
    solve := function(targets)
      local t, x, K;
      t := Product([1..Length(data)], i -> Image(Embedding(D, i), ToElt(H4Hs[i], targets[i])));
      if not t in Image(phi) then return []; fi;
      x := PreImagesRepresentative(phi, t);
      K := Kernel(phi);
      return List(Elements(K), k -> ToVec(H4G, torG, x*k));
    end);
end;

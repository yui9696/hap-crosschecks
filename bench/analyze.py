#!/usr/bin/env python3
"""Turn results.txt/exits.txt into the per-group table."""
import collections, sys

st=collections.defaultdict(set); dn={}; dims={}
for l in open("results.txt"):
    p=l.split()
    if len(p)<3: continue
    i,meth,tag=int(p[0]),p[1],p[2]
    if tag=="START": st[meth].add(i)
    elif tag=="DONE":
        dn.setdefault(meth,{})[i]=int(p[3])
        if "dims" in l: dims.setdefault(meth,{})[i]=l.split("dims",1)[1].strip()

METHS=["ResolutionFiniteGroup","ResolutionGenericGroup","ResolutionNormalSeries"]
attempted=sorted(st["ResolutionFiniteGroup"])
print(f"groups attempted: {len(attempted)} (ids {min(attempted)}..{max(attempted)})\n")

print(f"{'method':<24} {'completed':>9} {'died':>6} {'total ms (completed)':>22} {'median ms':>10} {'max ms':>10}")
for m in METHS:
    done=dn.get(m,{})
    died=sorted(st[m]-set(done))
    ts=sorted(done.values())
    med=ts[len(ts)//2] if ts else 0
    print(f"{m:<24} {len(done):>9} {len(died):>6} {sum(ts):>22} {med:>10} {max(ts) if ts else 0:>10}")

rfg_died=sorted(st["ResolutionFiniteGroup"]-set(dn.get("ResolutionFiniteGroup",{})))
print(f"\nResolutionFiniteGroup died (3 GB limit) on {len(rfg_died)} groups:")
print("  " + ", ".join(str(i) for i in rfg_died))

# groups where the other two succeeded but RFG died
both_ok=[i for i in rfg_died
         if i in dn.get("ResolutionGenericGroup",{}) and i in dn.get("ResolutionNormalSeries",{})]
print(f"\nof those, the other two methods completed on {len(both_ok)} groups")

common=set(dn.get("ResolutionFiniteGroup",{}))&set(dn.get("ResolutionGenericGroup",{}))
if common:
    a=sum(dn["ResolutionFiniteGroup"][i] for i in common)
    b=sum(dn["ResolutionGenericGroup"][i] for i in common)
    c=sum(dn["ResolutionNormalSeries"][i] for i in common)
    print(f"\non the {len(common)} groups where all completed:")
    print(f"  ResolutionFiniteGroup  {a:>9} ms")
    print(f"  ResolutionGenericGroup {b:>9} ms   ({a/b:.0f}x faster)")
    print(f"  ResolutionNormalSeries {c:>9} ms   ({a/c:.0f}x faster)")

with open("table.tsv","w") as f:
    f.write("id\tRFG_ms\tRGG_ms\tRNS_ms\n")
    for i in attempted:
        row=[str(i)]
        for m in METHS:
            v=dn.get(m,{}).get(i)
            row.append(str(v) if v is not None else "DIED")
        f.write("\t".join(row)+"\n")
print("\nper-group table written to table.tsv")

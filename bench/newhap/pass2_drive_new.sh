#!/bin/zsh
# The other two strategies on the groups where 1.79's ResolutionFiniteGroup died.
cd "$(dirname "$0")"
if [ -z "$HAPROOT" ]; then echo "set HAPROOT to the GAP root holding pkg/hap" >&2; exit 2; fi
: > results_new_pass2.txt
for i in 18 63 64 75 82 100 113 160 168 171 172 217 220 222 236 237 240 241 243 245 266; do
  sed "s/IDX/$i/" pass2_new.g > _cur2n.g
  timeout 600 gap -l "$HAPROOT;" -q -b -T -o 3g _cur2n.g < /dev/null > /dev/null 2>&1
done

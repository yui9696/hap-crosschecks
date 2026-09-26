#!/bin/zsh
# All 267 groups of order 64 against a HAP checked out from GitHub.
#
#   git clone --depth 1 https://github.com/gap-packages/hap.git <root>/pkg/hap
#   HAPROOT=<root> ./drive_new.sh
#
# <root> is a GAP root directory, i.e. it contains a pkg/ subdirectory.  It is
# prepended to GAP's root paths so the installed HAP is left alone.
cd "$(dirname "$0")"
if [ -z "$HAPROOT" ]; then echo "set HAPROOT to the GAP root holding pkg/hap" >&2; exit 2; fi
: > results_new.txt
: > exits_new.txt
for i in $(seq 1 267); do
  sed "s/IDX/$i/" one_new.g > _cur_new.g
  s=$(python3 -c 'import time;print(time.time())')
  timeout 600 gap -l "$HAPROOT;" -q -b -T -o 3g _cur_new.g < /dev/null > /dev/null 2>&1
  rc=$?
  e=$(python3 -c 'import time;print(time.time())')
  echo "$i exit=$rc wall=$(python3 -c "print(round($e-$s,1))")" >> exits_new.txt
done
echo "NEW ALL DONE" >> exits_new.txt

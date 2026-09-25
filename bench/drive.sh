#!/bin/zsh
# Per-group isolation: one GAP process per group, 3 GB cap, 600 s timeout.
cd "$(dirname "$0")"
: > results.txt
: > exits.txt
for i in $(seq 1 267); do
  sed "s/IDX/$i/" one.g > _cur.g
  timeout 600 gap -q -b -T -o 3g _cur.g < /dev/null > /dev/null 2>&1
  echo "$i exit=$?" >> exits.txt
done
echo "ALL DONE" >> exits.txt

#!/bin/zsh
cd "$(dirname "$0")"
: > results_pass2.txt
: > exits_pass2.txt
for i in $(cat died_ids.txt); do
  sed "s/IDX/$i/" pass2_one.g > _cur2.g
  timeout 600 gap -q -b -T -o 3g _cur2.g < /dev/null > /dev/null 2>&1
  echo "$i exit=$?" >> exits_pass2.txt
done
echo "PASS2 DONE" >> exits_pass2.txt

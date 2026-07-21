#!/bin/zsh
# Remaining extended k=2,3 slices, each internally 12-way parallel (geng res/mod).
set -e
cd ~/open_problem_mining
GENG=/opt/homebrew/bin/geng
R=k23_results

run_slice () {
  local tag=$1 dlo=$2 dhi=$3 n=$4
  echo "--- $tag (n=$n, degrees [$dlo,$dhi])"
  for k in {0..11}; do
    ( $GENG -cq -d$dlo -D$dhi $n $k/12 2>/dev/null | python3 stage2_k23.py \
        > $R/wit_${tag}_$k.txt 2> $R/stats_${tag}_$k.txt ) &
  done
  wait
  cat $R/wit_${tag}_*.txt > $R/wit_${tag}.txt
  local wc=$(grep -c WITNESS $R/wit_${tag}.txt || true)
  local tot=$(cat $R/stats_${tag}_*.txt | awk -F'[= ]' '{c+=$3} END {print c}')
  echo "$tag: checked=$tot witnesses=$wc"
}

run_slice reg_n14_d6 6 6 14
run_slice bideg_n12_23 2 3 12
run_slice bideg_n12_34 3 4 12
run_slice bideg_n12_45 4 5 12
run_slice bideg_n12_56 5 6 12
run_slice bideg_n13_23 2 3 13
run_slice bideg_n13_34 3 4 13
run_slice bideg_n13_45 4 5 13
run_slice bideg_n13_56 5 6 13
echo "PARALLEL EXTENDED COMPLETE"

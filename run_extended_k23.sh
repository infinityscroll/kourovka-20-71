#!/bin/zsh
# Exploratory Kourovka 20.71 k=2,3 sweeps beyond n=11 on tractable slices:
#  (a) selected regular graphs;
#  (b) selected near-regular graphs with degrees in a window [a, a+1].
# These slices are not exhaustive: generation is restricted to connected
# graphs, and complementation need not preserve connectivity.
set -e
SCRIPT_DIR=${0:A:h}
cd "$SCRIPT_DIR"
GENG=/opt/homebrew/bin/geng
mkdir -p k23_results

echo "=== (a) regular graphs n=12..14 ==="
for n in 12 13 14; do
  for d in $(seq 2 $(( (n-1)/2 ))); do
    # regular graphs need n*d even
    if (( (n * d) % 2 == 0 )); then
      echo "--- n=$n d=$d"
      $GENG -cq -d$d -D$d $n | python3 stage2_k23.py \
        > k23_results/wit_reg_n${n}_d${d}.txt 2> k23_results/stats_reg_n${n}_d${d}.txt
      tail -1 k23_results/stats_reg_n${n}_d${d}.txt
    fi
  done
done

echo "=== (b) bidegreed window graphs n=12,13 ==="
for n in 12 13; do
  for a in 2 3 4 5; do
    echo "--- n=$n degrees in [$a,$((a+1))]"
    $GENG -cq -d$a -D$((a+1)) $n | ./degfilter | python3 stage2_k23.py \
      > k23_results/wit_bideg_n${n}_a${a}.txt 2> k23_results/stats_bideg_n${n}_a${a}.txt
    tail -1 k23_results/stats_bideg_n${n}_a${a}.txt
  done
done
echo "EXTENDED SWEEPS COMPLETE"

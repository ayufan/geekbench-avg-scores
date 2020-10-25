#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "$0 <query>"
  exit 1
fi

query="$@"

maxPages=50
queryEncoded=$(node -p "encodeURIComponent('$query')")

search() {
  for page in $(seq 1 $maxPages); do
    echo -ne " -> Downloading page $page\033[0K\r" 1>&2

    result=$(curl -s https://browser.geekbench.com/v4/cpu/search\?utf8=%E2%9C%93\&page\=${page}\&q\=$queryEncoded)
    echo "$result"

    if echo "$result" | grep -q "did not match any Geekbench 4 results"; then
      echo 1>&2
      break
    fi
  done
}

scores() {
  search | grep -A 1 "<td class='score'>" | grep '^[1-9][0-9]*$'
}

printf "Average Geekbench 4 scores for \`${query}\`:\n\n"

scores=$(scores)
total=0
total_single=0
total_multi=0

while read single && read multi; do
  total_single=$(($total_single+$single))
  total_multi=$(($total_multi+$multi))
  total=$(($total+1))
done < <(echo "$scores")

avg_single=$(($total_single/$total))
avg_multi=$(($total_multi/$total))

dev_single=0
dev_multi=0

while read single && read multi; do
  single=$(($single-$avg_single))
  multi=$(($multi-$avg_multi))
  dev_single=$(($dev_single+$single*$single))
  dev_multi=$(($dev_multi+$multi*$multi))
done < <(echo "$scores")

dev_single=$(echo "sqrt($dev_single/$total)" | bc)
dev_multi=$(echo "sqrt($dev_multi/$total)" | bc)

echo "Single-Core Score:  $avg_single ($dev_single stddev)"
echo "Multi-Core Score:   $avg_multi ($dev_multi stddev)"
echo "Scores are based on ${total} results."

while read single && read multi; do
  echo "$single" >> "${query}_single.txt"
  echo "$multi" >> "${query}_multi.txt"
done < <(echo "$scores")

sort -rn < "${query}_single.txt" > "${query}_single_sorted.txt"
sort -rn < "${query}_multi.txt" > "${query}_multi_sorted.txt"

echo "${query} (single),${query} (multi)" > "${query}_unsorted.csv"
paste "${query}_single.txt" "${query}_multi.txt" | tr '\t' ',' > "${query}_unsorted.csv"
./plot_values.gp "${query}_unsorted.csv" "${query}_unsorted.png"

echo "${query} (single),${query} (multi)" > "${query}_sorted_independent.csv"
paste "${query}_single_sorted.txt" "${query}_multi_sorted.txt" | tr '\t' ',' >> "${query}_sorted_independent.csv"
./plot_values.gp "${query}_sorted_independent.csv" "${query}_sorted_independent.png"

temp=$(mktemp)

paste "${query}_single.txt" "${query}_multi.txt" | tr '\t' ',' > "${temp}"

echo "${query} (single),${query} (multi)" > "${query}_sorted_by_single.csv"
sort -rnt, -k1 "${temp}" >> "${query}_sorted_by_single.csv"
./plot_values.gp "${query}_sorted_by_single.csv" "${query}_sorted_by_single.png"

echo "${query} (single),${query} (multi)" > "${query}_sorted_by_multi.csv"
sort -rnt, -k2 "${temp}" >> "${query}_sorted_by_multi.csv"
./plot_values.gp "${query}_sorted_by_multi.csv" "${query}_sorted_by_multi.png"

rm "${temp}"

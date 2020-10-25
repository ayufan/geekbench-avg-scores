Script calculates average Geekbench scores (using data from [https://browser.primatelabs.com](https://browser.primatelabs.com)) for a given query (e.g. `macbook10,1 i5` or `macbookpro14,2 i7-7660U`).

> All Apple devices' model numbers can be found on [everymac.org](http://www.everymac.org).

Usage:

```
# pass the search string as script query arguments
./get-gb-scores.sh macbook10,1 i5

Average Geekbench 4 scores for `macbook10,1 i5`:

Single-Core Score:      3571.57
Multi-Core Score:       6943.02

Scores are based on 136 results.
```

If the [gnuplot](http://www.gnuplot.info/) is installed - the script will plot query data in four ways:
1. _unsorted (as data comes from browser.primatelabs.com) - to get some historical overview.
2. _sorted_independent (single-core results and multi-core results are sorted independently) - to estimate single/multi results distribution visually.
3. _sorted_by_single (results are sorted by single-core marks) - to get a chart of how well multi-core results are scaled against single-core results.
4. _sorted_by_multi (results are sorted by multi-core marks) - to get a chart of how well single-core results are scaled against multi-core results.

Also, this data will be saved in CSV files for further analysis.

Results and discussion on [reddit](https://www.reddit.com/r/apple/comments/6jdfcz/geekbench_average_cpu_scores_for_all_2017/?st=j4dvvlyg&sh=353d8fa9).

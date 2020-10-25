#!/usr/bin/gnuplot -c
FILENAME=ARG1
OUTPUT=ARG2

set datafile separator ",";
stats FILENAME nooutput;

set key right top;
set key autotitle columnhead
set xlabel "Tests";
set ylabel "Makrs";
set yrange [0:*];
set ytics 100 nomirror;
set mytics 1;

set style data lines

set term png enhanced size 3840,2160 linewidth 2 font "Helvetica,18"
set output OUTPUT

plot for [i=1:STATS_columns] FILENAME using 0:i with lines

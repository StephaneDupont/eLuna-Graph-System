#!/usr/bin/perl

$dummy = `cat /proc/meminfo`;
$dummy2=$dummy;
$dummy2=~ /MemFree:\s+(.*?) kB/mg;
$memfree=$1;
$dummy2=$dummy;
$dummy2=~ /MemTotal:\s+(.*?) kB/mg;
$total=$1;
$dummy2=$dummy;
$dummy2=~ /SwapTotal:\s+(.*?) kB/mg;
$swaptotal=$1;
$dummy2=$dummy;
$dummy2=~ /SwapFree:\s+(.*?) kB/mg;
$swapfree=$1;

my $mem = 100-(int(($memfree/$total)*100));
my $swap = ($swaptotal?100-(int(($swapfree/$swaptotal)*100)):0);

system("rrdtool update mem.rrd -t mem:swap N:".$mem.":".$swap);

#!/usr/bin/perl

$dummy = `cat /proc/loadavg`;
$dummy =~ /(.*) (.*) (.*) (.*) (.*)/;

system("rrdtool update load.rrd -t load_1mn:load_5mn:load_15mn N:$1:$2:$3");


#!/bin/perl

$dummy = `df | grep /\$`;
$dummy=~ /(.*) (.*)%/;

system("rrdtool update space.rrd -t space N:$2");

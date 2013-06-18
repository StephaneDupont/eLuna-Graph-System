#!/bin/perl

$dummy = `df | grep /home`;
$dummy=~ /(.*) (.*)%/;

system("rrdtool update space_home.rrd -t space N:$2");

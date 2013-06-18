#!/usr/bin/perl

$dummy = `cat /proc/stat | grep "^cpu "`;
$dummy =~ /^(\w*)\ *(\w*) (\w*) (\w*) (\w*)/;

system("rrdtool update cpu.rrd -t user:nice:system:idle N:$2:$3:$4:$5");


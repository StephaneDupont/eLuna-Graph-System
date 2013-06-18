#!/usr/bin/perl

$dummy = `www-browser -dump http://localhost/server-status/ | grep "Total accesses"`;
$dummy =~ /.*Total accesses\s*:\s*([0-9]*)\s*/;

system("rrdtool update apache_hits.rrd -t hits N:$1");


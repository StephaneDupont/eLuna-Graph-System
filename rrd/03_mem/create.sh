#!/bin/bash

rrdtool create mem.rrd \
  --start `date +%s` \
  --step 300 \
  DS:mem:GAUGE:600:0:U \
  DS:swap:GAUGE:600:0:U \
  RRA:AVERAGE:0.5:1:2016 \
  RRA:AVERAGE:0.5:6:1344 \
  RRA:AVERAGE:0.5:24:732 \
  RRA:AVERAGE:0.5:144:1460

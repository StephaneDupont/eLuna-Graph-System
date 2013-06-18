#!/bin/bash

rrdtool create space.rrd \
  --start `date +%s` \
  --step 300 \
  DS:space:GAUGE:600:U:U \
  RRA:AVERAGE:0.5:1:2016 \
  RRA:AVERAGE:0.5:6:1344 \
  RRA:AVERAGE:0.5:24:732 \
  RRA:AVERAGE:0.5:144:1460


#!/bin/bash

rrdtool create eth0_out.rrd \
  --start `date +%s` \
  --step 300 \
  DS:out:DERIVE:600:0:U \
  RRA:AVERAGE:0.5:1:2016 \
  RRA:AVERAGE:0.5:6:1344 \
  RRA:AVERAGE:0.5:24:732 \
  RRA:AVERAGE:0.5:144:1460

#!/bin/bash

a=`ps aux | wc -l | sed -e "s/ //g"`
b=`ps auxr | wc -l | sed -e "s/ //g"`

a=`expr $a - 1`
b=`expr $b - 1`

rrdtool update process.rrd \
  -t all:running \
  N:$a:$b

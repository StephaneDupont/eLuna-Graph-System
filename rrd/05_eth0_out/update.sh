#!/bin/bash

rrdtool update eth0_out.rrd \
  -t out \
  N:`/sbin/ifconfig eth0 |grep bytes|cut -d":" -f3|cut -d" " -f1`

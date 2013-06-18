#!/bin/bash

rrdtool update eth0_in.rrd \
  -t in \
  N:`/sbin/ifconfig eth0 |grep bytes|cut -d":" -f2|cut -d" " -f1`

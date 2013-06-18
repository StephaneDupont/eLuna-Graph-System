$GRAPH_TITLES{'cpu'} = "{#server#} - CPU Usage";
$GRAPH_CMDS{'cpu'} = <<"CPU_GRAPH_CMD";
--title "{#server#} - CPU Usage"
--vertical-label="Percent"
--lower-limit 0 --upper-limit 100
DEF:user={#path#}cpu.rrd:user:AVERAGE
DEF:nice={#path#}cpu.rrd:nice:AVERAGE
DEF:system={#path#}cpu.rrd:system:AVERAGE
DEF:idle={#path#}cpu.rrd:idle:AVERAGE
CDEF:total=user,nice,+,system,+,idle,+
CDEF:p_user=user,total,/,100,*
CDEF:p_nice=nice,total,/,100,*
CDEF:p_system=system,total,/,100,*
CDEF:mysum=p_user,p_nice,+,p_system,+
AREA:p_user{#dcolor1#}:"User   "
GPRINT:p_user:LAST:"Current\\: %5.2lf%%  "
GPRINT:p_user:AVERAGE:"Average\\: %5.2lf%%  "
GPRINT:p_user:MAX:"Max\\: %5.2lf%%\\n"
STACK:p_nice{#dcolor2#}:"Nice   "
GPRINT:p_nice:LAST:"Current\\: %5.2lf%%  "
GPRINT:p_nice:AVERAGE:"Average\\: %5.2lf%%  "
GPRINT:p_nice:MAX:"Max\\: %5.2lf%%\\n"
STACK:p_system{#dcolor3#}:"System "
GPRINT:p_system:LAST:"Current\\: %5.2lf%%  "
GPRINT:p_system:AVERAGE:"Average\\: %5.2lf%%  "
GPRINT:p_system:MAX:"Max\\: %5.2lf%%\\n"
LINE1:mysum{#linecolor#}
CPU_GRAPH_CMD

1; # Return true


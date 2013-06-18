$GRAPH_TITLES{'load'} = "{#server#} - Load Average";
$GRAPH_CMDS{'load'} = <<"LOAD_GRAPH_CMD";
--title "{#server#} - Load Average"
--vertical-label=""
--units-exponent 0
--lower-limit 0
DEF:load_1mn={#path#}load.rrd:load_1mn:AVERAGE
DEF:load_5mn={#path#}load.rrd:load_5mn:AVERAGE
DEF:load_15mn={#path#}load.rrd:load_15mn:AVERAGE
CDEF:mysum=load_1mn,load_5mn,+,load_15mn,+
AREA:load_1mn{#dcolor1#}:" 1mn load average "
GPRINT:load_1mn:LAST:"Current\\: %5.2lf "
GPRINT:load_1mn:AVERAGE:"Average\\: %5.2lf "
GPRINT:load_1mn:MAX:"Max\\: %5.2lf\\n"
STACK:load_5mn{#dcolor2#}:" 5mn load average "
GPRINT:load_5mn:LAST:"Current\\: %5.2lf "
GPRINT:load_5mn:AVERAGE:"Average\\: %5.2lf "
GPRINT:load_5mn:MAX:"Max\\: %5.2lf\\n"
STACK:load_15mn{#dcolor3#}:"15mn load average "
GPRINT:load_15mn:LAST:"Current\\: %5.2lf "
GPRINT:load_15mn:AVERAGE:"Average\\: %5.2lf "
GPRINT:load_15mn:MAX:"Max\\: %5.2lf\\n"
LINE1:mysum{#linecolor#}
LOAD_GRAPH_CMD

1; # Return true


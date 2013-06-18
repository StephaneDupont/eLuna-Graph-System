$GRAPH_TITLES{'eth0_out'} = "{#server#} - Eth0 Outbound Traffic";
$GRAPH_CMDS{'eth0_out'} = <<"ETH0_OUT_GRAPH_CMD";
--title "{#server#} - Eth0 Outbound Traffic"
--vertical-label="Bytes / second"
--lower-limit 0
DEF:out={#path#}eth0_out.rrd:out:AVERAGE
AREA:out{#color5#}:"Outbound "
GPRINT:out:LAST:"Current\\: %5.2lf %s  "
GPRINT:out:AVERAGE:"Average\\: %5.2lf %s  "
GPRINT:out:MAX:"Maximum\\: %5.2lf %s\\n"
LINE1:out{#linecolor#}
ETH0_OUT_GRAPH_CMD

1; # Return true

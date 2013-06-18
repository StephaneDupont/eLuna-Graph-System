$GRAPH_TITLES{'eth0_in'} = "{#server#} - Eth0 Inbound Traffic";
$GRAPH_CMDS{'eth0_in'} = <<"ETH0_IN_GRAPH_CMD";
--title "{#server#} - Eth0 Inbound Traffic"
--vertical-label="Bytes / second"
--lower-limit 0
DEF:in={#path#}eth0_in.rrd:in:AVERAGE
AREA:in{#color5#}:"Inbound  "
GPRINT:in:LAST:"Current\\: %5.2lf %s  "
GPRINT:in:AVERAGE:"Average\\: %5.2lf %s  "
GPRINT:in:MAX:"Maximum\\: %5.2lf %s\\n"
LINE1:in{#linecolor#}
ETH0_IN_GRAPH_CMD

1; # Return true

$GRAPH_TITLES{'mem'} = "{#server#} - Memory Usage";
$GRAPH_CMDS{'mem'} = <<"MEM_GRAPH_CMD";
--title "{#server#} - Memory Usage"
--vertical-label="Percent"
--lower-limit 0 --upper-limit 100 
DEF:mem={#path#}mem.rrd:mem:AVERAGE
DEF:swap={#path#}mem.rrd:swap:AVERAGE
AREA:mem{#color3#}:"Physical "
GPRINT:mem:LAST:"Current\\: %3.0lf%%  "
GPRINT:mem:AVERAGE:"Average\\: %3.0lf%%  "
GPRINT:mem:MAX:"Maximum\\: %3.0lf%%\\n"
AREA:swap{#color2#}:"Swap     "
GPRINT:swap:LAST:"Current\\: %3.0lf%%  "
GPRINT:swap:AVERAGE:"Average\\: %3.0lf%%  "
GPRINT:swap:MAX:"Maximum\\: %3.0lf%%\\n"
MEM_GRAPH_CMD

1; # Return true

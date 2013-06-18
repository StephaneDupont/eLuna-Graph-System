$GRAPH_TITLES{'process'} = "{#server#} - Processes";
$GRAPH_CMDS{'process'} = <<"PROC_GRAPH_CMD";
--title "{#server#} - Processes"
--vertical-label="Processes"
--units-exponent 0
--lower-limit 0
DEF:all={#path#}process.rrd:all:AVERAGE
DEF:running={#path#}process.rrd:running:AVERAGE
AREA:all{#color3#}:"All     "
GPRINT:all:LAST:"Current\\: %5.0lf  "
GPRINT:all:AVERAGE:"Average\\: %5.0lf  "
GPRINT:all:MAX:"Maximum\\: %5.0lf\\n"
AREA:running{#color1#}:"Running "
GPRINT:running:LAST:"Current\\: %5.0lf  "
GPRINT:running:AVERAGE:"Average\\: %5.0lf  "
GPRINT:running:MAX:"Maximum\\: %5.0lf\\n"
PROC_GRAPH_CMD

1; # Return true

$GRAPH_TITLES{'space'} = "{#server#} - Used Space On /";
$GRAPH_CMDS{'space'} = <<"SPACE_GRAPH_CMD";
--title "{#server#} - Used Space On /"
--vertical-label="Percent"
--lower-limit 0 --upper-limit 100
DEF:space={#path#}space.rrd:space:AVERAGE
AREA:space{#color2#}:"Used Space  "
GPRINT:space:LAST:"Current\\: %3.0lf%%  "
GPRINT:space:AVERAGE:"Average\\: %3.0lf%%  "
GPRINT:space:MAX:"Maximum\\: %3.0lf%%\\n"
LINE1:space{#linecolor#}
SPACE_GRAPH_CMD

1; # Return true

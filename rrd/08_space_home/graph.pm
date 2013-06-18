$GRAPH_TITLES{'space_home'} = "{#server#} - Used Space On /home";
$GRAPH_CMDS{'space_home'} = <<"SPACE_HOME_GRAPH_CMD";
--title "{#server#} - Used Space On /home"
--vertical-label="Percent"
--lower-limit 0 --upper-limit 100
DEF:space={#path#}space_home.rrd:space:AVERAGE
AREA:space{#color3#}:"Used Space  "
GPRINT:space:LAST:"Current\\: %3.0lf%%  "
GPRINT:space:AVERAGE:"Average\\: %3.0lf%%  "
GPRINT:space:MAX:"Maximum\\: %3.0lf%%\\n"
LINE1:space{#linecolor#}
SPACE_HOME_GRAPH_CMD

1; # Return true

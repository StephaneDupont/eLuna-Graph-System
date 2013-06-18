$GRAPH_TITLES{'apache_hits'} = "{#server#} - Apache Hits";
$GRAPH_CMDS{'apache_hits'} = <<"AH_GRAPH_CMD";
--title "{#server#} - Apache Hits"
--vertical-label="Hits / minute"
--units-exponent 0
--lower-limit 0
DEF:hits={#path#}apache_hits.rrd:hits:AVERAGE
CDEF:hits_mn=hits,60,*
AREA:hits_mn{#color2#}:"Hits / minute  "
GPRINT:hits_mn:LAST:"Current\\: %5.0lf  "
GPRINT:hits_mn:AVERAGE:"Average\\: %5.0lf  "
GPRINT:hits_mn:MAX:"Maximum\\: %5.0lf\\n"
LINE1:hits_mn{#linecolor#}
AH_GRAPH_CMD

1; # Return true

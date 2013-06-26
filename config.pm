 #                                                        #
 # ------------------------------------------------------ #
 # eLuna Graph System                                     #
 # ------------------------------------------------------ #
 # File    : config.pm                                    #
 # Author  : Stephane Dupont                              #
 # Version : 1.08                                         #
 # Date    : 2006-06-26                                   #
 # Summary :                                              #
 #   Config file                                          #
 # ------------------------------------------------------ #
 #                                                        #

# Name of the monitored server
$SERVER = "eLuna Web Server";

# Path to the directory containing the RRD elements
$RRD_DIR = 'rrd/';

# Path to the directory containing the graphs
$GRA_DIR = 'graphs/';

# Path to the directory containing the active template
$TEM_DIR = 'template/';

# Image format of the generated graphs (PNG|GIF|GD)
$IMG_FORMAT = 'PNG';

# Width of generated graphs (pixels)
$GRAPH_WIDTH = 500;

# Height of generated graphs (pixels)
$GRAPH_HEIGHT = 150;

# Width of graphs generated in zoom mode (pixels)
$ZOOM_WIDTH = 700;

# Height of graphs generated in zoom mode (pixels)
$ZOOM_HEIGHT = 300;

# Lines color
$GRAPH_LINECOLOR = '#000000';

# Graphs color 1
$GRAPH_COLOR1 = '#002997';

# Graphs color 2
$GRAPH_COLOR2 = '#4568E4';

# Graphs color 3
$GRAPH_COLOR3 = '#F51C2F';

# Graphs color 4
$GRAPH_COLOR4 = '#FFC73A';

# Graphs color 5
$GRAPH_COLOR5 = '#8DCD89';
# Graphs color 5
$GRAPH_COLOR5 = '#8DCD89';

# Graphs color 1 (gradation)
$GRAPH_DCOLOR1 = '#EACC00';

# Graphs color 2 (gradation)
$GRAPH_DCOLOR2 = '#EA8F00';

# Graphs color 3 (gradation)
$GRAPH_DCOLOR3 = '#FF0000';

# Default view (h(ourly)|d(aily)|b(i-daily)|w(eekly)|m(onthly)|y(early))
$DEFAULT_VIEW = 'd';

# Minimum time (in seconds) between two generations of a same graph
$DELAY_BETWEEN = '10';

# Minimum time (in seconds) between two generations of a custom graph
$DELAY_BETWEEN_CUSTOM = '2';

# Add UID to image urls to make sure images are not cached (bad IE behavior,
# other browsers are fine without this option).
# For this option to work, you must use an apache server with mod_rewrite
# or use a similar mecanism (see graphs/.htaccess file)
# 0 to disable.
$ADD_UID_TO_IMG_URL = 1;

1; # Return true

 #                                                        #
 # ------------------------------------------------------ #
 # eLuna Graph System                                     #
 # ------------------------------------------------------ #
 # File     : config.pm                                   #
 # Author   : Stephane Dupont                             #
 # Version  : 1.09                                        #
 # Released : 2013-11-17                                  #
 # Summary  :                                             #
 #   Config file                                          #
 # ------------------------------------------------------ #
 #                                                        #

# Name of the monitored server
$SERVER = "Localhost";

# Path to the directory containing the RRD elements
$RRD_DIR = 'rrd/';

# Path to the directory containing the graphs
$GRA_DIR = 'graphs/';

# Path to the directory containing the active template
$TEM_DIR = 'template/';

# Image format of the generated graphs (PNG|GIF|GD)
$IMG_FORMAT = 'PNG';

# Width of generated graphs (pixels)
$GRAPH_WIDTH = 600;

# Height of generated graphs (pixels)
$GRAPH_HEIGHT = 220;

# Width of graphs generated in zoom mode (pixels)
$ZOOM_WIDTH = 700;

# Height of graphs generated in zoom mode (pixels)
$ZOOM_HEIGHT = 300;

# Lines color
$GRAPH_LINECOLOR = '#000000';

# Graphs color 1
$GRAPH_COLOR1 = '#039be5';

# Graphs color 2
$GRAPH_COLOR2 = '#607d8b';

# Graphs color 3
$GRAPH_COLOR3 = '#ff7043';

# Graphs color 4
$GRAPH_COLOR4 = '#ffb300';

# Graphs color 5
$GRAPH_COLOR5 = '#55ad7e';

# Graphs color 1 (gradation)
$GRAPH_DCOLOR1 = '#eacc00';

# Graphs color 2 (gradation)
$GRAPH_DCOLOR2 = '#ea8f00';

# Graphs color 3 (gradation)
$GRAPH_DCOLOR3 = '#ff0000';

# Default view (h(ourly)|d(aily)|b(i-daily)|w(eekly)|m(onthly)|y(early))
$DEFAULT_VIEW = 'd';

# Generated images older than this value (seconds) will be deleted
$MAX_IMG_AGE = 3600; 

# When outputting data in a CSV file, shall we convert from scientific
# notation to decimal notation?
$CSV_DATA_CONVERT_TO_DECIMAL = 1;

1; # Return true

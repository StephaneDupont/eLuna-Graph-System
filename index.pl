#!/usr/bin/perl

 #                                                        #
 # ------------------------------------------------------ #
 # eLuna Graph System                                     #
 # ------------------------------------------------------ #
 # File    : index.pl                                     #
 # Author  : Stephane Dupont                              #
 # Version : 1.07                                         #
 # Date    : 2010-06-23                                   #
 # Summary :                                              #
 #   Script that display graphs                           #
 #   To be used in a web navigator                        #
 # ------------------------------------------------------ #
 #                                                        #


die ("This script must be executed as a web script !") if !$ENV{'HTTP_HOST'};

use POSIX qw(strftime);
use CGI;
use DateTime;
use HTML::Template::Expr;


# ------------- #
# Configuration #
# ------------- #

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


# ----------------- #
# Some variables... #
# ----------------- #

my $cgi = new CGI;
our (%GRAPH_CMDS, %GRAPH_TITLES);
my ($title, $back_link, $summary, $display_custom_view,
    $custom_view, $ctime1, $ctime2, @elgraphs);


# ------- #
# Headers #
# ------- #
if ($cgi->param('summary_view') && ($cgi->param('summary_view') =~ /^[hdbwmy]$/)) {
  my $cookie = $cgi->cookie(
    -name=>'summary_view',
    -value=>$cgi->param('summary_view'),
    -expires=>gmtime(time()+365*24*3600)." GMT",
    -path=>'/',
  );
  print $cgi->header(-cookie=>$cookie);
} else {
  print $cgi->header();
}


# ------------------------------------------ #
# Display an information in page source code #
# ------------------------------------------ #
# Param  : info                              #
# Return : none                              #
# ------------------------------------------ #
sub elTrace
{
  print "<!-- Trace: $_[0] -->\n";
}


# ------------------------------------------------------- #
# Convert a datetime from 'yyyy-mm-dd hh:mm' to epochtime #
# ------------------------------------------------------- #
# Param  : datetime_string                                #
# Return : epochtime                                      #
# ------------------------------------------------------- #

sub getEpoch
{
  if ($_[0] =~ /([0-9]{4})-([0-9]{2})-([0-9]{2}) ([0-9]{2}):([0-9]{2})/) {
    my $dt = DateTime->new(
      year      => $1,
      month     => $2,
      day       => $3,
      hour      => $4,
      minute    => $5,
      time_zone => "local"
    );
    $dt->epoch;
  } else {
    0;
  }
}


# ----------------------------- #
# Return RRD List               #
# ----------------------------- #
# Param  : none                 #
# Return : array_of_rrd_strings #
# ----------------------------- #

sub getRRDList
{
  opendir(DIR, $RRD_DIR);
  my @rrds =
    grep { -d $RRD_DIR.$_ }
      grep { ( $_ ne '.' ) and ( $_ ne '..' ) }
          readdir DIR;
  closedir DIR;
  sort @rrds;
}


# ----------------------------------- #
# Return RRD List (id, name, current) #
# ----------------------------------- #
# Param  : current_rrd_id             #
# Return : ref_on_array_of_hach_refs  #
# ----------------------------------- #

sub getRRDItems
{
  my @result;
  my @rrds = &getRRDList();
  foreach my $rrd (@rrds) {
    my %th;
    $th{'id'} = $rrd;
    require $RRD_DIR.$rrd.'/graph.pm';
    my $tt = $rrd; $tt =~ s/^[0-9]*_//;   
    $th{'name'} = $GRAPH_TITLES{$tt};
    $th{'name'} =~ s/\{#server#\}[ -]*//g;
    $th{'current'} = 1 if $th{'id'} eq $_[0];
    push @result, \%th;
  }
  \@result;
}


# ------------------------------------------------- #
# Create a graph                                    #
# ------------------------------------------------- #
# Param  : rrd_id                                   #
# Param  : type ('h', 'd', 'b', 'm', 'w', 'y', 'c') #
# Param  : [Optional] time1 (yyyy-mm-dd hh:mm)      # 
# Param  : [Optional] time2 (yyyy-mm-dd hh:mm)      #
# Return : none                                     #
# ------------------------------------------------- #

sub createRRDGraph
{
  my %elh;

  $elh{'rrd_dir'} = $_[0];
  $elh{'rrd_id'} = $_[0];
  $elh{'rrd_id'} =~ s/^[0-9]*_//;
  require $RRD_DIR.$elh{'rrd_dir'}.'/graph.pm';

  $elh{'gtitle'} = $GRAPH_TITLES{$elh{'rrd_id'}};
  $elh{'gtitle'} =~ s/\{#server#\}/$SERVER/g;
  $elh{'gtype'}  = $_[1];

  if ($_[1] ne 'c') {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst);
    do {
      $elh{'time2'} = time();
      ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($elh{'time2'});
    } until $sec != 0;
    $elh{'time2'} -= ($sec-1);
    for ($i = 0; $i < ($min%5); $i++) {$elh{'time2'} -= 60;}
    $elh{'time1'} = $elh{'time2'} - 14400    if $_[1] eq 'h';
    $elh{'time1'} = $elh{'time2'} - 86400    if $_[1] eq 'd';
    $elh{'time1'} = $elh{'time2'} - 172800   if $_[1] eq 'b';
    $elh{'time1'} = $elh{'time2'} - 604800   if $_[1] eq 'w';
    $elh{'time1'} = $elh{'time2'} - 2592000  if $_[1] eq 'm';
    $elh{'time1'} = $elh{'time2'} - 31536000 if $_[1] eq 'y';
  } else {
    $elh{'time1'} = &getEpoch($_[2]);
    $elh{'time2'} = &getEpoch($_[3]);
  }

  $elh{'img_src'}  = $GRA_DIR.$elh{'rrd_id'}.'_'.$_[1];
  $elh{'img_src'} .= '_zoom' if $cgi->param('type');
  $elh{'img_src'} .= '.'.lc($IMG_FORMAT);
  
  $elh{'strtime1'} = strftime "%Y-%m-%d %H\\:%M\\:%S", localtime($elh{'time1'});
  $elh{'strtime2'} = strftime "%Y-%m-%d %H\\:%M\\:%S", localtime($elh{'time2'});

  $elh{'cmd'} = "rrdtool graph ".$elh{'img_src'}." ";
  $elh{'cmd'} .= "--start ".$elh{'time1'}." --end ".$elh{'time2'}." ";
  $elh{'cmd'} .= "--imgformat ".$IMG_FORMAT." --lazy ";
  $elh{'cmd'} .= "-w ".$GRAPH_WIDTH." -h ".$GRAPH_HEIGHT." " if !$cgi->param('type');
  $elh{'cmd'} .= "-w ".$ZOOM_WIDTH." -h ".$ZOOM_HEIGHT." " if $cgi->param('type');
  $elh{'cmd'} .= 'COMMENT:"From '.$elh{'strtime1'}.' To '.$elh{'strtime2'}.'\c" ';
  $elh{'cmd'} .= 'COMMENT:"\n" ';
  $elh{'cmd'} .= $GRAPH_CMDS{$elh{'rrd_id'}};
  $elh{'cmd'} =~ s/[\n\r]+/ /g;
  $elh{'cmd'} =~ s/\{#server#\}/$SERVER/g;
  $elh{'cmd'} =~ s/\{#path#\}/$RRD_DIR$elh{'rrd_dir'}\//g;
  $elh{'cmd'} =~ s/\{#linecolor#\}/$GRAPH_LINECOLOR/g;
  $elh{'cmd'} =~ s/\{#color1#\}/$GRAPH_COLOR1/g;
  $elh{'cmd'} =~ s/\{#color2#\}/$GRAPH_COLOR2/g;
  $elh{'cmd'} =~ s/\{#color3#\}/$GRAPH_COLOR3/g;
  $elh{'cmd'} =~ s/\{#color4#\}/$GRAPH_COLOR4/g;
  $elh{'cmd'} =~ s/\{#color5#\}/$GRAPH_COLOR5/g;
  $elh{'cmd'} =~ s/\{#dcolor1#\}/$GRAPH_DCOLOR1/g;
  $elh{'cmd'} =~ s/\{#dcolor2#\}/$GRAPH_DCOLOR2/g;
  $elh{'cmd'} =~ s/\{#dcolor3#\}/$GRAPH_DCOLOR3/g;

  if (-e $elh{'img_src'} && (stat($elh{'img_src'}))[10] >=
      time - ($cgi->param('type') eq 'c'?$DELAY_BETWEEN_CUSTOM:$DELAY_BETWEEN)) {
    elTrace("Graph ".$elh{'rrd_id'}." has not been generated because you ".
            "must wait for ".
            ($cgi->param('type') eq 'c'?$DELAY_BETWEEN_CUSTOM:$DELAY_BETWEEN).
            " seconds between two generations");
  } else {
    open my $oldout, ">&STDOUT";
    open STDOUT, ">/dev/null";
    system('rm -f '.$elh{'img_src'});
    system($elh{'cmd'});
    close STDOUT;
    open STDOUT, ">&", $oldout;
  }

  if (!$cgi->param('rrd')) {
    $elh{'link_type'} = "more";
    $elh{'link_url'} = "index.pl?rrd=".$elh{'rrd_dir'};
  } elsif (!$cgi->param('type')) {
    $elh{'link_type'} = "zoom";
    $elh{'link_url'} = "index.pl?rrd=".$elh{'rrd_dir'}."&type=$_[1]&time1=$_[2]&time2=$_[3]";
  }

  $elh{'display_command'} = $cgi->param('type');

  push @elgraphs, \%elh;
}


# ----------------------------------------------------------- #
# Check validity of cgi parameters to limit security problems #
# ----------------------------------------------------------- #
my $trrd;
if (($cgi->param('type') &&
     !($cgi->param('type') =~ /^[hdbwmyc]$/))
    ||
    ($cgi->param('rrd') &&
     ($trrd = $cgi->param('rrd')) &&
     ! grep /^$trrd$/, &getRRDList())
    ||
    ($cgi->param('type') && !$cgi->param('rrd'))
    ||
    ($cgi->param('type') eq 'c' &&
      (!$cgi->param('time1') || !$cgi->param('time2')))
    ||
    ($cgi->param('time1') &&
     ! $cgi->param('time1') =~ 
         /[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}/)
    ||
    ($cgi->param('time2') &&
     ! $cgi->param('time2') =~
         /[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}/)) {
  print "Bad parameter value\n";
  exit 0;
}


# ----------------------------------------- #
# rrd is passed in parameter to the page... #
# ----------------------------------------- #
if (defined $cgi->param('rrd') && $cgi->param('rrd') =~ /[a-zA-Z0-9]/) {

  my $rrd_id = $cgi->param('rrd');
  $rrd_id =~ s/^[0-9]*_//;

  # ------------ #
  # Zoom mode on #
  # ------------ #
  if ($cgi->param('type')) {

    # ----------- #
    # Normal mode #
    # ----------- #
    if ($cgi->param('type') ne 'c') {
      &createRRDGraph($cgi->param('rrd'),$cgi->param('type'));
      $title = $GRAPH_TITLES{$rrd_id};
      $back_link = 'index.pl?rrd='.$cgi->param('rrd');
      $ctime1 = strftime "%Y-%m-%d %H:%M", localtime($elgraphs[0]{'time1'});
      $ctime2 = strftime "%Y-%m-%d %H:%M", localtime($elgraphs[0]{'time2'});
    }

    # ---------------- #
    # Custom view mode #
    # ---------------- #
    else {
      &createRRDGraph($cgi->param('rrd'),'c',$cgi->param('time1'),$cgi->param('time2'));
      $title = $GRAPH_TITLES{$rrd_id};
      $back_link = 'index.pl?rrd='.$cgi->param('rrd');
      $custom_view = 1;
      $display_custom_view = 1;
      $ctime1 = $cgi->param('time1');
      $ctime2 = $cgi->param('time2');
    }
    $display_custom_view = 1;
  }

  # ------------- #
  # Zoom mode off #
  # ------------- #
  else {

    &createRRDGraph($cgi->param('rrd'),'h');
    &createRRDGraph($cgi->param('rrd'),'d');
    &createRRDGraph($cgi->param('rrd'),'b');
    &createRRDGraph($cgi->param('rrd'),'w');
    &createRRDGraph($cgi->param('rrd'),'m');
    &createRRDGraph($cgi->param('rrd'),'y');

    $title = $GRAPH_TITLES{$rrd_id};
    $back_link = 'index.pl';
    $display_custom_view = 1;

    $ctime1 = DateTime->from_epoch( epoch => time() - 172800, time_zone => "local");
    $ctime2 = DateTime->from_epoch( epoch => time() - 86400, time_zone => "local");
    $ctime1 = $ctime1->strftime('%F %H:%M');
    $ctime2 = $ctime2->strftime('%F %H:%M'); 
  }
}


# ----------------------------------------- #
# rrd isn't passed in parameter to the page #
# ----------------------------------------- #
else {

  my $user_view = $cgi->param('summary_view');
  $user_view = $cgi->cookie('summary_view') unless $user_view =~ /^[hdbwmy]$/;
  $user_view = $DEFAULT_VIEW unless $user_view =~ /^[hdbwmy]$/; 
  $summary = $user_view;
  my @rrds = &getRRDList();
  foreach my $rrd (@rrds) {
    createRRDGraph($rrd, $user_view);
  }
}


# ------------------- #
# Displaying template #
# ------------------- #
my $template = HTML::Template::Expr->new(
  filename => $TEM_DIR.'index.html',
  die_on_bad_params => 0,
  global_vars => '1'
);
$title =~ s/\{#server#\}/$SERVER/g;
$template->param(template_path => $TEM_DIR);
$template->param(server => $SERVER);
$template->param(title => $title);
$template->param(back_link => $back_link);
$template->param(summary => $summary);
$template->param(display_custom_view => $display_custom_view);
$template->param(custom_view => $custom_view);
$template->param(ctime1 => $ctime1);
$template->param(ctime2 => $ctime2);
$template->param(elgraphs => \@elgraphs);
$template->param(rrd => $cgi->param('rrd'));
unless ($summary) {
  $template->param(
    rrds => &getRRDItems($cgi->param('rrd')));
  $template->param(
    curl => '&type='.$cgi->param('type').
            '&time1='.$cgi->param('time1').
            '&time2='.$cgi->param('time2'));
}
print($template->output);

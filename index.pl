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


# --------------------------------------------------------------- #
# Note : there's two types of ID's for RRDs,                      #
# - ID : for example load, cpu, ...                               #
# - SID (Sort ID) : for example 01_load, 02_cpu, ...              #
# ID can be equal to SID if no integer is added in the foldername #
# --------------------------------------------------------------- #


die ("This script must be executed as a web script !") if !$ENV{'HTTP_HOST'};

use POSIX qw(strftime);
use CGI;
use CGI::Cookie;
use DateTime;
use HTML::Template::Expr;


# ---------------- #
# Load config file #
# ---------------- #

require 'config.pm';


# ----------------- #
# Some variables... #
# ----------------- #

my $cgi = new CGI;
our (%GRAPH_CMDS, %GRAPH_TITLES);
my ($title, $back_link, $summary, $display_custom_view, $cookie,
    $custom_view, $ctime1, $ctime2, @elgraphs, @rrds, @trace);


# -------------------------- #
# Print something at the end #
# of page source code        #
# -------------------------- #
# Param  : info              #
# Return : none              #
# -------------------------- #

sub elTrace
{
  push @trace, "<!-- Trace: $_[0] -->\n";
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


# ---------------------------------- #
# Return RRD List (array of strings) #
# Strings are as SID                 #
# ---------------------------------- #
# Param  : none                      #
# Return : array_of_rrd_strings      #
# ---------------------------------- #

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


# ------------------------------------ #
# Return RRD List (sid, name, current) #
# Used in the template file to display #
# menu when not in summary view        #
# To be easier to use in it, 'sid' key #
# will be named 'id'                   #
# ------------------------------------ #
# Param  : current_rrd_sid             #
# Return : ref_on_array_of_hach_refs   #
# ------------------------------------ #

sub getRRDItems
{
  my @result;
  foreach my $rrd (@rrds) {
    my %th;
    $th{'id'} = $rrd;
    require $RRD_DIR.$rrd.'/graph.pm';
    my $tt = $rrd; $tt =~ s/^[0-9]+_//; 
    $th{'name'} = $GRAPH_TITLES{$tt};
    $th{'name'} =~ s/\{#server#\}[ -]*//g;
    $th{'current'} = 1 if $th{'id'} eq $_[0];
    push @result, \%th;
  }
  \@result;
}


# -------------------------------------- #
# Return the 'cds' (Custom Data Sources) #
# string for a RRD or empty string if    #
# not relevant (1..1, 0..0)              #
# Example : 110, 101, 01, ...            #
# -------------------------------------- #
# Param  : rrd_sid                       #
# Return : string                        #
# -------------------------------------- #

sub getCDSString
{
  my $str;
  if ($cookie && $cookie->name eq $_[0]) {
    $str = $cookie->value;
  } else {  
    $str = $cgi->cookie($_[0]);
  }
  if (($str =~ /^[0-1]+$/) && ($str =~ /0/) && ($str =~ /1/)) {
    return $str;
  } else {
    return '';
  }
}


# -------------------------------------- #
# Return DS List (id, name, type, state) #
# for a given RRD SID                    #
# -------------------------------------- #
# Param  : rrd_sid                       #
# Return : ref_on_array_of_hach_refs     #
# -------------------------------------- #

sub getDSItems
{
  my @result;

  my $rrd_id  = $_[0];
  $rrd_id =~ s/^[0-9]+_//;

  my $cmd = $GRAPH_CMDS{$rrd_id};

  my $cds = getCDSString($_[0]);

  my @lines = split(/\n/, $cmd);
  my $counter = 0;
  my $ctype = '';
  foreach my $line (@lines) {
    if ($line =~ /^\s*(AREA|STACK|LINE)\:([^\:]*)\:\"(.*)\"/) {
      $counter++;
      my $id = $2;
      my $name = $3;
      my $type = $1;
      my $stack = 0;
      if ($type eq 'STACK') {
        $type = $ctype;
        $stack = 1;
      } else {
        if ($line =~ /\:STACK/) { # New syntax for STACK, example:
          $stack = 1;             # AREA:value[#color][:[legend][:STACK]]
        }
        $ctype = $type;
      }
      $id =~ s/\{.*\}//g;
      $id =~ s/^\s+|\s+$//g;
      $name =~ s/^\s+|\s+$//g;
      $type =~ s/^\s+|\s+$//g;
      $state = 1;
      $state = 0 if $cds =~ /^0/;
      $cds =~ s/^.//;
      push @result, { 'id' => $id, 'name' => $name , 'type' => $type, 'stack' => $stack, 'state' => $state};
    }
  }
  shift(@result) if $#result==0; # we don't need DS list if only 1 item
  \@result;
}


# ----------------------------------------- #
# Customize a graph command to display only #
# some of the DS                            #
# ----------------------------------------- #
# Param  : list of DS (see getDSItems)      #
# Param  : command to customize (string)    #
# Return : customized command (string)      #
# ----------------------------------------- #

sub customizeRRDCmd
{
  my @dss = @{$_[0]};
  my $cmd = $_[1]; 
  my $result = '';
  my %ids;

  my $ctype = '';
  foreach my $ds (@dss) {
    if ($$ds{'state'} == 1) {
      $ids{$$ds{'id'}} = 1;
      if (($$ds{'type'} ne $ctype) && $$ds{'stack'}) {
        $ids{$$ds{'id'}} = $$ds{'type'};
      }
      $ctype = $$ds{'type'};
    }
  } 

  my @lines = split(/\n/, $cmd);
  foreach my $line (@lines) {
    if ($line =~ /^\s*(AREA|STACK|LINE|PRINT|GPRINT)\:([^\:]*)\:/) {
      $id = $2;
      $id =~ s/\{.*\}//g;
      $id =~ s/^\s+|\s+$//g;
      if ($ids{$id}) {
         if ($ids{$id} != 1) {
           my $correct = $ids{$id};
           $line =~ s/\:STACK//;
           $line =~ s/^\s*STACK/$correct/;
         }
         $result .= $line."\n";
      }
    } else {
      $result .= $line."\n";
    }
  }

  # Remove non-displayed DS from CDEF sums (used to draw lines on top of areas)
  @lines = split(/\n/, $result);
  $result = '';
  foreach my $line (@lines) {
    if ($line =~ /^\s*(C|V)DEF\:[^\,]+\,([^\,]+\,\+\,)+/) {
      &elTrace('Pb: '.$line);
      foreach my $ds (@dss) {
        if ($$ds{'state'} != 1) {
          my $id = $$ds{'id'};
          $line =~ s/([=\,])$id(\,\+)?\,?/$1/g;  # we remove the element and following '+' sign
        }
      }
      $line =~ s/(=[^\,\:]+)\,\+/$1/; # if $line is '=a,+[...]', we remove ',+'
      &elTrace('Pb: '.$line); 
    }
    $result .= $line."\n";
  }
 
  $result; 
}


# ------------------------------------------------- #
# Create a graph                                    #
# ------------------------------------------------- #
# Param  : rrd_sid                                  #
# Param  : type ('h', 'd', 'b', 'm', 'w', 'y', 'c') #
# Param  : [Optional] time1 (yyyy-mm-dd hh:mm)      # 
# Param  : [Optional] time2 (yyyy-mm-dd hh:mm)      #
# Return : none                                     #
# ------------------------------------------------- #

sub createRRDGraph
{
  my %elh;

  $elh{'rrd_sid'} = $_[0];

  $elh{'rrd_id'} = $_[0];
  $elh{'rrd_id'} =~ s/^[0-9]+_//;

  require $RRD_DIR.$elh{'rrd_sid'}.'/graph.pm';

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

  $elh{'dss'} = &getDSItems($elh{'rrd_sid'});

  $elh{'cmd'} = "rrdtool graph ".$elh{'img_src'}." ";
  $elh{'cmd'} .= "--start ".$elh{'time1'}." --end ".$elh{'time2'}." ";
  $elh{'cmd'} .= "--imgformat ".$IMG_FORMAT." --lazy ";
  $elh{'cmd'} .= "-w ".$GRAPH_WIDTH." -h ".$GRAPH_HEIGHT." " if !$cgi->param('type');
  $elh{'cmd'} .= "-w ".$ZOOM_WIDTH." -h ".$ZOOM_HEIGHT." " if $cgi->param('type');
  $elh{'cmd'} .= 'COMMENT:"From '.$elh{'strtime1'}.' To '.$elh{'strtime2'}.'\c" ';
  $elh{'cmd'} .= 'COMMENT:"\n" ';
 
  if (getCDSString($elh{'rrd_sid'}) =~ /0/) {
    $elh{'cmd'} .= customizeRRDCmd($elh{'dss'}, $GRAPH_CMDS{$elh{'rrd_id'}});
  } else {
    $elh{'cmd'} .= $GRAPH_CMDS{$elh{'rrd_id'}};
  }

  $elh{'cmd'} =~ s/[\n\r]+/ /g;
  $elh{'cmd'} =~ s/\{#server#\}/$SERVER/g;
  $elh{'cmd'} =~ s/\{#path#\}/$RRD_DIR$elh{'rrd_sid'}\//g;
  $elh{'cmd'} =~ s/\{#linecolor#\}/$GRAPH_LINECOLOR/g;
  $elh{'cmd'} =~ s/\{#color1#\}/$GRAPH_COLOR1/g;
  $elh{'cmd'} =~ s/\{#color2#\}/$GRAPH_COLOR2/g;
  $elh{'cmd'} =~ s/\{#color3#\}/$GRAPH_COLOR3/g;
  $elh{'cmd'} =~ s/\{#color4#\}/$GRAPH_COLOR4/g;
  $elh{'cmd'} =~ s/\{#color5#\}/$GRAPH_COLOR5/g;
  $elh{'cmd'} =~ s/\{#dcolor1#\}/$GRAPH_DCOLOR1/g;
  $elh{'cmd'} =~ s/\{#dcolor2#\}/$GRAPH_DCOLOR2/g;
  $elh{'cmd'} =~ s/\{#dcolor3#\}/$GRAPH_DCOLOR3/g;

  if ((-e $elh{'img_src'} && (stat($elh{'img_src'}))[10] >=
      time - ($cgi->param('type') eq 'c'?$DELAY_BETWEEN_CUSTOM:$DELAY_BETWEEN)) &&
      (!($cookie && $cookie->name eq $elh{'rrd_sid'}))) {
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

  if ($ADD_UID_TO_IMG_URL) {
    my $t = '.'.lc($IMG_FORMAT);  
    $elh{'img_src'} =~ s/$t$//;
    $elh{'img_src'} .= '-'.(time() + int rand(1000)).$t;
  }

  if (!$cgi->param('rrd')) {
    $elh{'link_type'} = "more";
    $elh{'link_url'} = "index.pl?rrd=".$elh{'rrd_sid'};
  } elsif (!$cgi->param('type')) {
    $elh{'link_type'} = "zoom";
    $elh{'link_url'} = "index.pl?rrd=".$elh{'rrd_sid'}."&type=$_[1]&time1=$_[2]&time2=$_[3]";
  }

  $elh{'display_command'} = $cgi->param('type');

  push @elgraphs, \%elh;
}


# ------------ #
# Get RRD list #
# ------------ #
@rrds = &getRRDList();


# ----------------------------------------------------------- #
# Check validity of cgi parameters to limit security problems #
# ----------------------------------------------------------- #
my $trrd;
if (($cgi->param('type') &&
     !($cgi->param('type') =~ /^[hdbwmyc]$/))
    ||
    ($cgi->param('rrd') &&
     ($trrd = $cgi->param('rrd')) &&
     !(grep /^$trrd$/, @rrds))
    ||
    ($cgi->param('type') && !$cgi->param('rrd'))
    ||
    ($cgi->param('type') eq 'c' &&
      (!$cgi->param('time1') || !$cgi->param('time2')))
    ||
    ($cgi->param('time1') &&
     !($cgi->param('time1') =~ 
         /^[0-9]{4}\-[0-9]{2}\-[0-9]{2} [0-9]{2}\:[0-9]{2}$/))
    ||
    ($cgi->param('time2') &&
     !($cgi->param('time2') =~
         /^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}$/))
    ||
    ($cgi->param('crrd') && !$cgi->param('cds'))
    ||
    ($cgi->param('cds') && !$cgi->param('crrd'))
    ||
    ($cgi->param('crrd') &&
     ($trrd = $cgi->param('crrd')) &&
     !(grep /^$trrd$/, @rrds))
    ||
    ($cgi->param('cds') && 
     !($cgi->param('cds') =~ /^[0-1]+$/))) {
  print $cgi->header();
  print "Bad parameter value\n";
  exit 0;
}


# ---------------- #
# Cookies & Header #
# ---------------- #

# Summary View cookie
if ($cgi->param('summary_view') && ($cgi->param('summary_view') =~ /^[hdbwmy]$/)) {
  $cookie = $cgi->cookie(
    -name=>'summary_view',
    -value=>$cgi->param('summary_view'),
    -expires=>gmtime(time()+365*24*3600)." GMT",
    -path=>'/',
  );
}

# RRD option cookie (which DS shall we display)
elsif ($cgi->param('crrd')) {
  my $temp = $cgi->cookie($cgi->param('crrd'));
  unless (($temp && $temp eq $cgi->param('cds')) ||
          (!$temp && ($cgi->param('cds') =~ /^1+$/)) ||
          ($cgi->param('cds') =~ /^0+$/)) {
    my $expires;
    if ($cgi->param('cds') =~ /^1+$/) {
      $expires = '-1d';
    } else {
      $expires = gmtime(time()+365*24*3600)." GMT";
    }
    $cookie = $cgi->cookie(
      -name=>''.$cgi->param('crrd'),
      -value=>$cgi->param('cds'),
      -expires=>$expires,
      -path=>'/',
    );
  }
}

# Header
if ($cookie) {
  print $cgi->header(-cookie=>$cookie);
} else {
  print $cgi->header();
}


# ----------------------------------------- #
# rrd is passed in parameter to the page... #
# ----------------------------------------- #
if (defined $cgi->param('rrd') && $cgi->param('rrd') =~ /[a-zA-Z0-9]/) {

  my $rrd_id = $cgi->param('rrd');
  $rrd_id =~ s/^[0-9]+_//;

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
  global_vars => '1',
  loop_context_vars => '1'
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
foreach my $trace (@trace) {print $trace;}

#!/usr/bin/perl

 #                                                        #
 # ------------------------------------------------------ #
 # eLuna Graph System                                     #
 # ------------------------------------------------------ #
 # File     : download.pl                                 #
 # Author   : Stephane Dupont                             #
 # Version  : 1.10                                        #
 # Released : 2017-06-23                                  #
 # Summary  :                                             #
 #   Script to force file download                        #
 # ------------------------------------------------------ #
 #                                                        #

use CGI;
use DateTime;

require 'config.pm';

my $cgi = new CGI;
my $filename = $cgi->param('uid');


# Expand from scientific notation to decimal notation
# ---------------------------------------------------
sub expand {
  my $n = shift;
  return $n unless $n =~ /^(.*)e([-+]?)(.*)$/;
  my ($num, $sign, $exp) = ($1, $2, $3);
  my $sig = $sign eq '-' ? "." . ($exp - 1 + length $num) : '';
  return sprintf "%${sig}f", $n;
}


# Image download
# --------------
if ($filename =~ /^[0-9]+$/) {

  $filename = $filename.'.png';

  print "Content-Type:application/octet-stream; name=\"$filename\"\r\n";
  print "Content-Disposition: attachment; filename=\"$filename\"\r\n\n";

  $filename = $GRA_DIR.$filename;
  open (FILE, "<$filename");
  while(read(FILE, $buffer, 100)) {
     print("$buffer");
  }
  close FILE;


# CSV data
# --------
} else {

  my $rrd = $cgi->param('rrd');
  my $time1 = $cgi->param('time1');
  my $time2 = $cgi->param('time2');

  my $rrdId = $rrd;
  $rrdId =~ s/^[0-9]+_//;

  my $rrdFile = $RRD_DIR.$rrd.'/'.$rrdId.'.rrd';

  if (-e $rrdFile && $time1 =~ /^[0-9]+$/ && $time2 =~ /^[0-9]+$/) {

    my $filename = $rrdId.'-'.$time1.'-'.$time2.'.csv';    

    # Headers
    print "Content-Type:application/octet-stream; name=\"$filename\"\r\n";
    print "Content-Disposition: attachment; filename=\"$filename\"\r\n\n";

    # Getting data
    my $cmd = 'rrdtool fetch '.$rrdFile.' AVERAGE --start '.$time1.' --end '.$time2;
    my @result = `$cmd`;

    my $header = 0;
    foreach my $line (@result) {
      if ($line =~ /\w/) {
        $line =~ s/^\s*//;
        $line =~ s/\s*$//;
        $line =~ s/\s+/,/g;

        # Header
        if (!$header) {
          print 'epoch,datetime,'.$line."\n";
          $header = 1;

        # Data line
        } else {
          $line =~ s/^(.*):,//;

          # epoch / datetime
          my $epoch = $1;
          my $dt = DateTime->from_epoch(epoch => $epoch, time_zone => "local");
          my $output = $epoch.','.$dt->ymd.' '.$dt->hms.',';

          # data
          my @data = split(/,/, $line);
          foreach my $data (@data) {        
            $data = &expand($data) if $CSV_DATA_CONVERT_TO_DECIMAL;
            $data =~ s/\.0+$//;            
            $output .= $data.',';
          }
          $output =~ s/,$//;
          print "$output\n" unless $output =~ /:[0-9]+(,(-)?nan)+$/;
        }
      }
    }
  } else {
    print $cgi->header();
    print "Bad parameter value\n";
    exit 0;
  }
}

#!/usr/bin/perl

 #                                                        #
 # ------------------------------------------------------ #
 # eLuna Graph System                                     #
 # ------------------------------------------------------ #
 # File    : update.pl                                    #
 # Author  : Stephane Dupont                              #
 # Version : 1.09                                         #
 # Date    : 2013-11-17                                   #
 # Summary :                                              #
 #   Script that updates the differents RRD elements      #
 #   To use with cron, by example :                       #
 #   */5 * * * * root /path/to/update.pl                  #
 # ------------------------------------------------------ #
 #                                                        #

use Cwd;

die "This script must be executed as root\n" if $< != 0;

# Path to the directory containing the RRD elements
my $RRD_DIR = 'rrd/';

my $origdir = getcwd;
my $ELG_DIR = $0;
$ELG_DIR =~ s/update\.pl//;
chdir($ELG_DIR) if $ELG_DIR;

opendir(DIR, $RRD_DIR) ||
  die "Unable to open RRD dir\n";
my @rrds =
  grep { -d $RRD_DIR.$_ }
      grep { ( $_ ne '.' ) and ( $_ ne '..' ) }
          readdir DIR;
closedir DIR;

foreach my $rrd (@rrds) {
  chdir($RRD_DIR.$rrd);
  $rrd =~ s/^[0-9]*_//;
  if (! -e $rrd.'.rrd') {
    system("./create.sh") == 0 ||
      print "Error while trying to create RRD '$rrd'\n";
    system('chmod -f 775 '.$rrd.'.rrd');
    sleep(2);
  }
  if (! -e $rrd.'.rrd') {
    print "Creation of RRD '$rrd' has failed\n";
  } else {
    if (-e 'update.sh') {
      system('./update.sh') == 0 ||
        print "Error while trying to update RRD '$rrd'\n";
    } elsif (-e 'update.pl') {
      system('perl update.pl') == 0 ||
        print "Error while trying to update RRD '$rrd'\n";
    } else {
      print "Unable to find an update script for RRD '$rrd'\n";
    }
  }
  chdir('../../');
}
chdir($origdir);

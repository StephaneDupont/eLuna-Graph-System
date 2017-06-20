# eLuna Graph System

## Description

* Title : eLuna Graph System
* Version : 1.09
* Released : 2013-11-17
* Website : [https://github.com/stephanedupont/eLunaGraphSystem](https://github.com/stephanedupont/eLunaGraphSystem)
* Author : Stephane Dupont
* License : GNU General Public License (see [LICENSE](LICENSE))

eLuna Graph System is an application written in Perl based on RRDTool. Its aim is collection and then presentation in graphic form of data to aid in the monitoring of a machine. By default, the application allows monitoring of the load, CPU usage, memory use, number of processes, amount of data transmitted via eth0 (In/Out) and disk space used in /.

## Prerequisite

* root access on the machine to monitor
* An http server (preferably Apache)
* RRDTool (preferably version >= 1.2)
* Perl (preferably version >= 5.8) with the following modules installed:
  * DateTime
  * HTML::Template::Expr

## Installation

* Download the latest version here: [http://graphs.eluna.org/releases/latest/eluna_graph_system.tar.gz](http://graphs.eluna.org/releases/latest/eluna_graph_system.tar.gz) 

* Decompress the archive into a folder accessible via Apache.

  Example:
  
  ```
  mv eluna_graph_system.tar.gz /var/www/graphs/
  cd /var/www/graphs/
  tar -xzf eluna_graph_system.tar.gz
  ```

* Perform if necessary a chown and/or a chmod on all scripts so that they are readable and executable by the user/group used by the http server. The 'graphs' folder must also be writeable by the http server. In the majority of cases, you have nothing to do.

* Schedule the execution of the [update.pl](update.pl) script every 5 minutes with crontab.

  Example:
  
  ```
  */5 * * * * root /var/www/graphs/update.pl
  ```

* Configure Apache so that the [index.pl](index.pl) script is interpreted correctly as a perl script and that is viewed as 'DirectoryIndex'.

  Example:
  
  ```
  <Directory /var/www/graphs/>
    AddHandler cgi-script .pl
    Options +ExecCGI
    DirectoryIndex index.pl
  </Directory>
  ```

* Ensure that the [.htaccess](rrd/.htaccess) file containing 'deny from all' and contained in the [rrd](rrd) folder is taken into account by Apache. The [rrd](rrd) folder must not be accessible via http. In the case of an http server other than Apache, create a similar protective mechanism.

The application should now work fine. Wait about ten minutes so that the cron task can be executed at least twice, then try to view the script in a web browser.

## Customization

### 1/ Configuration

The config file [config.pm](config.example.pm) contains a number of options like the name of the machine, the format of the pictures generated, the size of the images generated, the colours of the images generated, the default view, etc.

### 2/ Application appearance/texts

The application uses the Perl HTML::Template::Expr module, itself being an extension of the Perl HTML::Template module, which allows for definition of an external HTML template to manage the graphical appearance, the layout and the texts. This template is located in the [template](template) folder.

For more information please consult the documentation for these two modules here:

* [http://search.cpan.org/~samtregar/HTML-Template/lib/HTML/Template.pm](http://search.cpan.org/~samtregar/HTML-Template/lib/HTML/Template.pm)
* [http://search.cpan.org/~samtregar/HTML-Template-Expr/Expr.pm](http://search.cpan.org/~samtregar/HTML-Template-Expr/Expr.pm)

### 3/ Add/customize elements

Notes:

* It is strongly advised when adding elements to base these on an existing element rather than starting from scratch.

* It is strongly advised that you read the documentation on RDDTool before customizing or adding elements. This documentation, as well as tutorials, are available on the RRDTool site:
  
  [http://oss.oetiker.ch/rrdtool/doc/index.en.html](http://oss.oetiker.ch/rrdtool/doc/index.en.html)

#### How it works

Each element is composed of a folder placed in the [rrd](rrd) directory. This folder must contain a create file ('create.sh'), an update file ('update.sh' or 'update.pl') and a file for generating the graphs ('graph.pm').

#### Folder name

The name of the folder must be the element ID, possibly preceded by an integer and by the character '_'. For example, for an element which one wishes to identify by 'cpu', the name of the folder may be 'cpu' or, for example, '123_cpu'.

When the element ID is preceded by an integer this affects/determines the display order as the elements are displayed in alphabetical order of the folders containing them (and not in the alphabetical order of their IDs).

#### create.sh

The file 'create.sh' is responsible for the creation of the Round Robin Database. It is a shell file containing an RRD create command. The RRD created must be named 'id.rrd', where 'id' is the element ID.

For various reasons, it is desirable to specify the same RRA (Round Robin Archives) and the same step value for each of the application elements.

Example: Creation of a Round Robin Database corresponding to the 'cpu' element and intended for the storage of four DS (Data Sources): 'user', 'system', 'nice' and 'idle'.

```
#!/bin/bash

rrdtool create cpu.rrd \
 --start `date +%s` \
 --step 300 \
 DS:user:COUNTER:600:0:U \
 DS:system:COUNTER:600:0:U \
 DS:nice:COUNTER:600:0:U \
 DS:idle:COUNTER:600:0:U \
 RRA:AVERAGE:0.5:1:2016 \
 RRA:AVERAGE:0.5:6:1344 \
 RRA:AVERAGE:0.5:24:732 \
 RRA:AVERAGE:0.5:144:1460
```

#### update.sh / update.pl

The file 'update.sh' is responsible for updating the Round Robin Database associated with the element. The execution of this script must therefore insert into the RRD a new value for all the DS (Data Sources) that are defined in the create file.

Note that it is possible to replace this 'update.sh' shell file with a perl file 'update.pl'. If the first is not found, the second will be executed.

Example: Updating of the RRD associated with the 'cpu' element by a perl script

```
#!/usr/bin/perl

$dummy = `cat /proc/stat | grep "^cpu "`;
$dummy =~ /(.*) (.*) (.*) (.*) (.*)/;

system("rrdtool update cpu.rrd -t user:system:nice:idle N:$2:$3:$4:$5");
```
   
#### graph.pm

The file 'graph.pm' contains parameters for the display of the graph associated with the element. This must include:

* The graph title, contained in the variable $GRAPH_TITLES{'id'} (where 'id' is the element ID). If {#server#} is present in this title it will be substituted by the server name.

* A group of parameters that will be transferred to RDDTool. This group of parameters must be contained in the variable $GRAPH_CMDS{'id'} (where 'id' is the element ID).

  Some substitutions will be effected among these parameters. See the following list:

  ```
  {#server#}    : Server name
  {#path#}      : Element folder path
  {#color1#}    : Draw color 1
  {#color2#}    : Draw color 2
  {#color3#}    : Draw color 3
  {#color4#}    : Draw color 4
  {#color5#}    : Draw color 5
  {#dcolor1#}   : Gradient color 1
  {#dcolor2#}   : Gradient color 2
  {#dcolor3#}   : Gradient color 3
  {#linecolor#} : Lines color
  ```

  Note that certain parameters are managed by the application and do not require to be specified here. These parameters are:

  * the name of the image file generated
  * the type of the image file generated
  * the start date of the graph (--start)
  * the end date of the graph (--end)
  * the graph dimensions (--w and --h)
  * graph comment

Example: 'graph.pm' file associated with the 'cpu' element of previous examples

```
$GRAPH_TITLES{'cpu'} = "{#server#} - CPU Usage";
$GRAPH_CMDS{'cpu'} = <<"CPU_GRAPH_CMD";
--title "{#server#} - CPU Usage"
--vertical-label="Percent"
--lower-limit 0 --upper-limit 100
DEF:user={#path#}cpu.rrd:user:AVERAGE
DEF:system={#path#}cpu.rrd:system:AVERAGE
DEF:nice={#path#}cpu.rrd:nice:AVERAGE
DEF:idle={#path#}cpu.rrd:idle:AVERAGE
CDEF:total=user,system,+,nice,+,idle,+
CDEF:p_user=user,total,/,100,*
CDEF:p_system=system,total,/,100,*
CDEF:p_nice=nice,total,/,100,*
CDEF:mysum=p_user,p_system,+,p_nice,+
AREA:p_user{#dcolor1#}:"User   "
GPRINT:p_user:LAST:"Current\\: %5.2lf%%  "
GPRINT:p_user:AVERAGE:"Average\\: %5.2lf%%  "
GPRINT:p_user:MAX:"Max\\: %5.2lf%%\\n"
STACK:p_system{#dcolor2#}:"System "
GPRINT:p_system:LAST:"Current\\: %5.2lf%%  "
GPRINT:p_system:AVERAGE:"Average\\: %5.2lf%%  "
GPRINT:p_system:MAX:"Max\\: %5.2lf%%\\n"
STACK:p_nice{#dcolor3#}:"Nice   "
GPRINT:p_nice:LAST:"Current\\: %5.2lf%%  "
GPRINT:p_nice:AVERAGE:"Average\\: %5.2lf%%  "
GPRINT:p_nice:MAX:"Max\\: %5.2lf%%\\n"
LINE1:mysum{#linecolor#}
CPU_GRAPH_CMD

1; # Return true
```
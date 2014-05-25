#!/bin/bash
#
#  Copyright Leif Sawyer, ak.hepcat@gmail.com -  May 16, 2014
#  GPLv3
#  Version 0.1

# Change this to where your cache files and graphs are stored.
DATA="/opt/data/ArinRunRate"
# This is where the graphs and index pages are published.  If not set, uses $DATA
# WEBROOT="/var/www/ArinRunRate"

#
WEBROOT=${WEBROOT:-$DATA}
TDATA=$(pwd)
DATA=${DATA:-$TDATA}
PROGS=${0%/*}
DATE=$(date +'%Y%m%d')
YR=$(date +'%Y')
MO=$(date +'%m')

build_index()
{
	mydate=$1
	
	cat >$WEBROOT/index-${mydate}.html<<EOF
<HTML>
<HEAD>
<TITLE>Index for ${DATE}</TITLE>
<STYLE content="text/css">
html, body { height:100%; } 
img { -ms-interpolation-mode: bicubic; }
</STYLE>
</HEAD>
<BODY>
<H2>Index for ${DATE}</H2>
<br>
<a href="index.html">Main Index</a>
<br>
EOF

	for IMAGE in 12Month Y2K Full
	do
		if [ -r ${WEBROOT}/ARIN-Runout-${IMAGE}-${mydate}.png ]
		then
			echo "Runout data for ${IMAGE} data<br>" >> $WEBROOT/index-${mydate}.html
			echo "<a href=\"ARIN-Runout-${IMAGE}-${mydate}.png\">" >> $WEBROOT/index-${mydate}.html
			echo "<img style=\"height:70%;\" src=\"ARIN-Runout-${IMAGE}-${mydate}.png\" \></a>" >> $WEBROOT/index-${mydate}.html
			echo "<br>" >> $WEBROOT/index-${mydate}.html
		fi
	done

	cat >>$WEBROOT/index-${mydate}.html<<EOF
</BODY>
</HTML>
EOF

}
###
# Main prog here

# Just remove the old one.  
rm -f ${WEBROOT}/index.html

DATES=$( find -L $WEBROOT -maxdepth 1 -iname "ARIN-Runout-12Month-*.png" -o -iname "ARIN-Runout-Y2K-*.png" -iname "ARIN-Runout-Full-*.png" | sed 's/\.png$//g; s/.*-//g' | sort -n)

        cat >$WEBROOT/index.html<<EOF
<HTML>
<HEAD>
<TITLE>Index for Arin Runout Trending</TITLE>
<STYLE content="text/css">
html, body { height:100%; }
img { -ms-interpolation-mode: bicubic; }
</STYLE>
</HEAD>
<BODY>
<H2>Index for Arin Runout Trending</H2>
<br>
EOF
        
for DATE in $DATES
do
	if [ ! -r index-${DATE}.html ]
	then
		build_index ${DATE}
	fi
	echo "<a href=\"index-${DATE}.html\">Data for ${DATE}</a><br>" >>$WEBROOT/index.html
	echo "<img style=\"height:70%;\" src=\"ARIN-Runout-12Month-${mydate}.png\" \></a>" >> $WEBROOT/index.html
	echo "<br>" >> $WEBROOT/index.html
done

cat >>$WEBROOT/index.html<<EOF
</BODY>
</HTML>
EOF

##  done

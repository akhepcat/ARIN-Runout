#!/bin/bash
#
#  Copyright Leif Sawyer, ak.hepcat@gmail.com -  May 16, 2014
#  GPLv3
#  Version 0.1

# Change this to where your cache files and graphs are stored.
DATA="/opt/data/ArinRunRate"
# This is where the graphs and index pages are published.  If not set, uses $DATA
WEBROOT="/var/www/ArinRunRate"

#
WEBROOT=${WEBROOT:-$DATA}
TDATA=$(pwd)
DATA=${DATA:-$TDATA}
PROGS=${0%/*}
DATE=$(date +'%Y%m%d')
YR=$(date +'%Y')
MO=$(date +'%m')

if [ -n "$*" ];
then
	FORCE=1
else
	FORCE=0
fi



#### reindex all the graphs per year.
build_index()
{
	mydate=$1
	MYR=${mydate:0:4}
	
	cat >${WEBROOT}/${MYR}/index-${mydate}.html<<EOF
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
<a href="/ArinRunRate/index.html">Main Index</a><br />
<a href="/ArinRunRate/index-${MYR}.html">Year Index</a>
<br>
EOF

	for IMAGE in 12Month Y2K Full
	do
		IMGYEAR=${IMAGE//ARIN-Runout-*-/}
		if [ -r ${WEBROOT}/${IMAGE}/ARIN-Runout-${IMAGE}-${mydate}.png ]
		then
			echo "Runout data for ${IMAGE} data<br>" >> ${WEBROOT}/${MYR}/index-${mydate}.html
			echo "<a href=\"/ArinRunRate/${IMAGE}/ARIN-Runout-${IMAGE}-${mydate}.png\">" >> ${WEBROOT}/${MYR}/index-${mydate}.html
			echo "<img style=\"height:70%;\" src=\"/ArinRunRate/${IMAGE}/ARIN-Runout-${IMAGE}-${mydate}.png\" \></a>" >> ${WEBROOT}/${MYR}/index-${mydate}.html
			echo "<br>" >> $WEBROOT/${MYR}/index-${mydate}.html
		fi
	done

	cat >>$WEBROOT/${MYR}/index-${mydate}.html<<EOF
<hr>
<a href="https://github.com/akhepcat/ARIN-Runout">GPLv3 code, Distributed via GitHub</a>
</BODY>
</HTML>
EOF

}

###
# Main index here
DATES=$( find -L $WEBROOT -maxdepth 2 -iname "ARIN-Runout-12Month-*.png" -o -iname "ARIN-Runout-Y2K-*.png" -iname "ARIN-Runout-Full-*.png" | sed 's/\.png$//g; s/.*-//g' | sort -nu)

YEARS=$( echo $DATES | sed 's/\([0-9][0-9][0-9][0-9]\)[0-9][0-9][0-9][0-9]/\1\n/g; s/ *//g;' | sort -un | grep -v '^$')

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
        
for YEAR in ${YEARS}
do
   test -d ${WEBROOT}/${YEAR} || mkdir -p ${WEBROOT}/${YEAR}


   echo "<a href=\"/ArinRunRate/${YEAR}/index-${YEAR}.html\">Index for ${YEAR}</a><br>" >>${WEBROOT}/index.html

   cat >$WEBROOT/${YEAR}/index-${YEAR}.html<<EOF
<HTML>
<HEAD>
<TITLE>Index for Arin Runout Trending - ${YEAR}</TITLE>
<STYLE content="text/css">
html, body { height:100%; }
img { -ms-interpolation-mode: bicubic; }
</STYLE>
</HEAD>
<BODY>
<H2>Index for Arin Runout Trending - ${YEAR}</H2>
<br>
EOF
        
   for DATE in ${DATES}
   do
      if [ -z "${DATE##*$YEAR*}" ]
      then

         if [ ${FORCE} -o ! -r ${WEBROOT}/${YEAR}/index-${DATE}.html ]
         then
#		echo "building index for ${DATE}"
		build_index ${DATE}
         fi

         echo "<a href=\"/ArinRunRate/${YEAR}/index-${DATE}.html\">Data for ${DATE}</a><br>" >>${WEBROOT}/${YEAR}/index-${YEAR}.html
         echo "<img style=\"height:70%;\" src=\"/ArinRunRate/12Month/ARIN-Runout-12Month-${DATE}.png\" \></a>" >> ${WEBROOT}/${YEAR}/index-${YEAR}.html
         echo "<br>" >> ${WEBROOT}/${YEAR}/index-${YEAR}.html

      fi
   done

   cat >>${WEBROOT}/${YEAR}/index-${YEAR}.html<<EOF
<hr>
<a href="https://github.com/akhepcat/ARIN-Runout">GPLv3 code, Distributed via GitHub</a>
</BODY>
</HTML>
EOF

done

echo "<img style=\"height:70%;\" src=\"/ArinRunRate/12Month/ARIN-Runout-12Month-${DATE}.png\" \></a>" >> ${WEBROOT}/index.html

   cat >>${WEBROOT}/index.html<<EOF
<hr>
<a href="https://github.com/akhepcat/ARIN-Runout">GPLv3 code, Distributed via GitHub</a>
</BODY>
</HTML>
EOF

##  done

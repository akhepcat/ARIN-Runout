#!/bin/bash
#
#  Copyright Leif Sawyer, ak.hepcat@gmail.com -  May 16, 2014
#  GPLv3
#  Version 0.2

# Change this to where you want cache files and graphs to be stored.
DATA="/opt/data/ArinRunRate"

#
TDATA=$(pwd)
DATA=${DATA:-$TDATA}
PROGS=${0%/*}
DATE=$(date +'%Y%m%d')
YR=$(date +'%Y')
MO=$(date +'%m')

# Cache for a day
if [ ! -r delegated-arin-extended-latest -o -z "$(find . -maxdepth 1 -iname delegated-arin-extended-latest -ctime 0)" ]
then
	F=delegated-arin-extended-latest
	wget -O ${DATA}/${F} -c ftp://ftp.arin.net/pub/stats/arin/${F}
fi

# Cache for a week
if [ ! -r work_available.html -o -z "$(find . -maxdepth 1 -iname work_available.html -ctime -7)" ]
then
	F=work_available.html
	wget -O ${DATA}/${F}  -c https://www.arin.net/${F}
fi

sed 's/<?xml.*//g; s/<tr>/\n<tr>/g; s/<tr><td>\///g; s/<\/td><td>/,/g; s/<\/td><\/tr>//g' ${DATA}/work_available.html | grep -v '^$' > ${DATA}/ARIN-Inventory-${DATE}.csv

# Print out a header...
#echo "RIR,COUNTRY,RESOURCE,RESOURCE_ID,SIZE,DATESTAMP,STATUS,MD5,INVENTORY" >  ARIN-Delegated-${DATE}.csv
echo "DATESTAMP,INVENTORY" >  ${DATA}/ARIN-Delegated-${DATE}.csv

REMAIN=0
for LINE in $(cat ${DATA}/ARIN-Inventory-${DATE}.csv)
do
   CIDR=${LINE%%,*}
   COUNT=${LINE##*,}
   INVCIDR=$((32 - $CIDR))
   VALUE=$((2**$INVCIDR))
   TOTAL=$(($VALUE * $COUNT))
   REMAIN=$(($REMAIN + $TOTAL))
done

echo "Total remaining addresses: $REMAIN"

NEWTOTAL=${REMAIN}
COUNT=2

for ROW in $( grep -E '\|ipv4\|.*\|(assigned|allocated)' ${DATA}/delegated-arin-extended-latest | sed 's/|/,/g;' | sort -r -n -t, -k +6)
do
	CIDRSIZE=$(echo $ROW | cut -f 5 -d,)
	NEWTOTAL=$((NEWTOTAL + $CIDRSIZE))
	echo "${ROW},${NEWTOTAL}" 
	COUNT=$((COUNT + 1))
done | sort -n -t, -k +6 | cut -d, -f 6,9 | sed 's/^\([1-2][0-9][0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\),/\1-\2-\3,/g' >> ${DATA}/ARIN-Delegated-${DATE}.csv

# Set the starting month as next month for our 'current' remaining...
m=$((MO + 1))
[ $m -gt 12 ] && m=1
# printf 'arin,,ipv4,,,%04d%02d01,projected,,%d\n' ${YR} ${m} ${REMAIN} >> ARIN-Delegated-${DATE}.csv
printf '%04d%02d01,%d\n' ${YR} ${m} ${REMAIN} >> ${DATA}/ARIN-Delegated-${DATE}.csv

Rscript ${PROGS}/ArinRunout.R ${DATA}

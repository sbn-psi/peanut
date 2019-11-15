#!/bin/bash

### ### ### ###
# This script extracts keywords from FITS headers
### ### ### ###

if [ -f "meta.txt.sql" ]; then mv meta.txt.sql meta.txt.sql.old; fi

cd frame/camera
txtList=`ls *.txt`

for full in $txtList
do
    /usr/bin/awk -f ../../../bin/lrip.txt.awk $full >> ../../meta.txt.sql
done

    sed 's/\(\.[0-9]\)[0-9]*/\1/g' ../../meta.txt.sql > ../../meta.txt.small.sql


exit

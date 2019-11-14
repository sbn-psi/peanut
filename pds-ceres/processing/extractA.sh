#!/bin/bash

#		28 Aug 2013 
# This looks at the cubes and figures out what the level 1A filenames are, then 
# 		builds the sql command to run it
# 	Only works for FC

############ Do all setup ###########

p=`pwd`
echo "Starting Extract $p" >> ../cal.log

if [ -f "extractA.sql" ]; then mv extractA.sql extractA.sql.old; fi

############ Build the list of all the files to process ###########
#	Use all
imgList=`ls *.IMG`


############ Run the loop ###########
for full in $imgList
do
	echo "------------------- $full --------------------"
	awk -f /dsk2/PDS/pds-ceres/processing/extractA.awk $full >> extractA.sql
done


echo "-------- Done"
echo "Ending Extract $p" >> ../cal.log

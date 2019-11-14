#!/bin/bash

#		06 Nov 2017 
# This extracts i,e,and phase information and puts it into extractI.sql 
# 	Only works for FC

############ Do all setup ###########

p=`pwd`
echo "Starting Extract $p" >> ../cal.log

if [ -f "extractI.sql" ]; then mv extractI.sql extractI.sql.old; fi

############ Build the list of all the files to process ###########
#	Use all
imgList=`ls *.IMG`


############ Run the loop ###########
for full in $imgList
do
	echo "------------------- $full --------------------"
	awk -f /dsk2/PDS/pds-ceres/processing/extractI.awk $full >> extractI.sql
done


echo "-------- Done"
echo "Ending Extract I $p" >> ../cal.log

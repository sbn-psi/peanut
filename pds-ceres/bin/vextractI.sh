#!/bin/bash

#		06 Nov 2017 
# This extracts i,e,and phase information and puts it into extractI.sql 
# 	Only works for VIR

############ Do all setup ###########

p=`pwd`
echo "Starting Extract $p" >> ../cal.log

if [ -f "vextractI.sql" ]; then mv vextractI.sql vextractI.sql.old; fi

############ Build the list of all the files to process ###########
#	Use all
imgList=`ls *[0-9]_1.LBL`


############ Run the loop ###########
for full in $imgList
do
	echo "------------------- $full --------------------"
	awk -f /dsk2/PDS/pds-ceres/processing/vextractI.awk $full >> vextractI.sql
done


echo "-------- Done"
echo "Ending Extract I $p" >> ../cal.log

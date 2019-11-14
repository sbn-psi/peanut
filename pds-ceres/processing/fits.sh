#!/bin/bash

#  Fold fits and headers into a tar.gz file
#		11 Nov 2012

############ Do all setup ###########
#		Commented out because I don't want to put in g_* for this
#source /Volumes/Process/Dropbox/processing/setup.sh

p=`pwd`
#echo "Starting fits $p" >> ../cal.log

#  ---------------
#  ---------------
source ../../gGlobal.rc
source gConfig.rc
imgList=`ls | grep FIT`
oneList=`ls -1 | grep FIT | head -1`
imgLen=`echo $oneList | wc -c`
rootLen=`echo $imgLen -4 -1  | bc`
imgNum=`echo $imgList | wc -l`

cnt=0
############ Run the loop ###########
for full in $imgList
do
	cnt=`echo $cnt + 1 | bc`
	root=`echo $full | cut -c -$rootLen`
	# Neede for survey, cycle 0
	cd $p
	echo "------------------- $root -- $cnt ($imgNum) ----"
	tar vcf $root.tar $root.FIT $root.LBL 
	gzip $root.tar
        #mkdir -p frame/fits-$level
	#mv $root.tar.gz frame/fits-$level
        mkdir -p fits-$level
	mv $root.tar.gz fits-$level
	#rm $root.tar
	
done

############ Build directory in which to copy ###########
echo "  -------- copying"
#  rsync -ah frame ../../out/$gPath/$phase/$sequence-$camera/
#  rsync -ah fits-$level ../../out/$gPath/$phase/
   rsync -ah fits-$level ../../out/$gPath/$phase/$sequence-$camera/frame/

	#cd $p
	#mkdir -p /home/PDS/Documents/data/$gPath/$phase/$sequence-$camera
	#cmnd="rsync -avhp frame /home/PDS/Documents/data/$gPath/$phase/$sequence-$camera/"
	#echo $cmnd
	#echo $cmnd >> ../cal.log
	#$cmnd

echo "-------- Done"
#echo "Ending FITS $p" >> ../cal.log
#echo "imgNum: $imgNum"
#ls frame/fits/*gz | wc -w

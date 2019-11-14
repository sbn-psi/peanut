#!/bin/bash

#  Fold fits and headers into a tar.gz file
#		11 Nov 2012

############ Do all setup ###########

p=`pwd`
#echo "Starting fits $p" >> ../cal.log

#  ---------------
#  ---------------
source ../gGlobal.rc
source gConfig.rc
imgList=`ls | grep lbl`
oneList=`ls -1 | grep lbl | head -1`
imgLen=`echo $oneList | wc -c`
rootLen=`echo $imgLen -4 -1  | bc`
imgNum=`echo $imgList | wc -l`

cnt=0
############ Run the loop ###########
for full in $imgList
do
	cnt=`echo $cnt + 1 | bc`
	root=`echo $full | cut -c -$rootLen`
	cd $p
	echo "------------------- $root -- $cnt ($imgNum) ----"
	tar vcf $root.tar $root.fit $root.lbl 
	gzip $root.tar
        #mkdir -p frame/fits-$level
	#mv $root.tar.gz frame/fits-$level
        mkdir -p fits-$level
	mv $root.tar.gz fits-$level
	#rm $root.tar
	
done

############ Build directory in which to copy ###########
echo "  -------- copying"
#   rsync -ah fits-$level ../../out/$gPath/$phase/
   rsync -ah fits-$level ../out/$gPath/$phase/$sequence-$camera/frame/

echo "-------- Done"

#!/bin/bash

# Build ENVI headers from QUB headers
#		18 May 2012

source ../processing/lsetup.sh

p=`pwd`
echo "ENVI Running $p" >> ../cal.log

#mkdir frame/envi
#mkdir frame/raw

# Set for VIR
#list=`ls *_1.LBL`

# Set a variable to have the correct variable for the camera's wavelengths
if [ "$camera" == "VIR-IR" ]; then
	echo "camera is IR"
	waveFile="ir-header.txt"
else
	if [ "$camera" == "VIR-VIS" ]; then
		echo "camera is IR"
		waveFile="vis-header.txt"
	else
		echo "Camera is $camera"
		exit;
	fi

fi

len=`echo $oneList | wc -m`
echo "len >>>>>$len<<<<"
shortLen=`echo $len - 5 | bc`
echo ">$shortLen<"

# Needed for Survey, cycle 0
				#len=`ls *ed.LBL | head -1 | wc -m` 
				#list=`ls *ed.LBL`
				#shortLen=`echo $len - 14 | bc`

#  ---------------
#  --------------- Loop through all the images
for i in $imgList

do
	root=`echo $i | cut -c -$shortLen`

	echo "------------------- $i --------------------"

	echo "  -------- awk'n >>>$root<<<"
	awk -f $myPath/processing/envi.awk -v  sequence=$sequence -v phase=$phase $i > tmp
	cat tmp $myPath/processing/$waveFile > $root.HDR
	rm tmp

	echo "  -------- building"
	#tar cvf $root.tar $root.LBL $root.QUB $root.HDR
	#Neede for Survey, cycle 0
	#				str="_despiked"
					tar cvf $root.tar $i $root$str.QUB $root.HDR
	gzip -f $root.tar
	mv $root.tar.gz frame/envi/
	mv $root.HDR frame/envi/

done

#echo "  -------- copying"

   #rsync -apvh frame maps /Library/WebServer/Documents/data/Vesta-DB/$phase/$sequence-$camera/

echo "-------- Done"
echo "ENVI done $p" >> ../cal.log


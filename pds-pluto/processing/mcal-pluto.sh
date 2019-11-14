#!/bin/bash
# General pipeline for MVIC images

p=`pwd`
echo "MVIC Calib $p" >> ../cal.log


############ Do all setup ###########
source /dsk2/PDS/pds-pluto/processing/setup.sh

cnt=0
############ Run the loop ###########
for full in $imgList
do
   cnt=`echo $cnt + 1 | bc`
   root=`echo $full | cut -c -$rootLen`
	mapPath=tm-$root
	framePath=tf-$root

	echo
	echo "-------------------------------------- "
   echo "----- " $root  " ----- $cnt of $imgNum"
	echo "-------------------------------------- "

	#############################
	##### convert into ISIS & move files out of the way
	#############################
	echo "-------------------------------------- Convert"
	mvic2isis FROM=$root.fit TO=$framePath.cub
	
	#############################
	# Get the SPICE Information
	#############################
	echo "-------------------------------------- Spiceinit "


	#spiceinit from=$framePath.cub web=yes ckpredicted=TRUE spkpredicted=TRUE 

# By hand SPICE, using updated PCK
	spiceinit ATTACH from=$framePath.cub ckpredicted=TRUE spkpredicted=TRUE PCK=../pluto-eep.tpc shape=ellipsoid
#	spiceinit ATTACH from=$framePath.cub ckpredicted=TRUE spkpredicted=TRUE



# Using ISIS servers -- all final data
	#spiceinit ATTACH from=$framePath.cub 

# ***** PDS **** SPICE
#   spiceinit from=$framePath.cub ATTACH SPKPREDICT=true \
#			SPKRECON=false SHAPE=user \
#   	   MODEL=$vSupport/support/PreLAMO/gaskell_vesta_prelamo_dem.cub \
#      	EXTRA=$vSupport/support/HAMO_V1/dawn_vesta_v04-iau.tpc
	footprintinit FROM=$framePath.cub LIMBTEST=spiceinit \
			INCTYPE=VERTICES NUMVERTICES=10

	echo "-------------------------------------- Basic "
	isis2std FROM=$framePath.cub+1 TO=frame/$root.png MAXPERCENT=99.9 
	isis2std FROM=$framePath.cub+1 TO=frame/$root.tif format=tiff MAXPERCENT=99.9 

	#############################
	# Project the cube into a camera view
	#############################
	echo "-------------------------------------- Map"
	cam2map from=$framePath.cub TO=$mapPath.cub defaultrange=camera MAP=../equi.map
	if [ ! -e "$mapPath.cub" ]; then
		echo "$p $root ($cnt)" >> ../error.log
	fi


	#############################
	# Work on the poles
	#############################
	maxLat=`awk '/MaximumLatitude/ { printf("%d\n", $3)}' $mapPath.cub`
	minLat=`awk '/MinimumLatitude/ { printf("%d\n", $3)}' $mapPath.cub`
	echo "MaxLat: " $maxLat
	echo "MinLat: " $minLat
   if [ "$maxLat" -lt "-45" ]
   then
      echo "-------------------------------------- Process Lower"
      cam2map from=$framePath TO=$mapPath.cub defaultrange=camera MAP=../poleS.map
	fi

	if [ "$minLat" -gt "45" ]
	then
     	echo "-------------------------------------- Process Upper"
     	cam2map from=$framePath TO=$mapPath.cub defaultrange=camera MAP=../poleN.map
	fi


	#############################
	# Make Images
	#############################
	echo "-------------------------------------- Thumbs "
	isis2std FROM=$mapPath.cub+1 TO=maps/$root.png MAXPERCENT=99.9 
	isis2std FROM=$mapPath.cub+1 TO=maps/$root.jp2 MAXPERCENT=99.9 FORMAT=jp2 BITTYPE=u16bit
   convert -interpolate bicubic -resize 50% maps/$root.png maps/jpg/$root.jpg
   convert -interpolate bicubic -resize 50% frame/$root.png frame/jpg/$root.jpg

	#############################
	# Make cubes smaller to save space
	#############################
	gzip -c $framePath.cub > frame/cubes/f-$root.cub.gz
	gzip -c $mapPath.cub > maps/cubes/m-$root.cub.gz
	rm $framePath.cub $mapPath.cub
done	# loop

cd maps
#mv *.cub cubes
mv *.png png
mv *.pgw pgw
mv *.jp2 jp2
mv *.j2w j2w
#gzip cubes/*cub &
cd ..

cd frame
#mv *.cub cubes
mv *.png png
mv *.tif tif
#gzip cubes/*cub &
cd ..

echo "-------------------------------------- Done "

echo "done $p" >> ../cal.log

orig=`ls *fit | wc -w`
now=`ls maps/cubes/*.cub* | wc -w`
echo "Orig: $orig, Now: $now";



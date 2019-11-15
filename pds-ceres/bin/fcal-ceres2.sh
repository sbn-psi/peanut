#!/bin/bash
# General pipeline for FC images

p=`pwd`
echo "FC Calib $p" >> ../cal.log

mv -f t_* del/


############ Do all setup ###########
source /dsk2/PDS/pds-ceres/processing/setup.sh
#$DROP/processing/isisupdate

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
	dawnfc2isis FROM=$root.IMG TO=$framePath.cub target=Ceres
	
	#############################
	# Get the SPICE Information
	#############################
	echo "-------------------------------------- Spiceinit "

# DAWN SPICE - old (preLAMO)
   #spiceinit from=$framePath.cub ATTACH SPKPREDICT=true \
	#		SPKRECON=false SHAPE=user \
   #   MODEL=$vSupport/support/PreLAMO/gaskell_vesta_prelamo_dem.cub \
   #  	EXTRA=$vSupport/support/HAMO_V1/dawn_vesta_v04.tpc


# Dawn SPICE - post HAMO2
#   spiceinit from=$framePath.cub ATTACH SPKPREDICT=true \
#		SPKRECON=false SHAPE=user \
#      MODEL=$vSupport/20130522/gaskell_vesta_20130522_dem.cub \
#     	EXTRA=$vSupport/20130522/dawn_vesta_v05.tpc

# Basic SPICE from the web
	#spiceinit from=$framePath.cub web=yes ckpredicted=TRUE spkpredicted=TRUE 

# By hand SPICE, using updated PCK
	#spiceinit ATTACH from=$framePath.cub ckpredicted=TRUE spkpredicted=TRUE PCK=../dawn_ceres_v04.tpc

# Using ISIS servers -- all final data
	spiceinit ATTACH from=$framePath.cub 

# ***** PDS **** SPICE
#   spiceinit from=$framePath.cub ATTACH SPKPREDICT=true \
#			SPKRECON=false SHAPE=user \
#   	   MODEL=$vSupport/support/PreLAMO/gaskell_vesta_prelamo_dem.cub \
#      	EXTRA=$vSupport/support/HAMO_V1/dawn_vesta_v04-iau.tpc
	footprintinit FROM=$framePath.cub LIMBTEST=spiceinit \
			INCTYPE=VERTICES NUMVERTICES=10

	echo "-------------------------------------- Basic "
	isis2std FROM=$framePath.cub TO=frame/$root.png MAXPERCENT=99.9 

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
	isis2std FROM=$mapPath.cub TO=maps/$root.png MAXPERCENT=99.9 
	isis2std FROM=$mapPath.cub TO=maps/$root.jp2 MAXPERCENT=99.9 FORMAT=jp2 BITTYPE=u16bit
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
#gzip cubes/*cub &
cd ..

echo "-------------------------------------- Done "

echo "done $p" >> ../cal.log

orig=`ls *IMG | wc -w`
now=`ls maps/cubes/*.cub* | wc -w`
echo "Orig: $orig, Now: $now";



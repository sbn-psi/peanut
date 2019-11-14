#!/bin/bash
# Aug 25th, 2012
# General pipeline for VIR images
# This only does level 1B - and it needs the HK files 
#			from the 1A release in the same dir
#	Updated 31 July 2017 to support PDS processing of Ceres
#		VIR data by Eric E. palmer

p=`pwd`
echo "VIR Calib Start:  $p" >> ../cal.log

############# SETUP #############

mv t_* del/
source /dsk2/PDS/pds-ceres/processing/setup.sh

one=`ls VIR*1B*[0-9]_1.LBL | head -1`
type=`echo $one | cut -c 5-6`
echo $type

if [ "$type" == "IR" ]; then 
	echo "IR"; 
	max=23; 
	scaleStr="STRETCH=manual MINIMUM=0 MAXIMUM=15 "
	band=1
	start=13
fi

if [ "$type" == "VI" ]; then 
	echo "Vis"; 
	max=24; 
	scaleStr="STRETCH=manual MINIMUM=0 MAXIMUM=25 "
	band=200
	start=14
fi
scaleStr="MINPERCENT=1 MAXPERCENT=97"

echo "scaleStr> " $scaleStr

############# LIST #############
#list=`ls VIR*_1B_*_1.LBL | cut -c -$max | head -999` 
cnt=0
#num=`echo $list | wc -w`

############# LOOP #############
for i in $imgList
do
	cnt=`echo $cnt + 1 | bc`	
   echo
   echo "-------------------------------------- "
   echo "----- " $i  " ----- ($cnt of $imgNum)"
   echo "-------------------------------------- "
	
	max=`echo $i | wc -c`
   usefulLen=`echo $max - 5 | bc`
	#base=`echo $i | cut -c 1-$usefulLen`;
	#house=`echo "1A/"$base | tr B A`
	root=`echo $i | cut -c -$usefulLen`
	number=`echo $i | cut -c 13-21`
	house=`ls VIR_*_1B*$number*HK*.LBL`
	echo "house " $house

	#root=$i
	echo "root: $root"

	##### convert into ISIS & move files out of the way
	echo "-------------------------------------- Convert"
	echo $long
	cmnd="dawnvir2isis FROM=$root.LBL TO=t_raw.cub HKFROM=$house"
	#cmnd="dawnvir2isis FROM=$root.LBL TO=t_raw.cub HKFROM=$house"
	echo $cmnd
	$cmnd
#	rm $root.QUB
#	mv hold/$root.QUB .

	if [ ! -e "t_raw.cub" ] ; then 
		echo "Failed on $i"
		echo $root >> ../error.log
		continue
	fi

	# This is only needed for Survey, cycle 0 - it has despiked added to the names
	#desp="_despiked"
	#dawnvir2isis FROM=$i$desp.LBL TO=t_raw.cub HKFROM=$houseFull

	##### Calibrate 
	echo "-------------------------------------- Calibrate"

	#spiceinit from=finished.cub ATTACH SPKPREDICT=true SPKRECON=false \
	#	SHAPE=user MODEL=/Users/epalmer/Dropbox/Vesta/110831_DLR_dtm_RC3_750_sinu.cub \
	#	EXTRA=/Users/epalmer/Dropbox/Vesta/dawn_vesta_v05_dlr.tpc

	## This is for Dawn
	#cmnd="spiceinit from=t_raw.cub ATTACH=TRUE SPKPREDICT=true SPKRECON=false SHAPE=user MODEL=$drop/support/PreLAMO/gaskell_vesta_prelamo_dem.cub  EXTRA=$drop/support/HAMO_V1/dawn_vesta_v04.tpc"
	## This is for PDS
	#cmnd="spiceinit from=t_raw.cub ATTACH=TRUE SPKPREDICT=true SPKRECON=false SHAPE=user MODEL=$drop/support/PreLAMO/gaskell_vesta_prelamo_dem.cub  EXTRA=$drop/support/HAMO_V1/dawn_vesta_v04-iau.tpc"

	# Use for the mission
	cmnd="spiceinit from=t_raw.cub ATTACH=TRUE SPKPREDICT=true SPKRECON=false PCK=../dawn_ceres_v04.tpc"

# Using ISIS servers -- all final data
   cmnd="spiceinit ATTACH from=t_raw.cub"
	

	echo $cmnd
	$cmnd


	footprintinit FROM=t_raw.cub limbtest=spiceinit INCTYPE=VERTICES NUMVERTICES=10

	##### Destripe 
	echo "-------------------------------------- Destripe"
	lowpass from=t_raw.cub to=l.cub samples=11 lines=41
	highpass from=t_raw.cub to=h.cub samples=1 lines=41
	algebra operator=add from=l.cub from2=h.cub to=finished.cub
	mv l.cub h.cub del
	

	##### Make thumbs of the image frame
	echo "-------------------------------------- Thumb"
	isis2std FROM=finished.cub+$band TO=t_img.png  $scaleStr  
	convert -interpolate bicubic -resize 400% t_img.png frame/png/$root.png
	mv finished.cub frame/smooth/s-$root.cub
	#gzip frame/smooth/s-$root.cub 

	##### Project on a map and make thumbs
	echo "-------------------------------------- Map ($cnt of $imgNum) "

	cmnd="cam2map from=t_raw.cub MAP=../equi.map to=t_map.cub DEFAULT=camera"
	$cmnd



   #############################
   # Work on the poles
   #############################
   maxLat=`awk '/MaximumLatitude/ { printf("%d\n", $3)}' t_map.cub`
   minLat=`awk '/MinimumLatitude/ { printf("%d\n", $3)}' t_map.cub`
   echo "MaxLat: " $maxLat
   echo "MinLat: " $minLat
   if [ "$maxLat" -lt "-45" ]
   then
      echo "-------------------------------------- Process Lower"
      cam2map from=t_raw.cub TO=t_map.cub defaultrange=camera MAP=../poleS.map
   fi

   if [ "$minLat" -gt "45" ]
   then
      echo "-------------------------------------- Process Upper"
      cam2map from=t_raw.cub TO=t_map.cub defaultrange=camera MAP=../poleN.map
   fi


	##### Done with frame cube
	mv t_raw.cub frame/cubes/f-$root.cub
	#gzip frame/cubes/f-$root.cub 

	echo "-------------------------------------- Images"
	# Map projected images with world files (maybe someday again)
	isis2std FROM=t_map.cub+$band TO=t_map.png $scaleStr
	isis2std FROM=t_map.cub+$band TO=t_map.jp2 $scaleStr FORMAT=jp2 BITTYPE=u16bit
	mv t_map.cub maps/cubes/m-$root.cub 
	#gzip maps/cubes/m-$root.cub 

	# The actual thumbnails
   convert -interpolate bicubic -resize 800% t_map.png maps/jpg/$root.jpg
   convert -interpolate bicubic -resize 800% t_img.png frame/jpg/$root.jpg
	mv t_map.png maps/png/$root.png
	mv t_map.jp2 maps/jp2/$root.jp2
	mv t_map.pgw maps/pgw/$root.pgw
	mv t_map.j2w maps/j2w/$root.j2w


	#echo "-------------------------------------- Band1"
	#echo '.run ~/Dropbox/processing/band1.pro' | /Applications/itt/idl/bin/idl -32
	#crop from=t_band1.cub to=t_crop.cub sample=12
	#mv t_band1.cub del
	#isis2std FROM=t_crop.cub TO=t_band1.png $scaleStr 
	#convert -interpolate bicubic -resize 400% t_band1.png frame/band1/$root.png
	#mv t_crop.cub del
#scaleStr="MINPERCENT=1 MAXPERCENT=99"



done

############# CLEAN UP #############
echo "-------------------------------------- Moving"
sleep 5		# Delay to ensure gzip is done
cd maps
#mkdir cubes png pgw jp2 j2w
#mv *.cub.gz cubes
#mv *.png png
#mv *.jpg jpg
#mv *.pgw pgw
#mv *.jp2 jp2
#mv *.j2w j2w
cd ..

cd frame 
#mkdir png 
#mv *.cub.gz cubes
#mv *.png png
#mv *.jpg jpg
cd ..

echo "-------------------------------------- Compressing Frame"
gzip frame/cubes/*
gzip frame/smooth/*
echo "-------------------------------------- Compressing Map"
gzip maps/cubes/* 

echo "-------------------------------------- Done"
echo "VIR Calib done $p" >> ../cal.log


############# STATISTICS #############
orig=`ls *IMG | wc -w`
now=`ls maps/cubes/*cub | wc -w`
echo "Orig: $orig, Now: $now";




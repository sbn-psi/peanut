#!/bin/bash

# setup.sh
#   This ensures the variables are set that we need - ones local in each directory
#		3 Oct 2011

#DROP=/Volumes/Process/Dropbox
#vSupport=/Volumes/Process/Dropbox/Vesta

if [ -f "gConfig.rc"   ];
then 
	source gConfig.rc
else 
	echo "Running Individual"; 

	if [ -f "gSequence"   ]; then 
		sequence=`cat gSequence`; echo "Seq $sequence"
	else 
		echo "############## missing seq ############"; exit 1; 
	fi
	
	if [ -f "gPhase"  ]; then
		phase=`cat gPhase`; echo "Phase $phase"
	else
		echo "############## missing phase ##########"; exit 1
	fi
	
	if [ -f "gCamera"  ] ; then
		camera=`cat gCamera`; echo "Camera $camera" 
	else
		echo "############## missing gCamera ##########"; exit 1
	fi
	
fi		# gConfig fail


# Log useful data for debugging
date
pwd
echo "name: $name"
echo "seq: $sequence"
echo "phase: $phase"
echo "camera: $camera"
echo "level: $level"
echo "mid: $mid"
echo "min: $min"

# Used to set differences between filenames
shortCamera=`echo $camera | cut -c 1-2`
echo $camera $shortCamera
if [ "$shortCamera" == "VI" ]; then
	imgList=`ls *[0-9]_1.LBL`
	oneList=`ls *_1.LBL | head -1`
else
	imgList=`ls *.IMG`
	oneList=`ls *.IMG | head -1`
fi

if [ "$camera" == "MSI" ]; then
	imgList=`ls *.fit`
	oneList=`ls *.fit | head -1`
fi

imgLen=`echo $oneList | wc -c`
rootLen=`echo $imgLen -4 -1 | bc`
imgNum=`echo $imgList | wc -w`

if [ "$imgNum" -lt "1" ]; then 
	echo "############## OOPS - no images ##########"; exit 1
fi

# Just tests and makes the needed directories
#		22 Aug 2012

# Makes map directories
if [ ! -e "maps"   ]; then mkdir maps; fi
if [ ! -e "maps/cubes"   ]; then mkdir maps/cubes; fi
if [ ! -e "maps/j2w"   ]; then mkdir maps/j2w; fi
if [ ! -e "maps/jp2"   ]; then mkdir maps/jp2; fi
if [ ! -e "maps/jpg"   ]; then mkdir maps/jpg; fi
if [ ! -e "maps/pgw"   ]; then mkdir maps/pgw; fi
if [ ! -e "maps/png"   ]; then mkdir maps/png; fi

# Makes frame directories
if [ ! -e "frame"   ]; then mkdir frame; fi
if [ ! -e "frame/cubes"   ]; then mkdir frame/cubes; fi
if [ ! -e "frame/camera"   ]; then mkdir frame/camera; fi
if [ ! -e "frame/jpg"   ]; then mkdir frame/jpg; fi
if [ ! -e "frame/png"   ]; then mkdir frame/png; fi
if [ ! -e "frame/fits"   ]; then mkdir frame/fits; fi

# all done if we are using the framing camera
if [ "$shortCamera" != "FC" ]; then
	# Make VIR directories
	if [ ! -e "frame/band1"   ]; then mkdir frame/band1; fi
	if [ ! -e "frame/envi"   ]; then mkdir frame/envi; fi
	if [ ! -e "frame/raw"   ]; then mkdir frame/raw; fi
	if [ ! -e "frame/smooth"   ]; then mkdir frame/smooth; fi
fi
	


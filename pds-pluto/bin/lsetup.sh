#!/bin/bash

# setup.sh
#   This ensures the variables are set that we need - ones local in each directory
#		3 Oct 2011

myPath="/dsk2/PDS/pds-pluto/"

# This sets both global and local variables
if [ -f "$myPath/gGlobal.rc"   ];
then 
	source $myPath/gGlobal.rc
else 
	echo "############## missing gGlobal.rc ############"; >> $myPath/cal.log
	pwd >> $myPath/cal.log
	echo "############## missing gGlobal.rc ############"; exit 1; 
fi

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
 
# Check to see if local variables are set
if [ "$camera" == "Unset" ]; then
	echo "############## camera $camera ############" >> ../cal.log
	echo "############## camera $camera ############"; exit 1; 
fi
if [ "$phase" == "Unset" ]; then
	echo "############## phase $phase ############" >> ../cal.log
	echo "############## phase $phase ############"; exit 1; 
fi
if [ "$sequence" == "Unset" ]; then
	echo "############## sequence $sequence ############" >> ../cal.log
	echo "############## sequence $sequence ############"; exit 1; 
fi


imgList=`ls *.lbl`
oneList=`ls *.lbl | head -1`
imgLen=`echo $oneList | wc -c`
rootLen=`echo $imgLen -4 -1 | bc`
imgNum=`echo $imgList | wc -w`

if [ "$imgNum" -lt "1" ]; then 
	echo "############## OOPS - no images ##########" > ../cal.log 
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

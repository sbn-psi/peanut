#!/bin/bash

#vcal.sh (calibrated pipline) has already been done.  We start at the root directory
#   which has both cubes and maps
#		3 Oct 2011

############ Do all setup ###########
echo "1: gPath $gPath" 
source ../processing/lsetup.sh
echo "2: gPath $gPath" 

p=`pwd`
echo "Starting Rip $p" >> ../cal.log

if [ -f "foot.sql" ]; then mv foot.sql foot.sql.old; fi
if [ -f "meta.sql" ]; then mv meta.sql meta.sql.old; fi

# Set for VIR
if [ "$shortCamera" == "VI" ]; then
	size=800;
	band="+22";
	upLabel="LBL";
	stretchStr="MAXPERCENT=98";
	#list=`ls *_1.LBL`
	# Needed for survey, C0
				#cd frame/cubes
				#list=`ls *.cub.gz`
				#cd ../..
fi

# Reset for FC2
#type=`echo $list | head -1 | cut -c 1-3`
if [ "$shortCamera" == "FC" ]; then
	size=50;
	band="";
	upLabel="IMG";
	#list=`ls *.IMG `
	stretchStr="MAXPERCENT=99";
fi

#list=`ls *$howToList`

# Reset for FC1
#if [ "$camera" == "FC1" ]; then
#	size=50;
#	band="";
#	upLabel="IMG";
#	list=`ls *.IMG`
#	stretchStr="MAXPERCENT=99";
#fi
echo "upLabel $upLabel";


############ Build the list of all the files to process ###########
#	Only use files that have map projected versions
cd maps/cubes
len=`ls *.cub.gz | head -1 | wc | cut -c 23-40` 
#list=`ls *.cub`
cd ../..


#  ---------------
#  ---------------

cnt=0
num=`echo $imgList | wc -w `

############ Run the loop ###########
for full in $imgList
do
	cnt=$((cnt + 1))
	#len=`echo $i | wc -m`
	#shortLen=`echo $len - 5 | bc`
	root=`echo $full | cut -c -$rootLen`
	# Neede for survey, cycle 0
			#shortLen=`echo $len - 8 | bc`
			#root=`echo $i | cut -c 3-$shortLen`
	cd $p

	echo "------------------- $root -- $cnt (of $num)------------------"
	#echo "  -------- jpg'n <$root>"
	#isis2std FROM=maps/cubes/$i$band TO=t_img.png $stretchStr
	#convert -interpolate bicubic -resize $size% maps/png/$root.png maps/$root.jpg

	#isis2std FROM=frame/cubes/$i$band TO=t_img.png $stretchStr
	#convert -interpolate bicubic -resize $size% frame/png/$root.png frame/$root.jpg
	
	# Metadata
	cd maps/cubes

	echo "  -------- uncompressing $root"
	#cp m-$root.cub.gz t_working.cub.gz
	gunzip -c m-$root.cub.gz > $p/$root.cub
	cd $p

	echo "  -------- Awk'n"
	/usr/bin/awk -f ../processing/rip.awk -v  sequence=$sequence -v phase=$phase $root.cub >> $p/meta.sql
	rm $root.cub

	# Footprints & Camera Info
	echo "  -------- Footprints and Camera info"
	cd $p/frame/cubes
	echo "  -------- uncompressing $root"
	#cp f-$root.cub.gz t_working.cub.gz
	gunzip -c  f-$root.cub.gz > $p/$root.cub
	cd $p
	#mv t_working.cub $root.cub

	blobdump from=$root.cub to=$p/t_out.txt name=Footprint type=Polygon
	strings $p/t_out.txt | grep POLY > $p/t_poly.txt
	ply=`cat $p/t_poly.txt`
	awk -f ../processing/foot.awk -v ply="$ply" $root.cub >> $p/foot.sql
	rm $p/t_out.txt $p/t_poly.txt
	caminfo from=$root.cub to=$p/frame/info-$root.txt
	rm $root.cub
	cd $p
done

mv maps/*.jpg maps/jpg/
mv frame/*.jpg frame/jpg/
mv frame/info-*.txt frame/camera


echo "3: gPath $gPath" 
############ Build directory in which to copy ###########
   #path1=`cat gPhase`
   #path2=`cat gSequence`
   #camera=`cat gCamera`
   p1="../out/$gPath/$phase/"
   if [ ! -e $p1 ]; then
      echo "Creating $p1"
      mkdir -p $p1
   fi

   p2="$p1/$sequence-$camera/"
   if [ ! -e $p2 ]; then
      echo "Creating $p2"
      mkdir -p $p2
   fi

echo "  -------- copying"
echo "4: gPath $gPath" 
   cd $p
   rsync -ah frame maps ../out/$gPath/$phase/$sequence-$camera/


echo "-------- Done"
echo "Ending Rip $p" >> ../cal.log
echo "imgNum: $imgNum"
ls maps/jpg | wc -w

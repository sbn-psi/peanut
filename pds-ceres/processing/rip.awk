function smallPoly (str) {
	half=substr (str, 17, 1024)
	last = index (half, ")");
	final=substr(half, 1, last-1)
	return final;
}


function getRight (str) {
	split (str, newA, "=");
	ret = gsub ("\"", "", newA[2]);
	return newA[2];
}


/ StartTime/			{Time=$3;}
/TARGET_NAME/			{tname=getRight($0);}
#/TARGET_DESC/			{tdes=$3;}
#/IMAGE_OBSERVATION_TYPE/	{obs=$3;}
#//MISSION_PHASE_NAME/		{mphase=getRight($0);}
/InstrumentModeId/			{obs=$3;}
/OBSERVATION_ID/			{obs=$3;}
/InstrumentId/			{inst=$3;}

/ExposureDuration/		{exposure=$3;}
/FrameParameter/		{exposure=substr ($3, 2, 3);}

/InstrumentPointingQuality/		{ispice=$3}
/InstrumentPositionQuality/		{tspice=$3}
/ShapeModel/							{len=length($3); 
											shape=substr($3, len-15, len);
											}
#/TargetPosition/		{tspice=substr ($3 " " $4, 2, 90);}

/Channel/				{channel="-"$3;}
/FilterNumber/				{filter=$3;}

/MinimumLatitude/		{minLat=substr ($3, 1, 6);}
/MaximumLatitude/		{maxLat=substr ($3, 1, 6);}
/MinimumLongitude/		{minLon=substr ($3, 1, 6);}
/MaximumLongitude/		{maxLon=substr ($3, 1, 6);}
/PixelResolution/		{minRes=substr ($3, 1, 6);}
/SoftwareVersionId/		{cal=getRight($0);}
/ImageMidTime/			{dateTime=$3 }
/StartTime/			{dateTime=$3 }
/ Samples/			{samples=$3 }
/ Lines/			{lines=$3 }
/ProjectionName/		{projection=$3 }
END				{ 
		#len = length(longF);
		#filename = substr (longF, 0, len-4);
		full = ARGV[1]
		len = length(full);
		filename = substr (full, 1, len-4);
		full_inst = inst channel;

		pt_camera=substr(filename, 1,3);
		len = length(filename);
		key=substr(filename, 6, len-7);  # will be overwritten by VIR
		leadChar = "FC-";

		if (pt_camera == "VIR") {
			hold=substr(filename,5,2);
			if (hold == "IR")  {
				add = 0;
				leadChar = "IR-";
			}
			else {
				add = 1;
				leadChar = "VI-";
			}
			key = substr (full, len-10, 9);
			pt_inst=substr(filename,1,6+add);
			gsub ("_", "-", pt_inst);

			#pt_name=substr(filename,13+add,len-2-8);
			pt_camera=substr(filename, 1,6+add);
			pt_version=substr(filename, len,1);
			pt_level=substr(filename, 8+add, 2);
		} else {
			pt_inst=pt_camera;
			pt_level=substr(filename, 4,2);
			#pt_name=substr(filename,6,len-2-5);
			pt_version=substr(filename, len-1, 2);
		}#else
	s_title=sequence;
	key_name = leadChar key;


printf ("REPLACE INTO `images` (`image_name`, `Time` ) VALUES ( '" key_name "','" Time "');\n" ); 

printf ("UPDATE `images` SET `central_body`='%s' ", tname);
printf (", `filter`='%s' ", filter);
printf (", `filename`='%s' ", filename);
printf (", `target_name`='%s' ", tname);
printf (", `obs_type`='%s' ", obs);
printf (", `mission_phase`='%s' ", phase);
printf (", `sequence_title`='%s' ", s_title);
printf (", `thumb`='%s' ", sequence);
printf (", `instrument`='%s' ", pt_inst);
printf (", `exposure`='%s' ", exposure);
printf (", `i_spice`='%s' ", ispice);
printf (", `t_spice`='%s' ", tspice);
printf (", `min_lat`='%s' ", minLat);
printf (", `max_lat`='%s' ", maxLat);
printf (", `min_lon`='%s' ", minLon);
printf (", `max_lon`='%s' ", maxLon);
printf (", `min_res`='%s' ", minRes);
printf (", `cal_flat`='%s' ", cal);
printf (", `samples`='%s' ", samples);
printf (", `lines`='%s' ", lines);
printf (", `shape`='%s' ", shape);
printf (", `level`='%s' ", pt_level);
printf (", `projection`='%s' ", projection);
printf (", `version`='%s' ", pt_version);
printf (", `softVers`='%s' ", 2.0);
printf (" WHERE `image_name`='%s' ", key_name);
printf (";\n");



}#end

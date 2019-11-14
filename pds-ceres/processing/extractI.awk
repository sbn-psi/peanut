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
/InstrumentModeId/			{obs=$3;}
/OBSERVATION_ID/			{obs=$3;}
/InstrumentId/			{inst=$3;}

/ExposureDuration/		{exposure=$3;}
/FrameParameter/		{exposure=substr ($3, 2, 3);}
/ImageMidTime/			{dateTime=$3 }
/ProjectionName/		{projection=$3 }

/INCIDENCE_ANGLE/		{iAngle=$3 }
/EMISSION_ANGLE/		{eAngle=$3 }
/PHASE_ANGLE/		{pAngle=$3 }
END				{ 
		full = ARGV[1]
		len = length(full);
		filenameA = substr (full, 1, len-4);
		full_inst = inst channel;

		#pt_camera=substr(filenameA, 1,3);
		len = length(filenameA);

		key=substr(filenameA, 6, len-7);  
		leadChar = "FC-";

	s_title=sequence;
	key_name = leadChar key;


printf ("UPDATE `images` SET `i`='%s' ", iAngle);
printf (" WHERE `image_name`='%s' ", key_name);
printf (";\n");
printf ("UPDATE `images` SET `e`='%s' ", eAngle);
printf (" WHERE `image_name`='%s' ", key_name);
printf (";\n");
printf ("UPDATE `images` SET `phase`='%s' ", pAngle);
printf (" WHERE `image_name`='%s' ", key_name);
printf (";\n");



}#end

function smallPoly (str) {
	half=substr (str, 13, 4048)
	gsub ("\\), ", ", 1000 1000, ", half);
	gsub ("\\)", "", half);
	gsub ("\\(", "", half);
	return half;
}


/POLY/			{poly=smallPoly($0)}
/ Lines/			{lines=$3};
/ Sample/		{samples=$3};
END				{ 

	full = ARGV[1]
	len = length(full);
	filename = substr (full, 1, len-4);
	poly2=smallPoly(ply);


	pt_camera=substr(filename, 1,3);
	len = length(filename);
	key=substr(filename, 6, len-7);
	leadChar = "FC-";

	if (pt_camera == "VIR") {
		key=substr(full, len-10, 9);
		#key=substr(full, 15, len-15);
		hold=substr(filename,5,2);
		if (hold == "IR")  {
			add = 0;
			leadChar = "IR-";
		}
		else {
			add = 1;
			leadChar = "VI-";
		}#else
	}#if

	key_name = leadChar key;

	printf ("UPDATE `images` SET `Footprint`= ");
	printf ("'%s' ", poly2);
	printf (", `f_lines`='%s' ", lines);
	printf (", `f_samples`='%s' ", samples);
	printf (" WHERE `image_name`='%s';\n", key_name);


}#END



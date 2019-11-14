function smallPoly (str) {
	half=substr (str, 13, 4048)
	gsub ("\\), ", ", 1000 1000, ", half);
	gsub ("\\)", "", half);
	gsub ("\\(", "", half);
	return half;
}

/POLY/          { poly    = smallPoly($0) };
/ Lines/        { lines   = $3 };
/ Sample/       { samples = $3 };

END {
    full = ARGV[1];
    poly2 = smallPoly(ply);

    key_name = substr(full, 0, length(full) - 8);

    printf ("UPDATE `images` SET `Footprint`= ");
    printf ("'%s' ", poly2);
    printf (", `f_lines`='%s' ", lines);
    printf (", `f_samples`='%s' ", samples);
    printf (" WHERE `image_name`='%s';\n", key_name);
}#END

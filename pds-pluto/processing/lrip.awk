### This awk script is run by `setup.sh` in order to generate 
### the meta.sql file, which is then used to fill the database.

# Set variables on regex matches
/StartTime/                    { Time       = $3; };
/TargetName/                   { tname      = $3; };
/InstrumentId/                 { pi_inst    = $3; };
/ExposureDuration/             { exposure   = $3; };
/MinimumLatitude/              { minLat     = $3; };
/MaximumLatitude/              { maxLat     = $3; };
/MinimumLongitude/             { minLon     = $3; };
/MaximumLongitude/             { maxLon     = $3; };
/PixelResolution/              { minRes     = $3; };
/ShapeModel/                   { shape      = $3; };
/Samples/                      { samples    = $3; };
/Lines/                        { lines      = $3; };
/ProjectionName/               { projection = $3; };
/InstrumentId/                 { obs        = $3; };
/InstrumentPointingQuality/    { ispice     = $3; };
/InstrumentPositionQuality/    { tspice     = $3; };

END {
    full = ARGV[1];
    filename = substr(full, 0, length(full) - 4);

    key_name = substr(filename, 0, length(filename) - 4);
    suffix = "_eng";
    filename_a = key_name "_eng";

    # executes once per record/line
    printFile();
}

function printFile() {
    print("REPLACE INTO `images` (`image_name`, `Time` ) VALUES ( '" key_name "','" Time "');" );

    printf ("UPDATE `images` SET `central_body`='%s' ", tname);
    printf (", `filename`='%s' ", filename);
    printf (", `target_name`='%s' ", tname);
    printf (", `exposure`='%s' ", exposure);
    printf (", `min_lat`='%s' ", minLat);
    printf (", `max_lat`='%s' ", maxLat);
    printf (", `min_lon`='%s' ", minLon);
    printf (", `max_lon`='%s' ", maxLon);
    printf (", `min_res`='%s' ", minRes);
    printf (", `shape`='%s' ", shape);
    printf (", `samples`='%s' ", samples);
    printf (", `lines`='%s' ", lines);
    printf (", `projection`='%s' ", projection);
    printf (", `i_spice`='%s' ", ispice);
    printf (", `t_spice`='%s' ", tspice);
    printf (", `level`='%s' ", level);
    printf (", `filename_a`='%s' ", filename_a);

    # Some variables are configured externally in gConfig.rc
    printf (", `instrument`='%s' ", camera);
    printf (", `mission_phase`='%s' ", phase);
    printf (", `thumb`='%s' ", sequence);
    printf (", `sequence_title`='%s' ", sequence);

    printf (", `cal_flat`='%s' ", cal);     # Expected to be empty
    printf (", `softVers`='%s' ", "2019-07-23");
    printf (", `version`='%s' ", "3.0");

    printf (" WHERE `image_name`='%s' ", key_name);
    printf (";\n\n");
}
### ### ###
### END ###
### ### ###

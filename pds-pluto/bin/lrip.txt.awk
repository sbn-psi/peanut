### This awk script is run by `setup.sh` in order to generate 
### the meta.sql file, which is then used to fill the database.

# Set variables on regex matches
/PhaseAngle/       { p = $3; };
/EmissionAngle/    { e = $3; };
/IncidenceAngle/   { i = $3; };

END {
    full = ARGV[1];
    image_name = substr(full, 6, length(full) - 13);

    # executes once per record/linea
    printLine();
}

function printLine() {
    printf ("UPDATE `images` SET `i`='%s' ", i);
    printf (", `e`='%s' ", e);
    printf (", `phase`='%s' ", p);
    printf (" WHERE `image_name`='%s' ", image_name);
    printf (";\n");
}

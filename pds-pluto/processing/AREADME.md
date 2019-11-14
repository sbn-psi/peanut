## SBIB Pluto: LORRI Data Processing Tools

#### Usage

To run the process as a background task, run the following command from a LORRI data directory.

```bash
$ nohup ../processing/lrip.sh > log2 2>&1 &
```

You should expect to see the following 4 files after the above command is finished running

* meta.sql
* meta.fits.sql
* meta.txt.sql
* foot.sql

#### Descriptions of Files

+ fits.sh
The LORRI script for compressing FITS and their labels.

+ lcal.sh
The LORRI data calibration script.

+ lrip.fits.sh
The LORRI script for extracting keywords from FITS files and adding them to a SQL file.

+ lrip.sh
The LORRI script for ripping keywords from various sources into a collection of SQL files. These SQL files are later submitted to a MySQL database.

+ lrip.txt.sh
The LORRI script for extracting keywords from TXT files and adding them to a SQL file.

+ lsetup.sh
Configures environment with LORRI-specific information.

+ mcal.sh
The MVIC data calibration script.

+ setup.sh
Ensures that necessary environment variables have been properly configured for the directory to be processed.
#!/bin/bash

### ### ### ###
# This script extracts keywords from FITS headers
### ### ### ###

imgList=`ls *.fit`
count=80
initByte=0
reqid=''
p=`pwd`

if [ -f "meta.fits.sql" ]; then mv meta.fits.sql meta.fits.sql.old; fi

extractObsType()
{
    obs_type=`echo $line | grep -o -P "\'.*\'"`
    NEW_RECORD="UPDATE \`images\` SET \`obs_type\`=$obs_type WHERE \`image_name\`='$key_name';"
    echo $NEW_RECORD >> meta.fits.sql
}

checkLine()
{
    startByte=$1
    line=`dd if=$full ibs=1 skip=$startByte count=80`
    if [ ${#line} -eq 0 ]; then
        echo '=== === === END OF FILE === === ==='
        exit
    fi
    
    if [[ $line =~ 'SAPNAME' ]]; then
        extractObsType
    else
        newStartByte=`expr $startByte + 80`
        checkLine $newStartByte
    fi
}

imgNum=0

for full in $imgList
do
    imgNum=$((imgNum + 1))
    echo $count
    
    len=${#full}
    end=`expr $len - 8`
    
    key_name=${full:0:end}

    sapname=''
    filter=''

    checkLine $initByte
done

exit

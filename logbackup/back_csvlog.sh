#!/bin/sh
DATE=`date --date "1 days ago" +'%Y-%m-%d'`
if [ $# -eq 1 ]; then
    if [ -n "{$1}" ]; then
        DATE=$1
    fi
fi

MFX_LOG=oandaCsv.log.$DATE

cd /home/mfx/app/logs
tar zcvf $MFX_LOG$DATE.tar.gz $MFX_LOG

mv $MFX_LOG$DATE.tar.gz logbackup/

rm -f $MFX_LOG

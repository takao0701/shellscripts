#!/bin/sh
DATE=`date +'%Y-%m-%d'`

MFX_LOG=oanda.log

cd /home/mfx/app/logs
tar zcvf $MFX_LOG$DATE.tar.gz $MFX_LOG

mv $MFX_LOG$DATE.tar.gz logbackup/

cat /dev/null > $MFX_LOG


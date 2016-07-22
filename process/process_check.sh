#!/bin/sh

processName=aaa
interval=5

isAlive=`ps -ef | grep "$processName" | grep -v grep | grep -v srvchk | wc -l`
if [ $isAlive = 1 ]; then
   echo "$processName is running."
else
   echo "$processName is not running."
fi

#!/bin/sh
TARGET=aaa

pids=(`ps -ef | grep ${TARGET} | grep -v grep | awk '{ print $2; }'`)
for pid in ${pids[*]}
do
kill -9 ${pid}
done

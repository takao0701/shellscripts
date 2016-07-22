#!/bin/sh
flag=0
Mailtmp=/tmp/disktmp

echo "`df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }'`">$Mailtmp

while read line
do
  usep=$(echo $line | awk '{ print $1}' | cut -d'%' -f1  )
  partition=$(echo $line | awk '{ print $2 }' )

  if [ $usep -ge 70 ] && [ $partition == "/dev/vda3" ] ; then
    echo "Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date)"
    flag=1
  fi
  if [ $usep -ge 99 ] && [ $partition == "/dev/vda1" ] ; then
    echo "Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date)"
    flag=1
  fi
done < $Mailtmp

if [ $flag -eq 1 ]; then
  exit 1
fi
exit 0

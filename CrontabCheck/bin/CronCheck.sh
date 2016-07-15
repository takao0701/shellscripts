#!/bin/bash

#chk_cron.sh

#Server Cron check

#Directory Info
P_DIR=/home/user/CronShell/CrontabCheck
BIN_DIR=$P_DIR/bin
CONF_DIR=/home/user/CronShell/CrontabCheck/conf
REPORT_DIR=$P_DIR/report
TMP_DIR=$P_DIR/tmp

#Date Info
DATE_SEC=$(date +%F_%T)
DATE_DAY=$(date +%F)
DATE_START=$(date +%s)

#Mail Info
PROGRAM_NAME="Server Cron Check"
SUBJECT="$PROGRAM_NAME Report"
FROMMAIL='cronReport_Fx10@aaa.com'
REPLY_TO='akao0701@gmail.com'
TOMAIL='takao0701@gmail.com'

#File Info
CRON_DAY=$REPORT_DIR/cron_$DATE_SEC
LIST=$CONF_DIR/server_list
CRON_TMP=$TMP_DIR/cron.tmp
CRON_MAIL_TMP=$TMP_DIR/cron.warn.mail.tmp
CRON_MODIFY=$TMP_DIR/cron_modify.tmp
MAIL_INFO=$TMP_DIR/cron_mail_info.tmp

i=2
#END=$(sed -n '$=' $LIST)
#SSH_CHK_OK=0
#SSH_CHK_ERR=0

#get crontab info from server lists
while read INFO
do
        NO=$(echo $INFO |awk '{print $1}')
        IP=$(echo $INFO |awk '{print $2}')
        SERVER_NAME=$(echo $INFO |awk '{print $3}')
        USER=$(echo $INFO |awk '{print $4}')
	CRON_NEW=$TMP_DIR/${USER}-at-${IP}_new

        SSH_CHK=$(/usr/bin/nmap -n  -p 22 $IP  |awk /ssh/'{print $2}')

        if [ "$SSH_CHK" = "open" ]
        then
		echo "$USER@$IP 's crontab" >>$CRON_DAY
                #(ssh -n -l $USER $IP crontab -l |sed -n '/^[^#]/p' |egrep -v 'JAVA|PATH|tomcat') >> $CRON_DAY 2>&1
                (ssh -n -l $USER $IP crontab -l |sed -n '/^[^#]/p' |egrep -v 'JAVA|PATH|tomcat') > $CRON_NEW 2>&1
		cat $CRON_NEW >> $CRON_DAY
		echo "" >> $CRON_DAY
                SSH_CHK_OK=$( expr $SSH_CHK_OK + 1 )
        else
                echo "NO.$NO Warning !!!! " >> $CRON_NEW
                echo "-------------------- $SERVER_NAME ($IP) --------------------" >> $CRON_NEW
                echo " $SERVER_NAME ($IP) port 22 not open " >> $CRON_NEW
                echo "--------------------- ($IP) Finished ---------------------" >> $CRON_NEW
                echo "" >> $CRON_NEW
		cat $CRON_NEW >> $CRON_DAY
		#SSH_CHK_ERR=$( expr $SSH_CHK_ERR + 1 )
	fi
        i=$( expr $i + 1 )
done < <(grep -Ev "^$|^#" $LIST)


#If any server's crontab had modified , send mail to Fx-Service.
NEW_FILE_LIST=`ls ${TMP_DIR}/*_new`
#echo $NEW_FILE

#cp /dev/null $CRON_MODIFY
cp /dev/null $MAIL_INFO

for NEW_FILE in $NEW_FILE_LIST
do
	OLD_FILE=`echo $NEW_FILE |sed 's/new/old/'`
	#echo $OLD_FILE
	#continue
	if [ -f $OLD_FILE ]
	then
		#echo $OLD_FILE
		diff $NEW_FILE $OLD_FILE > $CRON_MODIFY
	else
		#echo no old file ,create it
		cat $NEW_FILE > $CRON_MODIFY
	fi

	cp $NEW_FILE $OLD_FILE

	if  [ -s $CRON_MODIFY ]
	then
		echo $OLD_FILE | awk -F"/|_" 'col=NF-1 {print $col}' | sed 's/-/_/g' >> $MAIL_INFO
		cat $CRON_MODIFY >> $MAIL_INFO
		echo "" >>$MAIL_INFO
	fi
done


#CRON DAILY REPORT MAIL INFO
        echo "Subject:$PROGRAM_NAME REPORT" > $CRON_MAIL_TMP
        echo "From:$FROMMAIL" >> $CRON_MAIL_TMP
        echo "To:$TOMAIL" >> $CRON_MAIL_TMP
        echo "Reply-To:$REPLY_TO" >> $CRON_MAIL_TMP
        echo "Return-Path:$FROMMAIL" >> $CRON_MAIL_TMP
        echo "" >> $CRON_MAIL_TMP

        echo "     -=-=-==$PROGRAM_NAME $DATE_DAY==-=-=-" >> $CRON_MAIL_TMP
        echo "" >> $CRON_MAIL_TMP
        echo "##############################################################################" >> $CRON_MAIL_TMP
        echo "# This Report Created By  $PROGRAM_NAME Program" >> $CRON_MAIL_TMP
        echo "# Report From : App-Monitor (127.0.0.7)" >> $CRON_MAIL_TMP
        echo "# Script Name : $BIN_DIR/`basename $0`" >> $CRON_MAIL_TMP
        echo "# Report Time : $DATE_SEC" >> $CRON_MAIL_TMP
        echo "##############################################################################" >> $CRON_MAIL_TMP
        echo "" >> $CRON_MAIL_TMP
        echo "Detail Report:" >> $CRON_MAIL_TMP
	echo "URL: http://127.0.0.1/syscheck/report/$(basename $CRON_DAY)" >> $CRON_MAIL_TMP


	if [ -s $MAIL_INFO  ]
	then
		echo "crontab has modified!"

        	echo "" >> $CRON_MAIL_TMP
		echo "Crontab changed!!!!!:" >> $CRON_MAIL_TMP
        	echo "" >> $CRON_MAIL_TMP
		cat $MAIL_INFO >> $CRON_MAIL_TMP
		/usr/sbin/sendmail -t < $CRON_MAIL_TMP
	else
		echo "crontab has not modified!"

		echo "Crontab no change:" >> $CRON_MAIL_TMP
	fi


exit 0

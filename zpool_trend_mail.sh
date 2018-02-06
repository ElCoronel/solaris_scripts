#!/usr/bin/bash
### mails logs and rotates/clean ups old logs
LOGDIR=$HOME/logs
WLOG=(`find $LOGDIR -type f | grep -v archive`)
FDATE=`cat ${WLOG[1]} | grep DATE | awk '{print $2}'`
LDATE=`cat ${WLOG[1]} | grep DATE | awk '{print $NF}'`
YDATE=`date +%Y`
### prep the email body before we clean up the attachments
echo "Weekly zpool capacity usage for $FDATE through $LDATE $YDATE attached." >> $HOME/temp/body.tmp
### create the attachments
for i in "${WLOG[@]}"
        do
                /usr/gnu/bin/sed -i "s/$/\r/" $i
                uuencode $i $(echo $i | awk -F/ '{print $NF}') >> $HOME/temp/multi_attachment.tmp
        done
### combine body and attachments so we can use mailx
cat $HOME/temp/body.tmp $HOME/temp/multi_attachment.tmp > $HOME/temp/combined.tmp
### send the email
mailx -s "Weekly zpool Capacity Usage Report" someone@somewhere < $HOME/temp/combined.tmp
### clean up the temp files
rm -rf $HOME/temp/body.tmp $HOME/temp/combined.tmp $HOME/temp/multi_attachment.tmp
### rotate logs
find $LOGDIR/*/zpool_trend -type f -ctime +365 -exec rm {} \;
for w in `find $LOGDIR/*/zpool_trend -depth -type f`
        do
                mv $w $(date +%y-%m-%d).archive.$w
        done

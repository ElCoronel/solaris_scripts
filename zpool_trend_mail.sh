#!/usr/bin/bash
### mails logs and rotates/clean ups old logs
LOGDIR=$HOME/logs
HOSTLIST=$HOME/etc/remote_hosts.list
WLOG=(`find $LOGDIR/*/zpool_trend -type f | grep -v archive`)
FDATE=`cat ${WLOG[1]} | grep DATE | awk '{print $2}'`
LDATE=`cat ${WLOG[1]} | grep DATE | awk '{print $NF}'`
YDATE=`date +%Y`
### weekly change
for i in `cat $HOSTLIST | awk '{print $1}'`; do
        REMHOST=`cat $HOSTLIST | grep $i | awk '{print $2}'`
        for z in `cat $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log | grep -v DATE | awk '{print $1}'`; do
                SVAL=`cat $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log | grep "^$z " | awk '{print $2}' | sed s/\%//`
                LVAL=`cat $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log | grep "^$z " | awk '{print $NF}' | sed s/\%//
`
                CVAL=$(($LVAL - $SVAL))
                if [ "$CVAL" -eq 0 ]; then
                        /usr/gnu/bin/sed -i "/^$z / s/$/\t$CVAL\%/" $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log
                fi
                if [ "$CVAL" -gt 0 ]; then
                        /usr/gnu/bin/sed -i "/^$z / s/$/\t\+$CVAL\%/" $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log
                fi
                if [ "$CVAL" -lt 0 ]; then
                        /usr/gnu/bin/sed -i "/^$z / s/$/\t$CVAL\%/" $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log
                fi
        done
        /usr/gnu/bin/sed -i "/DATE/ s/$/\tWeekly Change/" $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log
done
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
cat $HOME/temp/combined.tmp | mailx -s "Weekly zpool Capacity Usage Report" hpux_admin@opm.gov
### clean up the temp files
rm -rf $HOME/temp/body.tmp $HOME/temp/combined.tmp $HOME/temp/multi_attachment.tmp
### rotate logs
find $LOGDIR/*/zpool_trend -type f -ctime +365 -exec rm {} \;
for w in `find $LOGDIR/*/zpool_trend -depth -type f | grep -v archive`
        do
                mv $w $w.$(date +%y-%m-%d).archive
        done

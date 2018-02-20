#!/usr/bin/bash
### runs zonestat -q -R total,high 10s 3m 3m on remote hosts, logs output
### see man page for explanation of 3 below variables
INTERVAL=10s
DURATION=3m
REPORT=3m
HOSTLIST=$HOME/etc/remote_hosts.list
LOGDIR=$HOME/logs
RDATE=`date '+%m%d%Y-%H%M'`
if [ $# -eq 0 ]; then
        echo "usage: ./zonestat_report.sh <all/server1 server2 server3...>"
        exit 1
fi
ZARRAY=( "$@" )
### spell check
for s in "${ZARRAY[@]}"; do
        if [[ -z $(cat $HOSTLIST | grep $s) ]] && [[ ! $s == "all" ]]; then

                echo "'$s' not found in $HOSTLIST list. exiting..."
                exit 1
        fi
done
### header/config output
echo "|=============================|"
echo "| zonestat cpu and mem report |"
echo "|=============================|"
echo "executing... \n\tzonestat -q -r total,high $INTERVAL $DURATION $REPORT\nfor... \n\t${ZARRAY[*]}\nin... \n\t$HOSTLIST \n\ngenerating logs at..."
### loop through "all"
        if [ "${ZARRAY[0]}" = "all" ]; then
                for i in `cat $HOSTLIST | awk '{print $1}'`; do
                        REMHOST=`cat $HOSTLIST | grep $i | awk '{print $2}'`
                        if [ ! -d $LOGDIR/$REMHOST ]; then
                                mkdir $LOGDIR/$REMHOST
                        fi
                        if [ ! -d $LOGDIR/$REMHOST/zonestat ]; then
                                mkdir $LOGDIR/$REMHOST/zonestat
                        fi
                        if [ ! -f $LOGDIR/$REMHOST/zonestat/$RDATE-$REMHOST-zonestat.log ]; then
                                touch $LOGDIR/$REMHOST/zonestat/$RDATE.$REMHOST.zonestat.log
                        fi
                        echo "\t $LOGDIR/$REMHOST/zonestat/$RDATE.$REMHOST.zonestat.log"
                        ssh rmtmon@$i zonestat -q -R total,high $INTERVAL $DURATION $REPORT >> $LOGDIR/$REMHOST/zonestat/$RDATE.$REMHOST.zonestat.log &
                        find $LOGDIR/$REMHOST/zonestat -type f -ctime +365 -exec rm {} \;
                done
        else
### loop through the provided input
                for a in "${ZARRAY[@]}"; do
                        GHOST=`cat $HOSTLIST | grep $a| awk '{print $1}'`
                        REMHOST=`cat $HOSTLIST | grep $a | awk '{print $2}'`
                        if [ ! -d $LOGDIR/$REMHOST ]; then
                                mkdir $LOGDIR/$REMHOST
                        fi
                        if [ ! -d $LOGDIR/$REMHOST/zonestat ]; then
                                mkdir $LOGDIR/$REMHOST/zonestat
                        fi
                        if [ ! -f $LOGDIR/$REMHOST/zonestat/$RDATE-$REMHOST-zonestat.log ]; then
                                touch $LOGDIR/$REMHOST/zonestat/$RDATE.$REMHOST.zonestat.log
                        fi
                        echo "\t $LOGDIR/$REMHOST/zonestat/$RDATE.$REMHOST.zonestat.log"
                        ssh rmtmon@$GHOST zonestat -q -R total,high $INTERVAL $DURATION $REPORT >> $LOGDIR/$REMHOST/zonestat/$RDATE.$REMHOST.zonestat.log &
                        find $LOGDIR/$REMHOST/zonestat -type f -ctime +365 -exec rm {} \;

                done
        fi
ZPID=(`ps -ef | grep rmtmon | grep zonestat | grep "total,high" | grep -v grep | awk '{print $2}'`)
while [[ -n $(ps -ef | /usr/gnu/bin/grep ${ZPID[@]/#/-e } | grep -v grep) ]]; do
        echo "working..."
        sleep 30
done
echo "--- complete ---"

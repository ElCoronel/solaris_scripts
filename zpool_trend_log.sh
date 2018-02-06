#!/usr/bin/bash
### logs zpool capacity usage on remote systems
HOSTLIST=$HOME/etc/remote_hosts.list.test
LOGDIR=$HOME/logs
NDATE=`date '+%m-%d'`
### loop through remote hosts
for i in `cat $HOSTLIST | awk '{print $1}'`
        do
                REMHOST=`cat $HOSTLIST | grep $i | awk '{print $2}'`
                ssh user@$i /usr/sbin/zpool list | grep -v NAME | awk '{print $1, $5}' >> $LOGDIR/$REMHOST.usage.in
### check for log file
                if [[ -f $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log ]]; then
### if log exists append new data
                        for z in `cat $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log | awk '{print $1}' | grep -v DATE`
                                do
                                        NUSE=$(cat $LOGDIR/$REMHOST.usage.in | gawk -v v="$z" '$1==v { print }' | awk '{print $2}')
                                        /usr/gnu/bin/sed -i "/^$z / s/$/\t$NUSE/" $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log
                                done
                        /usr/gnu/bin/sed -i "/DATE/ s/$/\t$NDATE/" $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log
                else
### if log does not exist create
                        if [ ! -d $LOGDIR/$REMHOST ]; then
                                mkdir $LOGDIR/$REMHOST
                                mkdir $LOGDIR/$REMHOST/zpool_trend
                        fi
                        if [ ! -d $LOGDIR/$REMHOST/zpool_trend ]; then
                                mkdir $LOGDIR/$REMHOST/zpool_trend
                        fi
                        touch $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log
                        cat $LOGDIR/$REMHOST.usage.in >> $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log
                        /usr/gnu/bin/sed -i '1s/^/DATE\n/' $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log
                        /usr/gnu/bin/sed -i "/DATE/ s/$/ $NDATE/" $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log
                         awk '{printf "%-24s%-5s\n", $1, $2}' $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log >> $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log.tmp
                        mv $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log.tmp $LOGDIR/$REMHOST/zpool_trend/$REMHOST.usage.log
                fi
                rm -rf $LOGDIR/$REMHOST.usage.in
        done

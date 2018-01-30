#!/usr/bin/bash
### runs zpool status -xv on remote hosts, logs output, emails if error found
HOSTLIST=$HOME/etc/remote_hosts.list
LOGDIR=$HOME/logs
### run through hosts, check for error condition
for i in `cat $HOSTLIST | awk '{print $1}'`
        do
                REMHOST=`cat $HOSTLIST | grep $i | awk '{print $2}'`
                if [[ -z $(ssh user@$i /usr/sbin/zpool status -xv | grep "all pools are healthy") ]]; then
### if error exists, loop through errored pool
                        ZPOOL=(`ssh user@$i /usr/sbin/zpool status -xv | /usr/gnu/bin/grep 'pool:' | awk '{print $2}'`)
                        for a in "${ZPOOL[@]}"
                                do
### if error file exists log dated error
                                if [[ -f $LOGDIR/$REMHOST/$a-error.out ]]; then
                                        echo "$i $REMHOST - `date` - `ssh user@$i /usr/sbin/zpool status -xv | grep $a | awk '{print $2}' | grep $a`" >> $LOGDIR/$REMHOST/zpoolxv.$(date +%Y-%m).log
### if error file does not exist, create, log date error and send email
                                else
                                        if [ ! -d $LOGDIR/$REMHOST ]; then
                                        mkdir $LOGDIR/$REMHOST
                                        fi
                                        echo "$i $REMHOST - `date`" >> $LOGDIR/$REMHOST/$a-error.out
                                        ssh user@$i /usr/sbin/zpool status -xv | /usr/gnu/bin/grep -A 3 "pool: $a" >> $LOGDIR/$REMHOST/$a-error.out
                                         echo "$i $REMHOST - `date` - `ssh user@$i /usr/sbin/zpool status -xv | grep $a | awk '{print $2}' | grep $a`" >> $LOGDIR/$REMHOST/zpoolxv.$(date +%Y-%m).log
                                        cat $LOGDIR/$REMHOST/$a-error.out | mailx -s "zpool status error $REMHOST $(date '+%F %H:%M')" someone@somebody
                                fi
                        done
### if error condition does not exist log dated healthy status
                else
                        if [ ! -d $LOGDIR/$REMHOST ]; then
                                mkdir $LOGDIR/$REMHOST
                        fi
                        rm -rf $LOGDIR/$REMHOST/*error.out
                        echo "$i $REMHOST - `date` - `ssh user@$i /usr/sbin/zpool status -xv`" >> $LOGDIR/$REMHOST/zpoolxv.$(date +%Y-%m).log
                fi
        done
### clean up old logs
### need to edit
find $LOGDIR -depth -type f -mtime +30 -exec rm {} \;

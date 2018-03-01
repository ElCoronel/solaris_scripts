#!/usr/bin/bash
### runs zpool status -xv on remote hosts, logs output, emails if error found
### email is sent on initial detection and then once a month (as logs are cleaned)
### otherwise no news is good news, staff is notified of cleared zpools
HOSTLIST=$HOME/etc/remote_hosts.list
LOGDIR=$HOME/logs
### loop through hosts, write zpool status to file
for i in `cat $HOSTLIST | awk '{print $1}'`
        do
                REMHOST=`cat $HOSTLIST | grep $i | awk '{print $2}'`
                ssh rmtmon@$i /usr/sbin/zpool status -xv > $HOME/temp/$i-zpool_status-xv.tmp
                ZPOOL=($(cat $HOME/temp/$i-zpool_status-xv.tmp | /usr/gnu/bin/grep 'pool:' | awk '{print $2}' | tr -d '\r'))
## if not all pools are healthy check for existing error log or write new one and notify staff
                if [[ -z $(cat $HOME/temp/$i-zpool_status-xv.tmp | grep "all pools are healthy") ]]; then
                        for a in "${ZPOOL[@]}"; do
                                if [[ -f $LOGDIR/$REMHOST/zpool_status/$a-error.out ]]; then
                                        echo "$i $REMHOST - `date` - `cat $HOME/temp/$i-zpool_status-xv.tmp | grep $a | awk '{print $2}' | grep $a`" >> $LOGDIR/$REMHOST/zpool_status/zpoolxv.$(date +%Y-%m).log
                                else
                                        if [ ! -d $LOGDIR/$REMHOST ]; then
                                                mkdir $LOGDIR/$REMHOST
                                                mkdir $LOGDIR/$REMHOST/zpool_status
                                        fi
                                        echo "$i $REMHOST - `date`" >> $LOGDIR/$REMHOST/zpool_status/$a-error.out
                                        cat $HOME/temp/$i-zpool_status-xv.tmp | /usr/gnu/bin/grep -A 3 "pool: $a" >> $LOGDIR/$REMHOST/zpool_status/$a-error.out
                                         echo "$i $REMHOST - `date` - `cat $HOME/temp/$i-zpool_status-xv.tmp | grep $a | awk '{print $2}' | grep $a`" >> $LOGDIR/$REMHOST/zpool_status/zpoolxv.$(date +%Y-%m).log
                                        cat $LOGDIR/$REMHOST/zpool_status/$a-error.out | mailx -s "zpool status error $REMHOST $(date '+%F %H:%M')" someone@somewhere.com
                                fi
                        done
                else
#@@@ if aLL pools are healthy log status
                        if [ ! -d $LOGDIR/$REMHOST ]; then
                                mkdir $LOGDIR/$REMHOST
                                mkdir $LOGDIR/$REMHOST/zpool_status
                        fi
                        cat $HOME/temp/$i-zpool_status-xv.tmp >> $LOGDIR/$REMHOST/zpool_status/zpoolxv.$(date +%Y-%m).log
                fi
### check for cleared zpools and notify if needed
        ERRFILE=($(find $LOGDIR/$REMHOST/zpool_status -type f | grep "error.out" | sed "s/\-error.out//" | sed "s~$LOGDIR\/$REMHOST\/zpool_status\/~~"))
        for p in "${ERRFILE[@]}"; do
                if [[ ! "${ZPOOL[*]}" =~ "$p" ]]; then
                        rm -rf $LOGDIR/$REMHOST/zpool_status/$p-error.out
                        echo -e "  $i - $REMHOST - `date`\r  zpool $p error cleared." >> $HOME/temp/$i-$REMHOST-$p-cleared.tmp
                        cat $HOME/temp/$i-$REMHOST-$p-cleared.tmp | mailx -s "zpool status cleared $REMHOST $(date '+%F %H:%M')" someone@somewhere.com
                        rm -rf $HOME/temp/$i-$REMHOST-$p-cleared.tmp
                fi
        done
        rm -rf $HOME/temp/$i-zpool_status-xv.tmp
done

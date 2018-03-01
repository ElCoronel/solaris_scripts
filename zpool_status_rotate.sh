#!/usr/bin/bash
### deletes year old log files, moves current logs to archive, deletes error files, runs once a month
LOGDIR=$HOME/logs
find $LOGDIR/*/zpool_status -type f -ctime +365 -exec rm {} \;
for l in `find $LOGDIR/*/zpool_status -depth -type f -print | grep zpoolxv`; do
        mv $l $l.$(date +%y-%m-%d).archive
done
for d in `find $LOGDIR/*/zpool_status -depth -type f -print | grep error`; do
        rm -rf $d
done

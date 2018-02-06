#!/usr/bin/bash
### deletes year old log files, moves current logs to archive, runs once a month
LOGDIR=$HOME/logs
find $LOGDIR/*/zpool_status -type f -ctime +365 -exec rm {} \;
for l in `find $LOGDIR/*/zpool_status -depth -type f -print | grep zpool_status`
        do
                mv $l $(date +%y-%m-%d).archive.$l
        done

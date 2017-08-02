#!/bin/bash
############################################################
# script to clean 0 length files and count TO & MPL copies #
############################################################                            
#
## some variables
CURDATE=`date +%y%m%d-%H%M`     # get date for log filename
LOGPATH=/usr/local/scripts/logs           # log path
LOCKFILE=/usr/tmp/gwtmp_clean_count.lck
#
#
## redirect stdout and stderr to log file
exec &> >(tee $LOGPATH/gwtmp_zerolength_error_$CURDATE.log)
#
#
# create lock file if it doesn't exist
if [ ! -e $LOCKFILE ]; then
        touch $LOCKFILE
#
#
## log 0 length files
        if [[ -n $(ls -la /gwtmp | grep " 0 " | awk '{print $9}') ]]; then
                for g in `ls -la /gwtmp | grep " 0 " | awk '{print $9}'`; do
                        echo $g >> $LOGPATH/gwtmp_zerolength_ref_$CURDATE.log
                done
        else
                echo 'No 0 length files' >> $LOGPATH/gwtmp_zerolength_ref_$CURDATE.log
                rm $LOCKFILE
                exit
        fi
#
## generate text file and email list of broken TOs based on nightly GW download info
                cat $LOGPATH/gwtmp_zerolength_ref_$CURDATE.log | sed 's/.\{24\}$//' | uniq >> $LOGPATH/mai
l.txt
                /bin/mailx -s "TOs for Investigation" -r reply-to@addr.ess user1@addr.ess < $LOGPATH/mail.txt
                mv $LOGPATH/mail.txt $LOGPATH/mail.txt.$CURDATE
#
#
## delete old files
        cd /gwtmp
        for k in `find * ! -name . -prune`
        do
                rm -rf $k
                echo "Deleted local copy of $k"
        done
#
#
## remove lock file
        rm $LOCKFILE
#
#
## if lock file exists
else
        echo "Lock file exists, exiting."
fi
#
#
## close redirect and exit
 >&2
exit

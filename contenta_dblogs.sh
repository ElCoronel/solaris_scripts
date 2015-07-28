#!/usr/bin/bash
#########################################################
# Script to copy Contenta DB logs to warm site          #
# and clean up old local logs to preserve disk space    #
#
#########################################################
#
#
CURDATE=`date +%y%m%d-%H%M`     # get date for log filename
LOGPATH=/usr/local/scripts/logs           # log path
LOCKFILE=/usr/tmp/warm_contenta.lck
#
# redirect stdout and stderr to log file
exec &> >(tee $LOGPATH/contenta_dblogs_$CURDATE.log)
#
# create lock file if it doesn't exist and check ssh connection to warm site
cd /usr/local/scripts
if [ ! -e $LOCKFILE ]; then
	touch $LOCKFILE
	CHK_SSH=$(ssh -o BatchMode=yes -o ConnectTimeout=5 root@hotS echo warmup 2>&1)
        CHK_SSH=$(echo "$CHK_SSH" | grep warmup)
        if [[ $CHK_SSH != "warmup" ]]; then
		echo 'Warm Site SSH connection is down $CURDATE'
                exit
        fi
# transfer logs
	echo 'Starting Contenta Warm Site Transfers'
	rsync -e '/usr/bin/ssh' -rvuplt /export/home/contenta/ root@hots:/pdssoradata/contenta_dblogs/
echo 'Completed'
        sleep 5
# remove lock file
        rm $LOCKFILE
# lock file exists
else
	echo "Lock file exists, is script already running?"
fi
# close redirect and exit
>&2
exit

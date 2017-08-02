#!/usr/bin/bash
#########################################################
# Script to copy crls and run hash linker               #
#########################################################                            
#
#
CURDATE=`date +%y%m%d-%H%M`     # get date for log filename
LOGPATH=/usr/local/scripts/logs           # log path
LOCKFILE=/usr/tmp/crls.lck
#
# redirect stdout and stderr to log file
exec &> >(tee $LOGPATH/crls_$CURDATE.log)
#
# create lock file if it doesn't exist and check ssh connection to warm site
cd /usr/local/scripts
if [ ! -e $LOCKFILE ]; then
        touch $LOCKFILE
        CHK_SSH=$(ssh -o BatchMode=yes -o ConnectTimeout=5 crls@xxx.xxx.xxx.xxx echo warmup 2>&1)
        CHK_SSH=$(echo "$CHK_SSH" | grep warmup)
        if [[ $CHK_SSH != "warmup" ]]; then
                echo 'SSH connection is down ${CURDATE}'
                exit
        fi
# transfer crls
        echo 'Starting CRL Transfers'
        /usr/local/bin/rsync -e '/usr/bin/ssh' --rsync-path=/usr/bin/rsync -rvuplt crls@xxx.xxx.xxx.xxx:/home/crls/CRLAutoCache/crls/*.crl /usr/local/ssl-fips/crls/
        echo 'Completed'
        sleep 5
# remove lock file
        rm $LOCKFILE
# lock file exists
else
        echo "Lock file exists, is script already running?"
fi
#
# run hash linker
cd /usr/local/ssl-fips/crls/
/usr/local/ssl-fips/crls/hash_linker
#
# close redirect and exit
 >&2
exit

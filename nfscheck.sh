#!/usr/bin/bash
CURDATE=`date +%y%m%d-%H%MA`
NFSMOUNT=( "/path/1" "/path/2" )

for i in "${NFSMOUNT[@]}"
    do
        if [[ -z $(timeout -k 15s 10s stat -t $i 2>&-) ]]; then
            echo "stat command for $i failed!" >> /tmp/nfs_fail_$CURDATE.txt
        fi
    done

if [[ -f /tmp/nfs_fail_$CURDATE.txt ]]; then
    if [[ ! $(svcs /network/nfs/client | grep -v STATE | grep online) ]]; then
        echo "NFS Client service NOT running!" >> /tmp/nfs_fail_$CURDATE.txt
    else
        echo "NFS Client service is running." >> /tmp/nfs_fail_$CURDATE.txt
    fi
fi

if [[ -f /tmp/nfs_fail_$CURDATE.txt ]]; then
    cat /tmp/nfs_fail_$CURDATE.txt | mailx -s "NFS Failure $(hostname) $(date '+%F %H:%M')" someone@some.addy
    rm -rf /tmp/nfs_fail_$CURDATE.txt
else
    exit
fi

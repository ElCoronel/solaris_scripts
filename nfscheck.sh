#!/usr/bin/bash
### current date for tmp file name
CURDATE=`date +%y%m%d-%H%MA`
### edit array to reflect nfs mount locations
NFSMOUNT=( "/path/1" "/path/2" )
### stat each location and verify mounted
for i in "${NFSMOUNT[@]}"
    do
        if [[ -z $(timeout -k 15s 10s stat -t $i 2>&-) ]]; then
            echo "stat command for $i failed!" >> /tmp/nfs_fail_$CURDATE.txt
        else
            if [[ -z $(mount | awk '{print $1}' | grep $i) ]]; then
                echo "$i is not mounted!" >> /tmp/nfs_fail_$CURDATE.txt
            fi
        fi
    done
### check for nfs client service
if [[ -f /tmp/nfs_fail_$CURDATE.txt ]]; then
    if [[ ! $(svcs /network/nfs/client | grep -v STATE | grep online) ]]; then
        echo "NFS Client service NOT running!" >> /tmp/nfs_fail_$CURDATE.txt
    else
        echo "NFS Client service is running." >> /tmp/nfs_fail_$CURDATE.txt
    fi
fi
### email if tmp file exists
if [[ -f /tmp/nfs_fail_$CURDATE.txt ]]; then
    cat /tmp/nfs_fail_$CURDATE.txt | mailx -s "NFS Failure $(hostname) $(date '+%F %H:%M')" someone@some.addy
    rm -rf /tmp/nfs_fail_$CURDATE.txt
else
    exit
fi

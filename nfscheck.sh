#!/usr/bin/bash
### current date for tmp file name
CURDATE=`date +%y%m%d-%H%MA`
### edit array to reflect nfs mount locations
NFSMOUNT=( "/mount/1" "/mount/2")
### test to see if failure still exists
if [[ -f /tmp/nfs_failed.txt ]]; then
    for h in `sort /tmp/nfs_failed.txt | awk '{print $1}' | uniq`
        do
            if [[ -z $(timeout -k 15s 10s stat -t $h 2>&-) ]]; then
                echo "$h $(date '+%F %H:%M') stat failed" >> /tmp/nfs_failed.txt
            elif [[ -z $(mount | awk '{print $1}' | grep $h) ]]; then
                echo "$h $(date'+%F %H:%M') mount not present" >> /tmp/nfs_failed.txt
            else
                echo "$h is available again." | mailx -s "NFS Correction $(hostname) $(date '+%F %H:%M')" someone@somewhere
                rm -rf /tmp/nfs_failed.txt
            fi
        done
else
### stat each location and verify mounted
    for i in "${NFSMOUNT[@]}"
        do
            if [[ -z $(timeout -k 15s 10s stat -t $i 2>&-) ]]; then
                sleep 5m
                if [[ -z $(timeout -k 15s 10s stat -t $i 2>&-) ]]; then
                    echo "stat command for $i failed!" >> /tmp/nfs_fail_$CURDATE.txt
                    echo "$i $(date '+%F %H:%M') stat failed" >> /tmp/nfs_failed.txt
                fi
            else
                if [[ -z $(mount | awk '{print $1}' | grep $i) ]]; then
                    echo "$i is not mounted!" >> /tmp/nfs_fail_$CURDATE.txt
                    echo "$i $(date '+%F %H:%M') mount not present" >> /tmp/nfs_failed.txt
                fi
            fi
        done
### check for nfs client service
    if [[ -f /tmp/nfs_fail_$CURDATE.txt ]]; then
        if [[ -z $(svcs /network/nfs/client | grep -v STATE | grep online) ]]; then
            echo "NFS Client service NOT running!" >> /tmp/nfs_fail_$CURDATE.txt
        else
            echo "NFS Client service is running." >> /tmp/nfs_fail_$CURDATE.txt
        fi
    fi
### email if tmp file exists
    if [[ -f /tmp/nfs_fail_$CURDATE.txt ]]; then
        cat /tmp/nfs_fail_$CURDATE.txt | mailx -s "NFS Failure $(hostname) $(date '+%F %H:%M')" someone@somewhere
        rm -rf /tmp/nfs_fail_$CURDATE.txt
    else
        exit
    fi
fi

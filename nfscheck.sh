#!/usr/bin/bash
### current date for message file name
CURDATE=`date +%y%m%d-%H%MA`
### edit array to reflect nfs mount locations
NFSMOUNT=( "/mount/1" "/mount/2")
### checks nfs and mount, writes to message file if new failure, writes to log if old
for a in "${NFSMOUNT[@]}"
    do
        NAME=`echo $a | sed 's/\//\./g'`
        if [[ -f /tmp/nfs_fail$NAME.out ]]; then
            timeout -k 15s 10s df -h &>/dev/null
            if [[ -z $(timeout -k 15s 10s stat -t $a 2>&-) ]]; then
                echo "$a $(date '+%F %H:%M') stat failed" >> /tmp/nfs_fail$NAME.out
            elif [[ -z $(mount | awk '{print $1}' | grep $a) ]]; then
                echo "$a $(date'+%F %H:%M') mount not present" >> /tmp/nfs_fail$NAME.out
            else
                echo "$a is available again." | mailx -s "NFS Correction $(hostname) $(date '+%F %H:%M')" someone@somewhere
                rm -rf /tmp/nfs_fail$NAME.out
            fi
        else
            if [[ -z $(timeout -k 15s 10s stat -t $a 2>&-) ]]; then
                sleep 3m
                if [[ -z $(timeout -k 15s 10s stat -t $a 2>&-) ]]; then
                    echo "stat command for $a failed!" >> /tmp/nfs_message_$CURDATE.txt
                    echo "$a $(date '+%F %H:%M') stat failed" >> /tmp/nfs_fail$NAME.out
                fi
            else
                if [[ -z $(mount | awk '{print $1}' | grep $a) ]]; then
                    echo "$a is not mounted!" >> /tmp/nfs_message_$CURDATE.txt
                    echo "$a $(date '+%F %H:%M') mount not present" >> /tmp/nfs_fail$NAME.out
                fi
            fi
        fi
    done
### check for nfs client service
if [[ -f /tmp/nfs_message_$CURDATE.txt ]]; then
    if [[ -z $(svcs /network/nfs/client | grep -v STATE | grep online) ]]; then
        echo "NFS Client service NOT running!" >> /tmp/nfs_message_$CURDATE.txt
    else
        echo "NFS Client service is running." >> /tmp/nfs_message_$CURDATE.txt
    fi
fi
### email if tmp file exists
if [[ -f /tmp/nfs_message_$CURDATE.txt ]]; then
    cat /tmp/nfs_message_$CURDATE.txt | mailx -s "NFS Failure $(hostname) $(date '+%F %H:%M')" someone@somewhere
    rm -rf /tmp/nfs_message_$CURDATE.txt
else
    exit
fi

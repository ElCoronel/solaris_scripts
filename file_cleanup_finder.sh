#! /usr/bin/bash
## finds 10 largest files in filesystem provided as arguments
## usage file_cleanup_finder.sh <save|silent> <some filesystem> <some filesystem> ...
## if save or silent is not provided it assumes just screen output and no file save
IFS=$'\n'
RDATE=`date '+%m%d%Y-%H%M-%s'`
if [ $# -eq 0 ]; then
    echo "Usage: ./file_cleanup_funder.sh <save|silent> <some filesystem> <some filesystem> ..."
    exit 1
fi
ZARRAY=( "$@" )
if [[ $1 =~ ^(save|silent)$ ]]; then
    for f in "${ZARRAY[@]:1}"; do
        if [[ ! $(ls $f 2>/dev/null) ]]; then
            echo "$f is not a valid path. Exiting."
             rm -rf /tmp/file_cleanup_finder.list
            exit 1
        else
            /usr/gnu/bin/find $f -path "*/proc/*" -prune -o -path /proc -prune -o -type f -print0 | /usr/gnu/bin/xargs -0 /usr/gnu/bin/du | sort -n | tail -20 | cut -f2 >> /tmp/file_cleanup_finder.list
        fi
    done
else
    for f in "${ZARRAY[@]}"; do
        if [[ ! $(ls $f 2>/dev/null) ]]; then
            echo "$f is not a valid path. Exiting."
             rm -rf /tmp/file_cleanup_finder.list
            exit 1
        else
            /usr/gnu/bin/find $f -path "*/proc/*" -prune -o -path /proc -prune -o -type f -print0 | /usr/gnu/bin/xargs -0 /usr/gnu/bin/du | sort -n | tail -20 | cut -f2 >> /tmp/file_cleanup_finder.list
        fi
    done
fi
for g in `cat /tmp/file_cleanup_finder.list`; do
    DUSH=$(/usr/gnu/bin/du -sh $g)
    ## truncate the filename output if needed
    #LUSH=$(echo ${DUSH:0:45})
    LSLA=$(ls -la $g | awk '{print $6, $7, $8}')
    printf "%-15s%s\n" "$LSLA" "$DUSH" >> /tmp/file_cleanup_finder-$RDATE.out
done
if [[ $1 == "save" ]]; then
    cat /tmp/file_cleanup_finder-$RDATE.out
    echo "Output saved to /tmp/file_cleanup_finder-$RDATE.out"
    rm -rf /tmp/file_cleanup_finder.list
elif [[ $1 == "silent" ]]; then
    echo "Output saved to /tmp/file_cleanup_finder-$RDATE.out"
    rm -rf /tmp/file_cleanup_finder.list
else
    cat /tmp/file_cleanup_finder-$RDATE.out
    rm -rf /tmp/file_cleanup_finder.list
    rm -rf /tmp/file_cleanup_finder-$RDATE.out
fi

#! /usr/bin/bash
## finds 10 largest files in filesystem provided as arguments
## usage file_cleanup_finder.sh <some filesystem> <some filesystem> ...
IFS=$'\n'
if [ $# -eq 0 ]; then
    echo "Usage: ./file_cleanup_funder.sh <some filesystem> <some filesystem> ..."
    exit 1
fi
ZARRAY=( "$@" )
for f in "${ZARRAY[@]}"; do
    /usr/gnu/bin/find $f -type f -print0 | /usr/gnu/bin/xargs -0 /usr/gnu/bin/du | sort -n | tail -10 | cut -f2 >> /tmp/file_cleanup_finder.list
done
for g in `cat /tmp/file_cleanup_finder.list`; do
    DUSH=$(/usr/gnu/bin/du -sh $g)
    ## truncate the filename output if needed
    #LUSH=$(echo ${DUSH:0:45})
    LSLA=$(ls -la $g | awk '{print $6, $7, $8}')
    printf "%-15s%s\n" "$LSLA" "$DUSH" >> /tmp/file_cleanup_finder.out
done
cat /tmp/file_cleanup_finder.out
rm -rf /tmp/file_cleanup_finder.out
rm -rf /tmp/file_cleanup_finder.list

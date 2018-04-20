#! /usr/bin/bash
## finds 20 largest files
## usage: called by remote script ; not intended to be run locally
export LC_CTYPE=C
IFS=$'\n'
RDATE=`date '+%m%d%Y-%H%M-%s'`
for f in `ls -l / | grep "^d" | awk '{print $9}' | grep -v proc | grep -v system | grep -v zones`; do
        /usr/gnu/bin/find /$f -path "*/proc/*" -prune -o -type f -size +500M -print0 | /usr/gnu/bin/xargs -0 -I {} /usr/gnu/bin/du {} | sort -n | tail -20 >> /tmp/largefiles.list.tmp &
        pids+=($!)
done
for f in `ls -l /zones | grep "^d" | awk '{print $9}'`; do
        /usr/gnu/bin/find /zones/$f -path "*/proc/*" -prune -o -path "*/system/*" -prune -o -type f -size +500M -print0 | /usr/gnu/bin/xargs -0 -I {} /usr/gnu/bin/du {} | sort -n | tail -20 >> /tmp/largefiles.list.tmp &
        pids+=($!)
done
wait "${pids[@]}"
cat /tmp/largefiles.list.tmp | sort -n | tail -20 | cut -f2 >> /tmp/largefiles.list
for g in `cat /tmp/largefiles.list`; do
    DUSH=$(/usr/gnu/bin/du -sh $g)
    ## truncate the filename output if needed
    #LUSH=$(echo ${DUSH:0:45})
    LSLA=$(ls -la $g | awk '{print $6, $7, $8}')
    printf "%-15s%s\n" "$LSLA" "$DUSH" >> /tmp/largefiles-$RDATE.out
done
cat /tmp/largefiles-$RDATE.out
rm -rf /tmp/largefiles.list.tmp
rm -rf /tmp/largefiles.list
rm -rf /tmp/largefiles-$RDATE.out

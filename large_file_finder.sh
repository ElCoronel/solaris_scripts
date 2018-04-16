#!/usr/bin/bash
### find large file systems on remote servers. execute: ./large_file_finder.sh [all|person1|person2] [<global zone name>|all]
### requires file_cleanup_finder.sh installed on system
HOSTLIST=$HOME/etc/remote_hosts.list
DATE=`date '+%m%d%Y-%H%M'`
if [ $# -eq 0 ]; then
        echo "Usage: ./large_file_finder.sh <all|danny|greg> <all|list of global zones>"
        exit 1
fi
if [[ $1 == "all" ]]; then
        EADDR="persons@blah"
elif [[ $1 == "person1" ]]; then
        EADDR="person1@blah"
elif [[ $1 == "person2" ]]; then
        EADDR="person2@blah"
else
        echo"Usage: ./large_file_finder.sh <all|person1|person2> <all|list of global zones>"
        exit 1
fi
shift
echo -e "starting $(date)..."
ZARRAY=( "$@" )
### spell check
for s in "${ZARRAY[@]}"; do
        if [[ -z $(cat $HOSTLIST | grep $s) ]] && [[ ! $s == "all" ]]; then
                echo "'$s' not found in $HOSTLIST list. exiting..."
                exit 1
        fi
done
### loop through remote hosts for 'all'
if [ "${ZARRAY[0]}" = "all" ]; then
        for i in `cat $HOSTLIST | awk '{print $1}'`; do
                REMHOST=`cat $HOSTLIST | grep $i | awk '{print $2}'`
                echo "$HOME/temp/$REMHOST-global-$DATE-list.tmp" > "$HOME/temp/$REMHOST-largefiles-out.list.tmp"
                echo -ne "------------\n$REMHOST\n------------\n" > "$HOME/temp/$REMHOST-global-$DATE-list.tmp"
                GRUNDIR=$(ssh rmtmon@$i echo $HOME)
                ssh rmtmon@$i $GRUNDIR/file_cleanup_finder.sh / >> "$HOME/temp/$REMHOST-global-$DATE-list.tmp"
                ssh rmtmon@$i /usr/sbin/zoneadm list | grep -v global > $HOME/temp/zones.tmp
                for z in `cat $HOME/temp/zones.tmp`; do
                        echo "$HOME/temp/$REMHOST-$z-$DATE-list.tmp" >> "$HOME/temp/$REMHOST-largefiles-out.list.tmp"
                        echo -ne "-----------------\n$z\n-----------------\n" > "$HOME/temp/$REMHOST-$z-$DATE-list.tmp"
                        ZRUNDIR=$(ssh rmtmon@$i /usr/sbin/zlogin $z echo $HOME)
                        ssh rmtmon@$i sudo /usr/sbin/zlogin $z $ZRUNDIR/file_cleanup_finder.sh / >> "$HOME/temp/$REMHOST-$z-$DATE-list.tmp"
                        sleep 2
                done
                mapfile -t < $HOME/temp/$REMHOST-largefiles-out.list.tmp
                paste "${MAPFILE[@]}" | column -s $'\t' -t >> "$HOME/temp/$REMHOST-combined-largefiles-list.txt"
                rm -rf $HOME/temp/zones.tmp
                for d in `cat $HOME/temp/$REMHOST-largefiles-out.list.tmp`; do
                        rm -rf $d
                done
        done
else
### loop through the provided input
        for a in "${ZARRAY[@]}"; do
                GHOST=`cat $HOSTLIST | grep $a| awk '{print $1}'`
                REMHOST=`cat $HOSTLIST | grep $a | awk '{print $2}'`
                echo "$HOME/temp/$REMHOST-global-$DATE-list.tmp" > "$HOME/temp/$REMHOST-largefiles-out.list.tmp"
                echo -ne "------------\n$REMHOST\n------------\n" > "$HOME/temp/$REMHOST-global-$DATE-list.tmp"
                GRUNDIR=$(ssh rmtmon@$GHOST 'echo $HOME')
                ssh rmtmon@$GHOST "sudo $GRUNDIR/file_cleanup_finder.sh" / >> "$HOME/temp/$REMHOST-global-$DATE-list.tmp"
#               ssh rmtmon@$GHOST /usr/sbin/zoneadm list | grep -v global > $HOME/temp/zones.tmp
#                       for z in `cat $HOME/temp/zones.tmp`; do
#                               echo "$HOME/temp/$REMHOST-$z-$DATE-list.tmp" >> "$HOME/temp/$REMHOST-largefiles-out.list.tmp"
#                               echo -ne "-----------------\n$z\n-----------------\n" > "$HOME/temp/$REMHOST-$z-$DATE-list.tmp"
#                               ZRUNDIR=$(ssh rmtmon@$GHOST 'sudo /usr/sbin/zlogin $z echo $HOME')
#                               ssh rmtmon@$GHOST sudo /usr/sbin/zlogin $z $ZRUNDIR/file_cleanup_finder.sh / >> "$HOME/temp/$REMHOST-$z-$DATE-list.tmp" &
#                               sleep 2
#                       done
                mapfile -t < $HOME/temp/$REMHOST-largefiles-out.list.tmp
                paste "${MAPFILE[@]}" | column -s $'\t' -t >> "$HOME/temp/$REMHOST-combined-largefiles-list.txt"
                #rm -rf $HOME/temp/zones.tmp
                for d in `cat $HOME/temp/$REMHOST-largefiles-out.list.tmp`; do
                        rm -rf $d
                done
        done
fi
### spinner because it is slow
#ZPID=(`ps -ef | grep rmtmon | grep "large_file_finder.sh" | grep -v grep | awk '{print $2}'`)
#spin[0]="-"
#spin[1]="\\"
#spin[2]="|"
#spin[3]="/"
#/usr/gnu/bin/echo -ne "\nworking... ${sping[0]}"
#while [[ -n $(ps -ef | /usr/gnu/bin/grep ${ZPID[@]/#/-e } | grep -v grep) ]]; do
#        for b in "${spin[@]}"; do
#                /usr/gnu/bin/echo -ne "\b$b"
#                sleep 0.1
#        done
#done
### prep the email body before we clean up the attachments
echo "Large files list created on $(date)." >> $HOME/temp/largefiles-body.tmp
### create the attachments
for i in `find $HOME/temp -type f | grep "combined-largefiles-list.txt"`
        do
                /usr/gnu/bin/sed -i "s/$/\r/" $i
                uuencode $i $(echo $i | awk -F/ '{print $NF}') >> $HOME/temp/largefiles-multi_attachment.tmp
        done
### combine body and attachments so we can use mailx
cat $HOME/temp/largefiles-body.tmp $HOME/temp/largefiles-multi_attachment.tmp > $HOME/temp/largefiles-combined.tmp
### send the email
cat $HOME/temp/largefiles-combined.tmp | mailx -s "Large Files Lists" $EADDR
### clean up the temp files
rm -rf $HOME/temp/largefiles-body.tmp $HOME/temp/largefiles-combined.tmp $HOME/temp/largefiles-multi_attachment.tmp
rm -rf $HOME/temp/*largefiles*
echo -e "...finished $(date)."

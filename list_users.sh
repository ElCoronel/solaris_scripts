#!/usr/bin/bash
### list user accounts on systems. execute: ./list_users.sh [<global zone name>|all]
HOSTLIST=$HOME/etc/remote_hosts.list
DATE=`date '+%m%d%Y-%H%M'`
if [ $# -eq 0 ]; then
        echo "Usage: ./list_users.sh <global zone name>|all"
        exit 1
fi
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
                echo "$HOME/temp/$REMHOST-global-$DATE-list.tmp" > "$HOME/temp/$REMHOST-users-out.list.tmp"
                echo -ne "------------\n$REMHOST\n------------\n" > "$HOME/temp/$REMHOST-global-$DATE-list.tmp"
                ssh rmtmon@$i cat /etc/passwd | awk -F: '{print $1}' >> "$HOME/temp/$REMHOST-global-$DATE-list.tmp"
                ssh rmtmon@$i /usr/sbin/zoneadm list | grep -v global > $HOME/temp/zones.tmp
                for z in `cat $HOME/temp/zones.tmp`; do
                        echo "$HOME/temp/$REMHOST-$z-$DATE-list.tmp" >> "$HOME/temp/$REMHOST-users-out.list.tmp"
                        echo -ne "-----------------\n$z\n-----------------\n" > "$HOME/temp/$REMHOST-$z-$DATE-list.tmp"
                        ssh rmtmon@$i sudo /usr/sbin/zlogin $z 'cat /etc/passwd' | awk -F: '{print $1}' >> "$HOME/temp/$REMHOST-$z-$DATE-list.tmp"
                        sleep 2
                done
                mapfile -t < $HOME/temp/$REMHOST-users-out.list.tmp
                paste "${MAPFILE[@]}" | column -s $'\t' -t >> "$HOME/temp/$REMHOST-combined-users-list.txt"
                rm -rf $HOME/temp/zones.tmp
                for d in `cat $HOME/temp/$REMHOST-users-out.list.tmp`; do
                        rm -rf $d
                done
        done
else
### loop through the provided input
        for a in "${ZARRAY[@]}"; do
                GHOST=`cat $HOSTLIST | grep $a| awk '{print $1}'`
                REMHOST=`cat $HOSTLIST | grep $a | awk '{print $2}'`
                echo "$HOME/temp/$REMHOST-global-$DATE-list.tmp" > "$HOME/temp/$REMHOST-users-out.list.tmp"
                echo -ne "------------\n$REMHOST\n------------\n" > "$HOME/temp/$REMHOST-global-$DATE-list.tmp"
                ssh rmtmon@$GHOST cat /etc/passwd | awk -F: '{print $1}' >> "$HOME/temp/$REMHOST-global-$DATE-list.tmp"
                ssh rmtmon@$GHOST /usr/sbin/zoneadm list | grep -v global > $HOME/temp/zones.tmp
                for z in `cat $HOME/temp/zones.tmp`; do
                        echo "$HOME/temp/$REMHOST-$z-$DATE-list.tmp" >> "$HOME/temp/$REMHOST-users-out.list.tmp"
                        echo -ne "-----------------\n$z\n-----------------\n" > "$HOME/temp/$REMHOST-$z-$DATE-list.tmp"
                        ssh rmtmon@$GHOST sudo /usr/sbin/zlogin $z 'cat /etc/passwd' | awk -F: '{print $1}' >> "$HOME/temp/$REMHOST-$z-$DATE-list.tmp"
                        sleep 2
                done
                mapfile -t < $HOME/temp/$REMHOST-users-out.list.tmp
                paste "${MAPFILE[@]}" | column -s $'\t' -t >> "$HOME/temp/$REMHOST-combined-users-list.txt"
                rm -rf $HOME/temp/zones.tmp
                for d in `cat $HOME/temp/$REMHOST-users-out.list.tmp`; do
                        rm -rf $d
                done
        done
fi
### prep the email body before we clean up the attachments
echo "Users lists created on $(date)." >> $HOME/temp/users-body.tmp
### create the attachments
for i in `find $HOME/temp -type f | grep "combined-users-list.txt"`
        do
                /usr/gnu/bin/sed -i "s/$/\r/" $i
                uuencode $i $(echo $i | awk -F/ '{print $NF}') >> $HOME/temp/users-multi_attachment.tmp
        done
### combine body and attachments so we can use mailx
cat $HOME/temp/users-body.tmp $HOME/temp/users-multi_attachment.tmp > $HOME/temp/users-combined.tmp
### send the email
cat $HOME/temp/users-combined.tmp | mailx -s "Users Lists" someone@somewhere
### clean up the temp files
rm -rf $HOME/temp/users-body.tmp $HOME/temp/users-combined.tmp $HOME/temp/users-multi_attachment.tmp
rm -rf $HOME/temp/*users*

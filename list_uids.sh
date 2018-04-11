#!/usr/bin/bash
### list user accounts, uids and prikmary group on systems. execute: ./list_uids.sh [all|name1|name2] [<global zone name>|all]
HOSTLIST=$HOME/etc/remote_hosts.list
DATE=`date '+%m%d%Y-%H%M'`
if [ $# -eq 0 ]; then
        echo "Usage: ./list_uids.sh <all|name1|name2> <all|list of global zones>"
        exit 1
fi
if [[ $1 == "all" ]]; then
        EADDR="someone@somewhere"
elif [[ $1 == "name1" ]]; then
        EADDR="someone@somewhere"
elif [[ $1 == "name2" ]]; then
        EADDR="someone@somewhere"
else
        echo"Usage: ./list_uids.sh <all|name1|name2> <all|list of global zones>"
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
                echo "$HOME/temp/$REMHOST-global-$DATE-list.tmp" > "$HOME/temp/$REMHOST-uids-out.list.tmp"
                echo -ne "------------\n$REMHOST\n------------\n" > "$HOME/temp/$REMHOST-global-$DATE-list.tmp"
                ssh rmtmon@$i cat /etc/passwd | awk -F: '{print $1":"$3":"$4}' | sort >> "$HOME/temp/$REMHOST-global-$DATE-list.tmp"
                ssh rmtmon@$i cat /etc/group >> "$HOME/temp/$REMHOST-global-$DATE-groups.tmp"
                for f in `cat "$HOME/temp/$REMHOST-global-$DATE-list.tmp" | awk -F: '{print $3}'`; do
                        /usr/gnu/bin/sed -i "s/:$f$/:$(cat "$HOME/temp/$REMHOST-global-$DATE-groups.tmp" | /usr/gnu/bin/grep -w $f | awk -F: '{print $1}')/" "$HOME/temp/$REMHOST-global-$DATE-list.tmp"
                done
                ssh rmtmon@$i /usr/sbin/zoneadm list | grep -v global > $HOME/temp/zones.tmp
                for z in `cat $HOME/temp/zones.tmp`; do
                        echo "$HOME/temp/$REMHOST-$z-$DATE-list.tmp" >> "$HOME/temp/$REMHOST-uids-out.list.tmp"
                        echo -ne "-----------------\n$z\n-----------------\n" > "$HOME/temp/$REMHOST-$z-$DATE-list.tmp"
                        ssh rmtmon@$i sudo /usr/sbin/zlogin $z 'cat /etc/passwd' | awk -F: '{print $1":"$3":"$4}' | sort >> "$HOME/temp/$REMHOST-$z-$DATE-list.tmp"
                        ssh rmtmon@$i sudo /usr/sbin/zlogin $z 'cat /etc/group' >> "$HOME/temp/$REMHOST-$z-$DATE-groups.tmp"
                        for g in `cat "$HOME/temp/$REMHOST-$z-$DATE-list.tmp" | awk -F: '{print $3}'`; do
                                /usr/gnu/bin/sed -i "s/:$g$/:$(cat "$HOME/temp/$REMHOST-$z-$DATE-groups.tmp" | /usr/gnu/bin/grep -w $g | awk -F: '{print $1}')/" "$HOME/temp/$REMHOST-$z-$DATE-list.tmp"
                        done
                        sleep 2
                done
                for l in `cat $HOME/etc/sysaccnts.list`; do
                        /usr/gnu/bin/sed -i "/$l/d" $HOME/temp/$REMHOST*$DATE-list.tmp
                        /usr/gnu/bin/sed -i  "/^\s*$/d" $HOME/temp/$REMHOST*$DATE-list.tmp
                done
                mapfile -t < $HOME/temp/$REMHOST-uids-out.list.tmp
                paste "${MAPFILE[@]}" | column -s $'\t' -t >> "$HOME/temp/$REMHOST-combined-uids-list.txt"
                rm -rf $HOME/temp/zones.tmp
                for d in `cat $HOME/temp/$REMHOST-uids-out.list.tmp`; do
                        rm -rf $d
                done
        done
else
### loop through the provided input
        for a in "${ZARRAY[@]}"; do
                GHOST=`cat $HOSTLIST | grep $a| awk '{print $1}'`
                REMHOST=`cat $HOSTLIST | grep $a | awk '{print $2}'`
                echo "$HOME/temp/$REMHOST-global-$DATE-list.tmp" > "$HOME/temp/$REMHOST-uids-out.list.tmp"
                echo -ne "------------\n$REMHOST\n------------\n" > "$HOME/temp/$REMHOST-global-$DATE-list.tmp"
                ssh rmtmon@$GHOST cat /etc/passwd | awk -F: '{print $1":"$3":"$4}' | sort >> "$HOME/temp/$REMHOST-global-$DATE-list.tmp"
                ssh rmtmon@$GHOST cat /etc/group >> "$HOME/temp/$REMHOST-global-$DATE-groups.tmp"
                for f in `cat "$HOME/temp/$REMHOST-global-$DATE-list.tmp" | awk -F: '{print $3}'`; do
                        /usr/gnu/bin/sed -i "s/:$f$/:$(cat "$HOME/temp/$REMHOST-global-$DATE-groups.tmp" | /usr/gnu/bin/grep -w $f | awk -F: '{print $1}')/" "$HOME/temp/$REMHOST-global-$DATE-list.tmp"
                done
                ssh rmtmon@$GHOST /usr/sbin/zoneadm list | grep -v global > $HOME/temp/zones.tmp
                        for z in `cat $HOME/temp/zones.tmp`; do
                                echo "$HOME/temp/$REMHOST-$z-$DATE-list.tmp" >> "$HOME/temp/$REMHOST-uids-out.list.tmp"
                                echo -ne "-----------------\n$z\n-----------------\n" > "$HOME/temp/$REMHOST-$z-$DATE-list.tmp"
                                ssh rmtmon@$GHOST sudo /usr/sbin/zlogin $z 'cat /etc/passwd' | awk -F: '{print $1":"$3":"$4}' | sort >> "$HOME/temp/$REMHOST-$z-$DATE-list.tmp"
                                ssh rmtmon@$GHOST sudo /usr/sbin/zlogin $z 'cat /etc/group' >> "$HOME/temp/$REMHOST-$z-$DATE-groups.tmp"
                                for g in `cat "$HOME/temp/$REMHOST-$z-$DATE-list.tmp" | awk -F: '{print $3}'`; do
                                        /usr/gnu/bin/sed -i "s/:$g$/:$(cat "$HOME/temp/$REMHOST-$z-$DATE-groups.tmp" | /usr/gnu/bin/grep -w $g | awk -F: '{print $1}')/" "$HOME/temp/$REMHOST-$z-$DATE-list.tmp"
                                done
                                sleep 2
                        done
                for l in `cat $HOME/etc/sysaccnts.list`; do
                        /usr/gnu/bin/sed -i "/$l*$/d" $HOME/temp/$REMHOST*$DATE-list.tmp
                        /usr/gnu/bin/sed -i  "/^\s*$/d" $HOME/temp/$REMHOST*$DATE-list.tmp
                done
                mapfile -t < $HOME/temp/$REMHOST-uids-out.list.tmp
                paste "${MAPFILE[@]}" | column -s $'\t' -t >> "$HOME/temp/$REMHOST-combined-uids-list.txt"
                rm -rf $HOME/temp/zones.tmp
                for d in `cat $HOME/temp/$REMHOST-uids-out.list.tmp`; do
                        rm -rf $d
                done
        done
fi
### prep the email body before we clean up the attachments
echo "Users lists created on $(date)." >> $HOME/temp/uids-body.tmp
### create the attachments
for i in `find $HOME/temp -type f | grep "combined-uids-list.txt"`
        do
                /usr/gnu/bin/sed -i "s/$/\r/" $i
                uuencode $i $(echo $i | awk -F/ '{print $NF}') >> $HOME/temp/uids-multi_attachment.tmp
        done
### combine body and attachments so we can use mailx
cat $HOME/temp/uids-body.tmp $HOME/temp/uids-multi_attachment.tmp > $HOME/temp/uids-combined.tmp
### send the email
cat $HOME/temp/uids-combined.tmp | mailx -s "Users Lists" $EADDR
### clean up the temp files
rm -rf $HOME/temp/uids-body.tmp $HOME/temp/uids-combined.tmp $HOME/temp/uids-multi_attachment.tmp
rm -rf $HOME/temp/*uids*
rm -rf $HOME/temp/*group*
echo -e "...finished $(date)."

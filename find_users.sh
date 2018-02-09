#!/usr/bin/bash
### find user account on systems. execute: ./find_user.sh <username> [all]
HOSTLIST=$HOME/etc/remote_hosts.list
NAME=$1
if [ $# -eq 0 ]; then
        echo "Usage: ./find_user.sh <username> [all]"
        exit 1
fi
### loop through remote hosts
for i in `cat $HOSTLIST | awk '{print $1}'`; do
        REMHOST=`cat $HOSTLIST | grep $i | awk '{print $2}'`
        echo $i
        GOUT=$(ssh rmtmon@$i cat /etc/passwd | grep $NAME | awk -F: '{print $1}')
        echo "GLOBAL - $REMHOST - $GOUT" | grep $NAME
        ssh rmtmon@$i /usr/sbin/zoneadm list | grep -v global > $HOME/temp/zones.tmp
        for z in `cat $HOME/temp/zones.tmp`; do
                ZOUT=$(ssh rmtmon@$i sudo /usr/sbin/zlogin $z 'cat /etc/passwd' | grep $NAME | awk -F: '{print $1}')
                case "$2" in
                        "all")
                                echo " zone  - $z - $ZOUT"
                                ;;
                        "")
                                echo " zone  - $z - $ZOUT" | grep $NAME
                                ;;
                        *)
                                echo "Usage: ./find_user.sh <username> [all]"
                                exit 1
                                ;;
                esac
                sleep 2
        done
        rm -rf $HOME/temp/zones.tmp
done

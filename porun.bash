#! /usr/bin/bash

CURDTE=`date +%y%m%d-%H%M`

source /export/home/user/env.list

if [ -f /export/home/user/po/ponotification ]
        then
        cd /export/home/user/po/
        /export/home/user/po/ponotification /export/home/user/po/configuration.xml

        if [ -f /export/home/user/po/email/POEMailList.txt ]
        then

                cd /export/home/user/po/email

                for i in `ls /export/home/user/po/email/ | grep PO`
                        do dos2unix /export/home/user/po/email/$i /export/home/user/po/email/$i
                done

                INPUT=/export/home/user/po/email/POEMailList.txt
                OLDIFS=$IFS
                IFS=,
                [ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
                while read addr1 addr2 sub mesg
                        do
                                /bin/mailx -s $sub -reply-to@addr.ess $addr1 $addr2 < /export/home/user/po/$mesg
                        done < $INPUT
                IFS=$OLDIFS
                mv /export/home/user/po/email/POEMailList.txt /export/home/user/po/email/archive/POEMailList.txt.$CURDTE
                /usr/bin/gzip /export/home/user/po/email/archive/POEMailList.txt.$CURDTE
                for y in `ls /export/home/user/po/email | grep Message`
                        do mv /export/home/user/po/email/$y /export/home/user/po/email/archive/$y.$CURDTE
                        /usr/bin/gzip /export/home/user/po/email/archive/$y.$CURDTE
                done
        fi

fi

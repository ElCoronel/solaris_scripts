#! /usr/bin/bash

CURDTE=`date +%y%m%d-%H%M`

if [ -f /export/home/tcpo/ponotification ]
        then
        cd /export/home/tcpo/
        /export/home/tcpo/ponotification /export/home/tcpo/configuration.xml

        if [ -f /export/home/tcpo/email/POEMailList.txt ]
        then

                cd /export/home/tcpo/email

                for i in `ls /export/home/tcpo/email/ | grep PO`
                        do dos2unix /export/home/tcpo/email/$i /export/home/tcpo/email/$i
                done

                INPUT=/export/home/tcpo/email/POEMailList.txt
                OLDIFS=$IFS
                IFS=,
                [ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
                while read addr1 addr2 sub mesg
                        do
                                /bin/mailx -s $sub -r wralc.tila.centra@us.af.mil $addr1 $addr2 < /export/home/tcpo/$mesg
                        done < $INPUT
                IFS=$OLDIFS
                mv /export/home/tcpo/email/POEMailList.txt /export/home/tcpo/email/archive/POEMailList.txt.$CURDTE      
                /usr/bin/gzip /export/home/tcpo/email/archive/POEMailList.txt.$CURDTE
                for y in `ls /export/home/tcpo/email | grep Message`
                        do mv /export/home/tcpo/email/$y /export/home/tcpo/email/archive/$y.$CURDTE
                        /usr/bin/gzip /export/home/tcpo/email/archive/$y.$CURDTE
                done
        fi

fi

exit 0

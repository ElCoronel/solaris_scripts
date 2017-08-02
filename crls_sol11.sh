#!/bin/bash
CURDTE=`date +%y%m%d-%H%M`

cd /usr/local/ssl-fips/crls

/usr/bin/rsync -e '/usr/bin/ssh' --rsync-path=/usr/bin/rsync -rvuplt crls@xxx.xxx.xxx.xxx:/home/crls/CRLAu
toCache/crls/*.crl /usr/local/ssl-fips/crls/

for a in `ls *.crl`; do /usr/local/ssl-fips/bin/openssl crl -in $a -inform DER -outform PEM -out $a; done

for i in `ls | grep '.r0'`; do unlink $i; done
echo -e "Processed on $CURDTE" >> /export/home/user/crl.$CURDTE.log
for tCRL in *.crl
do
        crlHash=`/usr/local/ssl-fips/bin/openssl crl -in $tCRL -inform PEM -hash -noout`.r0
        crlNextUpdate=`/usr/local/ssl-fips/bin/openssl crl -in $tCRL -inform PEM -nextupdate -noout`
        echo -e "hash=$crlHash  $crlNextUpdate  $tCRL" >> /export/home/user/crl.$CURDTE.log
        if [ ! -L $crlHash ]; then
                ln -s $tCRL $crlHash
        fi
done

/usr/local/httpd/bin/apachectl restart

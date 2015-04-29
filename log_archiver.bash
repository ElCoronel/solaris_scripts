#!/usr/bin/bash
#
cd /tmp

if [[ -n $(find * ! -name . -prune  -type f -mtime +1) ]]

then
        echo "Success finding tmp files to process in `pwd`" >> /export/home/tc_logs/tc_archiver_`date +%m_%d_%Y`.log

        touch /export/home/tc_logs/tc_logs_archive_`date +%m_%d_%Y`.tar
        
        echo "Touched file to write archive to, named tc_logs_archive_`date +%m_%d_%Y`.tar" >> /export/home/tc_logs/tc_archi
ver_`date +%m_%d_%Y`.log

        cd /tmp

        for i in `find * ! -name . -prune  -type f -mtime +1`
            do
                chmod 755 $i
                /usr/bin/gtar uvf /export/home/tc_logs/tc_logs_archive_`date +%m_%d_%Y`.tar --transform=s/^/tmp\_/ $i
                rm -rf $i
                echo "Processed $i" >> /export/home/tc_logs/tc_archiver_`date +%m_%d_%Y`.log
        done
    
else

        echo "No tmp logs." >> /export/home/tc_logs/tc_archiver_`date +%m_%d_%Y`.log

fi

cd /export/home/jboss/server/default/log

if [[ -n $(find * ! -name . ! -name server.log ! -name boot.log -prune -type f -mtime +1) ]]

then
        echo "Success finding jboss files to process in `pwd`" >> /export/home/tc_logs/tc_archiver_`date +%m_%d_%Y`.log

        cd /export/home/jboss/server/default/log
        
        for j in `find * ! -name . ! -name server.log ! -name boot.log -prune -type f -mtime +1`
            do
                chmod 755 $j
                /usr/bin/gtar uvf /export/home/tc_logs/tc_logs_archive_`date +%m_%d_%Y`.tar --transform=s/^/jboss\_/ $j
                rm -rf $j
                echo "Processed $j" >> /export/home/tc_logs/tc_archiver_`date +%m_%d_%Y`.log
        done

else

        echo "No JBOSS logs." >> /export/home/tc_logs/tc_archiver_`date +%m_%d_%Y`.log

fi

cd /export/home/tcload/tomcat/logs

if [[ -n $(find * ! -name . ! -name catalina.out -prune -type f -mtime +1) ]]

then
        echo "Success finding tcload files to process in `pwd`" >> /export/home/tc_logs/tc_archiver_`date +%m_%d_%Y`.log

        cd /export/home/tcload/tomcat/logs
        
        for k in `find * ! -name . ! -name catalina.out -prune -type f -mtime +1`
            do
                chmod 755 $k
                /usr/bin/gtar uvf /export/home/tc_logs/tc_logs_archive_`date +%m_%d_%Y`.tar --transform=s/^/tcload\_/ $k
                rm -rf $k
                echo "Processed $k" >> /export/home/tc_logs/tc_archiver_`date +%m_%d_%Y`.log
        done

else

        echo "No tcload logs" >> /export/home/tc_logs/tc_archiver_`date +%m_%d_%Y`.log

fi

### AT THE END

if [ -f /export/home/tc_logs/tc_logs_archive_`date +%m_%d_%Y`.tar ]

then
        cd /export/home/tc_logs

        gzip /export/home/tc_logs/tc_logs_archive_`date +%m_%d_%Y`.tar

fi

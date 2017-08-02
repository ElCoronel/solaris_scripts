#!/usr/bin/csh

source /export/home/user/env.list

setenv TNS_ADMIN /export/home/user/ftsload

setenv LOCKFILE /tmp/ftsldr.lck
set crdate = `date`
set filename = fts_loader.log.`date +%Y%m%d%H%M%S`
#
echo "Starting FTCS Loader on " $crdate
#
if (! -e $LOCKFILE ) then
  touch $LOCKFILE
 else
   /bin/echo "FTS Loader already running, or check  Lockfile"
  exit 1
endif
#
./TcFTCSSustainment ftcs.loader.1 password "role" /export/home/user/ftsload/ftcs_sustainment.xml

if (-e /tmp/TC_FTCS_log ) then
  /bin/mv /tmp/TC_FTCS_log  $HOME/ftsload/logs/$filename 
endif
if (-e $HOME/ftsload/system_log ) then
   /bin/cat $HOME/ftsload/system_log >> $HOME/ftsload/logs/$filename
   rm $HOME/ftsload/system_log
endif
if (-e $HOME/ftsload/system_log.log) then
   /bin/cat $HOME/ftsload/system_log.log >> $HOME/ftsload/logs/$filename
   rm $HOME/ftsload/system_log.log
endif 
if (-e $HOME/ftsload/journal_file) then
   /bin/cat $HOME/ftsload/journal_file >> $HOME/ftsload/logs/$filename
   rm $HOME/ftsload/journal_file
endif
if (-e $LOCKFILE) then
   rm $LOCKFILE
endif
set crdate = `date`
echo "Ending FTCS Loader on " $crdate

### Edit perms of files loaded ###
foreach k ( `find /jedld -type f -perm 400 -print` )
        echo "Modifying $k" >> $HOME/ftsload/logs/$filename
        chmod 755 $k
end

### run curl command to start fusion process ###
curl -kv -sslv1 -u admin:adminpass -X POST https://hostname:8764/api/apollo/connectors/jobs/projects

#!/usr/bin/bash
#########################################################
# Script to copy newest compressed audit log to folder  #
# where is it uncompressed, and read to a text file     #
# so Splunk can index it                                #
#########################################################                            
#
curdate=`date +%y%m%d-%H%M`     # get date for log filename
outpath=/sysevts/logs           # log path
#
# redirect stdout and stderr to log file
exec &> >(tee $outpath/$curdate.log)
#
# some variables
apath=/var/audit/logs           # audit log path
tpath=/sysevts/tmp              # temp location to copy logs to
spath=/sysevts/splunk           # location for final text files
#
# copy logs to temp location for processing
cd $apath
alog=`ls -t $apath| head -1`
echo 'Copying '$apath/$alog' to '$tpath
cp $apath/$alog $tpath
#
# uncompress file in temp location
cd $tpath
echo 'Uncompressing '$tpath/$alog
uncompress $tpath/$alog
#
# convert to readable format
tlog=`ls -t $tpath | head -1`
echo 'Converting '$tpath/$tlog' to readable format at '$spath/$tlog.txt
praudit -ls $tpath/$tlog > $spath/$tlog.txt
#
# clean up oldest temp file
oldlog1=`ls -t $tpath | tail -1`
echo 'Deleting '$tpath/$oldlog1
rm -f $tpath/$oldlog1
#
#clean up oldest text file
cd $spath
oldlog2=`ls -t $spath | tail -1`
echo 'Deleting '$spath/$oldlog2
rm -f $spath/$oldlog2
#
echo 'Done.'
# close redirect
 >&2

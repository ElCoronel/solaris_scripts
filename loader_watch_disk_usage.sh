#/bin/sh
while true
do
 clear
 rm /export/home/user/suc_combined.list
 rm /export/home/user/fail_combined.list
 p=$n 
 echo 'Processes...'
 ps -ef | grep datasetloader | wc -l
 echo '##########'
 echo 'Disk usage...'
 df -h
 for b in 0{1..9} {10..20}
 do
        cat /export/home/user/ftrstlist/batch9/$b/JEDMICS_LOAD_STATUS.log | grep SUCCESS >> /export/home/user/suc_combined.list
        cat /export/home/user/ftrstlist/batch9$b/JEDMICS_LOAD_STATUS.log | grep FAIL >> /export/home/user/fail_combined.list
 done
 echo '##########'
 echo 'Failed items...'
 cat /export/home/user/fail_combined.list | wc -l
 n=$(cat /export/home/user/suc_combined.list | wc -l)
 echo '##########'
 echo 'Successful items in combined logs...'
 echo $n
 d=$((n-p))
 echo '##########'
 echo 'Increase since last run...'
 echo $d
 echo '##########'
 echo `date`
 echo "`date` Total: $n Per Minute: $d" >> /export/home/user/load_batch9.stats
 sleep 60
done

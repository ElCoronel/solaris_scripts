#!/usr/bin/bash
#
TSTAMP=`date +%y%m%d-%H%M`
#
for k in `find /TCpcms -type f -perm 400 -print | grep '.out'`
       do
               echo $TSTAMP "Copying $k to /jed_mpl/" >> /export/home/gsanders/mpl_copy_`date +%F`.log
               cp $k /jed_mpl/
done

for l in `find /jed_mpl/ -type f -perm 400 -print`
       do
               echo $TSTAMP "Modifying $l" >> /export/home/gsanders/mpl_copy_`date +%F`.log
               chmod 755 $l
done

for m in `find /TCpcms -type f -perm 400 -print`
        do
                echo $TSTAMP "Modifying $m" >> /export/home/gsanders/tc_vol_perms_`date +%F`.log
                chmod 755 $m
done

for i in `find /TCActive -type f -perm 400 -print`
        do
                echo $TSTAMP "Modifying $i" >> /export/home/gsanders/tc_vol_perms_`date +%F`.log
                chmod 755 $i
done

for j in `find /TCeng -type f -perm 400 -print`
        do
                echo $TSTAMP "Modifying $j" >> /export/home/gsanders/tc_vol_perms_`date +%F`.log
                chmod 755 $j
done

for n in `find  /jedld/TCunrst -type f -perm 400 -print`
        do
                echo $TSTAMP "Modifying $n" >> /export/home/gsanders/tc_vol_perms_`date +%F`.log
                chmod 755 $n
done

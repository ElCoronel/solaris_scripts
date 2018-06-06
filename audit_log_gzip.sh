#!/usr/bin/bash
HOSTLIST=$HOME/etc/remote_hosts.list.test
AUDITDIR=/var/share/audit
### loop through remote hosts
for i in `cat $HOSTLIST | awk '{print $1}'`; do
        if ssh rmtmon@$i "[ -f /tmp/audit_gzip.lck ]"
                then
                        echo "$i - lock file exists - not processing"
                else
                        echo "$i - lock file not present - processing"
                        ssh rmtmon@$i "touch /tmp/audit_gzip.lck && sudo find /var/share/audit/ -type f ! -name '*.gz' ! -name '*terminated*' -exec gzip {} \\; && rm -rf /tmp/audit_gzip.lck" &
        fi
done

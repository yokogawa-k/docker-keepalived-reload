#!/bin/bash

#set -e
set -u

TARGET_PID=$(cat /var/run/keepalived-checker.pid)

if [ -n "${TARGET_PID}" ]; then
  echo "TARGET_PID is ${TARGET_PID}"
else
  echo "No Target pid"
fi

/usr/local/sbin/keepalived --version
echo "### sleep 5sec ###"
sleep 5
echo "### ipvsadm(before) ###"
ipvsadm -L -n | tee /tmp/before
sed -i.bak -e 's/192.168.2\./192.168.3\./' /etc/keepalived/keepalived.conf

echo "### config diff ###"
colordiff -U1 /etc/keepalived/keepalived.conf.bak /etc/keepalived/keepalived.conf
echo "### reload(send sighup)"
kill -HUP ${TARGET_PID}
echo "### sleep 5sec ###"
sleep 5
echo "### ipvsadm(after) ###"
ipvsadm -L -n | tee /tmp/after

echo "### ipvsadm diff ###"
colordiff -U1 /tmp/before /tmp/after


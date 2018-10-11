#!/bin/bash

for down_osd in $(ceph osd tree | awk '/down/ {print $1}' | sort | uniq)
do
  host=$(ceph osd find $down_osd | awk -F\" '$2 ~ /host/ {print $4}')
  echo ssh $host "systemctl restart ceph-osd@${down_osd}.service"
  ssh $host "systemctl restart ceph-osd@${down_osd}.service"
done

#!/bin/bash

########调整池的pg数目###########
#######一个pg一个pg的增加########

POOLNMAE="cache"  #poolname
PGSTART=1000      #pool的当前pg数
PGALL=12264       #当前的pg总数
PGEND=2048        #pool将到达的pg数

while true
do
    PGNUM=`ceph -s | awk '/active\+clean/ {print $(NF-1)}' | head -n1`
    if [ $PGNUM -ne $PGALL ];then
        echo "$PGNUM != $PGALL"
        sleep 5
        continue
    fi

    if [ $PGSTART -eq $PGEND ];then
        break;
    fi

    PGSTART=$(($PGSTART+1))
    PGALL=$(($PGALL+1))
    echo ceph osd pool set ${POOLNMAE} pg_num $PGSTART --yes-i-really-mean-it
    echo ceph osd pool set ${POOLNMAE} pgp_num $PGSTART --yes-i-really-mean-it
    ceph osd pool set ${POOLNMAE} pg_num $PGSTART --yes-i-really-mean-it
    ceph osd pool set ${POOLNMAE} pgp_num $PGSTART --yes-i-really-mean-it

    sleep 5
done

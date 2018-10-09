#!/bin/bash 

################reweight pg distribution#################################



function usage() {
    echo
    echo "USAGE: `basename $0` [poolname] [-h]"
    echo "    -h        display this help and exit."
    echo "    poolname  distribution a single pool or whole pool.  default：whole pool"
}


function reweight_pg() {
    i=0
    pgnum=`ceph pg stat | awk '{print $1}'`
    POOLNAME=$1

    #while(($i<1000)) 
    while true
    do
        RESULT=`ceph -s | awk '/active\+clean/ {print $(NF-1)}' | head -n1`
        if [ $pgnum -ne $RESULT ];then
            echo "pg is not active+clean !"
            sleep 1
            continue
	fi
	  
	HEAD=`./get_pgs_per_osd ${POOLNAME} | grep ^osd | awk '{print $NF}' | sort -n | head -n1`
	TAIL=`./get_pgs_per_osd ${POOLNAME} | grep ^osd | awk '{print $NF}' | sort -n | tail -n1`
	((SUB=($TAIL-$HEAD)))
	
        if [ $SUB -lt "10" ];then
	  break
	fi
	ceph osd reweight-by-pg 105 ${POOLNAME} > /dev/null
        
	i=$(($i+1))
	echo "seq:$i max:$TAIL min:$HEAD sub:$SUB"
        
    done
}

if [ -n "$1" ];then                # have a word
    if [ "-h" = "$1" ];then        # help
        usage
        exit 0
    else                           # distribution a single pool
        POOLNAME=$1
        reweight_pg ${POOLNAME}
    fi 
else                               # distribution whole pool
    reweight_pg
fi

exit 0

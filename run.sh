#!/bin/bash
set -ex


add(){
    CID=$(docker run --rm -d --network=none alpine sh -c "sleep infinity")
    PID=$(docker inspect ${CID}|jq -r ".[0].State.Pid")

    mkdir -p /var/run/netns
    chmod 755 /var/run/netns
    chown root.root /var/run/netns

    export CNI_COMMAND=ADD
    export CNI_CONTAINERID=$CID
    export CNI_NETNS=/proc/$PID/ns/net
    export CNI_IFNAME=eth0
    export PID=$PID


    echo $CID > current_cid
    echo $PID > current_pid
}

del(){
    export CNI_COMMAND=DEL
    export CNI_CONTAINERID=`cat current_cid` # generate by kubectl
    export CNI_NETNS=/proc/`cat current_pid`/ns/net
    export CNI_IFNAME=eth0
}

check(){
    export CNI_COMMAND=CHECK
}

case $1 in
add)
    add
;;
del)
    del
;;

check)
    check
;;
version)
    export CNI_COMMAND=VERSION
;;

esac

sh -x demo < 10-demo.conf

#!/bin/sh
# Shapes (does not police!) incoming SMB: traffic to port 445 goes through ifb0 + HTB.
# Policing dropped 12% of packets and TCP fell to ~2.7 MB/s (27.10.2026); a queue holds the rate without loss.
# Why at all: Time Machine writes faster than rclone uploads to Drive; without this the
# guard has to pause the backup over and over, and Time Machine reports every pause as an interruption.
RATE="${RATE:-320mbit}"
case "$1" in
  start)
    modprobe ifb numifbs=1 2>/dev/null || modprobe ifb
    ip link show ifb0 >/dev/null 2>&1 || ip link add ifb0 type ifb
    ip link set ifb0 up
    tc qdisc del dev lima0 ingress 2>/dev/null; tc qdisc del dev ifb0 root 2>/dev/null
    tc qdisc add dev lima0 handle ffff: ingress
    tc filter add dev lima0 parent ffff: protocol ip prio 1 u32 match ip dport 445 0xffff action mirred egress redirect dev ifb0
    tc qdisc add dev ifb0 root handle 1: htb default 10 r2q 100
    tc class add dev ifb0 parent 1: classid 1:10 htb rate "$RATE" ceil "$RATE" burst 1mb
    tc qdisc add dev ifb0 parent 1:10 handle 10: fq_codel ;;
  stop)
    tc qdisc del dev lima0 ingress 2>/dev/null; tc qdisc del dev ifb0 root 2>/dev/null; true ;;
esac

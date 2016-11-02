#!/bin/bash

:<<NAT
1.define value ;
2.set ip forwad;
3.set firewall;
NAT

CONFIG_PATH=/proc/sys/net/ipv4/
IP_FORWARD=ip_forward
COMMAND=iptables
INPUT_FLAG=INPUT
FORWARD_FLAG=FORWARD



set_ip_forward(){
	if test -z $1; then
		echo "invalid argument"
	else
		BOOL=$1
		echo $BOOL > $CONFIG_PATH$IP_FORWARD
	fi
}

set_firewall(){
	$COMMAND -F
	$COMMAND -P $INPUT_FLAG ACCEPT
	$COMMAND -P $FORWARD_FLAG ACCEPT
	$COMMAND -t nat -A POSTROUTING -o eth5 -j MASQUERADE
}

set_ip_forward $1
set_firewall

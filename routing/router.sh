#!/bin/bash

set -eux

sleep 1

sysctl -w net.ipv4.ip_forward=1

ip addr add 192.168.2.2/24 dev eth0
ip addr add 192.168.1.1/24 dev eth1

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

sleep infinity

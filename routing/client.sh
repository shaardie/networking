#!/bin/bash

set -eux

sleep 1

ip addr add 192.168.1.2/24 dev eth0
ip route add default via 192.168.1.1 dev eth0

ping 192.168.2.1

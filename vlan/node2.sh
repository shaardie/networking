#!/bin/bash

set -eux

# wait for the setup to finish
while ! ip link show dev eth0 &>/dev/null; do
  sleep 0.1
done

# create virtual vlan 10 interface and set its ip address and activate it
ip link add link eth0 name eth0.10 type vlan id 10
ip link set eth0.10 up
ip addr add 192.168.1.2/24 dev eth0.10

# create virtual vlan 20 interface and set its ip address and activate it
ip link add link eth0 name eth0.20 type vlan id 20
ip link set eth0.20 up
ip addr add 192.168.2.2/24 dev eth0.20

# Keep container running
sleep infinity

#!/bin/bash

set -eux

# wait for the setup to finish
while ! ip link show dev eth0 &>/dev/null; do
  sleep 0.1
done

# create virtual vlan interface
ip link add link eth0 name eth0.10 type vlan id 10
ip link set eth0.10 up

# Set the IP address for the client
ip addr add 192.168.1.2/24 dev eth0.10

# Keep container running
sleep infinity

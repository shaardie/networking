#!/bin/bash

set -eux

# wait for the setup to finish
while ! ip link show dev eth0 &>/dev/null; do
  sleep 0.1
done
while ! ip link show dev eth1 &>/dev/null; do
  sleep 0.1
done

# Enable forwarding packages between different interfaces
sysctl -w net.ipv4.ip_forward=1

# Set the IP address to communicate with the network of node1
ip addr add 192.168.1.1/24 dev eth0

# Set the IP address to communicate with the network of node2
ip addr add 192.168.2.1/24 dev eth1

# Wait to keep the container running
sleep infinity

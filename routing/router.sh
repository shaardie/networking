#!/bin/bash

set -eux

# wait for the setup to finish
sleep 1

# Enable forwarding packages between different interfaces
sysctl -w net.ipv4.ip_forward=1

# Set the IP address to communicate with the internet
ip addr add 192.168.2.2/24 dev eth0

# Set the IP address to commicate with internal ip address
ip addr add 192.168.1.1/24 dev eth1

# NAT packages to the internet
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Wait to keep the container running
sleep infinity

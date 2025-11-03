#!/bin/bash

set -eux

# wait for the setup to finish
while ! ip link show dev eth0 &>/dev/null; do
  sleep 0.1
done
while ! ip link show dev eth1 &>/dev/null; do
  sleep 0.1
done
while ! ip link show dev eth2 &>/dev/null; do
  sleep 0.1
done
while ! ip link show dev eth3 &>/dev/null; do
  sleep 0.1
done

# Create bridge
ip link add name br0 type bridge

# Add Ports to bridge
ip link set eth0 master br0
ip link set eth1 master br0
ip link set eth2 master br0
ip link set eth3 master br0

# Set VLANs
bridge vlan add dev eth0 vid 10 pvid untagged
bridge vlan add dev eth1 vid 10 pvid untagged
bridge vlan add dev eth2 vid 20 pvid untagged
bridge vlan add dev eth3 vid 20 pvid untagged

# Activate bridge
ip link set br0 up

# Keep container running
sleep infinity

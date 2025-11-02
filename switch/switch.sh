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

# Ports hinzufügen
ip link set eth0 master br0
ip link set eth1 master br0
ip link set eth2 master br0
ip link set eth3 master br0

# Bridge aktivieren
ip link set br0 up
# sudo ip link set eth0 up
# sudo ip link set eth1 up
# sudo ip link set eth1 up
# sudo ip link set eth1 up

# Keep container running
sleep infinity

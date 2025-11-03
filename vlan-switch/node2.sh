#!/bin/bash

set -eux

# wait for the setup to finish
while ! ip link show dev eth0 &>/dev/null; do
  sleep 0.1
done

# Set the IP address for the client
ip addr add 192.168.1.2/24 dev eth0

# Keep container running
sleep infinity

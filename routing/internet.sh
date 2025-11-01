#!/bin/bash

set -eux

# wait for the setup to finish
sleep 1

# Set the IP address for the internet
ip addr add 192.168.2.1/24 dev eth0

# Wait to keep the container running
sleep infinity

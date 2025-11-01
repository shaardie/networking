#!/bin/bash

set -eux

# wait for the setup to finish
sleep 1

# Set the IP address for the client
ip addr add 192.168.1.2/24 dev eth0

# Set the default route to the router ip
ip route add default via 192.168.1.1 dev eth0

# ping the address in the internet
ping 192.168.2.1

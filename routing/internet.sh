#!/bin/bash

set -eux

sleep 1

ip addr add 192.168.2.1/24 dev eth0

sleep infinity

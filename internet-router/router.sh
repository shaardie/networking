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
ip addr add 192.168.1.1/24 dev eth1

cat <<EOF >/etc/nftables.conf
flush ruleset

# NAT table for source NAT (masquerading)
table ip nat {

    # Postrouting chain: NAT happens after routing decision
    chain postrouting {
        type nat hook postrouting priority 100;

        # Masquerade traffic leaving via WAN interface (eth0)
        # This rewrites the source IP to the interface's public IP
        oifname "eth0" masquerade
    }
}
EOF
nft -f /etc/nftables.conf

# Wait to keep the container running
sleep infinity

# VLAN

Sometimes we want to split our physical network into multiple parts, because we do not want all nodes to communicate with each other directly via Layer 2.
Think for example, that you have your network with several IOT Devices, workstations and servers.
Maybe IOT Devices should not *see* the workstations and the servers or you want to have hard firewall rules which workstation can see which service on which server and want all the traffic to not go directly between the workstations and the servers, but through your firewall.
In this case you can either re-wire your physical connections that way or our can split your network on Layer 2 using [VLANs](https://en.wikipedia.org/wiki/VLAN) into multiple virtual networks.
Traffic passing the underlying Layer 2 Network are getting *tagged* with a *VLAN ID*, usually a number between 1 and 4095 and you can filter the traffic on several points in your network based on this ID.

The Linux network stack does already support VLAN and in this setup we take a setup similar to [Direct Connection](/direct-connection/Readme.md), but send traffic in multiple VLANs between the nodes.

Just as a reminder once again the CONTAINERlab setup, we are using:

```yaml
name: vlan
topology:
  nodes:
    node1:
      kind: linux
      image: ghcr.io/shaardie/networking:latest
      network-mode: none
      binds:
        - ./node1.sh:/run.sh
      cmd: bash /run.sh
    node2:
      kind: linux
      image: ghcr.io/shaardie/networking:latest
      network-mode: none
      binds:
        - ./node2.sh:/run.sh
      cmd: bash /run.sh
  links:
    - endpoints: ["node1:eth0","node2:eth0"]
```

So our goal is now to have two different Layer 2 and Layer 3 connection between these to nodes. On with `VLAN 10` and the network `192.168.1.0/24` and one with `VLAN 20` and the network `192.168.2.0/24`.

Let's take an exemplarily look at the setup for `node1`:

```bash
#!/bin/bash

set -eux

# wait for the setup to finish
while ! ip link show dev eth0 &>/dev/null; do
  sleep 0.1
done

# create virtual vlan 10 interface and set its ip address and activate it
ip link add link eth0 name eth0.10 type vlan id 10
ip link set eth0.10 up
ip addr add 192.168.1.1/24 dev eth0.10

# create virtual vlan 20 interface and set its ip address and activate it
ip link add link eth0 name eth0.20 type vlan id 20
ip link set eth0.20 up
ip addr add 192.168.2.1/24 dev eth0.20

# Keep container running
sleep infinity
```

We create two *virtual interfaces* and assign them their VLAN ID.
The name indicates the physical interface these virtual interfaces are attached to.
So in this case they are both attached to `eth0`.

The setup for `node2` is the same, but we assign the IP addresses `192.168.1.2` and `192.168.2.2`.


```bash
❯ docker exec -it clab-vlan-node1 ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host proto kernel_lo
       valid_lft forever preferred_lft forever
2: eth0.10@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue state UP group default qlen 1000
    link/ether aa:c1:ab:3b:bc:40 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.1/24 scope global eth0.10
       valid_lft forever preferred_lft forever
    inet6 fe80::a8c1:abff:fe3b:bc40/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
20: eth0@if21: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue state UP group default
    link/ether aa:c1:ab:3b:bc:40 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::a8c1:abff:fe3b:bc40/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever

❯ docker exec clab-direct-connection-node1 ip address show dev eth0
28: eth0@if27: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue state UP group default
    link/ether aa:c1:ab:83:48:2a brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet 192.168.1.1/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a8c1:abff:fe83:482a/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever

❯ docker exec -it clab-vlan-node1 tcpdump -i eth0 -e not ip6
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
16:10:22.181660 aa:c1:ab:56:6d:cd (oui Unknown) > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 10, p 0, ethertype ARP (0x0806), Request who-has 192.168.1.2 tell 192.168.1.1, length 28
16:10:22.181694 aa:c1:ab:0b:ba:e8 (oui Unknown) > aa:c1:ab:56:6d:cd (oui Unknown), ethertype 802.1Q (0x8100), length 46: vlan 10, p 0, ethertype ARP (0x0806), Reply 192.168.1.2 is-at aa:c1:ab:0b:ba:e8 (oui Unknown), length 28
16:10:22.181698 aa:c1:ab:56:6d:cd (oui Unknown) > aa:c1:ab:0b:ba:e8 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4 (0x0800), 192.168.1.1 > 192.168.1.2: ICMP echo request, id 20, seq 0, length 64
16:10:22.181714 aa:c1:ab:0b:ba:e8 (oui Unknown) > aa:c1:ab:56:6d:cd (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4 (0x0800), 192.168.1.2 > 192.168.1.1: ICMP echo reply, id 20, seq 0, length 64
16:10:27.474373 aa:c1:ab:0b:ba:e8 (oui Unknown) > aa:c1:ab:56:6d:cd (oui Unknown), ethertype 802.1Q (0x8100), length 46: vlan 10, p 0, ethertype ARP (0x0806), Request who-has 192.168.1.1 tell 192.168.1.2, length 28
16:10:27.474409 aa:c1:ab:56:6d:cd (oui Unknown) > aa:c1:ab:0b:ba:e8 (oui Unknown), ethertype 802.1Q (0x8100), length 46: vlan 10, p 0, ethertype ARP (0x0806), Reply 192.168.1.1 is-at aa:c1:ab:56:6d:cd (oui Unknown), length 28

 ❯ docker exec -it clab-vlan-node2 tcpdump -i eth0 not ip6 -e
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
16:10:22.181667 aa:c1:ab:56:6d:cd (oui Unknown) > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 10, p 0, ethertype ARP (0x0806), Request who-has 192.168.1.2 tell 192.168.1.1, length 28
16:10:22.181693 aa:c1:ab:0b:ba:e8 (oui Unknown) > aa:c1:ab:56:6d:cd (oui Unknown), ethertype 802.1Q (0x8100), length 46: vlan 10, p 0, ethertype ARP (0x0806), Reply 192.168.1.2 is-at aa:c1:ab:0b:ba:e8 (oui Unknown), length 28
16:10:22.181699 aa:c1:ab:56:6d:cd (oui Unknown) > aa:c1:ab:0b:ba:e8 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4 (0x0800), 192.168.1.1 > 192.168.1.2: ICMP echo request, id 20, seq 0, length 64
16:10:22.181714 aa:c1:ab:0b:ba:e8 (oui Unknown) > aa:c1:ab:56:6d:cd (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4 (0x0800), 192.168.1.2 > 192.168.1.1: ICMP echo reply, id 20, seq 0, length 64
16:10:27.474368 aa:c1:ab:0b:ba:e8 (oui Unknown) > aa:c1:ab:56:6d:cd (oui Unknown), ethertype 802.1Q (0x8100), length 46: vlan 10, p 0, ethertype ARP (0x0806), Request who-has 192.168.1.1 tell 192.168.1.2, length 28
16:10:27.474409 aa:c1:ab:56:6d:cd (oui Unknown) > aa:c1:ab:0b:ba:e8 (oui Unknown), ethertype 802.1Q (0x8100), length 46: vlan 10, p 0, ethertype ARP (0x0806), Reply 192.168.1.1 is-at aa:c1:ab:56:6d:cd (oui Unknown), length 28
```

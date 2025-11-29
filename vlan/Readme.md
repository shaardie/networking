# VLAN

Sometimes we want to split our physical network into multiple parts, because we do not want all nodes to communicate with each other directly via Layer 2.
Think, for example, that you have a network with several IoT devices, workstations, and servers.
Maybe the IoT devices should not *see* the workstations and the servers, or you want to have strict firewall rules that control which workstations can access which services on which servers, ensuring all traffic passes through your firewall instead of flowing directly between workstations and servers.
In this case you can either re-wire your physical connections that way or you can split your network on Layer 2 using [VLANs](https://en.wikipedia.org/wiki/VLAN) into multiple virtual networks.
Traffic passing through the underlying Layer 2 network is *tagged* with a *VLAN ID*, usually a number between 1 and 4095, and you can filter the traffic at various points in your network based on this ID.

The Linux network stack already supports VLANs, and in this setup we create a configuration similar to [Direct Connection](/direct-connection/Readme.md), but send traffic in multiple VLANs between the nodes.

Just as a reminder, here is the CONTAINERlab setup we are using:

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

So our goal is now to have two different Layer 2 and Layer 3 connections between these two nodes. One with `VLAN 10` and the network `192.168.1.0/24` and one with `VLAN 20` and the network `192.168.2.0/24`.

Let's take a look at the setup for `node1` as an example:

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
The name indicates which physical interface these virtual interfaces are attached to.
So in this case they are both attached to `eth0`.

The setup for `node2` is the same, but we assign the IP addresses `192.168.1.2` and `192.168.2.2`.

If we take a look at the setup of `node1`, we see the two new virtual interfaces and their configuration:

```bash
❯ docker exec -it clab-vlan-node1 ip address show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host proto kernel_lo
       valid_lft forever preferred_lft forever
2: eth0.10@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue state UP group default qlen 1000
    link/ether aa:c1:ab:65:92:cf brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.1/24 scope global eth0.10
       valid_lft forever preferred_lft forever
    inet6 fe80::a8c1:abff:fe65:92cf/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
3: eth0.20@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue state UP group default qlen 1000
    link/ether aa:c1:ab:65:92:cf brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.1/24 scope global eth0.20
       valid_lft forever preferred_lft forever
    inet6 fe80::a8c1:abff:fe65:92cf/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
9: eth0@if8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue state UP group default
    link/ether aa:c1:ab:65:92:cf brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::a8c1:abff:fe65:92cf/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
```

So let's send an ICMP packet from `node1` to `node2` via VLAN 10:

```bash
❯ docker exec -it clab-vlan-node1 ping -c 1 192.168.1.2
PING 192.168.1.2 (192.168.1.2): 56 data bytes
64 bytes from 192.168.1.2: icmp_seq=0 ttl=64 time=0.093 ms
--- 192.168.1.2 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.093/0.093/0.093/0.000 ms
```

If we look at the traffic on the virtual interfaces, the VLAN is completely transparent and it looks the same as in [Direct Connection](../direct-connection/Readme.md):

```bash
❯ docker exec -it clab-vlan-node1 tcpdump -i eth0.10 -e not ip6
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0.10, link-type EN10MB (Ethernet), snapshot length 262144 bytes
18:27:25.319208 aa:c1:ab:65:92:cf (oui Unknown) > Broadcast, ethertype ARP (0x0806), length 42: Request who-has 192.168.1.2 tell 192.168.1.1, length 28
18:27:25.319238 aa:c1:ab:ae:71:fd (oui Unknown) > aa:c1:ab:65:92:cf (oui Unknown), ethertype ARP (0x0806), length 42: Reply 192.168.1.2 is-at aa:c1:ab:ae:71:fd (oui Unknown), length 28
18:27:25.319242 aa:c1:ab:65:92:cf (oui Unknown) > aa:c1:ab:ae:71:fd (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.1 > 192.168.1.2: ICMP echo request, id 35, seq 0, length 64
18:27:25.319260 aa:c1:ab:ae:71:fd (oui Unknown) > aa:c1:ab:65:92:cf (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.2 > 192.168.1.1: ICMP echo reply, id 35, seq 0, length 64

❯ docker exec -it clab-vlan-node2 tcpdump -i eth0.10 -e not ip6
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0.10, link-type EN10MB (Ethernet), snapshot length 262144 bytes
18:27:25.319217 aa:c1:ab:65:92:cf (oui Unknown) > Broadcast, ethertype ARP (0x0806), length 42: Request who-has 192.168.1.2 tell 192.168.1.1, length 28
18:27:25.319236 aa:c1:ab:ae:71:fd (oui Unknown) > aa:c1:ab:65:92:cf (oui Unknown), ethertype ARP (0x0806), length 42: Reply 192.168.1.2 is-at aa:c1:ab:ae:71:fd (oui Unknown), length 28
18:27:25.319243 aa:c1:ab:65:92:cf (oui Unknown) > aa:c1:ab:ae:71:fd (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.1 > 192.168.1.2: ICMP echo request, id 35, seq 0, length 64
18:27:25.319258 aa:c1:ab:ae:71:fd (oui Unknown) > aa:c1:ab:65:92:cf (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.2 > 192.168.1.1: ICMP echo reply, id 35, seq 0, length 64
```

But if we take a look at the traffic on the `eth0` interfaces, we can see that the VLAN ID is attached to the Layer 2 information of the packets:

```bash
❯ docker exec -it clab-vlan-node1 tcpdump -i eth0 -e not ip6
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
18:27:25.319213 aa:c1:ab:65:92:cf (oui Unknown) > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 10, p 0, ethertype ARP (0x0806), Request who-has 192.168.1.2 tell 192.168.1.1, length 28
18:27:25.319238 aa:c1:ab:ae:71:fd (oui Unknown) > aa:c1:ab:65:92:cf (oui Unknown), ethertype 802.1Q (0x8100), length 46: vlan 10, p 0, ethertype ARP (0x0806), Reply 192.168.1.2 is-at aa:c1:ab:ae:71:fd (oui Unknown), length 28
18:27:25.319243 aa:c1:ab:65:92:cf (oui Unknown) > aa:c1:ab:ae:71:fd (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4 (0x0800), 192.168.1.1 > 192.168.1.2: ICMP echo request, id 35, seq 0, length 64
18:27:25.319260 aa:c1:ab:ae:71:fd (oui Unknown) > aa:c1:ab:65:92:cf (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4 (0x0800), 192.168.1.2 > 192.168.1.1: ICMP echo reply, id 35, seq 0, length 64

❯ docker exec -it clab-vlan-node2 tcpdump -i eth0 -e not ip6
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
18:27:25.319217 aa:c1:ab:65:92:cf (oui Unknown) > Broadcast, ethertype 802.1Q (0x8100), length 46: vlan 10, p 0, ethertype ARP (0x0806), Request who-has 192.168.1.2 tell 192.168.1.1, length 28
18:27:25.319237 aa:c1:ab:ae:71:fd (oui Unknown) > aa:c1:ab:65:92:cf (oui Unknown), ethertype 802.1Q (0x8100), length 46: vlan 10, p 0, ethertype ARP (0x0806), Reply 192.168.1.2 is-at aa:c1:ab:ae:71:fd (oui Unknown), length 28
18:27:25.319243 aa:c1:ab:65:92:cf (oui Unknown) > aa:c1:ab:ae:71:fd (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4 (0x0800), 192.168.1.1 > 192.168.1.2: ICMP echo request, id 35, seq 0, length 64
18:27:25.319259 aa:c1:ab:ae:71:fd (oui Unknown) > aa:c1:ab:65:92:cf (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 10, p 0, ethertype IPv4 (0x0800), 192.168.1.2 > 192.168.1.1: ICMP echo reply, id 35, seq 0, length 64
```

This way the traffic between the nodes is identifiable as traffic within the VLAN 10 and therefore we can properly separate them.

This would look the same for traffic within the VLAN 20 between the nodes.

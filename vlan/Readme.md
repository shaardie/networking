# VLAN

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

# Direct Connection

It does not really get more basic than a direct connection between to machines.
So this is our starting point.

```bash
❯ docker exec clab-direct-connection-node1 ip address show dev eth0
28: eth0@if27: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue state UP group default
    link/ether aa:c1:ab:83:48:2a brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet 192.168.1.1/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a8c1:abff:fe83:482a/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever

❯ docker exec clab-direct-connection-node1 ping -c 1 192.168.1.2
PING 192.168.1.2 (192.168.1.2): 56 data bytes
64 bytes from 192.168.1.2: icmp_seq=0 ttl=64 time=0.087 ms
--- 192.168.1.2 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.087/0.087/0.087/0.000 ms

❯ docker exec clab-direct-connection-node1 ip neigh
192.168.1.2 dev eth0 lladdr aa:c1:ab:af:62:4c STAL

❯ docker exec -it clab-direct-connection-node1 tcpdump -i eth0
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
20:56:05.148583 ARP, Request who-has 192.168.1.2 tell 192.168.1.1, length 28
20:56:05.148606 ARP, Reply 192.168.1.2 is-at aa:c1:ab:af:62:4c (oui Unknown), length 28
20:56:05.148610 IP 192.168.1.1 > 192.168.1.2: ICMP echo request, id 18, seq 0, length 64
20:56:05.148625 IP 192.168.1.2 > 192.168.1.1: ICMP echo reply, id 18, seq 0, length 64

❯ docker exec -it clab-direct-connection-node2 tcpdump -i eth0
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
20:56:05.148587 ARP, Request who-has 192.168.1.2 tell 192.168.1.1, length 28
20:56:05.148605 ARP, Reply 192.168.1.2 is-at aa:c1:ab:af:62:4c (oui Unknown), length 28
20:56:05.148611 IP 192.168.1.1 > 192.168.1.2: ICMP echo request, id 18, seq 0, length 64
20:56:05.148624 IP 192.168.1.2 > 192.168.1.1: ICMP echo reply, id 18, seq 0, length 64
```

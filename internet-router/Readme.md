# Internet Router

```bash
❯ docker exec -it clab-routing-node1 ip route
192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.2
192.168.2.0/24 via 192.168.1.1 dev eth0

❯ docker exec -it clab-routing-router ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host proto kernel_lo
       valid_lft forever preferred_lft forever
42: eth0@if41: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue state UP group default
    link/ether aa:c1:ab:a2:72:96 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet 192.168.1.1/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a8c1:abff:fea2:7296/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
44: eth1@if43: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue state UP group default
    link/ether aa:c1:ab:5e:d1:41 brd ff:ff:ff:ff:ff:ff link-netnsid 2
    inet 192.168.2.1/24 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a8c1:abff:fe5e:d141/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever

❯ docker exec -it clab-internet-router-router tcpdump -i any -nne not ip6
tcpdump: WARNING: any: That device doesn't support promiscuous mode
(Promiscuous mode not supported on the "any" device)
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
20:14:34.447660 eth0  M   ifindex 2 5e:5d:03:a7:a8:2d ethertype IPv4 (0x0800), length 241: 172.20.20.1.5353 > 224.0.0.251.5353: 0*- [0q] 4/0/0 (Cache flush) PTR cithaardiek.local., (Cache flush) A 172.20.20.1, (Cache flush) PTR cithaardiek.local., (Cache flush) AAAA 3fff:172:20:20::1 (193)
20:14:39.656388 eth1  B   ifindex 73 aa:c1:ab:78:94:46 ethertype ARP (0x0806), length 48: Request who-has 192.168.1.1 tell 192.168.1.2, length 28
20:14:39.656417 eth1  Out ifindex 73 aa:c1:ab:b6:62:2a ethertype ARP (0x0806), length 48: Reply 192.168.1.1 is-at aa:c1:ab:b6:62:2a, length 28
20:14:39.656419 eth1  In  ifindex 73 aa:c1:ab:78:94:46 ethertype IPv4 (0x0800), length 104: 192.168.1.2 > 1.1.1.1: ICMP echo request, id 13, seq 0, length 64
20:14:39.656442 eth0  Out ifindex 2 72:90:57:eb:55:26 ethertype ARP (0x0806), length 48: Request who-has 172.20.20.1 tell 172.20.20.2, length 28
20:14:39.656458 eth0  In  ifindex 2 5e:5d:03:a7:a8:2d ethertype ARP (0x0806), length 48: Reply 172.20.20.1 is-at 5e:5d:03:a7:a8:2d, length 28
20:14:39.656459 eth0  Out ifindex 2 72:90:57:eb:55:26 ethertype IPv4 (0x0800), length 104: 172.20.20.2 > 1.1.1.1: ICMP echo request, id 13, seq 0, length 64
20:14:39.680655 eth0  In  ifindex 2 5e:5d:03:a7:a8:2d ethertype IPv4 (0x0800), length 104: 1.1.1.1 > 172.20.20.2: ICMP echo reply, id 13, seq 0, length 64
20:14:39.680671 eth1  Out ifindex 73 aa:c1:ab:b6:62:2a ethertype IPv4 (0x0800), length 104: 1.1.1.1 > 192.168.1.2: ICMP echo reply, id 13, seq 0, length 64
20:14:45.010431 eth1  Out ifindex 73 aa:c1:ab:b6:62:2a ethertype ARP (0x0806), length 48: Request who-has 192.168.1.2 tell 192.168.1.1, length 28
20:14:45.010464 eth0  In  ifindex 2 5e:5d:03:a7:a8:2d ethertype ARP (0x0806), length 48: Request who-has 172.20.20.2 tell 172.20.20.1, length 28
20:14:45.010530 eth0  Out ifindex 2 72:90:57:eb:55:26 ethertype ARP (0x0806), length 48: Reply 172.20.20.2 is-at 72:90:57:eb:55:26, length 28
20:14:45.010521 eth1  In  ifindex 73 aa:c1:ab:78:94:46 ethertype ARP (0x0806), length 48: Reply 192.168.1.2 is-at aa:c1:ab:78:94:46, length 28

❯ docker exec -it clab-internet-router-node1 ping 1.1.1.1 -c 1
PING 1.1.1.1 (1.1.1.1): 56 data bytes
64 bytes from 1.1.1.1: icmp_seq=0 ttl=54 time=24.936 ms
--- 1.1.1.1 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max/stddev = 24.936/24.936/24.936/0.000 ms
```

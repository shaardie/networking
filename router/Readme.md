# Router

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

❯ docker exec -it clab-routing-node1 ping 192.168.2.2 -c 1
PING 192.168.2.2 (192.168.2.2): 56 data bytes
64 bytes from 192.168.2.2: icmp_seq=0 ttl=63 time=0.168 ms
--- 192.168.2.2 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.168/0.168/0.168/0.000 ms

❯ docker exec -it clab-routing-router tcpdump -i any -e not ip6
tcpdump: WARNING: any: That device doesn't support promiscuous mode
(Promiscuous mode not supported on the "any" device)
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
16:44:58.570724 eth0  B   ifindex 42 aa:c1:ab:36:fe:43 (oui Unknown) ethertype ARP (0x0806), length 48: Request who-has 192.168.1.1 tell 192.168.1.2, length 28
16:44:58.570747 eth0  Out ifindex 42 aa:c1:ab:a2:72:96 (oui Unknown) ethertype ARP (0x0806), length 48: Reply 192.168.1.1 is-at aa:c1:ab:a2:72:96 (oui Unknown), length 28
16:44:58.570751 eth0  In  ifindex 42 aa:c1:ab:36:fe:43 (oui Unknown) ethertype IPv4 (0x0800), length 104: 192.168.1.2 > 192.168.2.2: ICMP echo request, id 13, seq 0, length 64
16:44:58.570760 eth1  Out ifindex 44 aa:c1:ab:5e:d1:41 (oui Unknown) ethertype ARP (0x0806), length 48: Request who-has 192.168.2.2 tell 192.168.2.1, length 28
16:44:58.570765 eth1  In  ifindex 44 aa:c1:ab:bd:53:4d (oui Unknown) ethertype ARP (0x0806), length 48: Reply 192.168.2.2 is-at aa:c1:ab:bd:53:4d (oui Unknown), length 28
16:44:58.570767 eth1  Out ifindex 44 aa:c1:ab:5e:d1:41 (oui Unknown) ethertype IPv4 (0x0800), length 104: 192.168.1.2 > 192.168.2.2: ICMP echo request, id 13, seq 0, length 64
16:44:58.570776 eth1  In  ifindex 44 aa:c1:ab:bd:53:4d (oui Unknown) ethertype IPv4 (0x0800), length 104: 192.168.2.2 > 192.168.1.2: ICMP echo reply, id 13, seq 0, length 64
16:44:58.570779 eth0  Out ifindex 42 aa:c1:ab:a2:72:96 (oui Unknown) ethertype IPv4 (0x0800), length 104: 192.168.2.2 > 192.168.1.2: ICMP echo reply, id 13, seq 0, length 64
```

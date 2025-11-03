# Direct Connection

```bash
❯ docker exec -it clab-switch-switch ip address show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host proto kernel_lo
       valid_lft forever preferred_lft forever
2: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue state UP group default qlen 1000
    link/ether aa:c1:ab:44:59:f3 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::a8c1:abff:fe44:59f3/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
40: eth0@if39: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue master br0 state UP group default
    link/ether aa:c1:ab:5a:34:d3 brd ff:ff:ff:ff:ff:ff link-netnsid 2
    inet6 fe80::a8c1:abff:fe5a:34d3/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
42: eth1@if41: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue master br0 state UP group default
    link/ether aa:c1:ab:92:71:04 brd ff:ff:ff:ff:ff:ff link-netnsid 3
    inet6 fe80::a8c1:abff:fe92:7104/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
44: eth2@if43: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue master br0 state UP group default
    link/ether aa:c1:ab:44:59:f3 brd ff:ff:ff:ff:ff:ff link-netnsid 4
    inet6 fe80::a8c1:abff:fe44:59f3/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
46: eth3@if45: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue master br0 state UP group default
    link/ether aa:c1:ab:e9:be:66 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::a8c1:abff:fee9:be66/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever

# first time
❯ docker exec -it clab-switch-switch tcpdump -i any not ip6
tcpdump: WARNING: any: That device doesn't support promiscuous mode
(Promiscuous mode not supported on the "any" device)
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
08:15:14.135669 eth0  B   ARP, Request who-has 192.168.1.3 tell 192.168.1.1, length 28
08:15:14.135709 eth3  Out ARP, Request who-has 192.168.1.3 tell 192.168.1.1, length 28
08:15:14.135713 eth2  Out ARP, Request who-has 192.168.1.3 tell 192.168.1.1, length 28
08:15:14.135716 eth1  Out ARP, Request who-has 192.168.1.3 tell 192.168.1.1, length 28
08:15:14.135669 br0   B   ARP, Request who-has 192.168.1.3 tell 192.168.1.1, length 28
08:15:14.135752 eth2  P   ARP, Reply 192.168.1.3 is-at aa:c1:ab:95:1a:d1 (oui Unknown), length 28
08:15:14.135759 eth0  Out ARP, Reply 192.168.1.3 is-at aa:c1:ab:95:1a:d1 (oui Unknown), length 28
08:15:14.135764 eth0  P   IP 192.168.1.1 > 192.168.1.3: ICMP echo request, id 12, seq 0, length 64
08:15:14.135767 eth2  Out IP 192.168.1.1 > 192.168.1.3: ICMP echo request, id 12, seq 0, length 64
08:15:14.135783 eth2  P   IP 192.168.1.3 > 192.168.1.1: ICMP echo reply, id 12, seq 0, length 64
08:15:14.135785 eth0  Out IP 192.168.1.3 > 192.168.1.1: ICMP echo reply, id 12, seq 0, length 64

# later
❯ docker exec -it clab-switch-switch tcpdump -i any not ip6
tcpdump: WARNING: any: That device doesn't support promiscuous mode
(Promiscuous mode not supported on the "any" device)
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
08:21:30.516324 eth0  P   IP 192.168.1.1 > 192.168.1.3: ICMP echo request, id 18, seq 0, length 64
08:21:30.516345 eth2  Out IP 192.168.1.1 > 192.168.1.3: ICMP echo request, id 18, seq 0, length 64
08:21:30.516375 eth2  P   IP 192.168.1.3 > 192.168.1.1: ICMP echo reply, id 18, seq 0, length 64
08:21:30.516377 eth0  Out IP 192.168.1.3 > 192.168.1.1: ICMP echo reply, id 18, seq 0, length 64
08:21:35.138852 eth0  P   IP 192.168.1.1 > 192.168.1.3: ICMP echo request, id 24, seq 0, length 64
08:21:35.138892 eth2  Out IP 192.168.1.1 > 192.168.1.3: ICMP echo request, id 24, seq 0, length 64
08:21:35.138914 eth2  P   IP 192.168.1.3 > 192.168.1.1: ICMP echo reply, id 24, seq 0, length 64
08:21:35.138917 eth0  Out IP 192.168.1.3 > 192.168.1.1: ICMP echo reply, id 24, seq 0, length 64
08:21:35.797465 eth2  P   ARP, Request who-has 192.168.1.1 tell 192.168.1.3, length 28
08:21:35.797555 eth0  Out ARP, Request who-has 192.168.1.1 tell 192.168.1.3, length 28
08:21:35.797492 eth0  P   ARP, Request who-has 192.168.1.3 tell 192.168.1.1, length 28
08:21:35.797562 eth2  Out ARP, Request who-has 192.168.1.3 tell 192.168.1.1, length 28
08:21:35.797582 eth0  P   ARP, Reply 192.168.1.1 is-at aa:c1:ab:9f:93:91 (oui Unknown), length 28
08:21:35.797590 eth2  Out ARP, Reply 192.168.1.1 is-at aa:c1:ab:9f:93:91 (oui Unknown), length 28
08:21:35.797588 eth2  P   ARP, Reply 192.168.1.3 is-at aa:c1:ab:95:1a:d1 (oui Unknown), length 28
08:21:35.797592 eth0  Out ARP, Reply 192.168.1.3 is-at aa:c1:ab:95:1a:d1 (oui Unknown), length 28

❯ docker exec -it clab-switch-node1 ping 192.168.1.3 -c 1
PING 192.168.1.3 (192.168.1.3): 56 data bytes
64 bytes from 192.168.1.3: icmp_seq=0 ttl=64 time=0.179 ms
--- 192.168.1.3 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.179/0.179/0.179/0.000 ms
```

# Networking

Networking can be challenging - even if you learned it at school or university.

When I discovered the tool [containerlab](https://containerlab.dev/), which makes it easy to create complex networking environments inside containers, I wanted to start building some examples and explain how they work.

I decided to use simple [Debian](https://www.debian.org/) containers as a base, rather than any fancy network operating system, so you can focus on learning the basics of Linux network configuration.

## Who is this for?

This repository is aimed at people who already have some experience with Linux and containers, and who might have learned the basics of networking at some point. 

The goal here is not to teach Linux or container fundamentals, but to provide **practical examples** that help you understand common networking structures in a hands-on way.

## Tooling

Base of all our different setups is [CONTAINERlab](https://containerlab.dev/).
It lets you create quite complex networking structures without any physical hardware or cables.
We are using it on top of [Docker](https://www.docker.com/) to create a bunch of different containers between which we can define network connections.
The configuration is done via a [YAML](https://yaml.org/) file and is pretty similar to [Docker Compose](https://docs.docker.com/compose/).
I will not go into details about the configuration, but explain the ideas of the different setups.
CONTAINERlab can do many things more and you can spin up complex environment even with different network operating systems, so if you want to know more about that, check it our yourself.

Next to CONTAINERlab we are pretty much only using bash scripts and basic linux networking tools to create our setups.
I mean, this is more or less the whole idea of this thing.

There are some networking tools, we will use quite often which are not part of the setup itself, but helps us analyse and *see* what is happening in the network, like [tcpdump](https://www.tcpdump.org/), which can be use to acutally look at the network traffic.
It is a very powerfull tool and we will familiarize ourself with some, but not all, of its functionality along the way.


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

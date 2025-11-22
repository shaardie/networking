# Switch

Most of the time, we want to have more than two nodes to communicate with each other in our layer 2 network.
In this case we often connect all of our nodes to a single or multiple switches, which sends to packets to the correct node.
But how does such a switch works?
We will find that out in this setup by creating our own switch.

So first lets take a look at our CONTAINERlab setup by taking a look at the [switch.clab.yml](./switch.clab.yml):

```yaml
name: switch
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
    node3:
      kind: linux
      image: ghcr.io/shaardie/networking:latest
      network-mode: none
      binds:
        - ./node3.sh:/run.sh
      cmd: bash /run.sh
    node4:
      kind: linux
      image: ghcr.io/shaardie/networking:latest
      network-mode: none
      binds:
        - ./node4.sh:/run.sh
      cmd: bash /run.sh
    switch:
      kind: linux
      image: ghcr.io/shaardie/networking:latest
      network-mode: none
      binds:
        - ./switch.sh:/run.sh
      cmd: bash /run.sh
  links:
    - endpoints: ["switch:eth0","node1:eth0"]
    - endpoints: ["switch:eth1","node2:eth0"]
    - endpoints: ["switch:eth2","node3:eth0"]
    - endpoints: ["switch:eth3","node4:eth0"]
```

We are creating four different nodes with an interface `eth0` each and connect all of them to another node called `switch` with to the interfaces `eth0` to `eth3`.

The setups for the different nodes are straight forward as they all simply get an IPv4 assigned and thats it:

* [`node1`](./node1.sh) -> `192.168.1.1`
* [`node2`](./node2.sh) -> `192.168.1.2`
* [`node3`](./node3.sh) -> `192.168.1.3`
* [`node4`](./node4.sh) -> `192.168.1.4`

So the most interesting part is the configuration of the switch itself, so lets take a look at the [`switch.sh`](./switch.sh):

```bash
#!/bin/bash

set -eux

# wait for the setup to finish
while ! ip link show dev eth0 &>/dev/null; do
  sleep 0.1
done
while ! ip link show dev eth1 &>/dev/null; do
  sleep 0.1
done
while ! ip link show dev eth2 &>/dev/null; do
  sleep 0.1
done
while ! ip link show dev eth3 &>/dev/null; do
  sleep 0.1
done

# Create bridge
ip link add name br0 type bridge

# Add Ports to bridge
ip link set eth0 master br0
ip link set eth1 master br0
ip link set eth2 master br0
ip link set eth3 master br0

# Activate bridge
ip link set br0 up

# Keep container running
sleep infinity
```

In this config we are introducing a new concept.
We are using the `ip` command to create a [Network Bridge](https://en.wikipedia.org/wiki/Network_bridge) within the switch node.
Its a *virtual interface* which is able to forwards packets between multiple other interfaces.
after that we set it as the master of all other interfaces on the switch which attach these interfaces to the bridge.
So now the bridge is able to forward packets between the interfaces.
After that we bring the bridge to an `UP` state, so that it is running.

After we again spin up the setup with `containerlab deploy`, we can look at the configuration of the interfaces of the switch:

```bash
❯ docker exec -it clab-switch-switch ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host proto kernel_lo
       valid_lft forever preferred_lft forever
2: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue state UP group default qlen 1000
    link/ether aa:c1:ab:33:18:50 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::a8c1:abff:fe33:1850/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
6: eth0@if5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue master br0 state UP group default
    link/ether aa:c1:ab:71:75:67 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::a8c1:abff:fe71:7567/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
8: eth1@if7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue master br0 state UP group default
    link/ether aa:c1:ab:e0:29:06 brd ff:ff:ff:ff:ff:ff link-netnsid 2
    inet6 fe80::a8c1:abff:fee0:2906/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
10: eth2@if9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue master br0 state UP group default
    link/ether aa:c1:ab:69:ca:0b brd ff:ff:ff:ff:ff:ff link-netnsid 4
    inet6 fe80::a8c1:abff:fe69:ca0b/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
11: eth3@if12: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue master br0 state UP group default
    link/ether aa:c1:ab:33:18:50 brd ff:ff:ff:ff:ff:ff link-netnsid 3
    inet6 fe80::a8c1:abff:fe33:1850/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
```

We see, that the create virtual bridge interface `br0` and we see `master br0` on the interfaces `eth0` - `eth3`, which indicates that these interfaces are attached to the bridge.

Now, lets start `tcpdump` on all nodes, and check send a ping from `node1` to the IPv4 address attached to the interface of `node4`:

```bash
❯ docker exec -it clab-switch-node1 ping -c 1 192.168.1.4
PING 192.168.1.4 (192.168.1.4): 56 data bytes
64 bytes from 192.168.1.4: icmp_seq=0 ttl=64 time=0.114 ms
--- 192.168.1.4 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.114/0.114/0.114/0.000 ms
```

First of all, we see that we received and answer to our ping and therefor that the switch is working properly.

Now lets take a look at the dumps from `node1` and `node4`:

```bash
❯ docker exec -it clab-switch-node1 tcpdump -i eth0 -e not ip6
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
19:44:21.531007 aa:c1:ab:1a:4f:fe (oui Unknown) > Broadcast, ethertype ARP (0x0806), length 42: Request who-has 192.168.1.4 tell 192.168.1.1, length 28
19:44:21.531061 aa:c1:ab:9c:bc:6f (oui Unknown) > aa:c1:ab:1a:4f:fe (oui Unknown), ethertype ARP (0x0806), length 42: Reply 192.168.1.4 is-at aa:c1:ab:9c:bc:6f (oui Unknown), length 28
19:44:21.531064 aa:c1:ab:1a:4f:fe (oui Unknown) > aa:c1:ab:9c:bc:6f (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.1 > 192.168.1.4: ICMP echo request, id 16, seq 0, length 64
19:44:21.531083 aa:c1:ab:9c:bc:6f (oui Unknown) > aa:c1:ab:1a:4f:fe (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.4 > 192.168.1.1: ICMP echo reply, id 16, seq 0, length 64

❯ docker exec -it clab-switch-node4 tcpdump -i eth0 -e not ip6
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
19:44:21.531024 aa:c1:ab:1a:4f:fe (oui Unknown) > Broadcast, ethertype ARP (0x0806), length 42: Request who-has 192.168.1.4 tell 192.168.1.1, length 28
19:44:21.531046 aa:c1:ab:9c:bc:6f (oui Unknown) > aa:c1:ab:1a:4f:fe (oui Unknown), ethertype ARP (0x0806), length 42: Reply 192.168.1.4 is-at aa:c1:ab:9c:bc:6f (oui Unknown), length 28
19:44:21.531068 aa:c1:ab:1a:4f:fe (oui Unknown) > aa:c1:ab:9c:bc:6f (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.1 > 192.168.1.4: ICMP echo request, id 16, seq 0, length 64
19:44:21.531080 aa:c1:ab:9c:bc:6f (oui Unknown) > aa:c1:ab:1a:4f:fe (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.4 > 192.168.1.1: ICMP echo reply, id 16, seq 0, length 64
```

They look exactly the same as in the setup of the [direct connection](/direct-connection/Readme.md).
This is an interesting fact, because we see that a switch is completely transparent.
For the two nodes it seems like their are directly connected with nothing in between.

And last, lets take a look at the `tcpdump` from the switch.
We start multiple `tcpdump`s to see the exact traffic on each interface.
There is also an `-i any` mode for `tcpdump`, but it does not show all packets, which is fine in a lot of cases, but still dont want to miss anything for this example.

```bash
❯ docker exec -it clab-switch-switch tcpdump -i eth0 -e not ip6
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
19:44:21.531012 aa:c1:ab:1a:4f:fe (oui Unknown) > Broadcast, ethertype ARP (0x0806), length 42: Request who-has 192.168.1.4 tell 192.168.1.1, length 28
19:44:21.531061 aa:c1:ab:9c:bc:6f (oui Unknown) > aa:c1:ab:1a:4f:fe (oui Unknown), ethertype ARP (0x0806), length 42: Reply 192.168.1.4 is-at aa:c1:ab:9c:bc:6f (oui Unknown), length 28
19:44:21.531065 aa:c1:ab:1a:4f:fe (oui Unknown) > aa:c1:ab:9c:bc:6f (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.1 > 192.168.1.4: ICMP echo request, id 16, seq 0, length 64
19:44:21.531082 aa:c1:ab:9c:bc:6f (oui Unknown) > aa:c1:ab:1a:4f:fe (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.4 > 192.168.1.1: ICMP echo reply, id 16, seq 0, length 64

❯ docker exec -it clab-switch-switch tcpdump -i eth3 -e not ip6
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth3, link-type EN10MB (Ethernet), snapshot length 262144 bytes
19:44:21.531022 aa:c1:ab:1a:4f:fe (oui Unknown) > Broadcast, ethertype ARP (0x0806), length 42: Request who-has 192.168.1.4 tell 192.168.1.1, length 28
19:44:21.531052 aa:c1:ab:9c:bc:6f (oui Unknown) > aa:c1:ab:1a:4f:fe (oui Unknown), ethertype ARP (0x0806), length 42: Reply 192.168.1.4 is-at aa:c1:ab:9c:bc:6f (oui Unknown), length 28
19:44:21.531068 aa:c1:ab:1a:4f:fe (oui Unknown) > aa:c1:ab:9c:bc:6f (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.1 > 192.168.1.4: ICMP echo request, id 16, seq 0, length 64
19:44:21.531081 aa:c1:ab:9c:bc:6f (oui Unknown) > aa:c1:ab:1a:4f:fe (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.4 > 192.168.1.1: ICMP echo reply, id 16, seq 0, length 64

❯ docker exec -it clab-switch-switch tcpdump -i eth2 -e not ip6
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth2, link-type EN10MB (Ethernet), snapshot length 262144 bytes
19:44:21.531025 aa:c1:ab:1a:4f:fe (oui Unknown) > Broadcast, ethertype ARP (0x0806), length 42: Request who-has 192.168.1.4 tell 192.168.1.1, length 28
```

The traffic is mostly what we expect.
We see the exact same packets on `eth0` than we saw on `node1` and the same for `eth3` and `node4`.
The most interesting part is that we see an ARP broadcast packet also on `eth2` (and also on `eth1`, but we did not look).
The switch sends the broadcast to each attached interface, so the correct node can answer.
All other nodes can ignore the traffic.

After finishing the analysis, we can tear down the whole setup again with `containerlab destroy`.
```

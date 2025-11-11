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
    link/ether aa:c1:ab:1f:54:14 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::a8c1:abff:fe1f:5414/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
51: eth2@if52: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue master br0 state UP group default
    link/ether aa:c1:ab:c4:80:67 brd ff:ff:ff:ff:ff:ff link-netnsid 2
    inet6 fe80::a8c1:abff:fec4:8067/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
53: eth3@if54: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue master br0 state UP group default
    link/ether aa:c1:ab:a6:02:1e brd ff:ff:ff:ff:ff:ff link-netnsid 3
    inet6 fe80::a8c1:abff:fea6:21e/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
55: eth0@if56: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue master br0 state UP group default
    link/ether aa:c1:ab:1f:54:14 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::a8c1:abff:fe1f:5414/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
57: eth1@if58: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue master br0 state UP group default
    link/ether aa:c1:ab:8d:e5:fd brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::a8c1:abff:fe8d:e5fd/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever```

We see, that the create virtual bridge interface `br0` and we see `master br0` on the interfaces `eth0` - `eth3`, which indicates that these interfaces are attached to the bridge.

Now, lets start `tcpdump` on all nodes, and check send a ping from `node1` to the IPv4 address attached to the interface of `node4`:

```bash
❯ docker exec -it clab-switch-node1 ping -c 1 192.168.1.4
PING 192.168.1.4 (192.168.1.4): 56 data bytes
64 bytes from 192.168.1.4: icmp_seq=0 ttl=64 time=0.097 ms
--- 192.168.1.4 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.097/0.097/0.097/0.000 ms
```

First of all, we see that we received and answer to our ping and therefor that the switch is working properly.

Now lets take a look at the dumps from `node1` and `node4`:

```bash
❯ docker exec -it clab-switch-node1 tcpdump -i eth0 -e not ip6
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
19:52:09.734239 aa:c1:ab:02:6e:29 (oui Unknown) > Broadcast, ethertype ARP (0x0806), length 42: Request who-has 192.168.1.4 tell 192.168.1.1, length 28
19:52:09.734298 aa:c1:ab:9b:85:97 (oui Unknown) > aa:c1:ab:02:6e:29 (oui Unknown), ethertype ARP (0x0806), length 42: Reply 192.168.1.4 is-at aa:c1:ab:9b:85:97 (oui Unknown), length 28
19:52:09.734302 aa:c1:ab:02:6e:29 (oui Unknown) > aa:c1:ab:9b:85:97 (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.1 > 192.168.1.4: ICMP echo request, id 18, seq 0, length 64
19:52:09.734322 aa:c1:ab:9b:85:97 (oui Unknown) > aa:c1:ab:02:6e:29 (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.4 > 192.168.1.1: ICMP echo reply, id 18, seq 0, length 64

❯ docker exec -it clab-switch-node4 tcpdump -i eth0 -e not ip6
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
19:35:16.001222 aa:c1:ab:79:3d:31 (oui Unknown) > Broadcast, ethertype ARP (0x0806), length 42: Request who-has 192.168.1.4 tell 192.168.1.1, length 28
19:35:16.001242 aa:c1:ab:79:a9:60 (oui Unknown) > aa:c1:ab:79:3d:31 (oui Unknown), ethertype ARP (0x0806), length 42: Reply 192.168.1.4 is-at aa:c1:ab:79:a9:60 (oui Unknown), length 28
19:35:16.001258 aa:c1:ab:79:3d:31 (oui Unknown) > aa:c1:ab:79:a9:60 (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.1 > 192.168.1.4: ICMP echo request, id 18, seq 0, length 64
19:35:16.001267 aa:c1:ab:79:a9:60 (oui Unknown) > aa:c1:ab:79:3d:31 (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.4 > 192.168.1.1: ICMP echo reply, id 18, seq 0, length 64
```

They look exactly the same as in the setup of the [direct connection](/direct-connection/Readme.md).
This is an interesting fact, because we see that a switch is completely transparent.
For the two nodes it seems like their are directly connected with nothin in between.

And last, lets take a look at the `tcpdump` from the switch:

```bash

```

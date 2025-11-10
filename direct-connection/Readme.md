# Direct Connection

The most basic kind of network communication is a direct connection between two nodes.
Since this is the first setup, I will use it to explain the setup and tooling a little bit more extensive.

As already described in the [beginning](../Readme.md), we are using [CONTAINERlab](https://containerlab.dev/) to create our different network setups.
The configuration is done via [`direct-connection.clab.yml`](./direct-connection.clab.yml), so lets take a look:

```yaml
name: direct-connection
topology:
  nodes:
    # Description of the first node
    node1:
      kind: linux
      # Image to use
      image: ghcr.io/shaardie/networking:latest
      network-mode: none
      # Mount setup script into the container
      binds:
        - ./node1.sh:/run.sh
      # Run script on startup
      cmd: bash /run.sh
    # Description of the first node
    node2:
      kind: linux
      # Image to use
      image: ghcr.io/shaardie/networking:latest
      network-mode: none
      # Mount setup script into the container
      binds:
        - ./node2.sh:/run.sh
      # Run script on startup
      cmd: bash /run.sh
  links:
    # Description of the network connections
    - endpoints: ["node1:eth0","node2:eth0"]
```

I will not explain every detail of this configuration files.
For this, take a look at the documentation of CONTAINERlab yourself.

This configuration spins up two nodes `node1` and `node2` in containers on your own machine.

The images used for this are our own images described in this [Dockerfile](../Dockerfile), which is basically a plain Debian Trixie with some additional tools and commands installed.

We have a Bash scripts [`node1.sh`](./node1.sh) and [`node2.sh`](./node2.sh), which describe the network setup for the nodes and are mounted into the container and executed on startup, so that the nodes are properly configured.

This will be more or less the same for all of our setups with some small exception we explain when they occur.

Last but not least, we define the actuall connection between the nodes.
In this case a simple direct connection, where we create interfaces called `eth0` on each node and connect them to each other.

Okay, so next lets take a look at the scripts.

`node1.sh`:
```bash
#!/bin/bash

set -eux

# wait for the setup to finish
while ! ip link show dev eth0 &>/dev/null; do
  sleep 0.1
done

# Set the IP address for the client
ip addr add 192.168.1.1/24 dev eth0

# Keep container running
sleep infinity
```

`node2.sh`:
```bash
#!/bin/bash

set -eux

# wait for the setup to finish
while ! ip link show dev eth0 &>/dev/null; do
  sleep 0.1
done

# Set the IP address for the client
ip addr add 192.168.1.2/24 dev eth0

# Keep container running
sleep infinity
```

We can see, that both of them pretty much so the same.
At the beginning, we wait for the network interfaces to become present, because this can take some time and we want to have the setup ready before we start to configure.

After that we are using the `ip` command to configure our interfaces.
We want to communicate between the nodes via *Layer 3*, so as we learned in [Network Basics](./Readme.md#network-basics), we need to assign those interfaces an IPv4 address within the same network.
`node1` gets the `192.168.1.1` and `node2` gets the `192.168.1.2` assigned to the interface `eth0`.
Both IPs are in the in the network `192.168.1.0/24` so we should be fine.

At the end the script halts without finishing the script to keep the containers running.

Now we have seen all configuration file, so lets spin up this setup by executing:

```bash
❯ sudo containerlab deploy
09:56:12 INFO Containerlab started version=0.71.0
09:56:12 INFO Parsing & checking topology file=direct-connection.clab.yml
09:56:12 INFO Pulling image image=ghcr.io/shaardie/networking:latest
latest: Pulling from shaardie/networking
13cc39f8244a: Pull complete
df7bd803a2d9: Pull complete
Digest: sha256:47f67be73a51cdf9270ca54374a6ae1b8a07737968fc1a87afb767df02833d34
Status: Downloaded newer image for ghcr.io/shaardie/networking:latest
09:56:19 INFO Done pulling image image=ghcr.io/shaardie/networking:latest
09:56:19 INFO Creating lab directory path=/home/sven/devel/networking/direct-connection/clab-direct-connection
09:56:19 INFO Creating container name=node1
09:56:19 INFO Creating container name=node2
09:56:19 INFO Created link: node1:eth0 ▪┄┄▪ node2:eth0
09:56:19 INFO Adding host entries path=/etc/hosts
09:56:19 INFO Adding SSH config for nodes path=/etc/ssh/ssh_config.d/clab-direct-connection.conf
🎉 A newer containerlab version (0.71.1) is available!
Release notes: https://containerlab.dev/rn/0.71/#0711
Run 'sudo clab version upgrade' or see https://containerlab.dev/install/ for installation options.
╭──────────────────────────────┬────────────────────────────────────┬─────────┬────────────────╮
│             Name             │             Kind/Image             │  State  │ IPv4/6 Address │
├──────────────────────────────┼────────────────────────────────────┼─────────┼────────────────┤
│ clab-direct-connection-node1 │ linux                              │ running │ N/A            │
│                              │ ghcr.io/shaardie/networking:latest │         │ N/A            │
├──────────────────────────────┼────────────────────────────────────┼─────────┼────────────────┤
│ clab-direct-connection-node2 │ linux                              │ running │ N/A            │
│                              │ ghcr.io/shaardie/networking:latest │         │ N/A            │
╰──────────────────────────────┴────────────────────────────────────┴─────────┴────────────────╯
```

Now our setup is running and we can start analysing it by using the `docker` command line tool.

```
❯ docker ps
CONTAINER ID   IMAGE                                COMMAND          CREATED         STATUS         PORTS     NAMES
465210d64ccf   ghcr.io/shaardie/networking:latest   "bash /run.sh"   4 seconds ago   Up 4 seconds             clab-direct-connection-node1
4d1c2c5d9a73   ghcr.io/shaardie/networking:latest   "bash /run.sh"   4 seconds ago   Up 4 seconds             clab-direct-connection-node2
```

We see that our containers are running and that they got the names `clab-direct-connection-node1` and `clab-direct-connection-node2`.

Lets take a look at the configuration of the interfaces within the containers.
For that we can again use the `ip` command.
I will limit the output by using `dev eth0` (only showing the configuration of the interface `eth0`) to keep it nice and clean, but most of the time, you are just using `ip a`, which is short for `ip address show` and ignore the output you are not interested in.

```bash
❯ docker exec -it clab-direct-connection-node1 ip address show dev eth0
14: eth0@if15: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue state UP group default
    link/ether aa:c1:ab:66:ba:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.1.1/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a8c1:abff:fe66:ba02/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever

❯ docker exec -it clab-direct-connection-node2 ip address show dev eth0
15: eth0@if14: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue state UP group default
    link/ether aa:c1:ab:4d:39:a7 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet 192.168.1.2/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a8c1:abff:fe4d:39a7/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
```

There are still a lot of information in this output, we currently do not need, so I will briefly describe them:

* `eth0@if15`: This is the *name* of the interface. The `@if15` is there due to the virtualization we are using the set this up. I will always refer to it as `eth0` and you can ignore it for now.
* `state UP`: This is the *state* of the interface, it will only accept packages, if it is `UP`.
* `inet 192.168.1.1/24`: This is an *IPv4 address with netmask* attached to this interface. We can see that our configuration script has done what it was supposed to be.
* `link/ether aa:c1:ab:4d:39:a7 `: This is the *MAC address* of the interface.

Okay, so now we have in theory a connection between the two nodes, how can we test it?

For this, we are using [`ping`](https://en.wikipedia.org/wiki/Ping_(networking_utility)) and [`tcpdump`](https://www.tcpdump.org/).

`ping` lets you send and receive small `ICMP` pakets. `ICMP` is another layer 3 protocol, so we can test with that, if we have a layer 3 connection and therefore also a layer 2 connection between the two nodes.
It works by sending a small paket of type `ICMP echo request` packet and waits for a `ICMP echo reply`, which the *pinged* node should give under normal circumstances.
In praxis there are sometimes firewalls blocking ICMP packets and also some systems might be configured to ignore echo request, but in our setups, it should be possible in most cases and we can use it to verify the connection.

We also want to acutally *see* which packets are send between the nodes and therefore using `tcpdump`, which is a tool to analyse network traffic live.
During the different setups, we will learn different command line parameters of `tcpdump` and explain them on the fly. For now we are using `docker exec` to start `tcpdump` on both nodes as following:

```bash
❯ tcpdump -i eth0 -e not ip6
```

With this parameters `tcpdump` will listen on interface `eth0` for packets.
`-e` lets us also see the layer 2 information and `not ip6` ignores all IPv6 traffic, because currently we are not interested in that.

After the `tcpdump`s are running we use `ping` to send a single `ICMP echo request` from `node1` to the IPv4 address of `node2`:

```bash
❯ docker exec -it clab-direct-connection-node1 ping -c 1 192.168.1.2
PING 192.168.1.2 (192.168.1.2): 56 data bytes
64 bytes from 192.168.1.2: icmp_seq=0 ttl=64 time=0.078 ms
--- 192.168.1.2 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.078/0.078/0.078/0.000 ms
```

There is again a lot of interessting output, but for now we are only interessted in the information, that we send out a packet and also received a packet, so the ping, and therefore the layer 3 connection test was successful.

Okay, lets take a look at the output of tcpdump on our `node1`:

```bash
❯ docker exec -it clab-direct-connection-node1 tcpdump -i eth0 -e not ip6
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
10:52:20.243705 aa:c1:ab:66:ba:02 (oui Unknown) > Broadcast, ethertype ARP (0x0806), length 42: Request who-has 192.168.1.2 tell 192.168.1.1, length 28
10:52:20.243729 aa:c1:ab:4d:39:a7 (oui Unknown) > aa:c1:ab:66:ba:02 (oui Unknown), ethertype ARP (0x0806), length 42: Reply 192.168.1.2 is-at aa:c1:ab:4d:39:a7 (oui Unknown), length 28
10:52:20.243731 aa:c1:ab:66:ba:02 (oui Unknown) > aa:c1:ab:4d:39:a7 (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.1 > 192.168.1.2: ICMP echo request, id 36, seq 0, length 64
10:52:20.243745 aa:c1:ab:4d:39:a7 (oui Unknown) > aa:c1:ab:66:ba:02 (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.2 > 192.168.1.1: ICMP echo reply, id 36, seq 0, length 64
```

We will break this down slowly, but starting at the end. First we will take a look at the last two lines:

```bash
10:52:20.243731 aa:c1:ab:66:ba:02 (oui Unknown) > aa:c1:ab:4d:39:a7 (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.1 > 192.168.1.2: ICMP echo request, id 36, seq 0, length 64
10:52:20.243745 aa:c1:ab:4d:39:a7 (oui Unknown) > aa:c1:ab:66:ba:02 (oui Unknown), ethertype IPv4 (0x0800), length 98: 192.168.1.2 > 192.168.1.1: ICMP echo reply, id 36, seq 0, length 64
```

These two lines describe two packets.
The first one was send from MAC address `aa:c1:ab:66:ba:02`, which is our `node1` to the MAC address `aa:c1:ab:4d:39:a7` which is our `node2`.
And the second packet vice versa.
So this is a direct layer 2 communication between our two nodes.

But there is also some layer 3 information in there and we see that the first packet is an `ICMP echo request` from `192.168.1.1` (`node1`) to `192.168.1.2` (`node2`).
And the second packet describe the answer.
An `ICMP echo reply` from `192.168.1.2` (`node2`) to `192.168.1.1` (`node1`).

So the two nodes can communicate with each other and we can even see how they are doing this, but an open question is still, how does the interface know to which MAC address to send packet for a specific IP?
Or more specific: How does `node1` know that it needs to send packets for the `192.168.1.2` to the MAC address `aa:c1:ab:4d:39:a7`?

Here a new layer 2 protocol comes into place, called [ARP](https://en.wikipedia.org/wiki/Address_Resolution_Protocol).
With ARP we can send our request which MAC Address belongs to which IPv4 address.
To analyse this, lets take a look at the first 2 lines of our `tcpdump`:

```bash
10:52:20.243705 aa:c1:ab:66:ba:02 (oui Unknown) > Broadcast, ethertype ARP (0x0806), length 42: Request who-has 192.168.1.2 tell 192.168.1.1, length 28
10:52:20.243729 aa:c1:ab:4d:39:a7 (oui Unknown) > aa:c1:ab:66:ba:02 (oui Unknown), ethertype ARP (0x0806), length 42: Reply 192.168.1.2 is-at aa:c1:ab:4d:39:a7 (oui Unknown), length 28
```

The first one is a packet send from the MAC address of our `node1` to the *Broadcast* MAC address, usually `ff:ff:ff:ff:ff:ff`, which is a packet for all nodes with a layer 2 connection to `node1` with the request `who-has 192.168.1.2 tell 192.168.1.1`.
This means `node1` is asking with MAC address is assisiated with the IP address `192.168.1.1` and also automatically telling other nodes that `192.168.1.1` is assisiated with its own MAC address.

In our case the `node2` answers this request in the next line and tells `nodd1` that the IP address is assosiated with the MAC address of `node2`.
So this way `node1` know where to send the layer 3 paket for the IPv4 Address of `node2`.

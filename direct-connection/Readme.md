# Direct Connection

The most basic kind of network communication is a direct connection between two nodes.
Since this is the first setup, I will use it to explain the setup and tooling a little bit more extensive.

As already described in the [beginning](../Readme.md), we are using [CONTAINERlab](https://containerlab.dev/) to create our different network setups.
The configuration is done via an YAML file, so lets take a look:

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
I will limit the output by using `-4` (only showing the IPv4 configuration) and `dev eth0` (only showing the configuration of the interface `eth0`) to keep it nice and clean, but most of the time, you are just using `ip a`, which is short for `ip address show` and ignore the output you are not interested in.

```bash
sven in pacman in devel/networking/direct-connection on  main [!]
at 10:19:57 ❯ docker exec clab-direct-connection-node1 ip -4 -c address show dev eth0
14: eth0@if15: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue state UP group default  link-netnsid 0
    inet 192.168.1.1/24 scope global eth0
       valid_lft forever preferred_lft forever

sven in pacman in devel/networking/direct-connection on  main [!]
at 10:20:00 ❯ docker exec clab-direct-connection-node2 ip -4 -c address show dev eth0
15: eth0@if14: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 qdisc noqueue state UP group default  link-netnsid 1
    inet 192.168.1.2/24 scope global eth0
       valid_lft forever preferred_lft forever
```

There are still a lot of information in this output, we currently do not need, so I will briefly describe them:

* `eth0@if15`: This is the *name* of the interface. The `@if15` is there due to the virtualization we are using the set this up. I will always refer to it as `eth0` and you can ignore it for now.
* `state UP`: This is the state of the interface, it will only accept packages, if it is `UP`.
* `inet 192.168.1.1/24`: This is an IPv4 address with netmask attached to this interface. We can see that our configuration script has done what it was supposed to be.

!TODO


It does not really get more basic than a direct connection between to machines.
So this is our starting point.

```bash
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

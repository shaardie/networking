# Networking

Networking can be challenging - even if you learned it at school or university.

When I discovered the tool [containerlab](https://containerlab.dev/), which makes it easy to create complex networking environments inside containers, I wanted to start building some examples and explain how they work.

I decided to use simple [Debian](https://www.debian.org/) containers as a base, rather than any fancy network operating system, so you can focus on learning the basics of Linux network configuration.

## Who is this for?

This repository is aimed at people who already have some experience with Linux and containers, and who might have learned the basics of networking at some point. 

The goal here is not to teach Linux or container fundamentals, but to provide **practical setups** that help you understand common networking structures in a hands-on way.

## Tooling

Base of all our different setups is [CONTAINERlab](https://containerlab.dev/).
It lets you create quite complex networking structures without any physical hardware or cables.
We are using it on top of [Docker](https://www.docker.com/) to create a bunch of different containers between which we can define network connections.
The configuration is done via a [YAML](https://yaml.org/) file and is pretty similar to [Docker Compose](https://docs.docker.com/compose/).
I will not go into details about the configuration, but explain the ideas of the different setups.
CONTAINERlab can do many things more and you can spin up complex environment even with different network operating systems, so if you want to know more about that, check it our yourself.

Next to CONTAINERlab we are pretty much only using bash scripts and basic linux networking tools to create our setups.
I mean, this is more or less the whole idea of this thing.

We are also using our own Container Image, but this is just to speed things a little bit up.
It is still the base image of Debian Trixie, but with some additional tools installed, like the one mentioned below and some other commands which are usually installed in the regular Debian Trixie, but just only not part of the minimal container image.
You can see the actuall Dockerfile [here](./Dockerfile).

There are some networking tools, we will use quite often which are not part of the setup itself, but helps us analyse and *see* what is happening in the network, like [tcpdump](https://www.tcpdump.org/), which can be use to acutally look at the network traffic.
It is a very powerfull tool and we will familiarize ourself with some, but not all, of its functionality along the way.

Despite that sometimes use [ipcalc](https://jodies.de/ipcalc) to analyse ip addreses and networks.

## Networking Basics

Before we dive into the different setups, we need to talks a little bit about the basics of networking.

So if we talk about networking we want connect multiple computer or devices together so that they can share information.
How this information is shared between different computes, we also often say nodes, it the [OSI Model](https://en.wikipedia.org/wiki/OSI_model).

Since they are a lot of different technologies and protocols involved during the communication, it is quite difficult to always think about all those at once.
So the OSI Model splits them up in different Layers, so you can concentrate on just one or two of them and dont worry about the others.
For example, if you setup your home network, you worry about *connecting* to some nodes in the internet, but not about the protocols you later talk over this connection.
I will not go into more details about the OSI Model and I also guess most of you have already heard about it.
Otherwise read about it, if your want.

We will concentrate here about the first three Layers, called the *physical layer*, the *data link layer* and the *network layer*.
So I explain them very shortly.

The *physical layer* or *layer 1* is responsibly for the actuall transmission and reception of the raw data.
Think for example about the hardware of your network.
We will not really talk about this that much, but we will describe the *physical* connections between our nodes, so I needed talk at least mentioned this.

The *data link layer* or *layer 2* is responsible for the communication between nodes or described a little different in the same *local network*.
For this, you can think about it as the encoded packages or data frames send directly between nodes over the physical layer.
Most of the time connection point in *layer 2* is a *interface* within your Linux operating system.
Something like `eth0` or `wlan0`.
But there are also special interface, which does not follow this rule like `lo` and maybe we will talk about this later in more detail.
Anyway, each of this interfaces does have an MAC address, which is the unique identifier of this interface.
They consist of 48 Bits and are nearly always represented by 12 hexadecimal number with each Bytes is seperated by a `:` (or similar), like this:

```
3b:a9:15:b5:a2:ef
```

So if we later take a look at communication between to nodes, we look at communication between two of those addresses.

The *network layer* or *layer 3* is responsible for communication between different networks.
So while layer 2 would be sufficient for the communication in a local network, layer 3 now adds the functionality to talk to nodes in other networks, beyond other things.

At this layer, nodes are identified by *IP addresses* instead of MAC addresses.
These IP addresses are assigned to interfaces in your operating system and can be configured or changed at any time.

We have to different kind of IP addresses, `IPv4` and `IPv6`.
For the beginning we will only concentrate on `IPv4`, but I am sure we will talk about `IPv6` later on.

IPv4 addresses consist of 32 Bits and are nearly always represented as four number between 0 and 255 delimited by a dot, like this:

```
192.168.1.1
```

But the address alone if not sufficient to describe the networks, because to split the whole address space into different networks, we need to know how big these networks are.

To describe to which ip address a network belongs most often the *CIDR* notation is used, which describes the size of the network by appending the number of fixed Bits as a *netmask*, like

```
192.168.1.1/24
```

This describes the IPv4 Address `192.168.1.1` as part of the network `192.168.1.0/24`, which consist of all ip addresses where the last entry of the addresse changed.

There are more than one tutorial in the internet which describes how this is actually used to calculate the network, so I will not bother at this point.

Practically speaking, I also never bother doing this by hand.
There are some CIDR notation, I simply know, like:

* `192.168.1.0/24` -> `192.168.1.1 - 192.168.1.255`
* `192.168..0/16` -> `192.168.1.1 - 192.168.255.255`
* `192.0.0.0/8` -> `192.168.1.1 - 192.255.255.255`

and for everything else, I use command line tools like [ipcalc](https://jodies.de/ipcalc) or any of the endless ip calculators on the internet.
With those you can calculate even odd mask pretty easily:

```bash
❯ ipcalc 192.168.1.1/23
Address:   192.168.1.1          11000000.10101000.0000000 1.00000001
Netmask:   255.255.254.0 = 23   11111111.11111111.1111111 0.00000000
Wildcard:  0.0.1.255            00000000.00000000.0000000 1.11111111
=>
Network:   192.168.0.0/23       11000000.10101000.0000000 0.00000000
HostMin:   192.168.0.1          11000000.10101000.0000000 0.00000001
HostMax:   192.168.1.254        11000000.10101000.0000000 1.11111110
Broadcast: 192.168.1.255        11000000.10101000.0000000 1.11111111
Hosts/Net: 510
```

With this knowledge you should now be able to start with the setups.
Everything else is explained on the way.

## Setups

So now to the actual content: 

* [Direct Connection](/direct-connection/Readme.md): The simplest of the setups. Just a direct connection between not nodes.
* [Switch](/switch/Readme.md): Connecting different nodes with a switch.
* [VLAN](/vlan/Readme.md): Direct connection between 2 nodes via VLAN.
* [VLAN Switch](/vlan-switch/Readme.md): Connection between different nodes in different VLANs.
* [Router](/router/Readme.md): A Router to route the traffic of different nodes in different networks.
* [Internet Router](/internet-router/Readme.md): The Setup of an internet router, like the one you have at home.

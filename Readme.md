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

## Setups

So now to the actual content: 

* [Direct Connection](/direct-connection/Readme.md): The simplest of the setups. Just a direct connection between not nodes.
* [Switch](/switch/Readme.md): Connecting different nodes with a switch.
* [VLAN](/vlan/Readme.md): Direct connection between 2 nodes via VLAN.
* [VLAN Switch](/vlan-switch/Readme.md): Connection between different nodes in different VLANs.
* [Router](/router/Readme.md): A Router to route the traffic of different nodes in different networks.
* [Internet Router](/internet-router/Readme.md): The Setup of an internet router, like the one you have at home.

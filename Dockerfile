FROM debian:trixie

# Install some dependencies into the image which are regualarly installed in
# the OS.
RUN apt-get update -y && \
  apt-get install inetutils-ping iproute2 procps tcpdump iptables bridge-utils -y


FROM debian:trixie

# Install some dependencies into the image which are regularly installed in
# the OS.
# Here is nothing fancy just the commands ping, ip, bridge, sysctl and tcpdump
RUN apt-get update -y && apt-get install -y inetutils-ping iproute2 bridge-utils procps tcpdump


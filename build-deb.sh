#!/bin/sh

# this script is to be run as root inside of a docker container
# repo is expected in /root/fadecandy

# install a few things
apt-get update && apt-get install -y devscripts equivs openssh-client

# setup SSH
mkdir -pm 700 ~/.ssh
ssh-keyscan packages.c2x.io > ~/.ssh/known_hosts

cd /root/fadecandy

# gather dependencies
mk-build-deps server/debian/control
dpkg -i *.deb
apt-get install -fy
rm *.deb

# build!
debian/rules binary

# upload
deb=$(cd .. && ls *.deb)
scp ../$deb debs@packages.c2x.io:
ssh debs@packages.c2x.io "reprepro -b develop includedebs trusty $deb && rm $deb"

# done.

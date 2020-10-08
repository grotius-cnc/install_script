#!/bin/bash
#This script is used to install ethercat on linux debian 10 buster.

sudo apt install linux-headers-$(uname -r) #install missing debian buster kernel headers
echo "Installing linux kernel header files for $(uname -r)"

sudo apt-get install debhelper dkms gettext autoconf automake libtool quilt mercurial git xarchiver wget
sudo apt-get install libexpat1-dev #needed by linuxcnc-ethercat
echo "Installing some depenencies"

# Download the first data..
wget https://github.com/grotius-cnc/install_script/raw/main/ethercat
wget https://github.com/grotius-cnc/install_script/raw/main/hgrc
echo "Download install script"

# mercurial, add mq extension
sudo rm /etc/mercurial/hgrc
sudo cp hgrc /etc/mercurial/
echo "Adding mercurial mq extension"

# Download zip archive 
echo "Download ethercat"
wget https://github.com/grotius-cnc/ethercat-hg/releases/download/1.2/ethercat.zip # depends on wget dependency

# Unzip downloaded zip file
unzip ethercat.zip # Unzip file
rm ethercat.zip # Delete zip file

# Prepare to build package
cd ec-debianize/etherlabmaster
dpkg-buildpackage

cd ..
sudo dpkg -i etherlabmaster_1.5.2+20190904hg33b922p8ea394-1_amd64.deb
sudo dpkg -i etherlabmaster-dbgsym_1.5.2+20190904hg33b922p8ea394-1_amd64.deb
sudo dpkg -i etherlabmaster-dev_1.5.2+20190904hg33b922p8ea394-1_amd64.deb
cd .. # Back to start dir.

# Delete installed ethercat file at /etc/default/ethercat.
sudo rm /etc/default/ethercat
echo "Delete ethercat file in /etc/default"

# Append text "mac-adres" to the local ethercat file.
echo MASTER0_DEVICE="$(cat /sys/class/net/enp0s25/address)" >> ethercat
echo "Mac adres : $(cat /sys/class/net/enp0s25/address), writing the Mac adres to ethercat file"

# Copy the modified ethercat file to /etc/default/
sudo cp ethercat /etc/default/
echo "Copy ethercat file to system folder /etc/default/"

# This permanent solution will set ethercat rules from root to user, dev/EtherCAT0 user permission's are ok at startup this way.
sudo rm /etc/udev/rules.d/99-ethercat.rules
sudo echo "KERNEL=="\"EtherCAT[0-9]*\"", MODE="\"$var\"", GROUP=" "\"$USER\"" >> /etc/udev/rules.d/99-ethercat.rules

# Update ethercat config
sudo update-ethercat-config
echo "Starting ethercat bus"

# Remove 2 install files
rm ethercat && rm hgrc

# Install linuxcnc-ethercat
git clone https://github.com/grotius-cnc/linuxcnc-ethercat.git
cd linuxcnc-ethercat
make
cd ..

# Install linuxcnc as rip
git clone https://github.com/grotius-cnc/linuxcnc.git

cd linuxcnc/debian/
./configure uspace
cd ..

# $ dpkg-checkbuilddeps
sudo apt-get install dh-python rtai-modules-4.14.174-dbgsym tcl8.6-dev tk8.6-dev libreadline-gplv2-dev asciidoc dblatex docbook-xsl dvipng ghostscript graphviz groff imagemagick inkscape python-lxml source-highlight w3c-linkchecker xsltproc texlive-extra-utils texlive-font-utils texlive-fonts-recommended texlive-lang-cyrillic texlive-lang-french texlive-lang-german texlive-lang-polish texlive-lang-spanish texlive-latex-recommended asciidoc-dblatex python-dev libxmu-dev libglu1-mesa-dev libgl1-mesa-dev libgtk2.0-dev intltool libboost-python-dev netcat libmodbus-dev libusb-1.0-0-dev yapps2 libtirpc-dev

cd src
./autogen.sh
./configure --with-realtime=uspace
make #-j2 
sudo make setuid
cd .. && cd ..

# copy the lcec.so to the linuxcnc rtlib folder & copy the lcec_conf to the linuxcnc bin folder.
cd linuxcnc-ethercat/src/
cp lcec.so ../../linuxcnc/rtlib/
cp lcec_conf ../../linuxcnc/bin/
cd .. && cd .. && cd linuxcnc/scripts

. ./rip-environment
linuxcnc # Integrate a ethercat example to the source.

# old, for info :
# set up and change dev/EtherCAT0 
# sudo mknod /dev/EtherCAT0 c 89 1
# sudo chmod go+rw /dev/EtherCAT0











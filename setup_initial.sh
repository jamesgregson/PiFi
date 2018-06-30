#!/usr/bin/env bash

# install the dnsmasq and hostapd packages
echo "Installing dnsmasq & hostapd...."
apt-get install dnsmasq hostapd

# stop the services
sudo systemctl stop dnsmasq
sudo systemctl stop hostapd

# make copies of all the files
mkdir conf
cp /etc/dhcpcd.conf conf/dhcpcd.conf.orig
cp /etc/dnsmasq.conf conf/dnsmasq.conf.orig
cp /etc/default/hostapd conf/hostapd.orig
cp /etc/wpa_supplicant/wpa_supplicant.conf conf/wpa_supplicant.conf.orig

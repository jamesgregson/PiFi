#!/usr/bin/env bash

WORK_DIR=`pwd`
CURR_DIR=$(dirname $(readlink -f $0))
cd $CURR_DIR

echo "Setting up network for $1, $2"

echo "Stopping dnsmasq, hostapd & dhcpcd services...."
systemctl disable dnsmasq
systemctl disable hostapd
service dhcpcd stop

echo "Writing wpa_suplicant.conf...."
echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" > conf/wpa_supplicant_dhcp.conf
echo "update_config=1" >> conf/wpa_supplicant_dhcp.conf
echo "network={" >> conf/wpa_supplicant_dhcp.conf
echo "  ssid=\"$1\"" >> conf/wpa_supplicant_dhcp.conf

# new stuff to use encrypted passphrase...
TMP=`wpa_passphrase $1 $2 | grep '[[:space:]]\psk=.*'`
echo "$TMP" >> conf/wpa_supplicant_dhcp.conf

echo "}" >> conf/wpa_supplicant_dhcp.conf
cp conf/wpa_supplicant_dhcp.conf /etc/wpa_supplicant/wpa_supplicant.conf

echo "Updating dhcpcd.conf...."
cp conf/dhcpcd.conf.orig /etc/dhcpcd.conf

echo "Restarting dhcpcd service...."
service dhcpcd start

sleep 10

#echo "Reconfiguring wlan0...."
#wpa_cli -i wlan0 reconfigure

cd $WORK_DIR

WIFI=`iwconfig wlan0 | sed -n 's/.*ESSID:"\(\S.*\)".*/\1/p'`
echo "Trying to connect to $1"
echo "Actually connected to $WIFI"
if [ "$WIFI" = "$1" ]; then
  echo "$WIFI" > last_network.txt
  echo "Connected to $1"
  exit 0
fi
echo "Failed to connect to $1"
exit 1

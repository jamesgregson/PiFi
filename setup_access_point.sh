#!/usr/bin/env bash
# PIFI

WORK_DIR=`pwd`
CURR_DIR=$(dirname $(readlink -f $0))
cd $CURR_DIR

echo "Stopping dnsmasq, hostapd & dhcpcd services...."
systemctl stop dnsmasq
systemctl stop hostapd
service dhcpcd stop

# generate the dhcpcd.conf file
echo "Generating dhcpcd.conf for PiFi...."
cp $CURR_DIR/conf/dhcpcd.conf.orig        conf/dhcpcd_static.conf
echo "interface wlan0"                 >> conf/dhcpcd_static.conf
echo "static ip_address=10.10.10.1/24" >> conf/dhcpcd_static.conf

# generate the dnsmasq file
echo "Generating dnsmasq.conf for PiFi...."
echo "interface=wlan0" > conf/dnsmasq_static.conf
echo "  dhcp-range=10.10.10.2,10.10.10.50,255.255.255.0,24h" >> conf/dnsmasq_static.conf

# generate the hostapd.conf file
echo "Generating hostapd.conf for PiFi...."
echo "interface=wlan0"                 >  conf/hostapd_static.conf 
echo "driver=nl80211"                  >> conf/hostapd_static.conf 
echo "hw_mode=g"                       >> conf/hostapd_static.conf
echo "channel=7"                       >> conf/hostapd_static.conf
echo "wmm_enabled=0"                   >> conf/hostapd_static.conf 
echo "macaddr_acl=0"                   >> conf/hostapd_static.conf
echo "auth_algs=1"                     >> conf/hostapd_static.conf 
echo "ignore_broadcast_ssid=0"         >> conf/hostapd_static.conf 
echo "wpa=2"                           >> conf/hostapd_static.conf 
echo "wpa_key_mgmt=WPA-PSK"            >> conf/hostapd_static.conf 
echo "wpa_pairwise=TKIP"               >> conf/hostapd_static.conf
echo "rsn_pairwise=CCMP"               >> conf/hostapd_static.conf
echo "ssid=ConnectToService"           >> conf/hostapd_static.conf 
echo "wpa_passphrase=ConnectToService" >> conf/hostapd_static.conf

# make a backup of the accesspoint config file
echo "Modifying hostapd for PiFi...."
cp conf/hostapd.orig conf/hostapd_static
sed -i -r 's/#DAEMON_CONF.*/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/' conf/hostapd_static


echo "Writing wpa_suplicant.conf...."
echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" > conf/wpa_supplicant_static.conf
echo "update_config=1" >> conf/wpa_supplicant_static.conf


echo "Updating dhcpcd.conf, wpa_supplicant.conf, dnsmasq.conf & hostapd.conf...."
cp conf/dhcpcd_static.conf         /etc/dhcpcd.conf
cp conf/wpa_supplicant_static.conf /etc/wpa_supplicant/wpa_supplicant.conf
cp conf/dnsmasq_static.conf        /etc/dnsmasq.conf
cp conf/hostapd_static.conf        /etc/hostapd/hostapd.conf
cp conf/hostapd_static             /etc/default/hostapd

echo "Restarting dhcpcd service...."
service dhcpcd start

sleep 5

echo "Restarting hostapd & dnsmasq services...."
systemctl start hostapd
systemctl start dnsmasq

echo "Reconfiguring wlan0...."
wpa_cli -i wlan0 reconfigure
sleep 10

cd $WORK_DIR
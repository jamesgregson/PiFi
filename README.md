# PiFi

Simple headless Raspberry Pi WiFi configuration. PiFi simplifies the process of getting a Raspberry Pi online without an attached display or terminal connection.

This is useful if you are using the Pi to connect sensors, instruments or robotic dealies to external WiFi networks but don't want to have to log in and configure them each time.

### Initial Setup

Initially clone the repository and run the ```setup_initial.sh``` script from the folder that is created. This will install hostapd and dnsmasq which are used to configure the Pi Wifi in access-point mode.

````
pi@raspberrypi:~ $ git clone http://www.github.com/jamesgregson/PiFi.git
pi@raspberrypi:~ $ cd PiFi
pi@raspberrypi:~/PiFi $ sudo ./setup_initial.sh
````

Next edit ```/etc/rc.local``` and add the ```setup_server.py``` script to the Pi startup.

````
pi@raspberrypi:~/PiFi $ sudo nano /etc/rc.local
````

The nano editor will open. Edit it to look like the following:

````
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

# Print the IP address
_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "My IP address is %s\n" "$_IP"
fi

# add this line for PiFi
sudo python3 /home/pi/PiFi/setup_server.py

exit 0
````

Hit ```Ctrl-X``` to exit, ```y``` to save and ```Enter``` to confirm the filename. Then reboot the Pi:

```
pi@raspberrypi:~/PiFi $ sudo reboot
```

## General Usage

When the Pi reboots, it will automatically check if the ```/home/pi/PiFi/last_network.txt``` file exists.  If not, it will set up the Pi in Access Point mode and create the following network:

* SSID: ConnectToService
* Passphrase: ConnectToService

Using a mobile device, connect to this network. Using a browser, navigate to ```http://10.10.10.1```. This will open a simple website where the credentials for the host network can be entered. Once entered, hit submit and the Pi will attempt to connect to the host network.

If it is successful, the next time the Pi boots it will attempt to reconnect to the host network. Otherwise you will have to reboot the Pi and try again.

## Notes

There's currently a few known issues:

* It works on my networks. It may not work on your networks.
* It has been tested on a stock Raspberry Pi Zero W with Raspbian installed via Noobs
* The scripts are hardcoded to configure the ```wlan0``` network interface, I may make this a configurable option later.
* The Pi will only remember the last network that it successfully connected to. This is intentional so that it minimizes the amount of network information that is stored on it (see next point).
* When the Pi fails to connect to the host network, it does not reset itself in access mode and try again. I also plan to fix this eventually.



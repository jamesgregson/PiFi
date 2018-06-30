# PiFi

Simple headless Raspberry Pi WiFi configuration. PiFi simplifies the process of getting a Raspberry Pi online without an attached display or terminal connection.

## How to Use PiFi

### Initial Setup

Initially clone the repository and run the ```setup_initial.sh``` script from the folder that is created. This will install hostapd and dnsmasq which are used to configure the Pi Wifi in access-point mode.

````
pi@raspberrypi:~ $ git clone http://www.github.com/jamesgregson/PiFi.git
pi@raspberrypi:~ $ cd pifi
pi@raspberrypi:~ $ sudo ./setup_initial.sh
````

Next edit ```/etc/rc.local``` and add the ```setup_server.py``` script to the Pi startup.

````
pi@raspberrypi:~ $ sudo nano /etc/rc.local
````

The nano editor will open. Edit it to look like the following:




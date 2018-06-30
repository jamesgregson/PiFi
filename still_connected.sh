#!/usr/bin/env bash

WORK_DIR=`pwd`
CURR_DIR=$(dirname $(readlink -f $0))
cd $CURR_DIR

# get the last network
if [ -e last_network.txt ] ; then 
  oldnetwork=`cat last_network.txt`
else
  oldnetwork="none"
fi

cd $WORK_DIR

# get the currently connected network
WIFI=`iwconfig wlan0 | sed -n 's/.*ESSID:"\(\S.*\)".*/\1/p'`

echo "Checking if $oldnetwork is still connected."
echo "New network is $WIFI"

if [ "$oldnetwork" = "$WIFI" ] ; then 
  echo "Still connected!"
  exit 0
else
  echo "Disconnected"
  exit 1
fi
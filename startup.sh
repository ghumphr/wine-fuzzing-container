#!/bin/bash

echo 'Updating /etc/hosts file...'
HOSTNAME=$(hostname)
echo "127.0.1.1\t$HOSTNAME" >> /etc/hosts

RESOLUTION="${RESOLUTION:-1024x768}"

echo "Starting VNC server at $RESOLUTION..."
Xtigervnc -kill :1 || true
Xtigervnc :1 -geometry $RESOLUTION -SecurityTypes=None && echo "VNC server started at $RESOLUTION! ^-^" &

export DISPLAY=":1"

(sleep 2; xfce4-session) &

echo "Starting tail -f /dev/null..."
tail -f /dev/null

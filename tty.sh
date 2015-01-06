#!/bin/bash
stty -F /dev/ttyUSB0 9600 ignbrk -brkint -icrnl -imaxbel -opost -onlcr -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke min 1 time 5
chmod 444 /dev/ttyUSB0

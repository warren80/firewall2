ifconfig p3p1
iptables --table nat --append POSTROUTING -o em1 -j MASQUERADE
iptables -A FORWARD -i p3p1 -j ACCEPT

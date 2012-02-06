#ifconfig p3p1
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables --table nat --append POSTROUTING -o em1 -j MASQUERADE
iptables -A FORWARD -i p3p1 -j ACCEPT

#ifconfig p3p1
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables --table nat --append POSTROUTING -o em1 -j MASQUERADE
iptables -A FORWARD -i p3p1 -j ACCEPT
iptables -t mangle -A INPUT -i em1 -d 192.168.180.0/24 -p tcp -m multiport \
        --sports ssh,ftp -j TOS --set-tos 0x10

		# set Maximum Throughput for ftp
		iptables -t mangle -A INPUT -p tcp -m multiport --dports ssh,ftp -j TOS --set-tos 0x08

iptables -A PREROUTING -t nat -p tcp -m multiport --dports 22,23 -j DNAT --to 192.168.180.2

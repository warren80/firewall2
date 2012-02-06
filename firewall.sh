#set WAN and LAN variables according to ifconfig on dual nic computer

WAN=eth0
LAN=em1
LOCALIP=192.168.0.243
LOCALNETWORK='192.168.0.0/24'  #is this format valid?
#allowed tcp services on following ports #,#,#,#,...  example 21,22,23
TCPSERVICES = "ssh, tcp, 111, 137:139, 515, 32768:32775"
UDPSERVICES = "ssh, tcp, 137:139, 32768:32775"
ICMP = 0
#ICMP ?
#TODO something to allow icmp services


#####DO NOT MODIFY AFTER THIS POINT#####
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables --table nat --append POSTROUTING -o $LAN -j MASQUERADE
iptables -A FORWARD -i $WAN -j ACCEPT


#clear previous settings
iptables -F
iptables -X
#set default policies
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
#Creates custom chains
iptables -N tcp
iptables -N udp
iptables -N icmp
#Drop All packets to local computer
iptables -A INPUT -d LOCALIP -j DROP #verified
#Drop all sin fin packets
iptables -A FORWARD -p tcp --tcp-flags SYN,FIN -j DROP #untested

#jump all traffic to the appropriate chain
iptables -p tcp -j tcp
iptables -p udp -j udp
iptables -p icmp -j icmp

#TODO block wrong way syns
#TODO accept fragments
#TODO accept all packets that belong to an existing connection on allowed ports
#TODO set minimum delay for FTP and SSH
#TODO set Maximim Throughput for ftp
#TODO only allow new and established traffic to go through firewall 'stateful'

# set minimum delaf for FTP and SSH
iptables -t mangle -A FORWARD -I $WAN -d 192.168.180.0/24 -p tcp -m multiport /
	--sports ssh,ftp -j tcp --set-tos 0x10

# set Maximum Throughput for ftp
iptables -t mangle -A FORWARD -p tcp -m multiport --dports ssh,ftp -j tcp --set-tos 0x08


iptables -A tcp -i $WAN -p tcp -m multiport --ports $TCPSERVICES -j DROP
iptables -A udp -i $WAN -p udp -m multiport --ports $UDPSERVICES -j DROP
#allow tcp and udp services

#block all telnet traffic
iptables -p tcp --sport telnet -j DROP
iptables -p tcp --dport telnet -j DROP



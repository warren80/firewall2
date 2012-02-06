#set WAN and LAN variables according to ifconfig on dual nic computer

#External Network Interface card
WAN=eth0

#Internal network Interface card
LAN=em1

#address from internal Network
INTERNALIP=192.168.180.1

#address from external Networks
EXTERNALIP=192.168.0.11

#address to client computer
CLIENTIP=192.168.180.12

#External Network subnet mask
LOCALNETWORK='192.168.0.0/24'  #is this format valid?

#Allowed tcp services to client computer following ports #,#,#,#,...  example 21,22,23
TCPSERVICES=21,22,53

#Allowed udp ports to enable services to client computer example 21,22,23
UDPSERVICES=21,22
q
#Allow ICMP protocols 0 Echo reply 8 Echo request etc
ICMP = 0 8
#TODO something to allow icmp services


#####DO NOT MODIFY AFTER THIS POINT#####
echo 1 > /proc/sys/net/ipv4/ip_forward
ifconfig $WAN down
ifconfig $LAN down

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
#TODO set minimum delay for FTP and SSH Matt
#TODO set Maximim Throughput for ftp Matt
#TODO only allow new and established traffic to go through firewall 'stateful'
iptables -A F

# set minimum delaf for FTP and SSH
iptables -t mangle -A INPUT -I $WAN -d 192.168.180.0/24 -p tcp -m multiport /
	--sports ssh,ftp -j TOS --set-tos 0x10

# set Maximum Throughput for ftp
iptables -t mangle -A INPUT -p tcp -m multiport --dports ssh,ftp -j TOS --set-tos 0x08


iptables -A tcp -i $WAN -p tcp -m multiport --ports 32768:32775,111:515 -j DROP
iptables -A udp -i $WAN -p udp -m multiport --ports 32768:32775,137:139 -j DROP
#allow tcp and udp services
iptables -A INPUT -p tcp -m multiport --ports TCPSERVICES -j FORWARD #needs to forward to client
iptables -A 

#block all telnet traffic
iptables -p tcp --sport telnet -j DROP
iptables -p tcp --dport telnet -j DROP
#ICMP Rules
iptables -A INPUT -p icmp --icmp-type 8 -s 0/0 -d $EXTERNALIP /
	-m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 0 -s $EXTERNALIP -d 0/0 /
	-m state --state ESTABLISHED,RELATED -j ACCEPT



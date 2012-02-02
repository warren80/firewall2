#set WAN and LAN variables according to ifconfig on dual nic computer

WAN=eth0
LAN=em1
LOCALIP=192.168.0.243
LOCALNETWORK='192.168.0.0/24'  #is this format valid?
#TODO something to allow tcp services
#TODO something to allow udp services
#TODO something to allow icmp services

#####DO NOT MODIFY AFTER THIS POINT#####

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
iptables -A INPUT -p tcp --tcp-flags SYN,FIN -j DROP

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

ptables -A tcp -i $WAN -p tcp -m multiport --ports 32768:32775,111:515 -j DROP
iptables -A udp -i $WAN -p udp -m multiport --ports 32768:32775,137:139 -j DROP
#block all telnet traffic
iptables -p tcp --sport telnet -j DROP
iptables -p tcp --dport telnet -j DROP



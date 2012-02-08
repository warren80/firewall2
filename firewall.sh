#set WAN and LAN variables according to ifconfig on dual nic computer

#External Network Interface card
WAN=eth0

#Internal network Interface card
LAN=em1

#address from internal Network
INTERNALIP=192.168.180.11

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

#Allowed ICMP protocols 
#
#You may allow as many ICMB services as you like to pass through the firewall. #Echo reply 0 and Echo replay 8 are enabled by default.
#To set additional services set the ICMP variable to the following pattern
#
# EXAMPLE:  ICMP=( 0 1 2 )
ICMP=( 0 8 )

#####DO NOT MODIFY AFTER THIS POINT#####

#explicitly block all external traffic to these ports
BLOCKEDTCP=32768:32775,137:139,111,515
BLOCKEDUDP=32768:32775,137:139
#Allow ip forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
#clear all previous settings
ifconfig $WAN down
ifconfig $LAN down
ifconfig $WAN UP
ifconfig $LAN UP
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

####ALL EXPLICITLY BLOCKED TRAFFIC IN THIS SECTION####
#some of these rules may be redundant may not need to specify INPUT and FORWARD FOR all need more tests to verify
iptables -I INPUT -i $WAN -p tcp -m multiport --ports $BLOCKEDTCP -j DROP
iptables -I INPUT -i $WAN -p udp -m multiport --ports $BLOCKEDUDP -j DROP
iptables -I FORWARD -i $WAN -p tcp -m multiport --ports $BLOCKEDTCP -j DROP
iptables -I FORWARD -i $WAN -p udp -m multiport --ports $BLOCKEDUDP -j DROP
iptables -A FORWARD -p tcp -i $WAN --tcp-flags SYN,FIN -j DROP
iptables -A INPUT -p tcp -i $WAN --tcp-flags SYN,FIN -j DROP
iptables -A INPUT -d LOCALIP -j DROP #this rule may have to be after all forwarding rules however prerouting should take care of this ie untested rule.


####ALL FORWARDING DATA HERE####

#sets forwarding data
iptables -A FORWARD -i em1 -o p3p1 -j ACCEPT
iptables -A FORWARD -i p3p1 -o em1 -j ACCEPT
#setup routing for tcp and udp services
iptables -t nat -A PREROUTING -p tcp -i em1 -m multiport --dports TCPSERVICES -j DNAT --to $CLIENTIP
iptables -t nat -A PREROUTING -p udp -i em1 -m multiport --dports UDPSERV
ICES -j DNAT --to $CLIENTIP
iptables -A POSTROUTING -t nat -o em1 -j MASQUERADE

#order of operation here may be bunk with forwarding then jumping after

#jump all traffic to the appropriate chain #currently no input/outout and what not ie these can't work
#iptables -p tcp -j tcp
#iptables -p udp -j udp
#iptables -p icmp -j icmp

#TODO block wrong way syns
#TODO accept fragments
#TODO accept all packets that belong to an existing connection on allowed ports
#TODO set minimum delay for FTP and SSH Matt
#TODO set Maximim Throughput for ftp Matt
#TODO only allow new and established traffic to go through firewall 'stateful'

# set minimum delaf for FTP and SSH error on local computers
#iptables -t mangle -A FORWARD -I $WAN -d 192.168.180.0/24 -p tcp -m multiport 	--sports ssh,ftp -j tcp --set-tos 0x10

# set Maximum Throughput for ftp
#iptables -t mangle -A FORWARD -p tcp -m multiport --dports ssh,ftp -j tcp --set-tos 0x08



#block all telnet traffic
#iptables -p tcp --sport telnet -j DROP
#iptables -p tcp --dport telnet -j DROP
#ICMP Rules
#for i in ${ICMP[@]}
#do
#	iptables -A INPUT -p icmp --icmp-type ${ICMP[$i]} \ 
#		-s 0/0 -d $EXTERNALIP \ 
#		-m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#	iptables -A OUTPUT -p icmp --icmp-type ${ICMP[$i]} \
#		-s $EXTERNALIP -d 0/0 -m state \
#		--state ESTABLISHED,RELATED -j ACCEPT
#done



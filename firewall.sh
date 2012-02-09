#External Network Interface card
WAN=em1

#Internal network Interface card
LAN=p3p1

#address from internal Network
INTERNALIP=192.168.180.11

#address from external Networks
EXTERNALIP=192.168.0.11

#address to client computer
CLIENTIP=192.168.180.12

#Allowed tcp services to client computer following ports #,#,#,#,...  example 21,22,23
TCPSERVICES=22,80

#Allowed udp ports to enable services to client computer example 21,22,23
UDPSERVICES=22

#Allowed ICMP protocols 
#
#You may allow as many ICMB services as you like to pass through the firewall. #Echo reply 0 and Echo replay 8 are enabled by default.
#To set additional services set the ICMP variable to the following pattern
#
# EXAMPLE:  ICMP=( 0 1 2 )
ICMP=( 0 8 )

#####DO NOT MODIFY AFTER THIS POINT#####

#explicitly block all external traffic to these ports
BLOCKEDTCP=32768:32775,137:139,111,515,23
BLOCKEDUDP=32768:32775,137:139
#Allow ip forwarding
echo Setting IP Forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
#clear all previous settings
echo Flushing iptables
iptables -F
iptables -t mangle -F
iptables -X
#set default policies
echo Setting default policies to DROP
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

####ALL EXPLICITLY BLOCKED TRAFFIC IN THIS SECTION####
#some of these rules may be redundant may not need to specify INPUT and FORWARD FOR all need more tests to verify
#iptables -I INPUT -i $WAN -p tcp -m multiport --ports $BLOCKEDTCP -j DROP
#iptables -I INPUT -i $WAN -p udp -m multiport --ports $BLOCKEDUDP -j DROP
iptables -I FORWARD -i $WAN -p tcp -m multiport --ports $BLOCKEDTCP -j DROP
iptables -I FORWARD -i $WAN -p udp -m multiport --ports $BLOCKEDUDP -j DROP
iptables -A FORWARD -p tcp -i $WAN --tcp-flags SYN FIN -j DROP
#iptables -A INPUT -p tcp -i $WAN --tcp-flags SYN,FIN -j DROP
#iptables -A INPUT -d $LOCALIP -j DROP #this rule may have to be after all forwarding rules however prerouting should take care of this ie untested rule.

####ALL FORWARDING DATA HERE####

#sets forwarding data
echo Setting Up forwarding between nics

iptables -A FORWARD -i $WAN -o $LAN -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -i $WAN -o $LAN -m multiport --dports $TCPSERVICES -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $LAN -o $WAN -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -f -j ACCEPT


#setup routing for tcp and udp services
echo Allowing tcp services through ports: $TCPSERVICES
iptables -t nat -A PREROUTING -p tcp -i $WAN -m multiport --dports $TCPSERVICES \
	-j DNAT --to $CLIENTIP
echo Allowing udp services through ports: $UDPSERVICES
iptables -t nat -A PREROUTING -p udp -i $WAN -m multiport --dports $UDPSERVICES \
	-j DNAT --to $CLIENTIP
iptables -A POSTROUTING -t nat -o $WAN -j MASQUERADE

# set minimum delay for FTP and SSH error on local computers
echo setting minimum delay
iptables -t mangle -A FORWARD -i $WAN -d $CLIENTIP -p tcp -m multiport 	--dports ssh,ftp -j TOS --set-tos 0x10

echo Setting maximum throughput
# set Maximum Throughput for ftp
iptables -t mangle -A FORWARD -i $WAN -p tcp --dport ftp -j TOS --set-tos 0x08

#TODO ICMP

#ICMP Rules
#does not yet forward
#for i in ${ICMP[@]}
#do
#	iptables -A INPUT -p icmp --icmp-type $i -s 0/0 -d $EXTERNALIP -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
#	iptables -A OUTPUT -p icmp --icmp-type $i -s $EXTERNALIP -d 0/0 -m state --state ESTABLISHED,RELATED -j ACCEPT
#done

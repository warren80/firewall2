i=0
ICMP=( 0 8 )
for i in ${ICMP[@]}
do
echo	iptables -A INPUT -p icmp --icmp-type $i -j ACCEPT
echo	iptables -A OUTPUT -p icmp --icmp-type $i -j ACCEPT
	echo $i
done


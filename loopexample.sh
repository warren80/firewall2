i=0
ICMP=( 0 8 )
for i in ${ICMP[@]}
do
	echo iptables -A INPUT -p icmp --icmp-type ${ICMP[$i - 1]} -j ACCEPT
	echo iptables -A OUTPUT -p icmp --icmp-type ${ICMP[$i - 1]} -j ACCEPT
done


while :
do
	echo moo
done

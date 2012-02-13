#!/bin/sh

# script tests all the banned ports and SYN+FIN and "on the outside looking in"
# starts a SSH to test mangle
# could use a FTP to show more mangle?
# 
# NEEDS TEST FOR WORKING CONDITIONS


target=192.168.0.100
internalAddr=192.168.180.1
port=0
numOfPings=1
udpBANNED=( 137 138 139 32768 32769 32770 32771 32772 32773 32773 32775 )
tcpBANNED=( 111 137 138 139 515 32768 32769 32770 32771 32772 32773 32774 32775 )
icmpBANNED=( 0 8 )
expected=100% packet loss
udpPASS=( 1 )
tcpPASS=( 22 80 )
icmpPASS=( 1 )
echo Target is 8006 asn2 firewall at $target
echo The following tests are packets of BANNED ports and types.
echo The expected result is that all packets are lost.

# tests udp banned ports
for port in ${udpBANNED[@]}
do
    echo udp on port $port
    results=`hping3 $target -2 -p $port -c $numOfPings 2>&1 >/dev/null | grep -o '100% packet loss'`

    if [ "$results" == "100% packet loss" ]
    then
        echo $results. PASS
    else
        echo $results. FAIL
    fi
done

# test tcp banned ports
for port in ${tcpBANNED[@]}
do	
    echo tcp on port $port
    results=`hping3 $target -p $port -c $numOfPings 2>&1 >/dev/null | grep -o '100% packet loss'`

    if [ "$results" == "100% packet loss" ]
    then
        echo $results. PASS
    else
        echo $results. FAIL
    fi
done

# test icmp banned types
for type in ${icmpBANNED[@]}
do
    echo icmp of type $type
    results=`hping3 $target -1 --icmptype $type -c $numOfPings 2>&1 > /dev/null | grep -o '100% packet loss'`

    if [ "$results" == "100% packet loss" ]
    then
        echo $results. PASS
    else
        echo $results. FAIL
    fi
	
done

# test tcp FYN + SYN
echo tcp packet with SYN and FIN set
results=`hping3 $target --fin --syn -c $numOfPings 2>&1 > /dev/null | grep -o '100% packet loss'`

if [ "$results" == "100% packet loss" ]
then
    echo $results. PASS
else
    echo $results. FAIL
fi

# test a packet that is on the outside looking in
echo tcp packet from outside with internal source address
echo To check this test run \'iptables -L -v\' on $target to see that the packet was dropped.
echo Press any key to send a packet.
read -n1 -s
results=`hping3 $target -a $internalAddr -c $numOfPings 2>&1 > /dev/null`
echo Packet sent.

# test udp pass ports
echo Testing allowed udp ports
for port in ${udpPASS[@]}
do	
    echo udp on port $port
    results=`hping3 $target -2 -p $port -c $numOfPings 2>&1 >/dev/null | grep -o '100% packet loss'`

    if [ "$results" == "100% packet loss" ]
    then
        echo $results. FAIL
    else
        echo $results. PASS
    fi
done


# test tcp pass ports
echo Testing allowed tcp ports
for port in ${tcpPASS[@]}
do	
    echo tcp on port $port
    results=`hping3 $target -p $port -c $numOfPings 2>&1 >/dev/null | grep -o '100% packet loss'`

    if [ "$results" == "100% packet loss" ]
    then
        echo $results. FAIL
    else
        echo $results. PASS
    fi
done

# test icmp pass types
echo Testing allowed icmp types
for type in ${icmpPASS[@]}
do	
    echo icmp on port $type
    results=`hping3 $target-1 --icmptype $type -c $numOfPings 2>&1 >/dev/null | grep -o '100% packet loss'`

    if [ "$results" == "100% packet loss" ]
    then
        echo $results. FAIL
    else
        echo $results. PASS
    fi
done

# test ssh minimum delay
echo ssh mangled to minimum delay
echo Press any key to start an ssh session with the target
read -n1 -s
ssh $target

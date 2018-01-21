#!/bin/bash
myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
myint=`ifconfig | grep -B1 "inet addr:$myip" | head -n1 | awk '{print $1}'`;


#needed by openvpn-nl
apt-get -y install apt-transport-https

#adding source list
echo "deb https://openvpn.fox-it.com/repos/deb wheezy main" > /etc/apt/sources.list.d/foxit.list
apt-get update
wget https://openvpn.fox-it.com/repos/fox-crypto-gpg.asc
apt-key add fox-crypto-gpg.asc

apt-get update
cd /root

#installing normal openvpn, easy rsa & openvpn-nl
apt-get install easy-rsa -y
apt-get install openvpn -y
apt-get install openvpn-nl -y

#ipforward
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
iptables -F
iptables -t nat -F
iptables -t nat -A POSTROUTING -s 10.8.0.0/16 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.16.0.0/16 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.1.0.0/16 -o eth0 -j MASQUERADE
iptables-save

#fast setup with old keys, optional if we want new key
cd /
wget https://raw.githubusercontent.com/zero9911/script/master/script/ovpn.tar
tar -xvf ovpn.tar
rm ovpn.tar

wget -O /etc/rc.local "https://raw.githubusercontent.com/rasta-team/Debian_V1/master/rc.local";chmod +x /etc/rc.local

#config upload
wget -O /home/vps/public_html/client.ovpn "https://raw.githubusercontent.com/zero9911/script/master/script/max.ovpn"
sed -i "s/ipserver/$myip/g" /home/vps/public_html/client.ovpn

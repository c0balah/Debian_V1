#!/bin/bash
myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`;
myint=`ifconfig | grep -B1 "inet addr:$myip" | head -n1 | awk '{print $1}'`;


# install openvpn
apt-get install openvpn -y
wget -O /etc/openvpn/openvpn.tar "https://raw.github.com/yusuf-ardiansyah/debian/master/conf/openvpn-debian.tar"
cd /etc/openvpn/
tar xf openvpn.tar
#wget -O /etc/openvpn/1194.conf "https://raw.github.com/yusuf-ardiansyah/debian/master/conf/1194.conf"
wget -O /etc/openvpn/1194.conf "https://raw.githubusercontent.com/rasta-team/Full-Debian7-32bit/master/1194.conf"
service openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

#wget -O /etc/iptables.conf "https://raw.github.com/yusuf-ardiansyah/debian/master/conf/iptables.conf"
wget -O /etc/iptables.conf "https://raw.githubusercontent.com/rasta-team/Full-Debian7-32bit/master/iptables.conf"
sed -i '$ i\iptables-restore < /etc/iptables.conf' /etc/rc.local

myip2="s/ipserver/$myip/g";
sed -i $myip2 /etc/iptables.conf;

iptables-restore < /etc/iptables.conf
service openvpn restart

# configure openvpn client config
cd /etc/openvpn/
#wget -O /etc/openvpn/1194-client.ovpn "https://raw.github.com/yusuf-ardiansyah/debian/master/conf/1194-client.conf"
wget -O /etc/openvpn/1194-client.ovpn "https://raw.githubusercontent.com/rasta-team/Full-Debian7-32bit/master/1194-client.conf"
usermod -s /bin/false mail
echo "mail:ardy" | chpasswd
useradd -s /bin/false -M ardiansyah
echo "ardiansyah:ardy" | chpasswd
#tar cf client.tar 1194-client.ovpn
cp /etc/openvpn/1194-client.ovpn /home/vps/public_html/
sed -i $myip2 /home/vps/public_html/1194-client.ovpn
sed -i "s/ports/55/" /home/vps/public_html/1194-client.ovpn
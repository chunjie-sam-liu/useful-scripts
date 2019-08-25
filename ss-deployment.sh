# get shadowsocks
wget https://raw.githubusercontent.com/chunjie-sam-liu/useful-scripts/master/ss.sh

# install shadowsocks
chmod a+x ss.sh
bash ss.sh
# specify password: password
# connecting port: 1070
# encryption: aes-256-cfb - 7

# open filewall
firewall-cmd --permanent --zone=public --add-port=1070/tcp
firewall-cmd --reload

# echo ipv4
echo "echo 3 > /proc/sys/net/ipv4/tcp_fastopen" >> /etc/rc.local
echo "net.ipv4.tcp_fastopen = 3" >> /etc/sysctl.conf

# restart shadowsocks
/etc/init.d/shadowsocks restart

# google scholar ipv6
echo "2404:6800:4008:c06::be scholar.google.com" >> /etc/hosts
echo "2404:6800:4008:c06::be scholar.google.com.hk" >> /etc/hosts
echo "2404:6800:4008:c06::be scholar.google.com.tw" >> /etc/hosts

# restart shadowsocks
/etc/init.d/shadowsocks restart

# run bbr
wget --no-check-certificate https://raw.githubusercontent.com/chunjie-sam-liu/useful-scripts/master/ss-bbr.sh
chmod +x ss-bbr.sh
bash ss-bbr.sh



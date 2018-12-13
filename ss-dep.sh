wget https://raw.githubusercontent.com/chunjie-sam-liu/useful-scripts/master/shadowsocks.sh

chmod a+xshadowsocks.sh && ./shadowsocks.sh


firewall-cmd --permanent --zone=public --add-port=1070/tcp
firewall-cmd --reload

echo "echo 3 > /proc/sys/net/ipv4/tcp_fastopen" >> /etc/rc.local 
echo "net.ipv4.tcp_fastopen = 3" >> /etc/sysctl.conf 

/etc/init.d/shadowsocks restart

wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh && chmod +x bbr.sh && ./bbr.sh 
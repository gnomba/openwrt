#!/bin/sh
# INFO: https://lsetc.ru/openwrt-otkljuchit-ipv6/

set -x

#uci set network.lan.ipv6='0'
#uci set network.wan.ipv6='0'
#uci set dhcp.lan.dhcpv6='disabled'
#uci -q delete dhcp.lan.dhcpv6
#uci -q delete dhcp.lan.ra
#uci set network.lan.delegate='0'
#uci -q delete network.globals.ula_prefix
#uci delete network.wan6
#/etc/init.d/odhcpd disable
#/etc/init.d/odhcpd stop
#uci commit network
#/etc/init.d/network restart

vNAME="disable_ipv6"
vSERVICE_FILE="/etc/init.d/${vNAME}"

uci delete network.wan6
uci commit network

echo 1 > /proc/sys/net/ipv6/conf/all/${vNAME}

echo -e "#!/bin/sh /etc/rc.common\n" > ${vSERVICE_FILE}
echo -e "START=11\n" >> ${vSERVICE_FILE}
echo -e "start() {" >> ${vSERVICE_FILE}
echo -e "    sysctl -wq \\" >> ${vSERVICE_FILE}
echo -e "    net.ipv6.conf.all.${vNAME}=1 \\" >> ${vSERVICE_FILE}
echo -e "    net.ipv6.conf.default.${vNAME}=1 \\" >> ${vSERVICE_FILE}
echo -e "    net.ipv6.conf.lo.${vNAME}=1" >> ${vSERVICE_FILE}
echo -e "}\n" >> ${vSERVICE_FILE}
#echo "exit 0" >> ${vSERVICE_FILE}

chmod +x ${vSERVICE_FILE}
echo " ### enable service ${vNAME} ###"
service ${vNAME} enable
echo " ### start service ${vNAME} ###"
service ${vNAME} start

echo " ### restart network ###"
/etc/init.d/network restart

exit 0

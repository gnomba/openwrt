#!/bin/sh
# INFO: https://lsetc.ru/openwrt-otkljuchit-ipv6/
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
#uci commit
#/etc/init.d/network restart

set -x

uci delete network.wan6
uci commit network

echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6

vSERVICE_FILE="/etc/init.d/disable_ipv6"

echo -e "#!/bin/sh /etc/rc.common\n\n" > ${vSERVICE_FILE}
echo -e "START=11\n\n" >> ${vSERVICE_FILE}
echo -e "start() {\n" >> ${vSERVICE_FILE}
echo -e "    sysctl -wq \\\n" >> ${vSERVICE_FILE}
echo -e "    net.ipv6.conf.all.disable_ipv6=1 \\\n" >> ${vSERVICE_FILE}
echo -e "    net.ipv6.conf.default.disable_ipv6=1 \\n" >> ${vSERVICE_FILE}
echo -e "    net.ipv6.conf.lo.disable_ipv6=1\n" >> ${vSERVICE_FILE}
echo -e "}\n\n" >> ${vSERVICE_FILE}
echo "exit 0" >> ${vSERVICE_FILE}

chmod +x ${vSERVICE_FILE}

/etc/init.d/network restart

exit 0

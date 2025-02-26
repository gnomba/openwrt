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
#uci commit
#/etc/init.d/network restart

echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6

sysctl -wq \
net.ipv6.conf.all.disable_ipv6=1 \
net.ipv6.conf.default.disable_ipv6=1 \
net.ipv6.conf.lo.disable_ipv6=1

exit 0

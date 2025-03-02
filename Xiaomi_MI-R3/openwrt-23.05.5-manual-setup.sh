### uci-defaults Xiaomi MI-R3 ###
### openwrt-23.05.5-ramips-mt7620-xiaomi_miwifi-r3-squashfs-sysupgrade.bin ###

set -x

opkg remove --force-depends dnsmasq luci-proto-ipv6 odhcp6c odhcpd-ipv6only 
opkg update
opkg install dnsmasq-full libnettle8 libgmp10 libnetfilter-conntrack3 libnfnetlink0 kmod-nf-conntrack-netlink kmod-nf-conntrack6 kmod-nf-log6 kmod-nf-reject6
opkg update
opkg install curl libcurl4 libnghttp2-14
opkg install wget-ssl libpcre2 zlib libopenssl3 libatomic1 librt
opkg install zram-swap kmod-zram
opkg install luci-i18n-base-ru luci-i18n-firewall-ru luci-i18n-opkg-ru
opkg install adblock luci-app-adblock luci-i18n-adblock-ru coreutils coreutils-sort coreutils-uniq gawk libncurses6 terminfo libreadline8 rpcd-mod-rpcsys
opkg install https-dns-proxy luci-app-https-dns-proxy luci-i18n-https-dns-proxy-ru libcares libev resolveip
opkg install ddns-scripts ddns-scripts-services luci-app-ddns luci-i18n-ddns-ru
opkg install igmpproxy

curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_fantastic-packages.sh | sh
curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_argon-theme.sh | sh
curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/disable_ipv6.sh | sh


ip a | grep 'state\|ether'
last_4_mac_brlan="$(ip a show br-lan | grep 'link/ether' | sed 's/ brd.*$//g' | awk -F':' '{print toupper($5$6)}')"
echo "last_4_mac_brlan=${last_4_mac_brlan}"
wlan_name_2g="Xiaomi_${last_4_mac_brlan}"
echo "wlan_name_2g='${wlan_name_2g}'"
wlan_name_5g="Xiaomi_${last_4_mac_brlan}_5G"
echo "wlan_name_5g=${wlan_name_5g}"
wlan_password="1234567890"
echo "wlan_password=${wlan_password}"
wlan_mode="ap"
echo "wlan_mode=${wlan_mode}"
wlan_encryption="psk2"
echo "wlan_encryption=${wlan_encryption}"

root_password="${wlan_password}"
echo "root_password=${root_password}"
lan_ip_address="192.168.31.1"
echo "lan_ip_address=${lan_ip_address}"

if [ -n "${root_password}" ]; then
  (echo "${root_password}"; sleep 1; echo "${root_password}") | passwd > /dev/null
fi

# system #
uci set system.@system[0].hostname=${wlan_name_2g}
uci set system.@system[0].timezone='MSK-3'
uci set system.@system[0].log_size='64'
uci set system.@system[0].zonename='Europe/Moscow'
uci set system.@system[0].zram_comp_algo='lz4'
uci set system.ntp.server='3.ru.pool.ntp.org 2.ru.pool.ntp.org 1.ru.pool.ntp.org 0.ru.pool.ntp.org'
uci commit system

# system led #
# нада разобраться со шморгалкой :-)
#add system led
#set system.@led[0].name='wan-on'
#set system.@led[0].sysfs='green:power'
#set system.@led[0].trigger='netdev'
#set system.@led[0].dev='wan'
#set system.@led[0].mode='link'
#commit system

# wireless #
# 5GHz #
uci set wireless.radio0.disabled='0'
uci set wireless.radio0.country='RU'
uci set wireless.radio0.channel='auto'
uci set wireless.radio0.band='5g'
uci set wireless.radio0.htmode='VHT80'
uci set wireless.default_radio0.device='radio0'
uci set wireless.default_radio0.network='lan'
uci set wireless.default_radio0.ssid=${wlan_name_5g}
uci set wireless.default_radio0.mode=${wlan_mode}
uci set wireless.default_radio0.encryption=${wlan_encryption}
uci set wireless.default_radio0.key=${wlan_password}
# 2.4GHz #
uci set wireless.radio1.disabled='0'
uci set wireless.radio1.country='RU'
uci set wireless.radio1.channel='auto'
uci set wireless.radio1.band='2g'
uci set wireless.radio1.htmode='HT40'
uci set wireless.radio1.legacy_rates='1'
uci set wireless.default_radio1.device='radio1'
uci set wireless.default_radio1.network='lan'
uci set wireless.default_radio1.ssid=${wlan_name_2g}
uci set wireless.default_radio1.mode=${wlan_mode}
uci set wireless.default_radio1.encryption=${wlan_encryption}
uci set wireless.default_radio1.key=${wlan_password}
uci commit wireless

# network #
uci set network.lan.ipaddr=${lan_ip_address}
uci set network.lan.netmask='255.255.255.0'
uci commit network

# adblock #
uci set adblock.global.adb_trigger='wan'
uci commit adblock

# https-dns-proxy #
while uci -q delete https-dns-proxy.@https-dns-proxy[0]; do :; done
uci set https-dns-proxy.config.force_dns='1'
uci set https-dns-proxy.config.canary_domains_icloud='1'
uci set https-dns-proxy.config.canary_domains_mozilla='1'
uci add https-dns-proxy https-dns-proxy
uci set https-dns-proxy.@https-dns-proxy[0].resolver_url='https://cloudflare-dns.com/dns-query'
uci set https-dns-proxy.@https-dns-proxy[0].bootstrap_dns='1.1.1.1,1.0.0.1'
uci set https-dns-proxy.@https-dns-proxy[0].listen_addr='127.0.0.1'
uci set https-dns-proxy.@https-dns-proxy[0].listen_port='5053'
uci set https-dns-proxy.@https-dns-proxy[0].user='nobody'
uci set https-dns-proxy.@https-dns-proxy[0].group='nogroup'
uci add https-dns-proxy https-dns-proxy
uci set https-dns-proxy.@https-dns-proxy[1].resolver_url='https://dns.google/dns-query'
uci set https-dns-proxy.@https-dns-proxy[1].bootstrap_dns='8.8.4.4,8.8.8.8'
uci set https-dns-proxy.@https-dns-proxy[1].listen_addr='127.0.0.1'
uci set https-dns-proxy.@https-dns-proxy[1].listen_port='5054'
uci set https-dns-proxy.@https-dns-proxy[1].user='nobody'
uci set https-dns-proxy.@https-dns-proxy[1].group='nogroup'
uci add https-dns-proxy https-dns-proxy
uci set https-dns-proxy.@https-dns-proxy[2].resolver_url='https://common.dot.dns.yandex.net/dns-query'
uci set https-dns-proxy.@https-dns-proxy[2].bootstrap_dns='77.88.8.8,77.88.8.1'
uci set https-dns-proxy.@https-dns-proxy[2].listen_addr='127.0.0.1'
uci set https-dns-proxy.@https-dns-proxy[2].listen_port='5055'
uci set https-dns-proxy.@https-dns-proxy[2].user='nobody'
uci set https-dns-proxy.@https-dns-proxy[2].group='nogroup'
uci add https-dns-proxy https-dns-proxy
uci set https-dns-proxy.@https-dns-proxy[3].resolver_url='https://router.comss.one/dns-query'
uci set https-dns-proxy.@https-dns-proxy[3].bootstrap_dns='195.133.25.16,212.109.195.93,83.220.169.155'
uci set https-dns-proxy.@https-dns-proxy[3].listen_addr='127.0.0.1'
uci set https-dns-proxy.@https-dns-proxy[3].listen_port='5056'
uci set https-dns-proxy.@https-dns-proxy[3].user='nobody'
uci set https-dns-proxy.@https-dns-proxy[3].group='nogroup'
uci commit https-dns-proxy

/etc/init.d/rpcd restart
/etc/init.d/https-dns-proxy enable
/etc/init.d/https-dns-proxy restart

# dnsmasq #
uci get dhcp.@dnsmasq[0] || uci add dhcp dnsmasq
uci set dhcp.@dnsmasq[0].cachesize='2048'
uci set dhcp.@dnsmasq[0].dnsforwardmax='2048'
uci set dhcp.@dnsmasq[0].min_cache_ttl="600"
uci set dhcp.@dnsmasq[0].max_cache_ttl="86400"
uci set dhcp.@dnsmasq[0].nonegcache='1'
vVIA_COMSS_LIST="comss.ru comss.one"
for vCOMSS_ITEM in ${vVIA_COMSS_LIST}; do
    uci add_list dhcp.@dnsmasq[0].server="/*.${vCOMSS_ITEM}/127.0.0.1#5056"
done
uci commit dhcp

# firewall fix mtu #
[ "$(uci get firewall.@zone[0].name 2>/dev/null)" = "lan" ] && {
    [ "$(uci get firewall.@zone[0].mtu_fix 2>/dev/null)" = "1" ] || uci set firewall.@zone[0].mtu_fix='1'
}
uci commit firewall
/etc/init.d/firewall restart

# network         #
# packet steering #
uci get network.globals.packet_steering > /dev/null || {
    uci set network.globals='globals'
    uci set network.globals.packet_steering=1
    uci commit network
}

echo "# ddns #"
uci delete ddns.myddns_ipv6
uci commit ddns
/etc/init.d/ddns disable
/etc/init.d/ddns stop

echo "# igmpproxy #"
/etc/init.d/igmpproxy disable
/etc/init.d/igmpproxy stop

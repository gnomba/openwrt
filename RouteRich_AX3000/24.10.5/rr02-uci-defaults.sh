#!/bin/sh
### uci-defaults RouteRich AX3000 [USB2.0] ###
setup_log="/tmp/setup.log"
echo "# log potential errors: $setup_log"
exec >$setup_log 2>&1
set -x
. /etc/os-release
lsmod | grep mt7
ip l
passw0rd="1234567890"

rr_mod() {
    etc_rclocal="/etc/rc.local"
    echo 'RR-3.9.0' > /etc/routerich_release
    echo '# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.
sleep 5
for i in sing-box stubby doh-proxy dns-failsafe-proxy; do
	/etc/init.d/${i} enable
	/etc/init.d/${i} reload
	/etc/init.d/${i} restart
done
exit 0' > $etc_rclocal
}

add_repository() {
    distfeeds_conf="/etc/opkg/distfeeds.conf"
    customfeeds_conf="/etc/opkg/customfeeds.conf"
    etc_opkg_keys="/etc/opkg/keys"
    mkdir -pv $etc_opkg_keys 2>/dev/null
    ### for Routerich Packages ###
    rrver="24.10.5"
    repo_url="src/gz routerich https://github.com/routerich/packages.routerich/raw/$rrver/routerich"
    sed -i 's/^src\/gz openwrt_core/#src\/gz openwrt_core/' $distfeeds_conf
	sed -i "1a src\/gz routerich_core https:\/\/github.com\/routerich\/packages.routerich\/raw\/$rrver\/core" $distfeeds_conf
	if ! grep -qF "$repo_url" "$distfeeds_conf"; then
        echo "$repo_url" >> "$distfeeds_conf"
    fi
	sed -i '/^src\/gz routerich http/d' $customfeeds_conf
    KEYID_r=2e724001fb65916f
    cat <<- PUBKEYR > $etc_opkg_keys/$KEYID_r
untrusted comment: Public usign key for ${rrver:0:5} release builds
RWQuckAB+2WRb9rwzhWarTedFmsvy8y5kxAS3A0KXe3yUou9V/Nfbqty
PUBKEYR
}

is_rr_inited() {
	[ -f /etc/config/.rr-init ]
}

add_rr_version() {
	if opkg list-installed | grep -q '^luci-app-attendedsysupgrade -'; then
		v="ASU"
	elif [ -s /etc/routerich_release ]; then
		v="$(cat /etc/routerich_release)"
	else
		return 0
	fi
	if ! grep -qF "$v" /etc/openwrt_release; then
		sed -i "s|\(DISTRIB_DESCRIPTION='[^']*\)'|\1 $v'|" /etc/openwrt_release
	fi
	if ! grep -qF "$v" /usr/lib/os-release; then
		sed -i "s|\(OPENWRT_RELEASE=\"[^\"]*\)\"|\1 $v\"|" /usr/lib/os-release
	fi
}

set_wan() {
    BOARD_NAME=$(ubus call system board | jsonfilter -e '@.board_name')
	case "$BOARD_NAME" in
		routerich,ax3000)
			WANDEV="wan"
			;;
		routerich,ax3000-v1)
			WANDEV="eth1"
			;;
		*)
			WANDEV="wan"
			;;
	esac
	MAC=$(cat /sys/class/net/$WANDEV/address)
	echo "$WANDEV" > /tmp/dev_wan.txt
    echo "$MAC" | awk -F: '{print toupper($5$6)}' > /tmp/last_4_mac_wan.txt
	last_4_mac_wan="$(cat /tmp/last_4_mac_wan.txt)"
	echo "WANDEV=$WANDEV"
    echo "MAC=$MAC"
    echo "last_4_mac_wan=$last_4_mac_wan"
	FOUND=""
	for s in $(uci show network | grep "=device" | sed -E 's/([^=]+)=device.*/\1/'); do
		name=$(uci -q get $s.name)
		if [ "$name" = "$WANDEV" ]; then
			FOUND="$s"
			break
		fi
	done
	if [ -n "$FOUND" ]; then
		CURRENT_MAC=$(uci -q get $FOUND.macaddr)
		if [ -z "$CURRENT_MAC" ]; then
			uci -q set $FOUND.macaddr="$MAC"
		fi
	else
		uci add network device >/dev/null
		uci -q set network.@device[-1].name="$WANDEV"
		uci -q set network.@device[-1].macaddr="$MAC"
	fi
	uci commit network
}

set_packet_steering() {
	is_rr_inited && return
	uci -q set network.globals.packet_steering='2'
	uci commit network
}

set_hw_offloading() {
	is_rr_inited && return
	uci -q del firewall.@defaults[0].syn_flood 2>/dev/null
	uci -q set firewall.@defaults[0].synflood_protect='1'
	uci -q set firewall.@defaults[0].flow_offloading='1'
	uci -q set firewall.@defaults[0].flow_offloading_hw='1'
	uci commit firewall
}

set_offload_delay() {
	sed -i 's/meta l4proto { tcp, udp } flow offload @ft;/meta l4proto { tcp, udp } ct original packets ge 30 flow offload @ft;/' /usr/share/firewall4/templates/ruleset.uc
}

set_firewall() {
	for s in $(uci show firewall | grep '=zone' | sed -E 's/([^=]+)=.*/\1/'); do
		name=$(uci -q get $s.name)
		[ "$name" = "wan" ] || continue
		current="$(uci -q get $s.network)"
		for proto in pppoe l2tp pptp; do
			found=0
			for n in $current; do
				[ "$n" = "$proto" ] && found=1
			done
			[ $found -eq 0 ] && uci add_list $s.network="$proto"
		done
	done
	uci commit firewall
}

set_upnp() {
	is_rr_inited && return
	uci -q set upnpd.config.enabled='1'
	uci -q set upnpd.config.enable_natpmp='1'
	uci -q set upnpd.config.enable_upnp='1'
	uci -q set upnpd.config.secure_mode='1'
	uci -q set upnpd.config.log_output='0'
	uci -q set upnpd.config.igdv1='1'
	uci -q set upnpd.config.ipv6_disable='1'
	uci commit upnpd
}

set_luci_nas() {
	cat <<EOF > /usr/share/luci/menu.d/luci-nas.json
{
	"admin/nas": {
		"title": "NAS",
		"order": 44
	}
}
EOF
}

set_ntp() {
	is_rr_inited && return
	uci set system.ntp.server=''
	uci set system.ntp.server='89.109.251.21 194.190.168.1 93.90.103.9 185.211.244.47 93.95.98.77 90.188.9.144'
	uci commit system
}

set_wifi() {
	last_4_mac_wan="$(cat /tmp/last_4_mac_wan.txt)"
	echo "last_4_mac_wan=$last_4_mac_wan"
	wlan_name_2g="RouteRich_${last_4_mac_wan}"
	wlan_name_5g="${wlan_name_2g}_5G"
	wlan_mode="ap"
	wlan_encryption="psk2"
	echo "last_4_mac_wan=$last_4_mac_wan"
	echo "wlan_name_2g='$wlan_name_2g'"
	echo "wlan_name_5g=$wlan_name_5g"
	echo "wlan_mode=$wlan_mode"
	echo "wlan_encryption=$wlan_encryption"
	# 2.4GHz #
	uci set wireless.radio0.disabled='0'
	uci set wireless.radio0.country='RU'
	uci set wireless.radio0.channel='auto'
	uci set wireless.radio0.band='2g'
	uci set wireless.radio0.htmode='HE40'
	uci set wireless.radio0.cell_density='0'
	uci set wireless.default_radio0.device='radio0'
	uci set wireless.default_radio0.network='lan'	
	uci set wireless.default_radio0.ssid="$wlan_name_2g"
	uci set wireless.default_radio0.mode="$wlan_mode"
	uci set wireless.default_radio0.encryption="$wlan_encryption"
	uci set wireless.default_radio0.key="$passw0rd"
	uci set wireless.default_radio0.dtim_period='3'
	uci set wireless.default_radio0.wpa_group_rekey='86400'
	# 5GHz #
	uci set wireless.radio1.disabled='0'
	uci set wireless.radio1.country='RU'
	uci set wireless.radio1.channel='auto'
	uci set wireless.radio1.band='5g'
	uci set wireless.radio1.htmode='HE160'
	uci set wireless.radio1.cell_density='0'
	uci set wireless.default_radio1.device='radio1'
	uci set wireless.default_radio1.network='lan'
	uci set wireless.default_radio1.ssid="$wlan_name_5g"
	uci set wireless.default_radio1.mode="$wlan_mode"
	uci set wireless.default_radio1.encryption="$wlan_encryption"
	uci set wireless.default_radio1.key="$passw0rd"
	uci set wireless.default_radio1.dtim_period='3'
	uci set wireless.default_radio1.wpa_group_rekey='86400'
	uci commit wireless
	wifi
}

set_system() {
	last_4_mac_wan="$(cat /tmp/last_4_mac_wan.txt)"
	echo "last_4_mac_wan=$last_4_mac_wan"
	hostname="RouteRich_${last_4_mac_wan}"
	uci -q set system.@system[0].hostname=$hostname
	uci -q set system.@system[0].timezone='MSK-3'
	uci -q set system.@system[0].log_size='128'
	uci -q set system.@system[0].zonename='Europe/Moscow'
	uci -q set system.@system[0].zram_comp_algo='lz4'
	uci commit system
	/etc/init.d/system reload 2>/dev/null
	uci set network.lan.ipaddr='192.168.1.1'
	uci set network.lan.netmask='255.255.255.0'
	uci commit network
	if [ -n "${passw0rd}" ]; then
		(echo "${passw0rd}"; sleep 1; echo "${passw0rd}") | passwd > /dev/null
	fi
	/etc/init.d/network restart 2>/dev/null
}

set_dnsmasq() {
	is_rr_inited && return
	uci -q del dhcp.@dnsmasq[0].filterwin2k 2>/dev/null
	uci -q del dhcp.@dnsmasq[0].filter_a 2>/dev/null
	uci -q del dhcp.@dnsmasq[0].filter_aaaa 2>/dev/null
	uci -q set dhcp.@dnsmasq[0].cachesize='0' 2>/dev/null
	uci -q set dhcp.@dnsmasq[0].nonegcache='1' 2>/dev/null
	uci -q set dhcp.@dnsmasq[0].confdir='/tmp/dnsmasq.d' 2>/dev/null
	vVIA_COMSS_LIST="comss.ru comss.one chatgpt.com oaistatic.com oaiusercontent.com openai.com microsoft.com windowsupdate.com bing.com supercell.com supercellid.com supercellgames.com clashroyale.com brawlstars.com clash.com clashofclans.com x.ai grok.com github.com forzamotorsport.net forzaracingchampionship.com forzarc.com gamepass.com orithegame.com renovacionxboxlive.com tellmewhygame.com xbox.co xbox.com xbox.eu xbox.org xbox360.co xbox360.com xbox360.eu xbox360.org xboxab.com xboxgamepass.com xboxgamestudios.com xboxlive.cn xboxlive.com xboxone.co xboxone.com xboxone.eu xboxplayanywhere.com xboxservices.com xboxstudios.com xbx.lv sentry.io usercentrics.eu recaptcha.net gstatic.com brawlstarsgame.com"
	for vCOMSS_ITEM in ${vVIA_COMSS_LIST}; do
    	uci add_list dhcp.@dnsmasq[0].server="/*.${vCOMSS_ITEM}/127.0.0.1#5056"
	done
	while uci -q delete dhcp.@domain[0]; do :; done
	vDHCP_DOMAIN_LIST="chatgpt.com openai.com webrtc.chatgpt.com ios.chat.openai.com searchgpt.com"
	for vDOMAIN_ITEM in ${vDHCP_DOMAIN_LIST}; do
    	uci add dhcp domain
    	uci set dhcp.@domain[-1].name="${vDOMAIN_ITEM}"
    	uci set dhcp.@domain[-1].ip="83.220.169.155"
	done
	uci commit dhcp
}

set_ttyd() {
	uci -q set ttyd.@ttyd[-1].debug='0'
	uci -q set ttyd.@ttyd[-1].credential=root:"$passw0rd"
	uci -q set ttyd.@ttyd[-1].uid='0'
	uci -q set ttyd.@ttyd[-1].gid='0'
	uci commit ttyd
}

set_ksmbd() {
	is_rr_inited && return
	MEM_KB=$(awk '/MemTotal/ { print $2 }' /proc/meminfo)
	uci -q set ksmbd.@globals[0].description='RouteRich Share'
	uci commit ksmbd
	buf_size=$( [ "$MEM_KB" -gt 480000 ] && echo "8MB" || ( [ "$MEM_KB" -gt 230000 ] && echo "4MB" || echo "2MB" ) )
	cat <<EOF >/etc/ksmbd/ksmbd.conf.template
[global]
	netbios name = |NAME|
	server string = |DESCRIPTION|
	workgroup = |WORKGROUP|
	interfaces = |INTERFACES|
	bind interfaces only = yes
	ipc timeout = 20
	deadtime = 15
	map to guest = Bad User
	smb2 max read = $buf_size
	smb2 max write = $buf_size
	smb2 max trans = $buf_size
	cache read buffers = yes
	cache trans buffers = yes
EOF
	sed -i 's/^\s*enable-reflector\s*=\s*no/enable-reflector=yes/' /etc/avahi/avahi-daemon.conf
}

set_pptp() {
	is_rr_inited && return
	sed -i 's/^mppe/#mppe/' /etc/ppp/options.pptp
	echo nomppe >> /etc/ppp/options.pptp
}

set_doh() {
	is_rr_inited && return
	if opkg list-installed | grep -q '^https-dns-proxy -'; then
		while uci -q delete https-dns-proxy.@https-dns-proxy[0]; do :; done
		uci set https-dns-proxy.config.force_dns='1'
		uci set https-dns-proxy.config.canary_domains_icloud='1'
		uci set https-dns-proxy.config.canary_domains_mozilla='1'
		uci set https-dns-proxy.config.user='nobody'
		uci set https-dns-proxy.config.group='nogroup'
		uci set https-dns-proxy.config.listen_addr='127.0.0.1'
		uci add https-dns-proxy https-dns-proxy
		uci set https-dns-proxy.@https-dns-proxy[-1].resolver_url='https://router.comss.one/dns-query'
		uci set https-dns-proxy.@https-dns-proxy[-1].bootstrap_dns='195.133.25.16,212.109.195.93,83.220.169.155'
		uci set https-dns-proxy.@https-dns-proxy[-1].listen_addr='127.0.0.1'
		uci set https-dns-proxy.@https-dns-proxy[-1].listen_port='5056'
		uci commit https-dns-proxy
		/etc/init.d/https-dns-proxy enable 2>/dev/null
		/etc/init.d/https-dns-proxy start 2>/dev/null
	fi
}

set_dot() {
	is_rr_inited && return
	if opkg list-installed | grep -q '^stubby -'; then
		uci -q del stubby.global.trigger
		uci add_list stubby.global.trigger='wan'
		uci add_list stubby.global.trigger='wan6'
		uci add_list stubby.global.trigger='pppoe'
		uci add_list stubby.global.trigger='l2tp'
		uci add_list stubby.global.trigger='pptp'
		uci add_list stubby.global.trigger='modem'
		uci add_list stubby.global.trigger='wwan'
		uci add_list stubby.global.trigger='wwan0'
		uci -q set stubby.global.log_level='3'
		uci -q set stubby.global.round_robin_upstreams='0'
		while uci show stubby | grep -q 'stubby.@resolver'; do
			uci -q del stubby.@resolver[0]
		done
		uci add stubby resolver >/dev/null 2>&1
		uci -q set stubby.@resolver[-1].address='94.140.14.14'
		uci -q set stubby.@resolver[-1].tls_auth_name='dns.adguard.com'
		uci add stubby resolver >/dev/null 2>&1
		uci -q set stubby.@resolver[-1].address='94.140.15.15'
		uci -q set stubby.@resolver[-1].tls_auth_name='dns.adguard.com'
		uci add stubby resolver >/dev/null 2>&1
		uci -q set stubby.@resolver[-1].address='2a10:50c0::ad1:ff'
		uci -q set stubby.@resolver[-1].tls_auth_name='dns.adguard.com'
		uci add stubby resolver >/dev/null 2>&1
		uci -q set stubby.@resolver[-1].address='2a10:50c0::ad2:ff'
		uci -q set stubby.@resolver[-1].tls_auth_name='dns.adguard.com'
		uci add stubby resolver >/dev/null 2>&1
		uci -q set stubby.@resolver[-1].address='8.8.8.8'
		uci -q set stubby.@resolver[-1].tls_auth_name='dns.google'
		uci add stubby resolver >/dev/null 2>&1
		uci -q set stubby.@resolver[-1].address='1.1.1.1'
		uci -q set stubby.@resolver[-1].tls_auth_name='cloudflare-dns.com'
		uci add stubby resolver >/dev/null 2>&1
		uci -q set stubby.@resolver[-1].address='2001:4860:4860::8888'
		uci -q set stubby.@resolver[-1].tls_auth_name='dns.google'
		uci add stubby resolver >/dev/null 2>&1
		uci -q set stubby.@resolver[-1].address='2606:4700:4700::1111'
		uci -q set stubby.@resolver[-1].tls_auth_name='cloudflare-dns.com'
		uci add stubby resolver >/dev/null 2>&1
		uci -q set stubby.@resolver[-1].address='8.8.4.4'
		uci -q set stubby.@resolver[-1].tls_auth_name='dns.google'
		uci add stubby resolver >/dev/null 2>&1
		uci -q set stubby.@resolver[-1].address='1.0.0.1'
		uci -q set stubby.@resolver[-1].tls_auth_name='cloudflare-dns.com'
		uci add stubby resolver >/dev/null 2>&1
		uci -q set stubby.@resolver[-1].address='2001:4860:4860::8844'
		uci -q set stubby.@resolver[-1].tls_auth_name='dns.google'
		uci add stubby resolver >/dev/null 2>&1
		uci -q set stubby.@resolver[-1].address='2606:4700:4700::1001'
		uci -q set stubby.@resolver[-1].tls_auth_name='cloudflare-dns.com'
		uci add stubby resolver >/dev/null 2>&1
		uci -q set stubby.@resolver[-1].address='9.9.9.9'
		uci -q set stubby.@resolver[-1].tls_auth_name='dns.quad9.net'
		uci add stubby resolver >/dev/null 2>&1
		uci -q set stubby.@resolver[-1].address='149.112.112.112'
		uci -q set stubby.@resolver[-1].tls_auth_name='dns.quad9.net'
		uci add stubby resolver >/dev/null 2>&1
		uci -q set stubby.@resolver[-1].address='2620:fe::fe'
		uci -q set stubby.@resolver[-1].tls_auth_name='dns.quad9.net'
		uci add stubby resolver >/dev/null 2>&1
		uci -q set stubby.@resolver[-1].address='2620:fe::9'
		uci -q set stubby.@resolver[-1].tls_auth_name='dns.quad9.net'
		uci commit stubby
		/etc/init.d/stubby enable 2>/dev/null
		/etc/init.d/stubby start 2>/dev/null
	fi
}

set_dfp() {
	is_rr_inited && return
	if opkg list-installed | grep -q '^luci-app-dns-failsafe-proxy -'; then
		SERVER='127.0.0.1#5359'
	else
		SERVER='127.0.0.1#5453'
	fi
	if ! uci get dhcp.@dnsmasq[0].server 2>/dev/null | grep -qw "$SERVER"; then
		uci add_list dhcp.@dnsmasq[0].server="$SERVER"
		uci commit dhcp
	fi
	uci -q set dhcp.@dnsmasq[0].noresolv='0'
	uci commit dhcp
}

set_led() {
	is_rr_inited && return
	# красным загорится 'WAN' если пропадает линк
	uci -q set system.led_lan_1=led
	uci -q set system.led_lan_1.name='lan-1'
	uci -q set system.led_lan_1.sysfs='blue:lan-1'
	uci -q set system.led_lan_1.trigger='none'
	uci -q set system.led_lan_1.default='0'
	uci -q set system.led_lan_2=led
	uci -q set system.led_lan_2.name='lan-2'
	uci -q set system.led_lan_2.sysfs='blue:lan-2'
	uci -q set system.led_lan_2.trigger='none'
	uci -q set system.led_lan_2.default='0'
	uci -q set system.led_lan_3=led
	uci -q set system.led_lan_3.name='lan-3'
	uci -q set system.led_lan_3.sysfs='blue:lan-3'
	uci -q set system.led_lan_3.trigger='none'
	uci -q set system.led_lan_3.default='0'
	uci -q set system.led_wan=led
	uci -q set system.led_wan.name='wan-on'
	uci -q set system.led_wan.sysfs='blue:wan'
	uci -q set system.led_wan.trigger='none'
	uci -q set system.led_wan.default='0'
	uci -q set system.led_wan_off=led
	uci -q set system.led_wan_off.name='wan-off'
	uci -q set system.led_wan_off.sysfs='red:wan'
	uci -q set system.led_wan_off.trigger='netdev'
	uci -q set system.led_wan_off.dev="$(cat /tmp/dev_wan.txt)"
	uci -q set system.led_wan_off.mode='link'
	uci -q set system.led_mesh2=led
	uci -q set system.led_mesh2.name='mesh-2g'
	uci -q set system.led_mesh2.sysfs='blue:mesh'
	uci -q set system.led_mesh2.trigger='none'
	uci -q set system.led_mesh2.default='0'
	uci -q set system.led_mesh5=led
	uci -q set system.led_mesh5.name='mesh-5g'
	uci -q set system.led_mesh5.sysfs='blue:mesh'
	uci -q set system.led_mesh5.trigger='none'
	uci -q set system.led_mesh5.default='0'
	uci -q add system led
	uci -q set system.@led[-1].name='power'
	uci -q set system.@led[-1].sysfs='blue:power'
	uci -q set system.@led[-1].trigger='none'
	uci -q set system.@led[-1].default='0'
	uci -q add system led
	uci -q set system.@led[-1].name='wlan-2g'
	uci -q set system.@led[-1].sysfs="$(cat /tmp/dev_wan.txt | sed 's/wan/blue:wlan-24/;s/eth1/blue:wlan-2ghz/')"
	uci -q set system.@led[-1].trigger='none'
	uci -q set system.@led[-1].default='0'
	uci -q add system led
	uci -q set system.@led[-1].name='wlan-5g'
	uci -q set system.@led[-1].sysfs="$(cat /tmp/dev_wan.txt | sed 's/wan/red:wlan-50/;s/eth1/red:wlan-5ghz/')"
	uci -q set system.@led[-1].trigger='none'
	uci -q set system.@led[-1].default='0'
	uci commit system
}

set_postupg() {
	cat <<EOF >/etc/init.d/postupgfix 2>/dev/null
#!/bin/sh /etc/rc.common

start() {
	# sort menu
	sed -i 's|"admin/status/amneziawg"|"admin/vpn/amneziawg"|' /usr/share/luci/menu.d/luci-proto-amneziawg.json 2>/dev/null
	sed -i 's|"admin/status/wireguard"|"admin/vpn/wireguard"|' /usr/share/luci/menu.d/luci-proto-wireguard.json 2>/dev/null
	sed -i 's|"admin/services/ksmbd"|"admin/nas/ksmbd"|' /usr/share/luci/menu.d/luci-app-ksmbd.json 2>/dev/null
	sed -i 's|"admin/system/filemanager"|"admin/nas/filemanager"|' /usr/share/luci/menu.d/luci-app-filemanager.json 2>/dev/null	
	# remove mm page
	[ -f /usr/share/luci/menu.d/luci-proto-modemmanager.json ] && rm /usr/share/luci/menu.d/luci-proto-modemmanager.json
	# replace ugly names
	sed -i 's/"title": "UPnP IGD & PCP"/"title": "UPnP"/' /usr/share/luci/menu.d/luci-app-upnp.json
	# replace led settings menu
	jq -e 'has("admin/system/leds")' /usr/share/luci/menu.d/luci-mod-system.json >/dev/null && jq 'del(."admin/system/leds")' /usr/share/luci/menu.d/luci-mod-system.json > /tmp/menu.json && mv /tmp/menu.json /usr/share/luci/menu.d/luci-mod-system.json
	# automodem
	[ -f /etc/hotplug.d/tty/25-modemmanager-tty ] && rm /etc/hotplug.d/tty/25-modemmanager-tty
	[ -f /etc/usb-mode.json ] && sed -i '/413c:81d7_disable/! s/413c:81d7/413c:81d7_disable/' /etc/usb-mode.json
	[ -f /etc/usb-mode.json ] && sed -i '/413c:81e0_disable/! s/413c:81e0/413c:81e0_disable/' /etc/usb-mode.json
	[ -f /etc/usb-mode.json ] && sed -i '/03f0:0857_disable/! s/03f0:0857/03f0:0857_disable/' /etc/usb-mode.json
	# remove custom rr repo
	sed -i '/^src\/gz routerich http/d' /etc/opkg/customfeeds.conf
}
EOF
	chmod +x /etc/init.d/postupgfix
	ln -s ../init.d/postupgfix /etc/rc.d/S99postupgfix
	/etc/init.d/postupgfix restart
}

set_rr_tailscale() {
	if opkg list-installed | grep -q '^luci-app-tailscale -'; then
		current_server=$(uci -q get tailscale.settings.login_server 2>/dev/null)
		if [ -z "$current_server" ]; then
			uci -q set tailscale.settings.login_server="https://rc.routerich.ru/"
			uci commit tailscale
		fi
	fi
}

set_igmp() {
	is_rr_inited && return
	opkg list-installed | grep -q '^igmpproxy -' || return
	local TARGET="br-lan"
	local FOUND=""
	local s name
	for s in $(uci show network | grep "=device" | sed -E 's/([^=]+)=device.*/\1/'); do
		name=$(uci -q get "$s.name")
		[ "$name" = "$TARGET" ] && FOUND="$s" && break
	done
	[ -n "$FOUND" ] || return
	uci -q set "$FOUND.igmp_snooping"='1'
	uci commit network
	uci -q set igmpproxy.@igmpproxy[0].verbose="0"
	uci -q set igmpproxy.@phyint[0].altnet="0.0.0.0/0"
	uci commit igmpproxy
}

hold_rr_defaults() {
	opkg flag hold routerich-defaults
}

set_adblock() {
	uci set adblock.global.adb_trigger='wan'
	uci commit adblock
}

set_ddns() {
	uci delete ddns.myddns_ipv6
	uci commit ddns
}

set_tmux() {
	echo -e "set -gq mouse on\nset -gq history-limit 100000\nset -gq status-position top\nset-option -ga terminal-overrides ',*:enacs@:smacs@:rmacs@:acsc@'" > /root/.tmux.conf
}

mark_rr_init() {
	touch /etc/config/.rr-init
}

rr_mod
add_repository
add_rr_version
(sleep 21; set_wan)&
set_packet_steering
set_hw_offloading
set_offload_delay
set_firewall
set_upnp
set_luci_nas
set_ntp
(sleep 22; set_wifi)&
(sleep 23; set_system)&
set_dnsmasq
set_ttyd
set_ksmbd
set_pptp
set_doh
set_dot
set_dfp
set_led
set_postupg
set_rr_tailscale
set_igmp
set_adblock
set_ddns
set_tmux
mark_rr_init

exit 0

vDOMAIN_LIST="raw.githubusercontent.com github.com firmware-selector.openwrt.org downloads.openwrt.org santa-atmo.ru dulcet-fox-556b08.netlify.app warp-config-generator-theta.vercel.app tcpdata.com elysiatools.com engage.cloudflareclient.com"
for vDOMAIN in $vDOMAIN_LIST; do
  vLIST_IP="$(nslookup $vDOMAIN 77.88.8.1 | grep '^Address:' | grep -v ':53$' | awk '{print $2}' || nslookup $vDOMAIN 77.88.8.2 | grep '^Address:' | grep -v ':53$' | awk '{print $2}')"
  for vIP in $vLIST_IP; do
   echo "$vIP $vDOMAIN" >> /etc/hosts
  done
done
# ---

for vDOMAIN in $vDOMAIN_LIST; do
  sed -i "/ $vDOMAIN$/d" /etc/hosts
done

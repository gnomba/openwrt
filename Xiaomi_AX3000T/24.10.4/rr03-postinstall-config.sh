#!/bin/sh
## detect WAN and MAC: dev_mac="$(grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' /sys/class/net/*/* | grep -v '00:00:00:00:00:00\|ff:ff:ff:ff:ff:ff' | sed 's/address:/ /g;s/\// /g' | awk '{print $4" "$5}' | sort -k 2,2 | head -n 1)"

# STEP-00: настроить тырнетский на ролтоныче

#for i in box blocks stars hash banner; do
#	curl -s "https://tcpdata.com/ascii/Xiaomi?style=$i&border=false" | jq -r '.ascii'
#	echo " -----------------------------------------------------"
#done
vDETECTED="$(dmesg | grep -i 'Machine model:' | awk '{print $5}')"
is_rr() {
	if [[ "${vDETECTED}" == "Routerich" ]]; then
		local vMODEL="$(dmesg | grep -i 'Machine model:' | awk -F: '{print $2}' | sed 's/ //')"
		echo "┌──────────┐"
		echo "│ DETECTED │ ${vMODEL}"
		echo "└──────────┘"
		curl -s "https://tcpdata.com/ascii/${vDETECTED}?style=banner&border=true" | jq -r '.ascii'
		return 0
	else
		return 1
	fi
}

set_banner() {
	is_rr && return 0
	local vETC_BANNER="/etc/banner"
	local vFONT="ANSI Shadow" # 'Big' 'Big ASCII 12' 'Big Mono 9' 'Small Shadow' 'Banner3' 'Block' 'Doom'
	local vMODEL="$(dmesg | grep -i 'Machine model:' | awk -F: '{print $2}' | sed 's/ //')"
	. /etc/os-release
	echo "┌──────────┐"
	echo "│ DETECTED │ ${vMODEL}"
	echo "└──────────┘"
	curl -s "https://tcpdata.com/ascii/${vDETECTED}?style=banner&border=true" | jq -r '.ascii'
	curl -s -X POST "https://elysiatools.com/en/api/tools/ascii-art-generator" -d "text=OpenWrt&font=${vFONT}" | jq -r '.data.result' > ${vETC_BANNER}
	echo " ${vMODEL} [ROUTERICH mod]" >> ${vETC_BANNER}
	echo " -----------------------------------------------------" >> ${vETC_BANNER}
	echo " ${NAME} ${VERSION}, ${BUILD_ID}" >> ${vETC_BANNER}
	echo " -----------------------------------------------------" >> ${vETC_BANNER}
}

set_https_dns_proxy() {
	if opkg list-installed | grep -q '^https-dns-proxy'; then
		echo "+------------------------------------+"
		echo "| Пакет 'https-dns-proxy' установлен |"
		echo "+------------------------------------+"
		while uci -q delete https-dns-proxy.@https-dns-proxy[0]; do :; done
		uci set https-dns-proxy.config.force_dns='1'
		uci set https-dns-proxy.config.canary_domains_icloud='1'
		uci set https-dns-proxy.config.canary_domains_mozilla='1'
		uci set https-dns-proxy.config.user='nobody'
		uci set https-dns-proxy.config.group='nogroup'
		uci set https-dns-proxy.config.listen_addr='127.0.0.1'
		uci add https-dns-proxy https-dns-proxy
		uci set https-dns-proxy.@https-dns-proxy[-1].resolver_url='https://dns.google/dns-query'
		uci set https-dns-proxy.@https-dns-proxy[-1].bootstrap_dns='8.8.4.4,8.8.8.8'
		uci set https-dns-proxy.@https-dns-proxy[-1].listen_port='5050'
		uci add https-dns-proxy https-dns-proxy
		uci set https-dns-proxy.@https-dns-proxy[-1].resolver_url='https://dns.adguard-dns.com/dns-query'
		uci set https-dns-proxy.@https-dns-proxy[-1].bootstrap_dns='94.140.15.15,94.140.14.14'
		uci set https-dns-proxy.@https-dns-proxy[-1].listen_port='5051'
		uci add https-dns-proxy https-dns-proxy
		uci set https-dns-proxy.@https-dns-proxy[-1].resolver_url='https://dns9.quad9.net/dns-query'
		uci set https-dns-proxy.@https-dns-proxy[-1].bootstrap_dns='9.9.9.9,149.112.112.112'
		uci set https-dns-proxy.@https-dns-proxy[-1].listen_port='5052'
		uci add https-dns-proxy https-dns-proxy
		uci set https-dns-proxy.@https-dns-proxy[-1].resolver_url='https://cloudflare-dns.com/dns-query'
		uci set https-dns-proxy.@https-dns-proxy[-1].bootstrap_dns='1.1.1.2,1.0.0.2'
		uci set https-dns-proxy.@https-dns-proxy[-1].listen_port='5053'
		uci add https-dns-proxy https-dns-proxy
		uci set https-dns-proxy.@https-dns-proxy[-1].resolver_url='https://common.dot.dns.yandex.net/dns-query'
		uci set https-dns-proxy.@https-dns-proxy[-1].bootstrap_dns='77.88.8.8,77.88.8.1'
		uci set https-dns-proxy.@https-dns-proxy[-1].listen_port='5054'
		uci add https-dns-proxy https-dns-proxy
		uci set https-dns-proxy.@https-dns-proxy[-1].resolver_url='https://freedns.controld.com/p3'
		uci set https-dns-proxy.@https-dns-proxy[-1].bootstrap_dns='76.76.2.0,76.76.10.0'
		uci set https-dns-proxy.@https-dns-proxy[-1].listen_port='5055'
		uci add https-dns-proxy https-dns-proxy
		uci set https-dns-proxy.@https-dns-proxy[-1].resolver_url='https://router.comss.one/dns-query'
		uci set https-dns-proxy.@https-dns-proxy[-1].bootstrap_dns='195.133.25.16,212.109.195.93,83.220.169.155'
		uci set https-dns-proxy.@https-dns-proxy[-1].listen_port='5056'
		uci commit https-dns-proxy
		uci commit
		for vACTION in enable reload restart; do
			service https-dns-proxy ${vACTION}
		done
	else
		echo "+---------------------------------------+"
		echo "| Пакет 'https-dns-proxy' не установлен |"
		echo "+---------------------------------------+"
	fi
}

install_packages() {
	vPACKAGES_RR="amneziawg-tools
atinout
automodem
doh-proxy
internet-detector
kmod-amneziawg
kmod-natflow
ksmbd-rrplug
lua-ipops
luci-app-access-control
luci-app-amneziawg
luci-app-atinout
luci-app-block-users
luci-app-dns-failsafe-proxy
luci-app-doh-proxy
luci-app-hostacl
luci-app-internet-detector
luci-app-ledcontrol
luci-app-log-viewer
luci-app-mmconfig
luci-app-modemband
luci-app-modeminfo
-luci-app-podkop
luci-app-smstools3
luci-app-stubby
luci-app-tailscale
luci-app-urllogger
luci-app-ussd
luci-app-wdoc
luci-app-wdoc-singbox
luci-app-wdoc-warp
luci-app-wdoc-wg
luci-app-wizard
luci-app-youtubeUnblock
luci-app-zapret
luci-app-zerotier
luci-i18n-access-control-ru
luci-i18n-amneziawg-ru
luci-i18n-atinout-ru
luci-i18n-doh-proxy-ru
luci-i18n-internet-detector-ru
luci-i18n-ledcontrol-ru
luci-i18n-log-ru
luci-i18n-mmconfig-ru
luci-i18n-modemband-ru
luci-i18n-modeminfo-ru
-luci-i18n-podkop-ru
luci-i18n-smstools3-ru
luci-i18n-stubby-ru
luci-i18n-tailscale-ru
luci-i18n-ussd-ru
luci-i18n-wdoc-singbox-ru
luci-i18n-wdoc-warp-ru
luci-i18n-wdoc-wg-ru
luci-i18n-zerotier-ru
luci-proto-xmm
luci-theme-routerich
modemband
modeminfo
modeminfo-qmi
modeminfo-serial-dell
modeminfo-serial-fibocom
modeminfo-serial-gosun
modeminfo-serial-huawei
modeminfo-serial-meig
modeminfo-serial-mikrotik
modeminfo-serial-quectel
modeminfo-serial-sierra
modeminfo-serial-simcom
modeminfo-serial-styx
modeminfo-serial-telit
modeminfo-serial-thales
modeminfo-serial-tw
modeminfo-serial-xmm
modeminfo-serial-yuge
modeminfo-serial-zte
opera-proxy
-podkop
routerich-defaults
smount
tailscale-lite
wdoc
wdoc-singbox
wdoc-warp
wdoc-wg
xmm-modem
youtubeUnblock
zapret
zerotier-lite"

	opkg update
	opkg install ${vPACKAGES_RR}
}

set_dns_services() {
	while uci -q delete doh-proxy.@doh-proxy[0]; do :; done
	uci add doh-proxy doh-proxy
	uci set doh-proxy.@doh-proxy[-1].resolver_url='https://dns.google/dns-query'
	uci set doh-proxy.@doh-proxy[-1].bootstrap_dns='8.8.4.4,8.8.8.8'
	uci set doh-proxy.@doh-proxy[-1].listen_addr='127.0.0.1'
	uci set doh-proxy.@doh-proxy[-1].listen_port='5050'
	uci set doh-proxy.@doh-proxy[-1].user='nobody'
	uci set doh-proxy.@doh-proxy[-1].group='nogroup'
	uci add doh-proxy doh-proxy
	uci set doh-proxy.@doh-proxy[-1].resolver_url='https://dns.adguard-dns.com/dns-query'
	uci set doh-proxy.@doh-proxy[-1].bootstrap_dns='94.140.15.15,94.140.14.14'
	uci set doh-proxy.@doh-proxy[-1].listen_addr='127.0.0.1'
	uci set doh-proxy.@doh-proxy[-1].listen_port='5051'
	uci set doh-proxy.@doh-proxy[-1].user='nobody'
	uci set doh-proxy.@doh-proxy[-1].group='nogroup'
	uci add doh-proxy doh-proxy
	uci set doh-proxy.@doh-proxy[-1].resolver_url='https://dns9.quad9.net/dns-query'
	uci set doh-proxy.@doh-proxy[-1].bootstrap_dns='9.9.9.9,149.112.112.112'
	uci set doh-proxy.@doh-proxy[-1].listen_addr='127.0.0.1'
	uci set doh-proxy.@doh-proxy[-1].listen_port='5052'
	uci set doh-proxy.@doh-proxy[-1].user='nobody'
	uci set doh-proxy.@doh-proxy[-1].group='nogroup'
	uci add doh-proxy doh-proxy
	uci set doh-proxy.@doh-proxy[-1].resolver_url='https://cloudflare-dns.com/dns-query'
	uci set doh-proxy.@doh-proxy[-1].bootstrap_dns='1.1.1.1,1.0.0.1'
	uci set doh-proxy.@doh-proxy[-1].listen_addr='127.0.0.1'
	uci set doh-proxy.@doh-proxy[-1].listen_port='5053'
	uci set doh-proxy.@doh-proxy[-1].user='nobody'
	uci set doh-proxy.@doh-proxy[-1].group='nogroup'
	uci add doh-proxy doh-proxy
	uci set doh-proxy.@doh-proxy[-1].resolver_url='https://common.dot.dns.yandex.net/dns-query'
	uci set doh-proxy.@doh-proxy[-1].bootstrap_dns='77.88.8.8,77.88.8.1'
	uci set doh-proxy.@doh-proxy[-1].listen_addr='127.0.0.1'
	uci set doh-proxy.@doh-proxy[-1].listen_port='5054'
	uci set doh-proxy.@doh-proxy[-1].user='nobody'
	uci set doh-proxy.@doh-proxy[-1].group='nogroup'
	uci add doh-proxy doh-proxy
	uci set doh-proxy.@doh-proxy[-1].resolver_url='https://freedns.controld.com/p3'
	uci set doh-proxy.@doh-proxy[-1].bootstrap_dns='76.76.2.0,76.76.10.0'
	uci set doh-proxy.@doh-proxy[-1].listen_addr='127.0.0.1'
	uci set doh-proxy.@doh-proxy[-1].listen_port='5055'
	uci set doh-proxy.@doh-proxy[-1].user='nobody'
	uci set doh-proxy.@doh-proxy[-1].group='nogroup'
	uci add doh-proxy doh-proxy
	uci set doh-proxy.@doh-proxy[-1].resolver_url='https://router.comss.one/dns-query'
	uci set doh-proxy.@doh-proxy[-1].bootstrap_dns='195.133.25.16,212.109.195.93,83.220.169.155'
	uci set doh-proxy.@doh-proxy[-1].listen_addr='127.0.0.1'
	uci set doh-proxy.@doh-proxy[-1].listen_port='5056'
	uci set doh-proxy.@doh-proxy[-1].user='nobody'
	uci set doh-proxy.@doh-proxy[-1].group='nogroup'
	uci commit doh-proxy

	if opkg list-installed | grep -q '^luci-app-dns-failsafe-proxy -'; then
		SERVER='127.0.0.1#5359'
	else
		SERVER='127.0.0.1#5453'
	fi
	if ! uci get dhcp.@dnsmasq[0].server 2>/dev/null | grep -qw "$SERVER"; then
		uci add_list dhcp.@dnsmasq[0].server="$SERVER"
		uci commit dhcp
	fi
	uci -q set dhcp.@dnsmasq[0].noresolv='1'
	uci commit dhcp
	# wdoc
	uci set wdoc-singbox.main.enabled='1'
	uci commit wdoc-singbox
	uci set wdoc.main.enabled='1'
	uci commit wdoc
	uci commit
	# enable-restart dns services #
	for i in sing-box stubby doh-proxy dns-failsafe-proxy dnsmasq; do
  		service ${i} enable
  		service ${i} reload
  		service ${i} restart
	done
}

set_rr_tailscale() {
	if opkg list-installed | grep -q '^luci-app-tailscale -'; then
		current_server=$(uci -q get tailscale.settings.login_server)
		if [ -z "$current_server" ]; then
			uci -q set tailscale.settings.login_server="https://rc.routerich.ru/"
			uci commit tailscale
		fi
	fi
}

set_n5() {
	sleep 5
	local vURL="https://raw.githubusercontent.com/routerich/RouterichAX3000_configs/refs/heads/wdoctrack/universal_config_new_podkop.sh"
	local vFILE="/tmp/universal_config_new_podkop.sh"
	wget ${vURL} -O ${vFILE}
	if ! is_rr; then sed -i "s/findKey=\"RouteRich\"/findKey=\"OpenWrt\"/g" ${vFILE}; fi
	sh ${vFILE}
}

set_n5beta() {
	sleep 5
	local vURL="https://raw.githubusercontent.com/routerich/RouterichAX3000_configs/refs/heads/podkop0711/universal_config_new_podkop.sh"
	local vFILE="/tmp/universal_config_new_podkop.sh"
	wget ${vURL} -O ${vFILE}
	if ! is_rr; then sed -i "s/findKey=\"RouteRich\"/findKey=\"OpenWrt\"/g" ${vFILE}; fi
	sh ${vFILE}
}

set_ZB() {
	echo "+---------------------+"
	echo "| Имя функции: $FUNCNAME |"
	echo "+---------------------+"
}

start_test() {
	sh <(wget -qO- https://raw.githubusercontent.com/kkkkCampbell/master/refs/heads/test_config_script/test_config_script_nightly)
}

is_rr
set_banner
set_https_dns_proxy
install_packages
set_dns_services
set_rr_tailscale
#set_n5
set_n5beta
set_ZB
start_test

exit 0

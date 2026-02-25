#!/bin/sh

echo "check_certificate = off" >> ~/.wgetrc
echo "insecure" >> ~/.curlrc
#export http_proxy=http://127.0.0.1:18080/
#export https_proxy=http://127.0.0.1:18080/

vDETECTED="$(dmesg | grep -i 'Machine model:' | awk '{print $5}')"
vDOMAIN_LIST="tcpdata.com raw.githubusercontent.com github.com downloads.openwrt.org"
for i in ${vDOMAIN_LIST}; do
	ping -c 5 $i
done

is_rr() {
	if [[ "${vDETECTED}" == "Routerich" ]]; then
		local vMODEL="$(dmesg | grep -i 'Machine model:' | awk -F: '{print $2}' | sed 's/ //')"
		echo "┌──────────┐"
		echo "│ DETECTED │ ${vMODEL}"
		echo "└──────────┘"
		curl --insecure -s "https://tcpdata.com/ascii/${vDETECTED}?style=banner&border=true" | jq -r '.ascii'
		return 0
	else
		return 1
	fi
}

set_n5beta() {
	#sleep 5
	local vURL="https://raw.githubusercontent.com/routerich/RouterichAX3000_configs/refs/heads/podkop0711/universal_config_new_podkop.sh"
	local vFILE="/tmp/universal_config_new_podkop.sh"
	wget --no-check-certificate ${vURL} -O ${vFILE}
	if ! is_rr; then sed -i "s/^findKey=\"RouteRich/findKey=\"OpenWrt/g" ${vFILE}; fi
	sed -i 's/wget/wget --no-check-certificate/g' ${vFILE}
	sh ${vFILE}
	sed -i "/^check_certificate = off/d" ~/.wgetrc
	sed -i "/^insecure/d" ~/.curlrc
	uci set podkop.settings.dns_server='8.8.8.8'
	uci set podkop.settings.bootstrap_dns_server='8.8.4.4'
	uci commit podkop
	uci set wdoc.main.enabled='1'
	uci commit wdoc
	uci set wdoc-singbox.main.enabled='1'
	uci commit wdoc-singbox
	uci set internet-detector.internet.description='Provider'
	uci set internet-detector.warp=instance
	uci set internet-detector.warp.description='Cloudflare'
	uci set internet-detector.warp.iface='awg10'
	uci set internet-detector.warp.mod_public_ip_enabled='1'
	uci set internet-detector.warp.mod_public_ip_provider='opendns1'
	uci set internet-detector.warp.enabled='1'
	uci commit internet-detector
	#unset http_proxy
	#unset https_proxy
}

set_n5beta

exit 0

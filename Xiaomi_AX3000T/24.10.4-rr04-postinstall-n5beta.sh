#!/bin/sh

echo "check_certificate = off" >> ~/.wgetrc
echo "insecure" >> ~/.curlrc

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
	if ! is_rr; then
		sed -i "s/findKey=\"RouteRich\"/findKey=\"OpenWrt\"/g" ${vFILE}
		sed -i 's/wget/wget --no-check-certificate/g' ${vFILE}
	fi
	sh ${vFILE}
	sed -i "/^check_certificate = off/d" ~/.wgetrc
	sed -i "/^insecure/d" ~/.curlrc
}

set_n5beta

exit 0

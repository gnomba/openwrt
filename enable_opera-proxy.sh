#!/bin/sh
# INFO: https://github.com/Snawoot/opera-proxy/releases

set -x

vNAME="opera-proxy"
vARCH="arm64" # amd64,arm,arm64,mips,mips64,mips64le,mipsle
vVER="$(curl -fs -o/dev/null -w %{redirect_url} https://github.com/Snawoot/${vNAME}/releases/latest | cut -b 54-)"
vPROXY_IP="$(uci show network.lan.ipaddr | awk -F "\'" '{print $2}')"
vPROXY_PORT="18080"
vPROXY_DNS="https://1.1.1.1/dns-query"
vPROXY_COUNTRY="AM" # AM,Americas - EU,Europe - AS,Asia

echo -e "Downloading binaries... \nVersion: ${vVER}"
curl -LS https://github.com/Snawoot/${vNAME}/releases/download/v${vVER}/${vNAME}.linux-${vARCH} -o /usr/bin/${vNAME}
chmod +x /usr/bin/${vNAME}

vSERVICE_FILE="/etc/init.d/${vNAME}"
vSERVICE_DATA="#!/bin/sh /etc/rc.common
# Copyright (C) 2011 OpenWrt.org

USE_PROCD=1
START=40
STOP=89
PROG=/usr/bin/${vNAME}
start_service() {
        procd_open_instance
        procd_set_param command "\$PROG" -country ${vPROXY_COUNTRY} -bootstrap-dns ${vPROXY_DNS} -bind-address ${vPROXY_IP}:${vPROXY_PORT} -verbosity 50
        procd_set_param stdout 1
        procd_set_param stderr 1
        procd_set_param respawn \${respawn_threshold:-3600} \${respawn_timeout:-5} \${respawn_retry:-5}
        procd_close_instance
}"

echo "${vSERVICE_DATA}" > ${vSERVICE_FILE}

chmod +x ${vSERVICE_FILE}
echo " ### enable service ${vNAME} ###"
service ${vNAME} enable
echo " ### start service ${vNAME} ###"
service ${vNAME} start

exit 0

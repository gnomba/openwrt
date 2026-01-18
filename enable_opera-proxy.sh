#!/bin/sh
# INFO: https://github.com/Snawoot/opera-proxy/releases

set -x

vNAME="opera-proxy"
vARCH="arm64" # amd64,arm,arm64,mips,mips64,mips64le,mipsle
vVER="$(curl -fs -o/dev/null -w %{redirect_url} https://github.com/Snawoot/${vNAME}/releases/latest | cut -b 54-)"
vPROXY_IP="$(uci get network.lan.ipaddr)"
vPROXY_PORT="18080"
vPROXY_DNS="https://9.9.9.9/dns-query"
vPROXY_COUNTRY="EU" # AM,Americas : EU,Europe : AS,Asia
vPATH="/usr/bin/${vNAME}"
vURL="https://github.com/Snawoot/${vNAME}/releases/download/v${vVER}"
vFILE="${vNAME}.linux-${vARCH}"
vOPKG_FILE="/etc/opkg.conf"
vCURL_FILE="~/.curlrc"
vWGET_FILE="~/.wgetrc"
vOPKG_SET="#option http_proxy http://${vPROXY_IP}:${vPROXY_PORT}/
#option https_proxy https://${vPROXY_IP}:${vPROXY_PORT}/"
vCURL_SET="#proxy = http://${vPROXY_IP}:${vPROXY_PORT}" 
vWGET_SET="#use_proxy = on
#http_proxy = http://${vPROXY_IP}:${vPROXY_PORT}
#https_proxy = http://${vPROXY_IP}:${vPROXY_PORT}" 

echo "${vOPKG_SET}" >> ${vOPKG_FILE}
echo "${vCURL_SET}" >> ${vCURL_FILE}
echo "${vWGET_SET}" >> ${vWGET_FILE}

service ${vNAME} stop
echo " ###########################"
echo " ### Service '${vNAME}' : $(service ${vNAME} status)"
echo " ###########################"

echo "Downloading binaries... Version: ${vVER}"
curl -LS ${vURL}/${vFILE} -o ${vPATH}
chmod +x ${vPATH}

vSERVICE_FILE="/etc/init.d/${vNAME}"
vSERVICE_DATA="#!/bin/sh /etc/rc.common
# Version: ${vVER}

USE_PROCD=1
START=40
STOP=89
PROG=${vPATH}
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

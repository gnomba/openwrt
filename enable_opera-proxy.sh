#!/bin/sh
# INFO: https://github.com/gnomba/openwrt/tree/main/_packages

set -x

. /etc/os-release
vNAME="opera-proxy"
vARCH="$OPENWRT_ARCH"
vVER="v1.15.0"
vPROXY_IP="127.0.0.1"
vPROXY_PORT="18080"
vPROXY_DNS="https://8.8.4.4/dns-query"
#vPROXY_COUNTRY="EU" # AM,Americas : EU,Europe : AS,Asia # -country ${vPROXY_COUNTRY}
vPATH="/usr/bin/${vNAME}"
vURL="https://github.com/gnomba/openwrt/raw/refs/heads/main/_packages/${vARCH}"
vFILE="${vNAME}_${vVER}"
vOPKG_FILE="/etc/opkg.conf"
vCURL_FILE="~/.curlrc"
vWGET_FILE="~/.wgetrc"
vOPKG_SET="#option http_proxy http://${vPROXY_IP}:${vPROXY_PORT}/
#option https_proxy https://${vPROXY_IP}:${vPROXY_PORT}/"
vCURL_SET="#proxy = http://${vPROXY_IP}:${vPROXY_PORT}" 
vWGET_SET="#use_proxy = on
#http_proxy = http://${vPROXY_IP}:${vPROXY_PORT}
#https_proxy = http://${vPROXY_IP}:${vPROXY_PORT}" 

grep -q "proxy" ${vOPKG_FILE} || echo "${vOPKG_SET}" >> ${vOPKG_FILE}
grep -q "proxy" ${vCURL_FILE} || echo "${vCURL_SET}" >> ${vCURL_FILE}
grep -q "proxy" ${vWGET_FILE} || echo "${vWGET_SET}" >> ${vWGET_FILE}

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
        procd_set_param command "\$PROG" -bootstrap-dns ${vPROXY_DNS} -bind-address ${vPROXY_IP}:${vPROXY_PORT} -verbosity 50
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

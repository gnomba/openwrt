#!/bin/sh
# INFO: https://github.com/SenseUnit/dumbproxy/releases

set -x

vNAME="dumbproxy"
vARCH="arm64" # amd64,arm,arm64,mips,mips64,mips64le,mipsle
vVER="$(curl -fs -o/dev/null -w %{redirect_url} https://github.com/SenseUnit/${vNAME}/releases/latest | cut -b 54-)"
vCONF_FILE="/etc/config/${vNAME}"
vPROXY_LOCAL_IP="127.0.0.1"
vPROXY_LOCAL_PORT="8080"
vPROXY_DNS="doh://8.8.4.4"
read -p "Proxy protocol [По умолчанию: h2]: " vPROXY_protocol
if [[ -z "$vPROXY_protocol" ]]; then
        vPROXY_protocol="h2"
fi
read -p "Proxy port [По умолчанию: 443]: " vPROXY_port
if [[ -z "$vPROXY_port" ]]; then
        vPROXY_port="443"
fi
read -p "Proxy host [По умолчанию: <ip_or_domain>]: " vPROXY_host
if [[ -z "$vPROXY_host" ]]; then
        vPROXY_host="<ip_or_domain>"
fi
read -p "Proxy user [По умолчанию: <login>]: " vPROXY_user
if [[ -z "$vPROXY_user" ]]; then
        vPROXY_user="<login>"
fi
read -p "Proxy password [По умолчанию: <password>]: " vPROXY_password
if [[ -z "$vPROXY_password" ]]; then
        vPROXY_password="<password>"
fi

vPATH="/usr/bin/${vNAME}"
vURL="https://github.com/SenseUnit/${vNAME}/releases/download/v${vVER}"
vFILE="${vNAME}.linux-${vARCH}"
vOPKG_FILE="/etc/opkg.conf"
vCURL_FILE="~/.curlrc"
vWGET_FILE="~/.wgetrc"
vOPKG_SET="#option http_proxy http://${vPROXY_LOCAL_IP}:${vPROXY_LOCAL_PORT}/
#option https_proxy https://${vPROXY_LOCAL_IP}:${vPROXY_LOCAL_PORT}/"
vCURL_SET="#proxy = http://${vPROXY_LOCAL_IP}:${vPROXY_LOCAL_PORT}" 
vWGET_SET="#use_proxy = on
#http_proxy = http://${vPROXY_LOCAL_IP}:${vPROXY_LOCAL_PORT}
#https_proxy = http://${vPROXY_LOCAL_IP}:${vPROXY_LOCAL_PORT}" 

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

echo "Create config ... Path: ${vCONF_FILE}"
echo "bind-address ${vPROXY_LOCAL_IP}:${vPROXY_LOCAL_PORT}
dns-server ${vPROXY_DNS}
proxy ${vPROXY_protocol}://${vPROXY_user}:${vPROXY_password}@${vPROXY_host}:${vPROXY_port}
#js-proxy-router dumbproxy_sni.js
verbosity 50" > ${vCONF_FILE}

vSERVICE_FILE="/etc/init.d/${vNAME}"
vSERVICE_DATA="#!/bin/sh /etc/rc.common
# Version: ${vVER}

USE_PROCD=1
START=40
STOP=89
PROG=${vPATH}
start_service() {
        procd_open_instance
        procd_set_param command "\$PROG" -config ${vCONF_FILE}
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
echo " ### status service ${vNAME} ###"
service ${vNAME} status

exit 0

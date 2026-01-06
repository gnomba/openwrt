#!/bin/sh
# INFO: https://github.com/animegasan/luci-app-dnsleaktest

set -x

#(opkg update && opkg install --force-checksum wget-ssl) || (apk update && apk add --allow-untrusted wget-ssl)

vRed='\033[1;31m'
vGreen='\033[1;32m'
vYellow='\033[1;33m'
vWhite='\033[1;37m'
vColor_Off='\033[0m'

vNAME="dnsleaktest"
. /etc/openwrt_release
vOWRT_VER="${DISTRIB_RELEASE%.*}"
vARCH="${DISTRIB_ARCH}"
vWGET_CMD="wget -q --show-progress -c"

case ${vOWRT_VER} in
    23.05)
    echo -e " ${vGreen}[+] ${vWhite}Version: ${vGreen}${vOWRT_VER} ${vARCH} ${vYellow}\n     continue ...${vColor_Off}"
    curl -s https://raw.githubusercontent.com/animegasan/luci-app-${vNAME}/master/install.sh | sh
    ;;
    24.10)
    echo -e " ${vGreen}[+] ${vWhite}Version: ${vGreen}${vOWRT_VER} ${vARCH} ${vYellow}\n     continue ...${vColor_Off}"
    curl -s https://raw.githubusercontent.com/animegasan/luci-app-${vNAME}/master/install.sh | sh
    ;;
    25.12)
    echo -e " ${vRed}[-] ${vWhite}Unsupported version: ${vRed}${vOWRT_VER} ${vARCH} ${vYellow}\n     exit 2 ...${vColor_Off}"
    exit 2
    ;;
    *)
    echo -e " ${vRed}[-] ${vWhite}Unknown version: ${vRed}${vOWRT_VER} ${vARCH} ${vYellow}\n     exit 1 ...${vColor_Off}"
    exit 1
    ;;
esac

rm -fv /root/*${vNAME}*

set +x

echo -e "---\nСеть -> DNS Leak Test\nNetwork -> DNS Leak Test\n---"

exit 0

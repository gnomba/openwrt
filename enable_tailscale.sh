#!/bin/sh
# INFO: https://github.com/asvow/luci-app-tailscale/releases

set -x

(opkg update && opkg install --force-checksum wget-ssl) || (apk update && apk add --allow-untrusted wget-ssl)

vRed='\033[1;31m'
vGreen='\033[1;32m'
vYellow='\033[1;33m'
vWhite='\033[1;37m'
vColor_Off='\033[0m'

vNAME="luci-app-tailscale"
. /etc/openwrt_release
vOWRT_VER="${DISTRIB_RELEASE%.*}"
vARCH="${DISTRIB_ARCH}"
vWGET_CMD="wget -q --show-progress -c"

case ${vOWRT_VER} in
    23.05)
    echo -e " ${vGreen}[+] ${vWhite}Version: ${vGreen}${vOWRT_VER} ${vARCH} ${vYellow}\n     continue ...${vColor_Off}"
    vVER="$(curl -fs -o/dev/null -w %{redirect_url} https://github.com/asvow/${vNAME}/releases/latest | cut -b 59-)"
    vURL="https://github.com/asvow/${vNAME}/releases/download/v${vVER}"
    vFILE="${vNAME}_${vVER}_all.ipk"
    opkg install --force-checksum ${vURL}/${vFILE}
    ;;
    24.10)
    echo -e " ${vGreen}[+] ${vWhite}Version: ${vGreen}${vOWRT_VER} ${vARCH} ${vYellow}\n     continue ...${vColor_Off}"
    vVER="$(curl -fs -o/dev/null -w %{redirect_url} https://github.com/asvow/${vNAME}/releases/latest | cut -b 59-)"
    vURL="https://github.com/asvow/${vNAME}/releases/download/v${vVER}"
    vFILE="${vNAME}_${vVER}_all.ipk"
    opkg install --force-checksum ${vURL}/${vFILE}
    ;;
    25.12)
    echo -e " ${vGreen}[+] ${vWhite}Version: ${vGreen}${vOWRT_VER} ${vARCH} ${vYellow}\n     continue ...${vColor_Off}"
    vVER="$(curl -fs -o/dev/null -w %{redirect_url} https://github.com/asvow/${vNAME}/releases/latest | cut -b 59-)"
    vURL="https://github.com/asvow/${vNAME}/releases/download/v${vVER}"
    vFILE="${vNAME}-${vVER}-r1.apk"
    ${vWGET_CMD} ${vURL}/${vFILE} -O /tmp/${vFILE}
    apk add --allow-untrusted /tmp/${vFILE}
    ;;
    *)
    echo -e " ${vRed}[-] ${vWhite}Unknown version: ${vRed}${vOWRT_VER} ${vARCH} ${vYellow}\n     exit 1 ...${vColor_Off}"
    exit 1
    ;;
esac

uci set tailscale.settings.login_server='https://rc.routerich.ru/'
uci set tailscale.settings.flags='--login-server=https://rc.routerich.ru/'
uci commit tailscale

echo " ### enable service tailscale ###"
service tailscale enable
echo " ### start service tailscale ###"
service tailscale start

tailscale up --login-server=https://rc.routerich.ru --force-reauth

exit 0

#!/bin/sh

set -x

(opkg update && opkg install --force-checksum wget-ssl) || (apk update && apk add --allow-untrusted wget-ssl)

vRed='\033[1;31m'
vGreen='\033[1;32m'
vYellow='\033[1;33m'
vWhite='\033[1;37m'
vColor_Off='\033[0m'

vNAME="fantastic"
. /etc/openwrt_release
vOWRT_VER="${DISTRIB_RELEASE%.*}"
vARCH="${DISTRIB_ARCH}"
vWGET_CMD="wget -q --show-progress -c"

vARGON_THM="luci-theme-argon"
vARGON_CFG="luci-app-argon-config"
vCUSTOM_LOGO_URL="https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/argon-icons-custom.zip"
#https://itshaman.ru/images/16516.webp
#https://github.com/smallprogram/OpenWrtAction/blob/main/docs/pic/openwrt-logo.jpg
vTMP_FILE="/tmp/tmp.zip"

case ${vOWRT_VER} in
    23.05)
    echo -e " ${vGreen}[+] ${vWhite}Version: ${vGreen}${vOWRT_VER} ${vARCH} ${vYellow}\n     continue ...${vColor_Off}"
    opkg install https://github.com/fantastic-packages/releases/raw/refs/heads/archive/23.05/packages/aarch64_cortex-a53/luci/luci-theme-argon_git-24.354.21394-1a22c2e_all.ipk
    #opkg install https://github.com/jerrykuku/luci-theme-argon/releases/download/v2.3.2/luci-theme-argon_2.3.2-r20250207_all.ipk
    #touch /etc/uci-defaults/luci-argon-config
    opkg install https://github.com/fantastic-packages/releases/raw/refs/heads/archive/23.05/packages/aarch64_cortex-a53/luci/luci-app-argon-config_1.0_all.ipk
    #opkg install https://github.com/jerrykuku/luci-app-argon-config/releases/download/v0.9/luci-app-argon-config_0.9_all.ipk
    ;;
    24.10)
    echo -e " ${vGreen}[+] ${vWhite}Version: ${vGreen}${vOWRT_VER} ${vARCH} ${vYellow}\n     continue ...${vColor_Off}"
    opkg install https://github.com/fantastic-packages/releases/raw/refs/heads/archive/23.05/packages/aarch64_cortex-a53/luci/luci-theme-argon_git-24.354.21394-1a22c2e_all.ipk
    #opkg install https://github.com/jerrykuku/luci-theme-argon/releases/download/v2.3.2/luci-theme-argon_2.3.2-r20250207_all.ipk
    #touch /etc/uci-defaults/luci-argon-config
    opkg install https://github.com/fantastic-packages/releases/raw/refs/heads/archive/23.05/packages/aarch64_cortex-a53/luci/luci-app-argon-config_1.0_all.ipk
    #opkg install https://github.com/jerrykuku/luci-app-argon-config/releases/download/v0.9/luci-app-argon-config_0.9_all.ipk
    ;;
    25.12)
    echo -e " ${vGreen}[+] ${vWhite}Version: ${vGreen}${vOWRT_VER} ${vARCH} ${vYellow}\n     continue ...${vColor_Off}"
    apk add --allow-untrusted ${vARGON_THM} ${vARGON_CFG}
    ;;
    *)
    echo -e " ${vRed}[-] ${vWhite}Unknown version: ${vRed}${vOWRT_VER} ${vARCH} ${vYellow}\n     exit 1 ...${vColor_Off}"
    exit 1
    ;;
esac

uci set argon.@global[0].primary='#8386a6'
uci set argon.@global[0].dark_primary='#2b594c'
uci set argon.@global[0].blur='1'
uci set argon.@global[0].blur_dark='1'
uci set argon.@global[0].transparency='0'
uci set argon.@global[0].transparency_dark='0'
uci set argon.@global[0].mode='dark'
uci set argon.@global[0].online_wallpaper='unsplash'

echo "###"
echo "### Unpack argon-icons-custom.zip"
echo "###"

${vWGET_CMD} -O ${vTMP_FILE} ${vCUSTOM_LOGO_URL} && echo A | unzip ${vTMP_FILE} -d /www/luci-static/argon/ && cp -fv /www/luci-static/argon/icon/favicon-16x16.png /www/luci-static/bootstrap/favicon.png && rm -fv ${vTMP_FILE}

uci commit argon

/etc/init.d/rpcd restart

exit 0

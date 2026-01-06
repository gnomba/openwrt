#!/bin/sh
# INFO: https://github.com/fantastic-packages/packages/tree/gh-pages?tab=readme-ov-file#readme

set -x

(opkg update && opkg install --force-checksum jq wget-ssl) || (apk update && apk add --allow-untrusted jq wget-ssl)

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

vALLOW_PKGS="luci-app-cpu-perf luci-i18n-cpu-perf-ru
luci-app-cpu-status luci-i18n-cpu-status-ru
internet-detector luci-app-internet-detector luci-i18n-internet-detector-ru
luci-app-netspeedtest
luci-app-ipinfo
luci-app-log-viewer luci-i18n-log-viewer-ru
luci-app-temp-status luci-i18n-temp-status-ru
luci-app-change-mac
"

case ${vOWRT_VER} in
    23.05)
    vBASE_URL="https://github.com/${vNAME}-packages/releases/tree/archive/${vOWRT_VER}/packages"
    vALLOW_ARCH="("aarch64_cortex-a53" "aarch64_cortex-a72" "aarch64_generic" "arm_cortex-a15_neon-vfpv4" "arm_cortex-a9_vfpv3-d16" "mips_24kc" "mipsel_24kc" "riscv64_riscv64" "x86_64")"
    echo -e " ${vGreen}[+] ${vWhite}Version: ${vGreen}${vOWRT_VER} ${vARCH} ${vYellow}\n     continue ...${vColor_Off}"
    vKEYRING_FILE="$(curl -s ${vBASE_URL}/${vARCH}/packages/ | grep packages/${vNAME}-keyring | sed -e 's/<[^>]*>//g' | jq | grep ${vNAME}-keyring | awk -F\" '{print $4}' | head -n 1)"
    vFEEDS_FILE="$(curl -s ${vBASE_URL}/${vARCH}/packages/ | grep packages/${vNAME}-packages-feeds | sed -e 's/<[^>]*>//g' | jq | grep ${vNAME}-packages-feeds | awk -F\" '{print $4}' | head -n 1)"
    ${vWGET_CMD} ${vBASE_URL}/${vARCH}/packages/${vKEYRING_FILE} -O /tmp/${vKEYRING_FILE}
    ${vWGET_CMD} ${vBASE_URL}/${vARCH}/packages/${vFEEDS_FILE} -O /tmp/${vFEEDS_FILE}
    if [ "$(opkg list-installed | grep "${vNAME}" | wc -l)" -lt "2" ]; then
        opkg install /tmp/${vKEYRING_FILE}
        opkg install /tmp/${vFEEDS_FILE}
    fi
    opkg update
    for vPKG in ${vALLOW_PKGS};do
        opkg install ${vPKG}
    done
    ;;
    24.10)
    vBASE_URL="https://${vNAME}-packages.github.io/releases"
    vALLOW_ARCH="("aarch64_cortex-a53" "aarch64_cortex-a72" "aarch64_generic" "arm_cortex-a15_neon-vfpv4" "arm_cortex-a9_vfpv3-d16" "mips_24kc" "mipsel_24kc" "riscv64_riscv64" "x86_64")"
    echo -e " ${vGreen}[+] ${vWhite}Version: ${vGreen}${vOWRT_VER} ${vARCH} ${vYellow}\n     continue ...${vColor_Off}"
    vKEYRING_FILE="$(curl -s ${vBASE_URL}/${vOWRT_VER}/packages/${vARCH}/packages/ | grep ${vNAME}-keyring | sed "s/\"/ /g" | awk '{print $5}')"
    vFEEDS_FILE="$(curl -s ${vBASE_URL}/${vOWRT_VER}/packages/${vARCH}/packages/ | grep ${vNAME}-packages-feeds | sed "s/\"/ /g" | awk '{print $5}')"
    ${vWGET_CMD} ${vBASE_URL}/${vOWRT_VER}/packages/${vARCH}/packages/${vKEYRING_FILE} -O /tmp/${vKEYRING_FILE}
    ${vWGET_CMD} ${vBASE_URL}/${vOWRT_VER}/packages/${vARCH}/packages/${vFEEDS_FILE} -O /tmp/${vFEEDS_FILE}
    if [ "$(opkg list-installed | grep "${vNAME}" | wc -l)" -lt "2" ]; then
        opkg install /tmp/${vKEYRING_FILE}
        opkg install /tmp/${vFEEDS_FILE}
    fi
    opkg update
    for vPKG in ${vALLOW_PKGS};do
        opkg install ${vPKG}
    done
    ;;
    25.12)
    vBASE_URL="https://${vNAME}-packages.github.io/releases"
    vALLOW_ARCH="("aarch64_cortex-a53" "aarch64_cortex-a72" "aarch64_generic" "arm_cortex-a15_neon-vfpv4" "arm_cortex-a9_vfpv3-d16" "mips_24kc" "mipsel_24kc" "riscv64_generic" "x86_64")"
    echo -e " ${vGreen}[+] ${vWhite}Version: ${vGreen}${vOWRT_VER} ${vARCH} ${vYellow}\n     continue ...${vColor_Off}"
    vKEYRING_FILE="$(curl -s ${vBASE_URL}/${vOWRT_VER}/packages/${vARCH}/packages/ | grep ${vNAME}-keyring | sed "s/\"/ /g" | awk '{print $5}')"
    vFEEDS_FILE="$(curl -s ${vBASE_URL}/${vOWRT_VER}/packages/${vARCH}/packages/ | grep ${vNAME}-packages-feeds | sed "s/\"/ /g" | awk '{print $5}')"
    ${vWGET_CMD} ${vBASE_URL}/${vOWRT_VER}/packages/${vARCH}/packages/${vKEYRING_FILE} -O /tmp/${vKEYRING_FILE}
    ${vWGET_CMD} ${vBASE_URL}/${vOWRT_VER}/packages/${vARCH}/packages/${vFEEDS_FILE} -O /tmp/${vFEEDS_FILE}
    if [ "$(apk list -a ${vNAME}* | grep "${vNAME}" | wc -l)" -lt "2" ]; then
        apk add --allow-untrusted /tmp/${vKEYRING_FILE}
        apk add --allow-untrusted /tmp/${vFEEDS_FILE}
    fi
    apk update
    for vPKG in ${vALLOW_PKGS};do
        apk add --allow-untrusted ${vPKG}
    done
    ;;
    *)
    echo -e " ${vRed}[-] ${vWhite}Unknown version: ${vRed}${vOWRT_VER} ${vARCH} ${vYellow}\n     exit 1 ...${vColor_Off}"
    exit 1
    ;;
esac

rm -fv /tmp/*${vNAME}*

/etc/init.d/rpcd reload

uci set cpu-perf.config.enabled='0'
/etc/init.d/cpu-perf disable
/etc/init.d/cpu-perf stop
uci commit cpu-perf

uci set internet-detector.internet.mod_public_ip_provider='google'
/etc/init.d/internet-detector enable
/etc/init.d/internet-detector start
uci commit internet-detector

uci set change-mac.@change-mac[0].mac_type_specific='24:0F:5E'
uci set change-mac.@change-mac[0].mac_type_vendor='router:zrouterTechn'
/etc/init.d/change-mac disable
/etc/init.d/change-mac stop
uci commit change-mac

uci commit

exit 0

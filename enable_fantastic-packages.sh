#!/bin/sh
# INFO: https://github.com/fantastic-packages/packages/tree/gh-pages?tab=readme-ov-file#readme

set -x

vNAME="fantastic"
vBASE_URL="https://${vNAME}-packages.github.io/packages/releases"

vALLOW_VER="("23.05" "24.10" "SNAPSHOT")"
vALLOW_ARCH="("aarch64_cortex-a53" "aarch64_generic" "arm_cortex-a15_neon-vfpv4" "mips_24kc" "mipsel_24kc" "x86_64")"
vALLOW_PKGS="luci-app-cpu-perf luci-i18n-cpu-perf-ru
luci-app-cpu-status luci-i18n-cpu-status-ru
internet-detector luci-app-internet-detector luci-i18n-internet-detector-ru
luci-app-ipinfo
luci-app-log-viewer luci-i18n-log-viewer-ru
luci-app-temp-status luci-i18n-temp-status-ru
"

vOWRT_VER="$(cat /etc/banner | grep OpenWrt | sed 's/\./ /g;s/\, .*$//g' | awk '{print $2"."$3}')"
vARCH="$(opkg print-architecture | tail -n 1 | awk '{print $2}')"
vWGET_CMD="wget -q --show-progress"

if ! [[ "$vALLOW_VER[@]" =~ "$vOWRT_VER" ]]; then
    echo " ###"
    echo " ### NEED OpenWrt VERSION -> $vALLOW_VER ###"
    echo " ###"
else
    if ! [[ "$vALLOW_ARCH[@]" =~ "$vARCH" ]]; then
        echo " ###"
        echo " ### NEED arch -> $vALLOW_ARCH ###"
        echo " ###"
    else
        if [ "$(opkg list-installed | grep "${vNAME}" | wc -l)" -lt "2" ]; then
            vKEYRING_FILE="$(curl -s ${vBASE_URL}/${vOWRT_VER}/packages/${vARCH}/packages/ | grep ${vNAME}-keyring | sed "s/\"/ /g" | awk '{print $5}')"
            vFEEDS_FILE="$(curl -s ${vBASE_URL}/${vOWRT_VER}/packages/${vARCH}/packages/ | grep ${vNAME}-packages-feeds | sed "s/\"/ /g" | awk '{print $5}')"
            ${vWGET_CMD} ${vBASE_URL}/${vOWRT_VER}/packages/${vARCH}/packages/${vKEYRING_FILE} -O /tmp/${vKEYRING_FILE}
            ${vWGET_CMD} ${vBASE_URL}/${vOWRT_VER}/packages/${vARCH}/packages/${vFEEDS_FILE} -O /tmp/${vFEEDS_FILE}
            opkg install /tmp/${vKEYRING_FILE}
            opkg install /tmp/${vFEEDS_FILE}
            rm -fv /tmp/*${vNAME}*
        else
            echo " ###"
            echo " ### ${vNAME}-packages repository already added ###"
            echo " ###"
        fi

        opkg update
        
        for vPKG in ${vALLOW_PKGS};do
            if [ "$(opkg list-installed | grep "${vPKG}" | wc -l)" -eq "2" ]; then
                echo " ###"
                echo " ### ${vPKG} already installed ###"
                echo " ###"
            else
                opkg install ${vPKG}
            fi
        done
        
        /etc/init.d/rpcd reload

        /etc/init.d/cpu-perf disable
        /etc/init.d/cpu-perf stop
        uci set cpu-perf.config.enabled='0'
        
        /etc/init.d/internet-detector enable
        /etc/init.d/internet-detector start
        uci set internet-detector.internet.mod_public_ip_provider='google'
        
        echo " ###"
        echo " ### NEED reboot ###"
        echo " ###"
    fi
fi

exit 0

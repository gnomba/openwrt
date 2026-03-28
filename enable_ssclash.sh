#!/bin/sh
# INFO: https://github.com/zerolabnet/SSClash/blob/main/README.ru.md

PKG_MANAGER=""
PKG_EXT=""

BASE_URL_ssclash="https://github.com/zerolabnet/ssclash/releases"
VERSION_ssclash="$(curl -fs -o/dev/null -w %{redirect_url} ${BASE_URL_ssclash}/latest | cut -b 53-)"
FILE_ssclash_ipk="${BASE_URL_ssclash}/download/v${VERSION_ssclash}/luci-app-ssclash_${VERSION_ssclash}-r1_all.ipk"
FILE_ssclash_apk="${BASE_URL_ssclash}/download/v${VERSION_ssclash}/luci-app-ssclash-${VERSION_ssclash}-r1.apk"

#BASE_URL_mihomo="https://github.com/MetaCubeX/mihomo/releases"
#VERSION_mihomo="$(curl -fs -o/dev/null -w %{redirect_url} ${BASE_URL_mihomo}/latest | cut -b 51-)"

detect_package_manager() {
    if command -v apk >/dev/null 2>&1; then
        PKG_MANAGER="apk"
        PKG_EXT="apk"
    elif command -v opkg >/dev/null 2>&1; then
        PKG_MANAGER="opkg"
        PKG_EXT="ipk"
    else
        printf "\033[32;1mNo supported package manager found (apk/opkg).\033[0m\n"
        exit 1
    fi
}

pkg_install() {
    if [ "$PKG_MANAGER" = "apk" ]; then
        apk update
        apk add --allow-untrusted ${FILE_ssclash_apk}
    else
        opkg update
        opkg install --force-checksum --no-check-certificate ${FILE_ssclash_ipk}
    fi
}

pkg_install
mv -fv /opt/clash/config.yaml /opt/clash/config_orig.yaml
curl -o /opt/clash/config.yaml https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/sett_ssclash
#curl -L -o - https://github.com/MetaCubeX/mihomo/releases/download/v1.19.21/mihomo-linux-mipsle-softfloat-v1.19.21.gz | gunzip > /opt/clash/bin/clash; chmod +x /opt/clash/bin/clash; ls -la /opt/clash/bin/
/etc/init.d/clash enable && /etc/init.d/clash restart

exit 0

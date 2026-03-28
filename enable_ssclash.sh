#!/bin/sh
# INFO: https://github.com/zerolabnet/SSClash/blob/main/README.ru.md

set -x

PKG_MANAGER=""
PKG_EXT=""

BASE_URL_ssclash="https://github.com/zerolabnet/ssclash/releases"
VERSION_ssclash="$(curl -fs -o/dev/null -w %{redirect_url} ${BASE_URL_ssclash}/latest | cut -b 53-)"
FILE_ssclash_ipk="${BASE_URL_ssclash}/download/v${VERSION_ssclash}/luci-app-ssclash_${VERSION_ssclash}-r1_all.ipk"
FILE_ssclash_apk="${BASE_URL_ssclash}/download/v${VERSION_ssclash}/luci-app-ssclash-${VERSION_ssclash}-r1.apk"

BASE_URL_mihomo="https://github.com/MetaCubeX/mihomo/releases"
ARCH="$(uname -m)"
TARGET="$(grep -o 'ARCH=[^ ]*' /etc/openwrt_release | cut -d= -f2 || echo "")"
VERSION_mihomo="$(curl -fs -o/dev/null -w %{redirect_url} ${BASE_URL_mihomo}/latest | cut -b 51-)"
case "$ARCH" in
    x86_64|amd64)
        FILE_mihomo="${BASE_URL_mihomo}/download/v${VERSION_mihomo}/mihomo-linux--amd64-${VERSION_mihomo}.gz"
        ;;
    aarch64|arm64)
        FILE_mihomo="${BASE_URL_mihomo}/download/v${VERSION_mihomo}/mihomo-linux-arm64-${VERSION_mihomo}.gz"
        ;;
    armv7l|armv7)
        FILE_mihomo="${BASE_URL_mihomo}/download/v${VERSION_mihomo}/mihomo-linux-armv7-${VERSION_mihomo}.gz"
        ;;
    mips|mipsel)
        # Специальная логика для MIPS/MT7621 и подобных
        if echo "$TARGET" | grep -q "mipsel"; then
            # Для mipsel_24kc (MT7621, MT7628 и т.п.) — почти всегда softfloat
            FILE_mihomo="${BASE_URL_mihomo}/download/v${VERSION_mihomo}/mihomo-linux-mipsle-softfloat-v${VERSION_mihomo}.gz"
        elif echo "$TARGET" | grep -q "mips"; then
            # Редкий big-endian MIPS
            FILE_mihomo="${BASE_URL_mihomo}/download/v${VERSION_mihomo}/mihomo-linux-mips-hardfloat-${VERSION_mihomo}.gz"   # или без -hardfloat
        else
            # Fallback
            FILE_mihomo="${BASE_URL_mihomo}/download/v${VERSION_mihomo}/mihomo-linux-mipsle-softfloat-v${VERSION_mihomo}.gz"
        fi
        ;;
    *)
        echo "Неизвестная архитектура: $ARCH"
        echo "TARGET: $TARGET"
        exit 1
        ;;
esac

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
echo -e "myip.com\n4pda.ru\n4pda.to\nproxy.golang.org\ngolang.org\nsum.golang.org" > /opt/clash/lst/file-user-list-proxy.txt
echo -e "2ip.ru\namazonaws.com\nwhatsapp.com\nwhatsapp.net\nwhatsapp.biz\nwa.me" > /opt/clash/lst/file-user-list-warp.txt

echo "Определена архитектура: $ARCH (OpenWrt target: $TARGET)"
echo "Скачиваем: $FILE_mihomo"
curl -L -o - ${FILE_mihomo} | gunzip > /opt/clash/bin/clash
chmod +x /opt/clash/bin/clash
ls -la /opt/clash/bin/

/etc/init.d/clash enable && /etc/init.d/clash restart

exit 0

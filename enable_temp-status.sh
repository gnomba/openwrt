#!/bin/sh
# INFO: https://github.com/gSpotx2f/luci-app-temp-status

set -x

opkg install https://github.com/gSpotx2f/packages-openwrt/raw/master/current/luci-app-temp-status_0.4.1-r1_all.ipk
opkg install https://github.com/gSpotx2f/packages-openwrt/raw/master/current/luci-i18n-temp-status-ru_0.4.1-r1_all.ipk

set +x

echo -e "---\nСтатус -> Обзор -> Температура\nStatus -> Overview -> Temperature\n---"

exit 0

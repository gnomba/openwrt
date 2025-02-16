#!/bin/sh
# INFO: https://github.com/gSpotx2f/luci-app-log

set -x

opkg install https://github.com/gSpotx2f/packages-openwrt/raw/master/current/luci-app-log-viewer_1.2.0-r1_all.ipk
service rpcd restart

opkg install https://github.com/gSpotx2f/packages-openwrt/raw/master/current/luci-i18n-log-viewer-ru_1.2.0-r1_all.ipk

set +x

#echo -e "---\nСтатус -> Просмотр лога\nStatus -> Log viewer\n---"

exit 0

#!/bin/sh
# INFO: https://github.com/gSpotx2f/luci-app-cpu-status

set -x

opkg install https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current/luci-app-cpu-status_0.5.0-r1_all.ipk
opkg install https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current/luci-i18n-cpu-status-ru_0.5.0-r1_all.ipk
/etc/init.d/rpcd reload

set +x

echo -e "---\nСтатус -> Загрузка ЦПУ\nStatus -> CPU Load\n---"

exit 0

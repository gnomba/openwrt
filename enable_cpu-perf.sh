#!/bin/sh
# INFO: https://github.com/gSpotx2f/luci-app-cpu-perf

set -x

opkg install https://github.com/gSpotx2f/packages-openwrt/raw/master/current/luci-app-cpu-perf_0.4.0-r1_all.ipk
opkg install https://github.com/gSpotx2f/packages-openwrt/raw/master/current/luci-i18n-cpu-perf-ru_0.4.0-r1_all.ipk
/etc/init.d/rpcd reload
/etc/init.d/cpu-perf enable
/etc/init.d/cpu-perf start

set +x

echo -e "---\nСтатус -> Производительность ЦПУ\nStatus -> CPU Performance\n---"

exit 0

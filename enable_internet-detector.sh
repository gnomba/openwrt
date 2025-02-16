#!/bin/sh
# INFO: https://github.com/gSpotx2f/luci-app-internet-detector

set -x

opkg install https://github.com/gSpotx2f/packages-openwrt/raw/master/current/internet-detector_1.4.0-r1_all.ipk
/etc/init.d/internet-detector enable
/etc/init.d/internet-detector start

opkg install https://github.com/gSpotx2f/packages-openwrt/raw/master/current/luci-app-internet-detector_1.4.0-r1_all.ipk
/etc/init.d/rpcd restart

opkg install https://github.com/gSpotx2f/packages-openwrt/raw/master/current/luci-i18n-internet-detector-ru_1.4.0-r1_all.ipk

set +x

echo -e "---\nСтатус -> Обзор -> Интернет\nСлужбы -> Интернет-детектор\nStatus -> Overview -> Internet\nServices -> Internet-detector\n---"

exit 0

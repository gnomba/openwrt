#!/bin/sh

set -x

### START MODEM support ###
. /etc/openwrt_release
vBRANCH=${DISTRIB_RELEASE%.*}
curl -s https://openwrt.132lan.ru/packages/${vBRANCH}/packages/add.sh | sh
opkg update
vMODEM="adb adb-enablemodem atinout comgt comgt-directip comgt-ncm kmod-usb-acm kmod-usb-core kmod-usb-net kmod-usb-net-cdc-ether kmod-usb-net-cdc-mbim kmod-usb-net-cdc-ncm
kmod-usb-net-huawei-cdc-ncm kmod-usb-net-qmi-wwan kmod-usb-net-rndis kmod-usb-serial kmod-usb-serial-option kmod-usb-serial-qualcomm kmod-usb-serial-wwan kmod-usb-wdm libmbim libqmi
luci-app-atinout luci-app-modeminfo luci-app-smstools3 luci-i18n-atinout-ru luci-i18n-modeminfo-ru luci-i18n-smstools3-ru luci-proto-3g luci-proto-mbim luci-proto-ncm luci-proto-ppp
luci-proto-qmi luci-proto-xmm modeminfo modeminfo-qmi modeminfo-serial-dell modeminfo-serial-fibocom modeminfo-serial-gosun modeminfo-serial-huawei modeminfo-serial-meig
modeminfo-serial-mikrotik modeminfo-serial-quectel modeminfo-serial-sierra modeminfo-serial-simcom modeminfo-serial-simcom-a7xxx modeminfo-serial-styx modeminfo-serial-telit
modeminfo-serial-thales modeminfo-serial-tw modeminfo-serial-xmm modeminfo-serial-yuge modeminfo-serial-zte ppp qmi-utils sms-tool smstools3 umbim uqmi wwan xmm-modem"
for vITEM_MODEM in ${vMODEM}; do
    opkg install ${vITEM_MODEM}
done
# -fm350-modem -luci-proto-fm350 -modeminfo-serial-fm350
# -luci-app-3ginfo-lite -luci-i18n-3ginfo-lite-ru -modemband -luci-app-modemband -luci-app-sms-tool-js -luci-i18n-sms-tool-js-ru
/etc/init.d/rpcd restart
### END MODEM support ###

exit 0
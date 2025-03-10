#!/bin/sh
#1 INFO: https://github.com/koshev-msk/modemfeed
#2 INFO: https://github.com/4IceG/luci-app-3ginfo
#3 INFO: https://github.com/4IceG/luci-app-3ginfo-lite
set -x

#1
. /etc/openwrt_release
vBRANCH=${DISTRIB_RELEASE%.*}
curl -s https://openwrt.132lan.ru/packages/${vBRANCH}/packages/add.sh | sh
#opkg update
vMODEM="adb adb-enablemodem atinout comgt comgt-directip comgt-ncm kmod-usb-acm kmod-usb-core kmod-usb-net kmod-usb-net-cdc-ether kmod-usb-net-cdc-mbim kmod-usb-net-cdc-ncm
kmod-usb-net-huawei-cdc-ncm kmod-usb-net-qmi-wwan kmod-usb-net-rndis kmod-usb-serial kmod-usb-serial-option kmod-usb-serial-qualcomm kmod-usb-serial-wwan kmod-usb-wdm libmbim libqmi
luci-app-atinout luci-app-modeminfo luci-app-smstools3 luci-i18n-atinout-ru luci-i18n-modeminfo-ru luci-i18n-smstools3-ru luci-proto-3g luci-proto-mbim luci-proto-ncm luci-proto-ppp
luci-proto-qmi luci-proto-xmm modeminfo modeminfo-qmi modeminfo-serial-dell modeminfo-serial-fibocom modeminfo-serial-gosun modeminfo-serial-huawei modeminfo-serial-meig
modeminfo-serial-mikrotik modeminfo-serial-quectel modeminfo-serial-sierra modeminfo-serial-simcom modeminfo-serial-simcom-a7xxx modeminfo-serial-styx modeminfo-serial-telit
modeminfo-serial-thales modeminfo-serial-tw modeminfo-serial-xmm modeminfo-serial-yuge modeminfo-serial-zte ppp qmi-utils sms-tool smstools3 umbim uqmi wwan xmm-modem"
for vITEM_MODEM in ${vMODEM}; do
    opkg install ${vITEM_MODEM}
done
# -modemband -luci-app-modemband
### for mhi pci ###
# kmod-mhi-bus kmod-mhi-net kmod-mhi-pci-generic kmod-mhi-wwan-ctrl kmod-mhi-wwan-mbim kmod-qrtr-mhi

#2
vWGET_CMD="wget -q --show-progress -c"
vNAME2="3ginfo"
vBASE_URL2="https://github.com/4IceG/luci-app-${vNAME2}/releases"
vTMP_DIR2="/tmp/${vNAME2}"
vLIST_FILES2="$(curl -s ${vBASE_URL2} | grep "download" | grep qmisignal | grep -v "2017" | awk -F"\"" '{print $2}')"

mkdir -pv ${vTMP_DIR2}

for vITEM in ${vLIST_FILES2}; do
    ${vWGET_CMD} https://github.com${vITEM} -P ${vTMP_DIR2}
done

#3
grep -q IceG_repo /etc/opkg/customfeeds.conf || echo 'src/gz IceG_repo https://github.com/4IceG/Modem-extras/raw/main/myrepo' >> /etc/opkg/customfeeds.conf
wget https://github.com/4IceG/Modem-extras/raw/main/myrepo/IceG-repo.pub -O /tmp/IceG-repo.pub
opkg-key add /tmp/IceG-repo.pub
opkg update

# luci-app-sms-tool-js luci-i18n-sms-tool-js-ru
opkg install luci-app-3ginfo-lite modemband luci-app-modemband 

#uci set 3ginfo.@3ginfo[0].language='en'
#uci commit 3ginfo
#uci commit

rm -rfv ${vTMP_DIR2}

/etc/init.d/rpcd restart

exit 0

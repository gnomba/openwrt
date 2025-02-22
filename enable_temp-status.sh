#!/bin/sh
# INFO: https://github.com/gSpotx2f/luci-app-temp-status

set -x

vBOARD_ID="$(cat /etc/board.json | grep id | sed 's/\"/ /g;s/,/ /g' | awk '{print $3}')"

if [ "${vBOARD_ID}" == "routerich" ]
then
    echo " --- DETECTED BOARD: routerich ---"
else
    vNAME="temp-status"
    vVERSION="0.4.1-r1" # TODO: add check version
    vFILELUCI="luci-app-${vNAME}_${vVERSION}_all.ipk"
    vFILELUCILANG="luci-i18n-${vNAME}-ru_${vVERSION}_all.ipk"
    vURL="https://github.com/gSpotx2f/packages-openwrt/raw/master/current"

    wget ${vURL}/${vFILELUCI} -O /tmp/${vFILELUCI}
    wget ${vURL}/${vFILELUCILANG} -O /tmp/${vFILELUCILANG}

    opkg install /tmp/${vFILELUCI}
    opkg install /tmp/${vFILELUCILANG}

    rm -fv /tmp/*${vNAME}*
if

set +x

echo -e "---\nСтатус -> Обзор -> Температура\nStatus -> Overview -> Temperature\n---"

exit 0

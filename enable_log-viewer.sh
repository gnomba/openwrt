#!/bin/sh
# INFO: https://github.com/gSpotx2f/luci-app-log

set -x

vBOARD_ID="$(cat /etc/board.json | grep '"id"\:' | head -n 1 | sed 's/\"/ /g;s/,/ /g' | awk '{print $3}')"

if [ "${vBOARD_ID}" == "routerich" ]; then 
    echo " --- DETECTED BOARD: routerich ---"
else
    vNAME="log-viewer"
    vBASE_URL="https://github.com/gSpotx2f/luci-app-log"
    vVERSION="$(curl -s ${vBASE_URL} | grep "^opkg" | grep luci-app-${vNAME}| uniq | head -n 1 | sed 's/\_/ /g' | awk '{print $4}')"
    vFILELUCI="luci-app-${vNAME}_${vVERSION}_all.ipk"
    vFILELUCILANG="luci-i18n-${vNAME}-ru_${vVERSION}_all.ipk"
    vURL="https://github.com/gSpotx2f/packages-openwrt/raw/master/current"

    wget ${vURL}/${vFILELUCI} -O /tmp/${vFILELUCI}
    wget ${vURL}/${vFILELUCILANG} -O /tmp/${vFILELUCILANG}

    opkg install /tmp/${vFILELUCI}
    service rpcd restart

    opkg install /tmp/${vFILELUCILANG}

    rm -fv /tmp/*${vNAME}*
fi

set +x

echo -e "---\nСтатус -> Просмотр лога\nStatus -> Log viewer\n---"

exit 0

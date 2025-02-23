#!/bin/sh
# INFO: https://github.com/gSpotx2f/luci-app-internet-detector

set -x

vBOARD_ID="$(cat /etc/board.json | grep '"id"\:' | head -n 1 | sed 's/\"/ /g;s/,/ /g' | awk '{print $3}')"

if [ "${vBOARD_ID}" == "routerich" ]; then 
    echo " --- DETECTED BOARD: routerich ---"
else
    vNAME="internet-detector"
    vVERSION="1.4.2-r1"
    vFILE="${vNAME}_${vVERSION}_all.ipk"
    vFILELUCI="luci-app-${vNAME}_${vVERSION}_all.ipk"
    vFILELUCILANG="luci-i18n-${vNAME}-ru_${vVERSION}_all.ipk"
    vURL="https://github.com/gSpotx2f/packages-openwrt/raw/master/current"

    wget ${vURL}/${vFILE} -O /tmp/${vFILE}
    wget ${vURL}/${vFILELUCI} -O /tmp/${vFILELUCI}
    wget ${vURL}/${vFILELUCILANG} -O /tmp/${vFILELUCILANG}

    opkg install /tmp/${vFILE}
    /etc/init.d/internet-detector enable
    /etc/init.d/internet-detector start

    opkg install /tmp/${vFILELUCI}
    /etc/init.d/rpcd restart

    opkg install /tmp/${vFILELUCILANG}

    rm -fv /tmp/*${vNAME}*
fi

set +x

echo -e "---\nСтатус -> Обзор -> Интернет\nСлужбы -> Интернет-детектор\nStatus -> Overview -> Internet\nServices -> Internet-detector\n---"

exit 0

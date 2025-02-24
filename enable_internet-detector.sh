#!/bin/sh
# INFO: https://github.com/gSpotx2f/luci-app-internet-detector

set -x

vBOARD_ID="$(cat /etc/board.json | grep '"id"\:' | head -n 1 | sed 's/\"/ /g;s/,/ /g' | awk '{print $3}')"

if [ "${vBOARD_ID}" == "routerich" ]; then 
    echo " --- DETECTED BOARD: routerich ---"
else
    vBASE_URL="https://github.com/gSpotx2f/luci-app-internet-detector"
    vNAME="internet-detector"
    vVERSION="$(curl -s ${vBASE_URL} | grep "^opkg" | grep "/tmp/internet-detector_" | sed "s/\_/ /g" | awk '{print $4}' | uniq)"
    vFILE="${vNAME}_${vVERSION}_all.ipk"
    vVERLUCI="$(curl -s ${vBASE_URL} | grep "^opkg" | grep "/tmp/luci-app-internet-detector_" | sed "s/\_/ /g" | awk '{print $4}' | uniq)"
    vFILELUCI="luci-app-${vNAME}_${vVERLUCI}_all.ipk"
    vVERLANG="$(curl -s ${vBASE_URL} | grep "^opkg" | grep "/tmp/luci-i18n-internet-detector" | sed "s/\_/ /g" | awk '{print $4}' | uniq)"
    vFILELUCILANG="luci-i18n-${vNAME}-ru_${vVERLANG}_all.ipk"
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

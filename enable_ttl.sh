#!/bin/sh
# INFO: https://github.com/kenzok8/jell/tree/main/luci-app-ttl
# INFO: https://github.com/routerich/packages.routerich/tree/23.05.5/routerich

# opkg list-installed | grep ttl
# opkg remove luci-i18n-ttl-ru luci-app-ttl

set -x

vBOARD_ID="$(cat /etc/board.json | grep '"id"\:' | head -n 1 | sed 's/\"/ /g;s/,/ /g' | awk '{print $3}')"

if [ "${vBOARD_ID}" == "routerich" ]; then 
    echo " --- DETECTED BOARD: routerich ---"
else
    vNAME="ttl"
    vBASE_URL="https://raw.githubusercontent.com/routerich/packages.routerich/refs/heads/23.05.5/routerich/Packages"
    vVERSION="$(curl -s ${vBASE_URL} | grep "luci-app-ttl" | grep ^Filename | sed 's/\_/ /g'| awk '{print $3}')"
    vVERLANG="$(curl -s ${vBASE_URL} | grep "luci-i18n-ttl" | grep ^Filename | sed 's/\_/ /g'| awk '{print $3}')"
    vFILELUCI="luci-app-${vNAME}_${vVERSION}_all.ipk"
    vFILELUCILANG="luci-i18n-${vNAME}-ru_${vVERLANG}_all.ipk"
    vURL="https://github.com/routerich/packages.routerich/raw/refs/heads/23.05.5/routerich"

    wget ${vURL}/${vFILELUCI} -O /tmp/${vFILELUCI}
    wget ${vURL}/${vFILELUCILANG} -O /tmp/${vFILELUCILANG}

    opkg install /tmp/${vFILELUCI}
    opkg install /tmp/${vFILELUCILANG}

    rm -fv /tmp/*${vNAME}*
fi

set +x

echo -e "---\nСеть -> Межсетевой экран -> TTL\nNetwork -> Firewall -> TTL\n---"

exit 0

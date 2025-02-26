#!/bin/sh
# INFO: https://github.com/kenzok8/jell/tree/main/luci-app-ttl
# INFO: https://github.com/routerich/packages.routerich/tree/23.05.5/routerich

# opkg list-installed | grep ttl
# opkg remove luci-i18n-ttl-ru luci-app-ttl

set -x

vWGET_CMD="wget -q --show-progress"
vBOARD_ID="$(cat /etc/board.json | grep '"id"\:' | head -n 1 | sed 's/\"/ /g;s/,/ /g' | awk '{print $3}')"

if [ "${vBOARD_ID}" == "routerich" ]; then 
    echo " --- DETECTED BOARD: routerich ---"
else
    vNAME="ttl"
    vBASE_URL="https://raw.githubusercontent.com/routerich/packages.routerich/refs/heads/23.05.5/routerich/Packages"
    vFILELUCI="$(curl -s ${vBASE_URL} | grep "luci-app-ttl" | grep ^Filename | awk '{print $2}')"
    vFILELUCILANG="$(curl -s ${vBASE_URL} | grep "luci-i18n-ttl" | grep ^Filename | awk '{print $2}')"
    vURL="https://github.com/routerich/packages.routerich/raw/refs/heads/23.05.5/routerich"

    ${vWGET_CMD} ${vURL}/${vFILELUCI} -O /tmp/${vFILELUCI}
    ${vWGET_CMD} ${vURL}/${vFILELUCILANG} -O /tmp/${vFILELUCILANG}

    opkg install /tmp/${vFILELUCI}
    opkg install /tmp/${vFILELUCILANG}

    rm -fv /tmp/*${vNAME}*
fi

set +x

echo -e "---\nСеть -> Межсетевой экран -> TTL\nNetwork -> Firewall -> TTL\n---"

exit 0

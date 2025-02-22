#!/bin/sh
# INFO: https://github.com/kenzok8/jell/tree/main/luci-app-ttl
# INFO: https://github.com/routerich/packages.routerich/tree/23.05.5/routerich

set -x

# exit if routerich #
vBOARD_ID="$(cat /etc/board.json | grep id | sed 's/\"/ /g;s/,/ /g' | awk '{print $3}')"
[ "${vBOARD_ID}" = "routerich" ] && (echo " --- DETECTED BOARD: ${vBOARD_ID} --- Exit with code '1' ---"; exit 1)

vNAME="ttl"
vVERSION="0.0.3"
vFILELUCI="luci-app-${vNAME}_${vVERSION}_all.ipk"
vFILELUCILANG="luci-i18n-${vNAME}-ru_git-24.255.44995-eddd63f_all.ipk"
vURL="https://github.com/routerich/packages.routerich/raw/refs/heads/23.05.5/routerich"

wget ${vURL}/${vFILELUCI} -O /tmp/${vFILELUCI}
wget ${vURL}/${vFILELUCILANG} -O /tmp/${vFILELUCILANG}

opkg install /tmp/${vFILELUCI}
opkg install /tmp/${vFILELUCILANG}

rm -fv /tmp/*${vNAME}*

set +x

echo -e "---\nСеть -> Межсетевой экран -> TTL\nNetwork -> Firewall -> TTL\n---"

exit 0

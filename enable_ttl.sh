#!/bin/sh
# INFO: https://github.com/kenzok8/jell/tree/main/luci-app-ttl
# INFO: https://github.com/routerich/packages.routerich/tree/23.05.5/routerich
# INFO: https://4pda.to/forum/index.php?showtopic=689378&st=82000#entry122252968

# opkg list-installed | grep ttl
# opkg remove luci-i18n-ttl-ru luci-app-ttl

set -x

vVALUE="64"
vFILE="/etc/nftables.d/10-custom-filter-chains.nft"
vDATA="
## Set ttl ${vVALUE}

chain mangle_postrouting_ttl${vVALUE} {
type filter hook postrouting priority 300; policy accept;
counter ip ttl set ${vVALUE}
}

chain mangle_prerouting_ttl${vVALUE} {
type filter hook prerouting priority 300; policy accept;
counter ip ttl set ${vVALUE}
}
"

vCHECK="$(cat ${vFILE} | grep "_ttl${vVALUE}" | wc -l)"

if [ "${vCHECK}" -ge "2" ];then
    echo " ###"
    echo " ### Enabled TTL = ${vVALUE} ###"
    echo " ###"
else
    echo " ###"
    echo " ### Set TTL to ${vVALUE} ###"
    echo " ###"
    echo "${vDATA}" >> ${vFILE}
    fw4 reload
    ping -c 5 ya.ru | grep ttl
fi

#vWGET_CMD="wget -q --show-progress -c"
#vBOARD_ID="$(cat /etc/board.json | grep '"id"\:' | head -n 1 | sed 's/\"/ /g;s/,/ /g' | awk '{print $3}')"

#if [ "${vBOARD_ID}" == "routerich" ]; then 
#    echo " --- DETECTED BOARD: routerich ---"
#else
#    vNAME="ttl"
#    vBASE_URL="https://raw.githubusercontent.com/routerich/packages.routerich/refs/heads/23.05.5/routerich/Packages"
#    vFILELUCI="$(curl -s ${vBASE_URL} | grep "luci-app-ttl" | grep ^Filename | awk '{print $2}')"
#    vFILELUCILANG="$(curl -s ${vBASE_URL} | grep "luci-i18n-ttl" | grep ^Filename | awk '{print $2}')"
#    vURL="https://github.com/routerich/packages.routerich/raw/refs/heads/23.05.5/routerich"

#    ${vWGET_CMD} ${vURL}/${vFILELUCI} -O /tmp/${vFILELUCI}
#    ${vWGET_CMD} ${vURL}/${vFILELUCILANG} -O /tmp/${vFILELUCILANG}

#    opkg install /tmp/${vFILELUCI}
#    opkg install /tmp/${vFILELUCILANG}

#    rm -fv /tmp/*${vNAME}*
#fi

set +x

#echo -e "---\nСеть -> Межсетевой экран -> TTL\nNetwork -> Firewall -> TTL\n---"
echo " # ${vFILE} #"
cat ${vFILE} | grep -v "^#\|^$"
echo " # ------------------------------------------- #"

exit 0

#!/bin/sh

set -x

# youtubeUnblock #
vNAME="youtubeUnblock"
vURL="https://github.com/Waujito/${vNAME}/releases"
vWGET_CMD="wget -q --show-progress -c"
vTEXT="$(curl -s ${vURL} | grep "luci-app-youtubeUnblock-" | grep download | sed 's/\// /g;s/-/ /g;s/\.ipk/ /g')"

vRELEASE="$(echo ${vTEXT} | awk '{print $7}')"
vBUILD="$(echo ${vTEXT} | awk '{print $12}')"
vCOMMIT="$(echo ${vTEXT} | awk '{print $13}')"
vVERSION="$(echo ${vTEXT} | awk '{print $11}')"
vARCH="$(opkg print-architecture | tail -n 1 | awk '{print $2}')"
vFILE="${vNAME}-${vVERSION}-${vBUILD}-${vCOMMIT}-${vARCH}-openwrt-23.05.ipk"
vFILELUCI="luci-app-${vNAME}-${vVERSION}-${vBUILD}-${vCOMMIT}.ipk"

vBOARD_ID="$(cat /etc/board.json | grep '"id"\:' | head -n 1 | sed 's/\"/ /g;s/,/ /g' | awk '{print $3}')"

if [ "${vBOARD_ID}" == "routerich" ]; then
    echo " --- DETECTED BOARD: routerich ---"
    if [ "$(opkg list-installed | grep ${vNAME} | wc -l)" -lt "2" ]
    then
        opkg update
        opkg install ${vNAME}
        opkg install luci-app-${vNAME}
    else
        echo " --- ${vNAME} уже установлен ---"
    fi
else
    echo " --- DETECTED BOARD: non-routerich ---"
    if [ "$(opkg list-installed | grep ${vNAME} | wc -l)" -lt "2" ]
    then
        ${vWGET_CMD} ${vURL}/download/${vRELEASE}/${vFILE} -O /tmp/${vFILE}
        ${vWGET_CMD} ${vURL}/download/${vRELEASE}/${vFILELUCI} -O /tmp/${vFILELUCI}
        opkg install /tmp/${vFILE}
        opkg install /tmp/${vFILELUCI}
        rm -fv /tmp/*${vNAME}*
    else
        echo " --- ${vNAME} уже установлен ---"
    fi
fi

vDOMAINS_URL="https://raw.githubusercontent.com/v2fly/domain-list-community/refs/heads/master/data"
#echo "vDOMAINS_URL=${vDOMAINS_URL}"
vDOMAINS_LIST="youtube discord facebook instagram whatsapp twitter"
#echo "vDOMAINS_LIST=${vDOMAINS_LIST}"
vDOMAINS_CUSTOM="googleapis.com play.google.com googleusercontent.com gstatic.com l.google.com gvt1.com yt-video-upload.l.google.com meta.ai meta.com
filmix.day rutracker.org rutracker.net rutracker.cc rutor.info rutor.is nnmclub.to pscp.tv upaste.me dmitry-tv.ddns.net dmi3y-tv.ru"
#echo "vDOMAINS_CUSTOM=${vDOMAINS_CUSTOM}"

uci set youtubeUnblock.youtubeUnblock.silent='0'
uci set youtubeUnblock.youtubeUnblock.no_ipv6='1'
uci set youtubeUnblock.@section[0].sni_domains=''
uci set youtubeUnblock.@section[0].all_domains='0'
uci set youtubeUnblock.@section[0].quic_drop='1'

for vYT_ITEM in ${vDOMAINS_CUSTOM}; do
    uci add_list youtubeUnblock.@section[0].sni_domains=${vYT_ITEM}
done

for vDOMAIN_ITEM in ${vDOMAINS_LIST};do
    echo "###--- ${vDOMAIN_ITEM} ---###"
    vITEM_URL="${vDOMAINS_URL}/${vDOMAIN_ITEM}"
    for vYT_ITEM in $(curl -s ${vITEM_URL} | grep -v "^#\|^$\|^include\:\|-ads\|ads-\|@ads" | sed "s/link\://g;s/ @.*$//g;s/full\://g"); do
        uci add_list youtubeUnblock.@section[0].sni_domains=${vYT_ITEM}
    done
done

uci commit ${vNAME}
/etc/init.d/${vNAME} restart
/etc/init.d/https-dns-proxy restart

vVIA_COMSS_LIST="$(curl -s https://raw.githubusercontent.com/CodeRoK7/RouterichAX3000_configs/refs/heads/main/configure_zaprets.sh | grep "cfg01411c\.server=\'\/\*\." | sed "s/\'/ /g" | awk '{print $4}')"
for vCOMSS_ITEM in ${vVIA_COMSS_LIST}; do
    uci add_list dhcp.@dnsmasq[0].server="${vCOMSS_ITEM}"
done
while uci -q delete dhcp.@domain[0]; do :; done
vDHCP_DOMAIN_LIST="$(curl -s https://raw.githubusercontent.com/CodeRoK7/RouterichAX3000_configs/refs/heads/main/configure_zaprets.sh | grep 'nPermanentName' | grep -v '(' | sed "s/\"//g" | awk '{print $2}')"
for vDOMAIN_ITEM in ${vDHCP_DOMAIN_LIST}; do
    uci add dhcp domain
    uci set dhcp.@domain[-1].name="${vDOMAIN_ITEM}"
    uci set dhcp.@domain[-1].ip="94.131.119.85"
done
uci commit dhcp
/etc/init.d/dnsmasq restart

set +x

echo -e "---\nСлужбы -> youtubeUnblock\nServices -> youtubeUnblock\n---"

exit 0

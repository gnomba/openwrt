#!/bin/sh

set -x

vCURL="$(which curl) -s"

# youtubeUnblock #
vNAME="youtubeUnblock"
vRELEASE="v1.0.0"
vBUILD="10" # TODO: add check version
vCOMMIT="f37c3dd"
vVERSION="$(echo ${vRELEASE} | sed 's/v//g;s/rc//g')"
vURL="https://github.com/Waujito/${vNAME}/releases/download/${vRELEASE}"
vARCH="$(opkg print-architecture | tail -n 1 | awk '{print $2}')"
vFILE="${vNAME}-${vVERSION}-${vBUILD}-${vCOMMIT}-${vARCH}-openwrt-23.05.ipk"
vFILELUCI="luci-app-${vNAME}-${vVERSION}-${vBUILD}-${vCOMMIT}.ipk"

vBOARD_ID="$(cat /etc/board.json | grep id | sed 's/\"/ /g;s/,/ /g' | awk '{print $3}')"

if [ "${vBOARD_ID}" == "routerich" ]; then
    echo " --- DETECTED BOARD: routerich ---"
    opkg update
    opkg install ${vNAME}
    opkg install luci-app-${vNAME}
else
    echo " --- DETECTED BOARD: non-routerich ---"
    wget ${vURL}/${vFILE} -O /tmp/${vFILE}
    wget ${vURL}/${vFILELUCI} -O /tmp/${vFILELUCI}
    opkg install /tmp/${vFILE}
    opkg install /tmp/${vFILELUCI}
    rm -fv /tmp/*${vNAME}*
fi

vDOMAINS_URL="https://raw.githubusercontent.com/v2fly/domain-list-community/refs/heads/master/data"
#echo "vDOMAINS_URL=${vDOMAINS_URL}"
vDOMAINS_LIST="youtube discord facebook instagram whatsapp twitter"
#echo "vDOMAINS_LIST=${vDOMAINS_LIST}"
vDOMAINS_CUSTOM="googleapis.com play.google.com googleusercontent.com gstatic.com l.google.com gvt1.com yt-video-upload.l.google.com meta.ai meta.com
filmix.day rutracker.org rutracker.net rutracker.cc rutor.info rutor.is nnmclub.to pscp.tv upaste.me dmitry-tv.ddns.net dmi3y-tv.ru"
#echo "vDOMAINS_CUSTOM=${vDOMAINS_CUSTOM}"

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
    for vYT_ITEM in $(${vCURL} ${vITEM_URL} | grep -v "^#\|^$\|^include\:\|-ads\|ads-" | sed "s/link\://g;s/ @.*$//g;s/full\://g"); do
        uci add_list youtubeUnblock.@section[0].sni_domains=${vYT_ITEM}
    done
done

uci commit ${vNAME}
/etc/init.d/${vNAME} restart

set +x

echo -e "---\nСлужбы -> youtubeUnblock\nServices -> youtubeUnblock\n---"

exit 0

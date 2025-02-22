#!/bin/sh

set -x
vCURL="$(which curl) -s"

# youtubeUnblock #
vNAME="youtubeUnblock"
vRELEASE="v1.0.0"; echo "vRELEASE=${vRELEASE}"
vBUILD="10"
vCOMMIT="f37c3dd"; echo "vCOMMIT=${vCOMMIT}"
vVERSION="$(echo ${vRELEASE} | sed 's/v//g;s/rc//g')"; echo "vVERSION=${vVERSION}"
vURL="https://github.com/Waujito/${vNAME}/releases/download/${vRELEASE}"; echo "vURL=${vURL}"
vARCH="$(opkg print-architecture | tail -n 1 | awk '{print $2}')"; echo "vARCH=${vARCH}"
vFILE="${vNAME}-${vVERSION}-${vBUILD}-${vCOMMIT}-${vARCH}-openwrt-23.05.ipk"
vFILELUCI="luci-app-${vNAME}-${vVERSION}-${vBUILD}-${vCOMMIT}.ipk"
echo "${vURL}/${vFILE}"
echo "${vURL}/${vFILELUCI}"
curl ${vURL}/${vFILE} -O /tmp/${vFILE}
curl ${vURL}/${vFILELUCI} -O /tmp/${vFILELUCI}
#opkg remove ${vNAME}
#opkg remove luci-app-${vNAME}
opkg install /tmp/${vFILE}
opkg install /tmp/${vFILELUCI}
rm -fv /tmp/${vFILE}
rm -fv /tmp/${vFILELUCI}

vDOMAINS_URL="https://raw.githubusercontent.com/v2fly/domain-list-community/refs/heads/master/data"
echo "vDOMAINS_URL=${vDOMAINS_URL}"
vDOMAINS_LIST="youtube discord facebook instagram whatsapp twitter"
echo "vDOMAINS_LIST=${vDOMAINS_LIST}"
vDOMAINS_CUSTOM="googleapis.com play.google.com googleusercontent.com gstatic.com l.google.com gvt1.com yt-video-upload.l.google.com meta.ai meta.com
filmix.day rutracker.org rutracker.net rutracker.cc rutor.info rutor.is nnmclub.to pscp.tv upaste.me dmitry-tv.ddns.net dmi3y-tv.ru"
echo "vDOMAINS_CUSTOM=${vDOMAINS_CUSTOM}"

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

uci commit youtubeUnblock
/etc/init.d/youtubeUnblock restart

set +x

echo -e "---\nСлужбы -> youtubeUnblock\nServices -> youtubeUnblock\n---"

exit 0

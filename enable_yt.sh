#!/bin/sh

set -x

# youtubeUnblock #
vNAME="youtubeUnblock"
vRELEASE="v1.0.0-rc6"; echo "vRELEASE=${vRELEASE}"
vCOMMIT="a03d05c"; echo "vCOMMIT=${vCOMMIT}"
vVERSION="$(echo ${vRELEASE} | sed 's/v//g;s/rc//g')"; echo "vVERSION=${vVERSION}"
vURL="https://github.com/Waujito/${vNAME}/releases/download/${vRELEASE}"; echo "vURL=${vURL}"
vARCH="$(opkg print-architecture | tail -n 1 | awk '{print $2}')"; echo "vARCH=${vARCH}"
vFILE="${vNAME}-${vVERSION}-${vCOMMIT}-${vARCH}-openwrt-23.05.ipk"
vFILELUCI="luci-app-${vNAME}-${vVERSION}-${vCOMMIT}.ipk"
echo "${vURL}/${vFILE}"
echo "${vURL}/${vFILELUCI}"
opkg install ${vURL}/${vFILE}
opkg install ${vURL}/${vFILELUCI}

vCURL="$(which curl) -s"
## TODO vFILTER : grep -v "^#\|^$\|^include\:\|-ads\|ads-" | sed "s/link\://g;s/ @.*$//g;s/full\://g"

uci set youtubeUnblock.@section[0].all_domains='0'
uci set youtubeUnblock.@section[0].quic_drop='1'

#- google -#
vGOOGLE=""
uci set youtubeUnblock.@section[0].sni_domains='googleapis.com'
uci add_list youtubeUnblock.@section[0].sni_domains='play.google.com'
uci add_list youtubeUnblock.@section[0].sni_domains='googleusercontent.com'
uci add_list youtubeUnblock.@section[0].sni_domains='gstatic.com'
uci add_list youtubeUnblock.@section[0].sni_domains='l.google.com'
uci add_list youtubeUnblock.@section[0].sni_domains='gvt1.com'
uci add_list youtubeUnblock.@section[0].sni_domains='yt-video-upload.l.google.com'

#- youtube -#
vYOUTUBE="https://raw.githubusercontent.com/v2fly/domain-list-community/refs/heads/master/data/youtube"
for vYT_ITEM in $(${vCURL} ${vYOUTUBE} | grep -v "^#\|^$\|^include\:\|-ads\|ads-" | sed "s/link\://g;s/ @.*$//g;s/full\://g"); do
    uci add_list youtubeUnblock.@section[0].sni_domains=${vYT_ITEM}
done

#- discord -#
vDISCORD="https://raw.githubusercontent.com/v2fly/domain-list-community/refs/heads/master/data/discord"
for vDS_ITEM in $(${vCURL} ${vDISCORD} | grep -v "^#\|^$\|^include\:\|-ads\|ads-" | sed "s/link\://g;s/ @.*$//g;s/full\://g"); do
    uci add_list youtubeUnblock.@section[0].sni_domains=${vDS_ITEM}
done

#- facebook -#
vFACEBOOK="https://raw.githubusercontent.com/v2fly/domain-list-community/refs/heads/master/data/facebook"
uci add_list youtubeUnblock.@section[0].sni_domains='meta.ai'
uci add_list youtubeUnblock.@section[0].sni_domains='meta.com'
for vFB_ITEM in $(${vCURL} ${vFACEBOOK} | grep -v "^#\|^$\|^include\:\|-ads\|ads-" | sed "s/link\://g;s/ @.*$//g;s/full\://g"); do
    uci add_list youtubeUnblock.@section[0].sni_domains=${vFB_ITEM}
done

#- instagram -#
vINSTAGRAM="https://raw.githubusercontent.com/v2fly/domain-list-community/refs/heads/master/data/instagram"
for vIN_ITEM in $(${vCURL} ${vINSTAGRAM} | grep -v "^#\|^$\|^include\:\|-ads\|ads-" | sed "s/link\://g;s/ @.*$//g;s/full\://g"); do
    uci add_list youtubeUnblock.@section[0].sni_domains=${vIN_ITEM}
done

#- whatsapp  -#
vWHATSAPP="https://raw.githubusercontent.com/v2fly/domain-list-community/refs/heads/master/data/whatsapp"
for vWT_ITEM in $(${vCURL} ${vWHATSAPP} | grep -v "^#\|^$\|^include\:\|-ads\|ads-" | sed "s/link\://g;s/ @.*$//g;s/full\://g"); do
    uci add_list youtubeUnblock.@section[0].sni_domains=${vWT_ITEM}
done

#- twitter -#
vTWITTER="https://raw.githubusercontent.com/v2fly/domain-list-community/refs/heads/master/data/twitter"
for vTW_ITEM in $(${vCURL} ${vTWITTER} | grep -v "^#\|^$\|^include\:\|-ads\|ads-" | sed "s/link\://g;s/ @.*$//g;s/full\://g"); do
    uci add_list youtubeUnblock.@section[0].sni_domains=${vTW_ITEM}
done

#- other -#
uci add_list youtubeUnblock.@section[0].sni_domains='filmix.day'
uci add_list youtubeUnblock.@section[0].sni_domains='rutracker.org'
uci add_list youtubeUnblock.@section[0].sni_domains='nnmclub.to'
uci add_list youtubeUnblock.@section[0].sni_domains='upaste.me'
uci add_list youtubeUnblock.@section[0].sni_domains='dmitry-tv.ddns.net'

uci commit youtubeUnblock
/etc/init.d/youtubeUnblock restart

set +x

echo -e "---\nСлужбы -> youtubeUnblock\nServices -> youtubeUnblock\n---"

exit 0

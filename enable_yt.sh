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
uci set youtubeUnblock.@section[0].all_domains='0'
uci set youtubeUnblock.@section[0].quic_drop='1'
uci set youtubeUnblock.@section[0].sni_domains='googlevideo.com'
uci add_list youtubeUnblock.@section[0].sni_domains='ggpht.com'
uci add_list youtubeUnblock.@section[0].sni_domains='ytimg.com'
uci add_list youtubeUnblock.@section[0].sni_domains='youtube.com'
uci add_list youtubeUnblock.@section[0].sni_domains='play.google.com'
uci add_list youtubeUnblock.@section[0].sni_domains='youtu.be'
uci add_list youtubeUnblock.@section[0].sni_domains='googleapis.com'
uci add_list youtubeUnblock.@section[0].sni_domains='googleusercontent.com'
uci add_list youtubeUnblock.@section[0].sni_domains='gstatic.com'
uci add_list youtubeUnblock.@section[0].sni_domains='l.google.com'
uci add_list youtubeUnblock.@section[0].sni_domains='yt.be'
uci add_list youtubeUnblock.@section[0].sni_domains='gvt1.com'
uci add_list youtubeUnblock.@section[0].sni_domains='youtube-nocookie.com'
uci add_list youtubeUnblock.@section[0].sni_domains='youtube-ui.l.google.com'
uci add_list youtubeUnblock.@section[0].sni_domains='youtubeembeddedplayer.googleapis.com'
uci add_list youtubeUnblock.@section[0].sni_domains='youtube.googleapis.com'
uci add_list youtubeUnblock.@section[0].sni_domains='youtubei.googleapis.com'
uci add_list youtubeUnblock.@section[0].sni_domains='yt-video-upload.l.google.com'
uci add_list youtubeUnblock.@section[0].sni_domains='wide-youtube.l.google.com'
uci add_list youtubeUnblock.@section[0].sni_domains='discord.com'
uci add_list youtubeUnblock.@section[0].sni_domains='discordapp.com'
uci add_list youtubeUnblock.@section[0].sni_domains='discord.gg'
uci add_list youtubeUnblock.@section[0].sni_domains='discordapp.net'
uci add_list youtubeUnblock.@section[0].sni_domains='discord.media'
uci add_list youtubeUnblock.@section[0].sni_domains='filmix.day'
uci add_list youtubeUnblock.@section[0].sni_domains='rutracker.org'
uci add_list youtubeUnblock.@section[0].sni_domains='nnmclub.to'
uci add_list youtubeUnblock.@section[0].sni_domains='upaste.me'
uci add_list youtubeUnblock.@section[0].sni_domains='dmitry-tv.ddns.net'
uci add_list youtubeUnblock.@section[0].sni_domains='facebook.com'
uci commit youtubeUnblock
/etc/init.d/youtubeUnblock restart

exit 0

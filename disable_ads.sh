#!/bin/sh

set -x

(opkg update && opkg install --force-checksum adblock luci-app-adblock luci-i18n-adblock-ru) || (apk update && apk add --allow-untrusted adblock luci-app-adblock luci-i18n-adblock-ru)

vADBLOCK_BLACK="/etc/adblock/adblock.blacklist"
vADBLOCK_BLOCK="/etc/adblock/adblock.blocklist"

vDOMAINS_URL="https://raw.githubusercontent.com/v2fly/domain-list-community/refs/heads/master/data"
#echo "vDOMAINS_URL=${vDOMAINS_URL}"
vDOMAINS_LIST="clearbitjs-ads tappx-ads inner-active-ads youku-ads unity-ads sohu-ads supersonic-ads qihoo360-ads kugou-ads
snap adjust-ads newrelic-ads dmm-ads pubmatic-ads pocoiq-ads spotify-ads google-ads tencent-ads onesignal-ads sensorsdata-ads
duolingo-ads adcolony-ads acfun-ads mxplayer-ads jd-ads leanplum-ads iqiyi-ads mopub-ads zynga-ads hiido-ads category-ads-all
letv-ads amazon-ads openai sina-ads alibaba-ads hotjar-ads atom-data-ads openx-ads instagram-ads category-httpdns-cn wteam-ads
umeng-ads kuaishou-ads hetzner pixiv uberads-ads hunantv-ads fqnovel pikpak growingio-ads ximalaya-ads tagtic-ads facebook-ads
microsoft mixpanel-ads bytedance-ads ogury-ads yahoo-ads emogi-ads flurry-ads apple-ads television-ads xiaomi-ads adobe-ads
whatsapp-ads baidu-ads applovin-ads segment-ads xhamster-ads netease-ads"
#echo "vDOMAINS_LIST=${vDOMAINS_LIST}"
    
### ookla-speedtest-ads:1:regexp:^speed\.(coe|open)\.ad\.[a-z]{2,6}\.prod\.hosts\.ooklaserver\.net$
### google-ads:47:regexp:^adservice\.google\.([a-z]{2}|com?)(\.[a-z]{2})?$

for vAD_ITEM in ${vDOMAINS_LIST}; do
    echo "# ${vAD_ITEM} #"
    curl -s ${vDOMAINS_URL}/${vAD_ITEM} | grep '@ads' | grep -v 'regexp' | sed "s/link\://g;s/ @.*$//g;s/full\://g" >> ${vADBLOCK_BLACK}
done

curl -s https://raw.githubusercontent.com/Turtlecute33/toolz/refs/heads/master/src/d3host.txt | grep -v '^#\|^$' | sed 's/^0.0.0.0 //g' >> ${vADBLOCK_BLACK}

if [ "$(uci show adblock.global.adb_sources | wc -l)" -eq "1" ]; then
    uci set adblock.global.adb_sources='adguard adguard_tracking certpl oisd_big oisd_nsfw'
fi
if [ "$(uci show adblock.global.adb_feed | wc -l)" -eq "1" ]; then
    uci set adblock.global.adb_feed='adguard adguard_tracking certpl oisd_big oisd_nsfw'
fi

uci commit adblock

cp -fv ${vADBLOCK_BLACK} ${vADBLOCK_BLOCK}

rm -fv ${vADBLOCK_BLACK}

echo " ### restart adblock ###"
/etc/init.d/adblock restart

exit 0

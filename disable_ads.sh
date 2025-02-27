#!/bin/sh

set -x

vADBLOCK_BLACK="/etc/adblock/adblock.blacklist"
vADBLOCK_CHK="$(opkg list-installed | grep '^adblock' | awk '{print $1}') | wc -l"
#echo "vADBLOCK_CHK='${vADBLOCK_CHK}'"

if [ "${vADBLOCK_CHK}" -eq "1" ]; then
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

    for vADS_ITEM in ${vDOMAINS_LIST}; do
        echo "# ${vADS_ITEM} #"
        curl -s ${vDOMAINS_URL}/${vADS_ITEM} | grep '@ads' | grep -v 'regexp' | sed "s/link\://g;s/ @.*$//g;s/full\://g" >> ${vADBLOCK_BLACK}
    done

    /etc/init.d/adblock restart
else
    echo "+-----------------------------------------------------------+"
    echo "| 'adblock' не установлен                                   |"
    echo "| требуется ручная установка: opkg install adblock          |"
    echo "|                             opkg install luci-app-adblock |"
    echo "| потом заново запустить ентот скрипт                       |"
    echo "+-----------------------------------------------------------+"
fi

exit 0

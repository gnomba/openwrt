#!/bin/sh

set -x

vARGON_THM="luci-theme-argon"
vARGON_CFG="luci-app-argon-config"
vRR_THM="luci-theme-routerich"
vWGET_CMD="wget -q --show-progress -c"
vIMG_URL="https://itshaman.ru/images/16516.webp"
#https://github.com/smallprogram/OpenWrtAction/blob/main/docs/pic/openwrt-logo.jpg

vRR_THM_CHK="$(opkg list-installed | grep "^${vRR_THM}" | awk '{print $1}' | wc -l)"
if [ "${vRR_THM_CHK}" -eq "1" ]; then
    echo "###"
    echo "### Remove ${vRR_THM}"
    echo "###"
    opkg remove ${vRR_THM}
    rm -rfv  /www/luci-static/routerich
fi

echo "###"
echo "### Install ${vARGON_THM}"
echo "###"
opkg install ${vARGON_THM}

echo "###"
echo "### Install ${vARGON_CFG}"
echo "###"
opkg install ${vARGON_CFG}

uci set argon.@global[0].primary='#8386a6'
uci set argon.@global[0].dark_primary='#2b594c'
uci set argon.@global[0].blur='1'
uci set argon.@global[0].blur_dark='1'
uci set argon.@global[0].transparency='0'
uci set argon.@global[0].transparency_dark='0'
uci set argon.@global[0].mode='dark'
uci set argon.@global[0].online_wallpaper='unsplash'
for vIMG in ${vIMG_URL}; do
    ${vWGET_CMD} ${vIMG} -P /www/luci-static/argon/background
done
uci commit argon

/etc/init.d/rpcd restart

exit 0

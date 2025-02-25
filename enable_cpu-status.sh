#!/bin/sh
# INFO: https://github.com/gSpotx2f/luci-app-cpu-status

set -x

vNAME="cpu-status"
vBASE_URL="https://github.com/gSpotx2f/luci-app-${vNAME}"
vVERSION="$(curl -s ${vBASE_URL} | grep "^opkg" | grep luci-app-${vNAME}| uniq | head -n 1 | sed 's/\_/ /g' | awk '{print $4}')"
vFILELUCI="luci-app-${vNAME}_${vVERSION}_all.ipk"
vFILELUCILANG="luci-i18n-${vNAME}-ru_${vVERSION}_all.ipk"
vURL="https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"

wget ${vURL}/${vFILELUCI} -O /tmp/${vFILELUCI}
wget ${vURL}/${vFILELUCILANG} -O /tmp/${vFILELUCILANG}

opkg install /tmp/${vFILELUCI}
opkg install /tmp/${vFILELUCILANG}

/etc/init.d/rpcd reload

rm -fv /tmp/*${vNAME}*

set +x

echo -e "---\nСтатус -> Загрузка ЦПУ\nStatus -> CPU Load\n---"

exit 0

#!/bin/sh
# INFO: https://github.com/gSpotx2f/luci-app-cpu-perf

set -x
# TODO: add check cpu model
vNAME="cpu-perf"
vVERSION="0.4.0-r1"
vFILELUCI="luci-app-${vNAME}_${vVERSION}_all.ipk"
vFILELUCILANG="luci-i18n-${vNAME}-ru_${vVERSION}_all.ipk"
vURL="https://github.com/gSpotx2f/packages-openwrt/raw/refs/heads/master/current"

wget ${vURL}/${vFILELUCI} -O /tmp/${vFILELUCI}
wget ${vURL}/${vFILELUCILANG} -O /tmp/${vFILELUCILANG}

opkg install /tmp/${vFILELUCI}
opkg install /tmp/${vFILELUCILANG}

/etc/init.d/rpcd reload
/etc/init.d/cpu-perf enable
/etc/init.d/cpu-perf start

rm -fv /tmp/*${vNAME}*

set +x

echo -e "---\nСтатус -> Производительность ЦПУ\nСлужбы -> Производительность ЦПУ\nStatus -> CPU Performance\nServices -> CPU Performance\n---"

exit 0

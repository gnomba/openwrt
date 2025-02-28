#!/bin/sh

set -x

vARGON_THM="luci-theme-argon"
vARGON_CFG="luci-app-argon-config"
vRR_THM="luci-theme-routerich"

vRR_THM_CHK="$(opkg list-installed | grep "^${vRR_THM}" | awk '{print $1}' | wc -l)"
if [ "${vRRTHEME_CHK}" -eq "1" ]; then
    opkg remove ${vRR_THM}
fi

opkg install ${vARGON_THM}
opkg install ${vARGON_CFG}

exit 0

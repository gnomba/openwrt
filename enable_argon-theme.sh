#!/bin/sh

set -x

vARGON_THM="luci-theme-argon"
vARGON_CFG="luci-app-argon-config"
vRR_THM="luci-theme-routerich"

vRR_THM_CHK="$(opkg list-installed | grep "^${vRR_THM}" | awk '{print $1}' | wc -l)"
if [ "${vRR_THM_CHK}" -eq "1" ]; then
    echo "###"
    echo "### Remove ${vRR_THM}"
    echo "###"
    opkg remove ${vRR_THM}
fi

echo "###"
echo "### Install ${vARGON_THM}"
echo "###"
opkg install ${vARGON_THM}

echo "###"
echo "### Install ${vARGON_CFG}"
echo "###"
opkg install ${vARGON_CFG}

exit 0

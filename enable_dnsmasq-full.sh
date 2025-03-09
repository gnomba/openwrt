#!/bin/sh

set -x

vNAME="dnsmasq-full"

if [ "$(opkg list-installed | grep "^${vNAME}" | wc -l)" -eq "1" ]; then
    echo " ###"
    echo " ### ${vNAME} already installed ###"
    echo " ###"
else
    opkg update
    cd /tmp/ && opkg download ${vNAME}
    opkg remove dnsmasq && opkg install ${vNAME} --cache /tmp/
    [ -f /etc/config/dhcp-opkg ] && cp /etc/config/dhcp /etc/config/dhcp-old && mv /etc/config/dhcp-opkg /etc/config/dhcp
fi

set +x

exit 0

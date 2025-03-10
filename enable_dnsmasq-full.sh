#!/bin/sh

set -x

vNAME="dnsmasq-full"

if [ "$(opkg list-installed | grep "^${vNAME}" | wc -l)" -eq "1" ]; then
    echo " ###"
    echo " ### ${vNAME} already installed ###"
    echo " ###"
else
    echo "nameserver 1.1.1.1" >> /etc/resolv.conf
    opkg update
    opkg install libgmp10
    cd /tmp/
    opkg download ${vNAME}
    opkg remove dnsmasq
    opkg install ${vNAME} --cache /tmp
    #[ -f /etc/config/dhcp-opkg ] && cp -fv /etc/config/dhcp /etc/config/dhcp-old && mv -fv /etc/config/dhcp-opkg /etc/config/dhcp
    /etc/init.d/dnsmasq enable
    /etc/init.d/dnsmasq start
    /etc/init.d/network restart
    sed -i "s/^nameserver 1\.1\.1\.1.*$//" /etc/resolv.conf
fi

set +x

exit 0

#!/bin/sh
# INFO: https://github.com/routerich/packages.routerich/tree/23.05.5/routerich

set -x

opkg install https://github.com/routerich/packages.routerich/raw/refs/heads/23.05.5/routerich/luci-app-ttl_0.0.3_all.ipk
opkg install https://github.com/routerich/packages.routerich/raw/refs/heads/23.05.5/routerich/luci-i18n-ttl-ru_git-24.255.44995-eddd63f_all.ipk

set +x

echo -e "---\nСеть -> Межсетевой экран -> TTL\nNetwork -> Firewall -> TTL\n---"

exit 0

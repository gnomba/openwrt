#!/bin/sh
# INFO: https://github.com/animegasan/luci-app-dnsleaktest

set -x

curl -s https://raw.githubusercontent.com/animegasan/luci-app-dnsleaktest/master/install.sh | sh
rm -fv /root/luci-app-dnsleaktest*

set +x

echo -e "---\nСеть -> DNS Leak Test\nNetwork -> DNS Leak Test\n---"

exit 0

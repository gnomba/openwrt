#!/bin/sh
# INFO: https://github.com/animegasan/luci-app-dnsleaktest

set -x

vNAME="dnsleaktest"

curl -s https://raw.githubusercontent.com/animegasan/luci-app-${vNAME}/master/install.sh | sh
rm -fv /root/*${vNAME}*

set +x

echo -e "---\nСеть -> DNS Leak Test\nNetwork -> DNS Leak Test\n---"

exit 0

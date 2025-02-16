#!/bin/sh
# INFO: https://github.com/animegasan/luci-app-ipinfo

set -x

curl -s https://raw.githubusercontent.com/animegasan/luci-app-ipinfo/master/install.sh | sh
rm -fv /root/luci-app-ipinfo*

set +x

echo -e "---\nСлужбы -> IP Information\nServices -> IP Information\n---"

exit 0

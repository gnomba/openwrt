#!/bin/sh
# INFO: https://github.com/animegasan/luci-app-ipinfo

set -x

curl -s https://raw.githubusercontent.com/animegasan/luci-app-ipinfo/master/install.sh | sh

exit 0

#!/bin/sh
# INFO: https://github.com/animegasan/luci-app-speedtest

set -x

curl -s https://raw.githubusercontent.com/animegasan/luci-app-speedtest/master/install | sh

echo -e "---\nСеть -> Speedtest\nNetwork -> Speedtest\n---"

exit 0

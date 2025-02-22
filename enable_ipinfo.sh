#!/bin/sh
# INFO: https://github.com/animegasan/luci-app-ipinfo

set -x

vNAME="ipinfo"

curl -s https://raw.githubusercontent.com/animegasan/luci-app-${vNAME}/master/install.sh | sh
rm -fv /root/*${vNAME}*

set +x

echo -e "---\nСтатус -> Обзор -> IP Information\nСлужбы -> IP Information\nStatus -> Overview -> IP Information\nServices -> IP Information\n---"

exit 0

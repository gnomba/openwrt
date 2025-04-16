#!/bin/sh
# INFO: https://github.com/Snawoot/opera-proxy/releases

set -x

vNAME="opera-proxy"
vARCH="mipsel"
vPROXY_IP="$(uci show network.lan.ipaddr | awk -F "\'" '{print $2}')"
vPROXY_PORT="18080"

exit 0

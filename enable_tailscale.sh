#!/bin/sh
# INFO: https://github.com/asvow/luci-app-tailscale/releases

set -x

vNAME="luci-app-tailscale"
vVER="$(curl -fs -o/dev/null -w %{redirect_url} https://github.com/asvow/${vNAME}/releases/latest | cut -b 59-)"
vURL="https://github.com/asvow/${vNAME}/releases/download/v${vVER}"
vFILE="${vNAME}_${vVER}_all.ipk"
vPATH="/tmp"

service tailscale stop
echo " ###########################"
echo " ### Service 'tailscale' : $(service tailscale status)"
echo " ###########################"

echo "Downloading binaries... Version: ${vVER}"
curl -LS ${vURL}/${vFILE} -o ${vPATH}
opkg install tailscale
opkg install ${vPATH}/${vFILE}
rm -fv ${vPATH}/${vFILE}

echo " ### enable service tailscale ###"
service tailscale enable
echo " ### start service tailscale ###"
service tailscale start

exit 0

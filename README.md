# openwrt

```
opkg update; for vPKG in "$(opkg list-upgradable | awk '{print $1}')"; do opkg install ${vPKG}; done
(opkg update; for vPKG in "$(opkg list-upgradable | awk '{print $1}')"; do opkg install ${vPKG}; done; reboot)&

vURL="https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main"
vLIST_OPTIONS="enable_fantastic-packages
enable_argon-theme
enable_modems
enable_dnsleaktest
enable_opera-proxy
enable_speedtest
enable_yt
disable_ads
disable_ipv6
"
for vITEM in ${vLIST_OPTIONS}; do
    curl -s ${vURL}/${vITEM}.sh | sh
done
```
 ### curl ###
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_fantastic-packages.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_argon-theme.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_modems.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_dnsleaktest.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_opera-proxy.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_speedtest.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_yt.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_access-control.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/disable_ads.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/disable_ipv6.sh | sh

 ### uclient-fetch ###
 - [x] uclient-fetch --no-check-certificate -O /tmp/enable_yt.sh https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_yt.sh; sh /tmp/enable_yt.sh; rm -fv /tmp/enable_yt.sh
 - [x] uclient-fetch --no-check-certificate -O /tmp/disable_ads.sh https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/disable_ads.sh; sh /tmp/disable_ads.sh; rm -fv /tmp/disable_ads.sh
```
------
```
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_dnsmasq-full.sh | sh
 - [ ] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_ttl.sh | sh
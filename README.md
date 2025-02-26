# openwrt

```
vURL="https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main"
vLIST_OPTIONS="disable_ads
disable_ipv6
enable_fantastic-packages
enable_dnsleaktest
enable_speedtest
enable_ttl
enable_yt
"
for vITEM in ${vLIST_OPTIONS}; do
    curl -s ${vURL}/${vITEM}.sh | sh
done
```
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/disable_ads.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/disable_ipv6.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_fantastic-packages.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_dnsleaktest.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_speedtest.sh | sh
 - [ ] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_ttl.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_yt.sh | sh

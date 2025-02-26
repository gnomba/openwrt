# openwrt

```
vURL="https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main"
vLIST_OPTIONS="
enable_yt
enable_ttl
enable_temp-status
enable_speedtest
enable_log-viewer
enable_ipinfo
enable_internet-detector
enable_fantastic-packages
enable_dnsleaktest
enable_cpu-status
enable_cpu-perf
disable_ipv6
disable_ads"
for vITEM in ${vLIST_OPTIONS}; do
    curl -s ${vURL}/${vITEM}.sh | sh
done
```
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/disable_ads.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/disable_ipv6.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_cpu-perf.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_cpu-status.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_dnsleaktest.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_internet-detector.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_ipinfo.sh | sh
 - [ ] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_fantastic-packages.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_log-viewer.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_speedtest.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_temp-status.sh | sh
 - [ ] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_ttl.sh | sh
 - [x] curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_yt.sh | sh

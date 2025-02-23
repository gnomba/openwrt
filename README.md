# openwrt

vURL="https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main"
vLIST_OPTIONS="
enable_yt
enable_ttl
enable_temp-status
enable_speedtest
enable_log-viewer
enable_ipinfo
enable_internet-detector
enable_dnsleaktest
enable_cpu-status
enable_cpu-perf
disable_ipv6
disable_ads"
for vITEM in ${vLIST_OPTIONS}; do
    curl -s ${vURL}/${vITEM}.sh | sh
done

curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_yt.sh | sh
curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_ttl.sh | sh
curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_temp-status.sh | sh
curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_speedtest.sh | sh
curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_log-viewer.sh | sh
curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_ipinfo.sh | sh
curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_internet-detector.sh | sh
curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_dnsleaktest.sh | sh
curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_cpu-status.sh | sh
curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/enable_cpu-perf.sh | sh
curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/disable_ipv6.sh | sh
curl -s https://raw.githubusercontent.com/gnomba/openwrt/refs/heads/main/disable_ads.sh | sh

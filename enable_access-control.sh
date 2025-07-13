#!/bin/sh
# INFO: https://github.com/k-szuster/luci-access-control/releases

vNAME="luci-access-control"
vARCH="all"
vVER="$(curl -fs -o/dev/null -w %{redirect_url} https://github.com/k-szuster/${vNAME}/releases/latest | cut -b 63-)"
vURL="https://github.com/k-szuster/${vNAME}/releases/download/${vVER}"; echo "vURL=${vURL}"
vFILE="${vNAME//luci/luci-app}_${vVER//sk/}_${vARCH}.ipk"; echo "vFILE=${vFILE}"
opkg install ${vURL}/${vFILE}

vMAC_LIST="01:23:45:67:89:AB 56:67:78:89:9A:AB"
vIFACE="wan"

# enable #
for vMAC in ${vMAC_LIST}; do
uci add firewall rule
uci set firewall.@rule[-1].ac_enabled='0'
uci set firewall.@rule[-1].enabled='0'
uci set firewall.@rule[-1].src='*'
uci set firewall.@rule[-1].dest="${vIFACE}"
uci set firewall.@rule[-1].proto='all'
uci set firewall.@rule[-1].target='REJECT'
uci set firewall.@rule[-1].name="Access-Control-${vMAC//\:/}"
uci set firewall.@rule[-1].src_mac="${vMAC}"
uci set firewall.@rule[-1].start_time='00:00:00'
uci set firewall.@rule[-1].stop_time='07:00:00'
uci commit firewall
done
/etc/init.d/firewall restart
# disable ??? #

echo -e "---\nСеть -> Access Control\nNetwork -> Access Control\n---"
exit 0

#### EXAMPLE

# LUCI ACCESS CONTROL
#access_control.general=access_control
#access_control.general.enabled='0' # 0 - Выключен; 1 - Включен
#access_control.general.ticket='60' # Временный доступ [мин]

# FIREWALL
#firewall.@rule[10]=rule
#firewall.@rule[10].ac_enabled='0'
#firewall.@rule[10].enabled='0'
#firewall.@rule[10].src='*'
#firewall.@rule[10].dest='wan'
#firewall.@rule[10].proto='all'
#firewall.@rule[10].target='REJECT'
#firewall.@rule[10].name='Phone'
#firewall.@rule[10].src_mac='56:67:78:89:9A:AB'
#firewall.@rule[10].start_time='00:00:00'
#firewall.@rule[10].stop_time='07:00:00'
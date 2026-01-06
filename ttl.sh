#!/bin/sh
# INFO: https://4pda.to/forum/index.php?showtopic=689378&st=81980#entry122252968

vTTL="64"
vFILE="/etc/nftables.d/10-custom-filter-chains.nft"
vDATA="##
## Set ttl ${vTTL}
##

chain mangle_postrouting_ttl${vTTL} {
type filter hook postrouting priority 300; policy accept;
counter ip ttl set ${vTTL}
}

chain mangle_prerouting_ttl${vTTL} {
type filter hook prerouting priority 300; policy accept;
counter ip ttl set ${vTTL}
}
"

echo "${vDATA}" >> ${vFILE}

exit 0

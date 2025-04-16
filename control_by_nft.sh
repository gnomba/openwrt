#!/bin/sh

vMAC_LIST="40:B0:76:5C:86:91 80:AD:16:EE:A1:67"
vIFACE="br-lan"

# enable #
for vMAC in ${vMAC_LIST}; do
    nft add rule input iif ${vIFACE} ether saddr == ${vMAC} drop
done

# disable ??? #

exit 0

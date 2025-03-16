#!/bin/sh

# Ручная конфигурация порта.
vMODEM="/dev/ttyUSB1"
# Команда, например, *100#
USSD=$1

SCRIPT=/etc/gcom/ussd.gcom
device="${vMODEM}"

# Автоматический экспорт из /etc/smsd.conf
#export $(awk '/device =/{gsub(" ", "", $0); print}' /etc/smsd.conf)

PDU=$(ussd=$USSD gcom -v -d ${device} -s ${SCRIPT} | awk -F [,\"] '{gsub("\"", "", $0); print $2}')

decodeUCS2()
{
    bytes=$(echo -n $1 | sed "s/\(.\{2\}\)/\\\x\1/g")
    PDU=$(printf $bytes | iconv -f UCS-2BE -t UTF-8)
}


case $PDU in
	[0-9]*|[A-F]*) decodeUCS2 $PDU ;;
esac

echo $PDU

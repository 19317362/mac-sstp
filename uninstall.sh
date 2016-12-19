#! /bin/bash

if [ "$(whoami)" != 'root' ]; then
	echo 'This script require root permission'
	exit 1
fi

DIR="$(dirname $0)"
ABSPATH="$(cd "$DIR"; pwd)"

"$DIR/stop.sh"

rm -f "$DIR/.vpnacc" "$DIR/vpn.log"

sed -i '' "\|$ABSPATH/vpn.sh|d" /private/etc/sudoers.d/sstp
if [ `grep -v '^#' /private/etc/sudoers.d/sstp | grep -c -E '[^[:space:]]'` -eq 0 ]; then
	rm /private/etc/sudoers.d/sstp
fi

sed -i '' "\|$ABSPATH/connected.sh|d" /private/ppp/ip-up
if [ `grep -v '^#' /private/ppp/ip-up | grep -c -E '[^[:space:]]'` -eq 0 ]; then
	rm /private/ppp/ip-up
fi

sed -i '' "\|$ABSPATH/disconnected.sh|d" /private/ppp/ip-down
if [ `grep -v '^#' /private/ppp/ip-down | grep -c -E '[^[:space:]]'` -eq 0 ]; then
	rm /private/ppp/ip-down
fi

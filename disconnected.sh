#! /bin/sh

if [ "$(whoami)" != 'root' ]; then
	echo 'This script require root permission'
	exit 1
fi

DIR="$(dirname $0)"

if [ ! -e "$DIR/vpn.ini" ]; then
	echo 'No vpn.ini file found' >> "$DIR/vpn.log"
	exit 2
fi

. "$DIR/vpn.ini"

"$DIR/dns.sh" disable "$domains" >> "$DIR/vpn.log"
"$DIR/route.sh" disable "$routes" >> "$DIR/vpn.log"

for i in `find "$DIR/disconnected.d" -maxdepth 1 -type f -name '*.sh'`; do
	sudo -u "$localuser" -- "$i" "$DIR" >> "$DIR/vpn.log"
done

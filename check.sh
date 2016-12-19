#! /bin/bash

DIR="$(dirname $0)"

if [ ! -e "$DIR/vpn.ini" ]; then
	if [ "$(whoami)" == 'root' ]; then
		echo 'No vpn.ini file found' >> "$DIR/vpn.log"
	else
		echo 'No vpn.ini file found' >&2
	fi
	exit 1
fi

. "$DIR/vpn.ini"

if [ -z "$host" ]; then
	if [ "$(whoami)" == 'root' ]; then
		echo "No host found in '$DIR/vpn.ini' file" >> "$DIR/vpn.log"
	else
		echo "No host found in '$DIR/vpn.ini' file" >&2
	fi
	exit 2
fi

pid=`ps -e | grep "/usr/local/sbin/sstpc .* $host " | grep -v -E ' (grep /usr/local/sbin/sstpc|sudo -b /usr/local/sbin/sstpc) ' | awk '{print $1}'`
if [ -z "$pid" ]; then
	exit 3
fi

if [ "$(whoami)" == 'root' ]; then
	echo "$pid"
fi
exit 0

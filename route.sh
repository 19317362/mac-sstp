#! /bin/bash

if [ "$(whoami)" != 'root' ]; then
	echo 'This script require root permission'
	exit 1
fi

if [ -z "$2" ]; then
	echo 'No routes given'
	exit 2
fi

if [ -z "$IFNAME" ] || [ -z "$IPREMOTE" ]; then
	echo 'No interface name and remote IP provided'
	exit 3
fi

case "$1" in
	'enable')
		for i in `echo "$2" | tr ',' '\n' | tr -d '[:blank:]'`; do
			/sbin/route add -net "$i" -iface "$IFNAME"
		done
		;;
	'disable')
		for i in `echo "$2" | tr ',' '\n' | tr -d '[:blank:]'`; do
			/sbin/route delete -net "$i" -iface "$IFNAME"
		done
		;;
	*)
		echo "Usage: $(basename $0) <enable|disable> <comma separated route newtork list>"
		exit 4
esac

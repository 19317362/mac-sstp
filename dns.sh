#! /bin/bash

if [ "$(whoami)" != 'root' ]; then
	echo 'This script require root permission'
	exit 1
fi

if [ -z "$2" ]; then
	echo 'No domains given'
	exit 2
fi

case "$1" in
	'enable')
		if [ -z "$DNS1" ] && [ -z "$DNS2" ]; then
			echo 'No DNS server found'
			exit 3
		fi
		for i in `echo "$2" | tr ',' '\n' | tr -d '[:blank:]' | grep -v -E '(\.\.|/)'`; do
			echo "domain $i" > "/etc/resolver/$i"
			chmod 0644 "/etc/resolver/$i"
			if [ -n "$DNS1" ]; then
				echo "nameserver $DNS1" >> "/etc/resolver/$i"
			fi
			if [ -n "$DNS2" ]; then
				echo "nameserver $DNS2" >> "/etc/resolver/$i"
			fi
		done
		;;
	'disable')
		for i in `echo "$2" | tr ',' '\n' | tr -d '[:blank:]' | grep -v -E '(\.\.|/)'`; do
			rm -f "/etc/resolver/$i"
		done
		;;
	*)
		echo "Usage: $(basename $0) <enable|disable> <comma separated domain list>"
		exit 4
esac

dscacheutil -flushcache || true

#! /bin/bash

if [ "$(whoami)" != 'root' ]; then
	echo 'This script require root permission'
	exit 1
fi

DIR="$(dirname $0)"

function down {
	pid="$($DIR/check.sh)"
	if [ -n "$pid" ]; then
		kill "$pid"
		sleep 1
		pid="$($DIR/check.sh)"
		if [ -n "$pid" ]; then
			kill -9 "$pid"
		fi
	fi
	if [ -s "/var/run/ppp-$1.pid" ]; then
		pid=`cat "/var/run/ppp-$1.pid" | head -1`
		if [ `ps -p "$pid" | grep -c -E '[[:space:]]/dev/ttys' 2>/dev/null` ]; then
			kill "$pid"
			sleep 1
			if [ `ps -p "$pid" | grep -c -E '[[:space:]]/dev/ttys' 2>/dev/null` ]; then
				kill -9 "$pid"
			fi
		fi
	fi
}

if [ -s "$DIR/vpn.log" ]; then
	mv "$DIR/vpn.log" "$DIR/vpn.log.1"
fi
if [ ! -e "$DIR/vpn.ini" ]; then
	echo 'No vpn.ini file found' >> "$DIR/vpn.log"
	exit 2
fi

. "$DIR/vpn.ini"

if [ -z "$host" ]; then
	echo "No host found in '$DIR/vpn.ini' file" >> "$DIR/vpn.log"
	exit 3
fi

if [ ! -e "$DIR/.vpnacc" ]; then
	echo 'No vpnacc file found' >> "$DIR/vpn.log"
	exit 4
fi

if [ "$(stat -f '%u:%p' $DIR/.vpnacc)" != '0:100600' ]; then
	echo 'Account file permission error' >> "$DIR/vpn.log"
	exit 5
fi

. "$DIR/.vpnacc"

if [ -z "$username" ] || [ -z "$password" ]; then
	echo "No user credentials in '$DIR/.vpnacc' file" >> "$DIR/vpn.log"
	exit 6
fi

case "$1" in
	'connect')

		trap "{ down '$username@$host'; exit }" SIGHUP SIGINT SIGTERM

		conf=`cat "$DIR/pppd.conf" | sed 's/\n/ /g' | grep -v -E '^(nodetach|ipparam)'`
		/usr/local/sbin/sstpc --log-level 2 --log-stderr --cert-warn --user "$domain\\$username" --password "$password" "$host" ipparam "$username@$host" linkname "$username@$host" $conf 2>&1 >> "$DIR/vpn.log"
		;;
	'disconnect')
		down "$username@$host"
		;;
	*)
		echo "Usage: $(basename $0) <connect|disconnect>"
		exit 7
esac

exit 0

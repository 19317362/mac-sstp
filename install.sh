#! /bin/bash

function readinfo {
	local defval="$1"
	local vprompt="$2"
	local eprompt="$3"
	local emptymsg="$4"

	local input=''
	while [ -z "$input" ]; do
		if [ -n "$defval" ]; then
			IFS="" read -p "$vprompt" input
			if [ -z "$input" ]; then
				input="$defval"
			fi
		else
			IFS="" read -p "$eprompt" input
		fi
		if [ -z "$input" ]; then
			echo "$emptymsg" >&2
		fi
	done
	echo "$input"
}

if [ "$(whoami)" != 'root' ]; then
	echo 'This script require root permission'
	exit 1
fi

if [ ! -e /usr/bin/xcode-select ]; then
	echo 'Please install XCode first' >&2
	exit 2
fi

DIR="$(dirname $0)"
ABSPATH="$(cd "$DIR"; pwd)"

if [ ! -e /usr/local/sbin/sstpc ]; then
	if [ ! -e /usr/local/bin/brew ]; then
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi
	/usr/local/bin/brew install sstp-client
fi

if [ ! -x /usr/local/sbin/sstpc ]; then
	echo 'No sstp-client' >&2
	exit 3
fi

if [ "$(grep -c '^#includedir /private/etc/sudoers\.d' /etc/sudoers)" -eq 0 ]; then
	echo 'No sudoers drop in folder supported' >&2
	exit 4
fi

if [ ! -e /etc/sudoers.d/sstp ]; then
	echo -n '' > /etc/sudoers.d/sstp
	chown root:wheel /etc/sudoers.d/sstp
	chmod 0640 /etc/sudoers.d/sstp
fi
if [ `grep -c "$ABSPATH/vpn.sh" /etc/sudoers.d/sstp` -eq 0 ]; then
	echo "%admin ALL=(ALL) NOPASSWD: $ABSPATH/vpn.sh" >> /etc/sudoers.d/sstp
fi

for sf in `find "$DIR" -maxdepth 1 -type f -name '*.sh'`; do
	chown root:admin "$sf"
	chmod 0755 "$sf"
done

if [ -e "$DIR/vpn.ini" ]; then
	. "$DIR/vpn.ini"
fi

host=`readinfo "$host" "VPN host [$host]: " 'VPN host (example: vpn.company.com): ' 'VPN host required, can not be empty'`
domains=`readinfo "$domains" "VPN DNS domains [$domains]: " 'VPN DNS domains (example: mycompany.com,partnercompany.com): ' 'This value can not be empty, use a single space to clear values'`
routes=`readinfo "$routes" "VPN routes [$routes]: " 'VPN routes (example: 10.0.0.0/8,198.168.0.0/16): ' 'This value can not be empty, use a single space to clear values'`

if [ -z "$localuser" ]; then
	localuser="$SUDO_USER"
	if [ -z "$localuser" ]; then
		localuser="$USER"
	fi
fi
while [ "$localuser" == 'root' ] || [ id "$localuser" 2>/dev/null > /dev/null ]; do
	localuser=`readinfo '' '' 'Local unprivileged user : ' 'Local unprivileged user, can not be empty'`
done

echo "host=\"$host\"" > "$DIR/vpn.ini"
echo "domains=\"$domains\"" >> "$DIR/vpn.ini"
echo "routes=\"$routes\"" >> "$DIR/vpn.ini"
echo "localuser=\"$localuser\"" >> "$DIR/vpn.ini"
chown root:admin "$DIR/vpn.ini"
chmod 0644 "$DIR/vpn.ini"


mkdir -p "$DIR/data"
chown -R $localuser:staff "$DIR/data" "$DIR/connected.d" "$DIR/disconnected.d"

if [ -e "$DIR/.vpnacc" ]; then
	. "$DIR/.vpnacc"
fi

domain=`readinfo "$domain" "User domain [$domain]: " 'User domain (example: OFFICE): ' 'User domain required, can not be empty, use a single space to clear the value'`

username=`readinfo "$username" "User name [$username]: " 'User name (example: john.doe): ' 'User name required, can not be empty'`

password=''
while [ -z "$password" ] || [ "$password" != "$password2" ]; do
	read -s -p 'Password: ' password
	echo ''
	read -s -p 'Password again: ' password2
	echo ''

	if [ -z "$password" ]; then
		echo 'Password required, can not be empty' >&2
	fi
	if [ "$password" != "$password2" ]; then
		echo 'Two password input not match' >&2
	fi
done

echo "domain=\"$domain\"" > "$DIR/.vpnacc"
chown root:admin "$DIR/.vpnacc"
chmod 0600 "$DIR/.vpnacc"
echo "username=\"$username\"" >> "$DIR/.vpnacc"
echo "password=\"$password\"" >> "$DIR/.vpnacc"

for i in up down; do
	if [ ! -e "/etc/ppp/ip-$i" ]; then
		echo '#! /bin/sh' > "/etc/ppp/ip-$i"
		echo '' >> "/etc/ppp/ip-$i"
		chmod 755 "/etc/ppp/ip-$i"
	fi
done

if [ `grep -c "'$ABSPATH/connected.sh'" /etc/ppp/ip-up` -eq 0 ]; then
	echo "if [ \"\$6\" == '$username@$host' ] && [ -x '$ABSPATH/connected.sh' ]; then '$ABSPATH/connected.sh'; fi" >> /etc/ppp/ip-up
fi
if [ `grep -c "'$DIR/disconnected.sh'" /etc/ppp/ip-down` -eq 0 ]; then
	echo "if [ \"\$6\" == '$username@$host' ] && [ -x '$ABSPATH/disconnected.sh' ]; then '$ABSPATH/disconnected.sh'; fi" >> /etc/ppp/ip-down
fi

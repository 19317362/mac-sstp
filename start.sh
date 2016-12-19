#! /bin/bash

DIR="$(dirname $0)"

trap "$DIR/stop.sh; exit" SIGHUP SIGINT SIGTERM EXIT

sudo "$DIR/vpn.sh" connect

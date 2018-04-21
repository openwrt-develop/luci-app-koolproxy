#!/bin/sh

kpfolder="/usr/share/koolproxy/data"
if [ -f $kpfolder/private/ca.key.pem ]; then
	echo "Already generate ca"
else
	echo "Generating ca once time"
	/usr/share/koolproxy/koolproxy --cert 2>&1 >/dev/null
fi

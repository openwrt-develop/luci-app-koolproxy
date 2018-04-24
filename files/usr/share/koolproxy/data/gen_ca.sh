#!/bin/sh

kpfolder="/usr/share/koolproxy/data"
if [ ! -f $kpfolder/openssl.cnf ]; then
	echo "Cannot found openssl.cnf"
	exit 1
fi
if [ -f $kpfolder/private/ca.key.pem ]; then
	echo "Already generate ca"
else
	echo "Generating ca once time"

	#step 1, root ca
	mkdir -p $kpfolder/certs $kpfolder/private
	rm -f $kpfolder/index.txt $kpfolder/serial $kpfolder/private/ca.key.pem
	chmod 700 $kpfolder/private
	touch $kpfolder/index.txt
	echo 1000 > $kpfolder/serial
	openssl genrsa -aes256 -passout pass:koolshare -out $kpfolder/private/ca.key.pem 2048
	chmod 400 $kpfolder/private/ca.key.pem
	openssl req -config $kpfolder/openssl.cnf -passin pass:koolshare \
		-subj "/C=CN/ST=Beijing/L=KP/O=KoolProxy inc/CN=koolproxy.com" \
		-key $kpfolder/private/ca.key.pem \
		-new -x509 -days 7300 -sha256 -extensions v3_ca \
		-out $kpfolder/certs/ca.crt

	#step 2, domain rsa key
	openssl genrsa -aes256 -passout pass:koolshare -out $kpfolder/private/base.key.pem 2048
fi

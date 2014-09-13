#!/usr/bin/bash


## You want to change this like:
DOMAIN="fusion"


if [[ "$DOMAIN" == "mysite1.net" ]]
then
    echo "Please change your domain!"
    exit 1

fi

fail_if_error() {
    [ $1 != 0 ] && {
        unset PASSPHRASE
        exit 10
    }
}

CERTDIR="/var/db/ssl/certs"
CERTPREFIX="nginx"
GROUP="www"

SUBJ="
C=AU
ST=Victoria
O=FusionPBX
localityName=Melbourne
commonName=$DOMAIN
organizationalUnitName=Infrastructure
emailAddress=domains@fusionpbx.com
"

export PASSPHRASE=$(head -c 128 /dev/random  | uuencode - | grep -v "^end" | tr "\n" "d")
echo "Creating certificates"
mkdir -p $CERTDIR

openssl genrsa -des3 -out $CERTDIR/$CERTPREFIX.key -passout env:PASSPHRASE 2048
fail_if_error $?

openssl req \
    -new \
    -batch \
    -subj "$(/opt/local/bin/echo -n "$SUBJ" | /opt/local/bin/tr "\n" "/")" \
    -key $CERTDIR/$CERTPREFIX.key \
    -out $CERTDIR/$CERTPREFIX.csr \
    -passin env:PASSPHRASE
fail_if_error $?

cp $CERTDIR/$CERTPREFIX.key $CERTDIR/$CERTPREFIX.key.org
fail_if_error $?

openssl rsa -in $CERTDIR/$CERTPREFIX.key.org -out $CERTDIR/$CERTPREFIX.key -passin env:PASSPHRASE
fail_if_error $?

openssl x509 -req -days 365 -in $CERTDIR/$CERTPREFIX.csr -signkey $CERTDIR/$CERTPREFIX.key -out $CERTDIR/$CERTPREFIX.crt
fail_if_error $?

cat $CERTDIR/$CERTPREFIX.key $CERTDIR/$CERTPREFIX.crt > $CERTDIR/$CERTPREFIX.pem

chgrp -R $GROUP $CERTDIR

unset PASSPHRASE


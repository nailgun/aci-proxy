#!/bin/sh

set -e

openssl req -new -newkey rsa:2048 -subj '/CN=Squid CA' -sha256 -days 36500 -nodes -x509 -extensions v3_ca -keyout ca-key.pem -out ca.pem
cat ca-key.pem ca.pem > ca-bundle.pem
rm ca-key.pem
openssl x509 -in ca.pem -text

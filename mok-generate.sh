#!/bin/bash
# CHANGELOG: Script as-code per Cold Storage MOK Root CA creation.
set -euo pipefail
echo "1. Creazione file di configurazione OpenSSL (mokconfig.cnf)"
cat << 'EOF' > mokconfig.cnf
[ req ]
default_bits = 4096
distinguished_name = req_distinguished_name
prompt = no
string_mask = utf8only
x509_extensions = myexts
[ req_distinguished_name ]
O = Ermete OS Project
CN = Ermete OS v1.0 MOK Root CA
emailAddress = security@ermeteos.local
[ myexts ]
basicConstraints=critical,CA:FALSE
keyUsage=digitalSignature
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid
EOF

echo "2. Esecuzione della generazione asimmetrica RSA 4096"
openssl req -new -x509 -newkey rsa:4096 \
        -config mokconfig.cnf \
        -keyout ErmeteOS-MOK.key \
        -out ErmeteOS-MOK.crt \
        -nodes -days 3650 -outform PEM

echo "3. Conversione del Certificato Pubblico da PEM a DER"
openssl x509 -in ErmeteOS-MOK.crt -out ErmeteOS-MOK.der -outform DER
echo "Generazione terminata. Esportare in /etc/pki/ermeteos/"

#!/bin/bash

REL_PATH=/var/www/ssl

echo -e "\e[36;1mSSL CERTIFICAT GENERATOR\e[0m"
read -p "Please enter SSL directory path : " REL_PATH
read -p "Please enter website name : " NAME

openssl genrsa -des3 -out $REL_PATH/$NAME.key 1024

# GENERATING CSR FILE
openssl req -new -key $REL_PATH/$NAME.key -out $REL_PATH/$NAME.csr

# CREATING BACKUP OF THE KEY
cp $REL_PATH/$NAME.key $REL_PATH/$NAME.key.org
openssl rsa -in $REL_PATH/$NAME.key.org -out $REL_PATH/$NAME.key

#CERTIFICATE GENERATiON
openssl x509 -req -days 365 -in $REL_PATH/$NAME.csr -signkey $REL_PATH/$NAME.key -out $REL_PATH/$NAME.crt

echo "Add these lines to your Virtual host :"
echo -e "\n----------------ADD LINES UNDER TO YOUR VIRTUAL HOST----------------"
echo "SSLEngine On"
echo "SSLOptions +FakeBasicAuth +ExportCertData +StrictRequire"
echo "SSLCertificateFile \"$REL_PATH/$NAME.crt\""
echo "SSLCertificateKeyFile \"$REL_PATH/$NAME.key\""
echo "--------------------------------END----------------------------------"

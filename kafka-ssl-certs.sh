#!/bin/bash

rm -rf kafka-certs
rm -rf secrets

mkdir kafka-certs
mkdir secrets
cd kafka-certs

# Inputs for keystore passwords:
echo -n "Enter the password for ssl creds: "
read -s ssl_pass
echo 

echo -n "Enter the password for broker keystore: "
read -s keystore_pass
echo 

echo -n "Enter the password for kafka truststore: "
read -s truststore_pass
echo 

echo -n "Enter the password for client keystore: "
read -s client_keystore_pass
echo


openssl req -new -x509 -keyout ca-key.pem -out ca-cert.pem -days 365 -subj "/CN=kafka" -passout pass:"$ssl_pass"

  

echo "generating broker certs"
# Generating certs and keystores for each Kafka Broker:
for i in "$@"
do
   openssl genrsa -out "$i".key 2048
   openssl req -new -key "$i".key -out "$i".csr -subj "/CN=$i"
   openssl x509 -req -in "$i".csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out "$i".crt -days 365 -extensions v3_req -passin pass:"$ssl_pass"
   openssl pkcs12 -export -in "$i".crt -inkey "$i".key -out "$i".p12 -name "$i" -passout pass:"$keystore_pass"
   openssl pkcs12 -export -in ca-cert.pem -inkey ca-key.pem -out broker.p12 -name "caroot" -passout pass:"$keystore_pass"
   keytool -keyalg RSA -importkeystore -srckeystore "$i".p12 -srcstoretype PKCS12 -srcstorepass "$keystore_pass" -destkeystore "$i".keystore.jks -deststorepass "$keystore_pass"
   keytool -keyalg RSA -importkeystore -srckeystore broker.p12 -srcstoretype PKCS12 -srcstorepass "$keystore_pass" -destkeystore "$i".keystore.jks -deststorepass "$keystore_pass"
done

# Genrating client keystore
openssl genrsa -out client.key 2048
openssl req -new -key client.key -out client.csr -subj "/CN=client"
openssl x509 -req -in client.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out client.crt -days 365 -extensions v3_req -passin pass:"$ssl_pass"
openssl pkcs12 -export -in client.crt -inkey client.key -out client.p12 -name client -passout pass:"$client_keystore_pass"
keytool -keyalg RSA -importkeystore -srckeystore client.p12 -srcstoretype PKCS12 -srcstorepass "$client_keystore_pass" -destkeystore client.keystore.jks -deststorepass "$client_keystore_pass"
keytool -keyalg RSA -importkeystore -srckeystore broker.p12 -srcstoretype PKCS12 -srcstorepass "$client_keystore_pass" -destkeystore client.keystore.jks -deststorepass "$client_keystore_pass"

# Trust store generate:
keytool -keystore kafka.truststore.jks -alias CARoot -import -file ca-cert.pem -storepass "$truststore_pass" -noprompt

# Copy keystore and truststore files to /secrets:

cp -R *.keystore.jks *.truststore.jks ../secrets

echo "$keystore_pass" > ../secrets/kafka_keystore_creds
echo "$truststore_pass" > ../secrets/kafka_truststore_creds
echo "$client_keystore_pass" > ../secrets/client_keystore_creds
echo "$keystore_pass" > ../secrets/kafka_ssl_key_creds


sed -i "s|^\(ssl\.truststore\.password=\).*|\1$truststore_pass|" ../client.properties
sed -i "s|^\(ssl\.keystore\.password=\).*|\1$client_keystore_pass|" ../client.properties
sed -i "s|^\(ssl\.key\.password=\).*|\1$client_keystore_pass|" ../client.properties



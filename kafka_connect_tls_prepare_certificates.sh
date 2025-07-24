
#!/usr/bin/env bash

set -e

CERTS_STORE_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32)
export CERTS_STORE_PASSWORD

function create_truststore {
  # Disable FIPS if needed
  if [ "$FIPS_MODE" = "disabled" ]; then
      KEYTOOL_OPTS="${KEYTOOL_OPTS} -J-Dcom.redhat.fips=false"
  else
      KEYTOOL_OPTS=""
  fi

   # shellcheck disable=SC2086
   keytool ${KEYTOOL_OPTS} -keystore "$1" -storepass "$2" -noprompt -alias "$4" -import -file "$3" -storetype PKCS12
}

function create_keystore_without_ca_file {
   RANDFILE=/tmp/.rnd openssl pkcs12 -export -in "$3" -inkey "$4" -name "$5" -password pass:"$2" -out "$1" -certpbe aes-128-cbc -keypbe aes-128-cbc -macalg sha256
}

function create_keystore {
   RANDFILE=/tmp/.rnd openssl pkcs12 -export -in "$3" -inkey "$4" -chain -CAfile "$5" -name "$6" -password pass:"$2" -out "$1" -certpbe aes-128-cbc -keypbe aes-128-cbc -macalg sha256
}

function prepare_truststore {
    TRUSTSTORE=$1
    PASSWORD=$2
    BASEPATH=$3
    TRUSTED_CERTS=$4

    rm -f "$TRUSTSTORE"

    IFS=';' read -ra CERTS <<< "${TRUSTED_CERTS}"
    for cert in "${CERTS[@]}"
    do
        for file in $BASEPATH/$cert
        do
            if [ -f "$file" ]; then
                echo "Adding $file to truststore $TRUSTSTORE with alias $file"
                create_truststore "$TRUSTSTORE" "$PASSWORD" "$file" "$file"
            fi
        done
    done
}

echo "Preparing keystore ..."
STORE=/tmp/cluster.keystore.p12
rm -f "$STORE"
crtfile=`find /opt/kafka/connect-certs -name 'user.crt' | head -1`
keyfile=`find /opt/kafka/connect-certs -name 'user.key' | head -1`
echo "Preparing keystore with ${crtfile} and ${keyfile}..."
create_keystore_without_ca_file "$STORE" "$CERTS_STORE_PASSWORD" "${crtfile}" "${keyfile}" "user.crt"
ls -lrt /tmp

echo "Preparing truststore..."
keytool -keystore "/tmp/cluster.truststore.p12" -storepass "$CERTS_STORE_PASSWORD" -noprompt -alias "cacrt" -import -file "/mnt/kafka/external-configuration/kafka-cluster-secrets/ca.crt" -storetype PKCS12
ls -lrt /tmp

exec "$@"
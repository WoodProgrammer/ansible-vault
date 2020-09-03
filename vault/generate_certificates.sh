#!/bin/bash
set -x

CERT_COMPANY_NAME=${CERT_COMPANY_NAME:=MyCompany}
CERT_COUNTRY=${CERT_COUNTRY:=TR}
CERT_STATE=${CERT_STATE:=ISTANBUL}
CERT_CITY=${CERT_CITY:=ISTANBUL}

CERT_DIR=${CERT_DIR:=certs}

ROOT_CERT=${ROOT_CERT:=rootCA.pem}
ROOT_CERT_KEY=${ROOT_CERT_KEY:=rootCA.key.pem}


mkdir -p $CERT_DIR

create_root_cert(){

  openssl genrsa \
    -out $CERT_DIR/$ROOT_CERT_KEY \
    2048

  openssl req \
    -x509 \
    -new \
    -nodes \
    -key ${CERT_DIR}/$ROOT_CERT_KEY \
    -days 1024 \
    -out ${CERT_DIR}/$ROOT_CERT \
    -subj "/C=$CERT_COUNTRY/ST=$CERT_STATE/L=$CERT_CITY/O=$CERT_COMPANY_NAME Signing Authority/CN=$CERT_COMPANY_NAME Signing Authority"
}


create_domain_cert()
{
  local FQDN=$1
  local FILENAME=${FQDN/\*/wild}

  openssl genrsa \
    -out $CERT_DIR/${FILENAME}.key \
    2048

  if [[ ! -z "${SAN}" ]]; then
    openssl req -new \
      -key ${CERT_DIR}/${FILENAME}.key \
      -out ${CERT_DIR}/${FILENAME}.csr \
      -subj "/C=${CERT_COUNTRY}/ST=${CERT_STATE}/L=${CERT_CITY}/O=$CERT_COMPANY_NAME/CN=${FQDN}" \
      -reqexts san_env -config <(cat /etc/ssl/openssl.cnf <(cat ./openssl-san.cnf))
  else
    openssl req -new \
      -key ${CERT_DIR}/${FILENAME}.key \
      -out ${CERT_DIR}/${FILENAME}.csr \
      -subj "/C=${CERT_COUNTRY}/ST=${CERT_STATE}/L=${CERT_CITY}/O=$CERT_COMPANY_NAME/CN=${FQDN}"
  fi


  if [[ ! -z "${SAN}" ]]; then
    openssl x509 \
      -sha256 \
      -req -in $CERT_DIR/${FILENAME}.csr \
      -CA $CERT_DIR/$ROOT_CERT \
      -CAkey $CERT_DIR/$ROOT_CERT_KEY \
      -CAcreateserial \
      -out $CERT_DIR/${FILENAME}.crt \
      -days 500 \
      -extensions san_env \
      -extfile openssl-san.cnf
  else
    openssl x509 \
      -sha256 \
      -req -in $CERT_DIR/${FILENAME}.csr \
      -CA $CERT_DIR/$ROOT_CERT \
      -CAkey $CERT_DIR/$ROOT_CERT_KEY \
      -CAcreateserial \
      -out $CERT_DIR/${FILENAME}.crt \
      -days 500
  fi
}

 METHOD=$1
 ARGS=${*:2}

echo "Called with $METHOD and $ARGS"
if [ -z "${METHOD}" ]; then
  echo "Usage ./sslcerts.sh [create_root_cert|create_domain_cert] <args>"
  echo "Below are the environment variabls you can use:"
  echo "CERT_COMPANY_NAME=Company Name"
  echo "CERT_COUNTRY=Country"
  echo "CERT_STATE=State"
  echo "CERT_CITY=City"
  echo "CERT_DIR=Directory where certificate needs to be genereated"
  echo "ROOT_CERT=Name of the root cert"
  echo "ROOT_CERT_KEY=Name of root certificate key"
else
  ${METHOD} ${ARGS}
fi

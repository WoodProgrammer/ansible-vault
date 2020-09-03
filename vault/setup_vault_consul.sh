#!/bin/bash
export USER=${USER:=ubuntu}
export PRIVATE_KEY=${PRIVATE_KEY:=key}
export DOMAIN=$1


generate_certificates(){
    ./generate_certificates.sh create_root_cert
    ./generate_certificates.sh create_domain_cert "*.${DOMAIN}"

    cp certs/*.${DOMAIN}.* roles/nginx/tasks/files
    cp certs/rootCA.pem roles/vault/tasks/files

}

setup_nginx(){

    ansible-playbook -i hosts.ini  \
     -u ${USER} nginx.yaml \
     --private-key ${PRIVATE_KEY}

}

setup_consul(){
    
    ansible-playbook -i hosts.ini  \
     -u ${USER} common.yaml \
     --private-key ${PRIVATE_KEY}

}


setup_(){
    
    ansible-playbook -i hosts.ini  \
     -u ${USER} common.yaml \
     --private-key ${PRIVATE_KEY}

}

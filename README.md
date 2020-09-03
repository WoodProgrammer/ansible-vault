# vault-ansible-playbook
Consul Based Vault Playbook

This repository contains playbooks to deploy Vault and Consule all together by architectural design of this repository is terminating TLS option on nginx.

## Components of this repository:
* Nginx 
* Consul (Single Node) (notice: Multi Node not tested)
* Vault (Single Node) (notice: Multi Node not tested)

Let's have a look how can you run those stack:

1-) You should group by role the nodes on hosts.ini file ;
``` # hosts.ini
[local]
127.0.0.1

[consul]
N.D.N.H

[vault]
A.B.C.D

[nginx]
B.C.D.E

```

2-) You should generate you certificate files via this script:
```sh
    ./generate_certificates.sh create_root_cert
    ./generate_certificates.sh create_domain_cert DOMAIN_NAME

```
This script helps to you sign your AUTHORITY certificates and make you able to issue self signed SSL.You can trust those certs via update-ca-certs.

3-) nginx, consul and vault playbooks are setting up Systemd and application based requirements you can check the `setup_vault_consul.sh` script.

Notice: Vault is setting up sealed mode so in current stack you should make unsealing process as manually.

Thanks 
Any question: emirozbirdeveloper@gmail.com

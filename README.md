# Vagrant Multi-machine env

>Vagrant 2.0.1 Virtualbox 5.2.6

Multi-machine Vault Lab environment. Vault and PostgreSQL servers are set up on CentOS7. Storage backend used does not support HA

- Configuration dirs:
  - /etc/vault
  - /var/lib/pgsql/10/data/
- Folder sync: enabled
- Provision: bash
- Network: private

Unseal keys and root token available as $key1 $key2 $key3 $root_token

```bash

vagrant up
.....
vagrant ssh vault
vault status

vault operator unseal $key1
vault operator unseal $key2
vault operator unseal $key3

```
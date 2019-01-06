#!/bin/bash

sudo yum -y install vim > /dev/null
sudo yum -y install net-tools > /dev/null

postgresql_url="https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm"

echo "Install PostgreSQL"

sudo yum install $postgresql_url -y
sudo yum install postgresql10-server postgresql10-contrib -y
echo "Initialize database"
sudo /usr/pgsql-10/bin/postgresql-10-setup initdb

echo "Start&Enable postgres"
sudo systemctl enable postgresql-10 > /dev/null
sudo systemctl start postgresql-10 

echo "Configure Postgresql"
sudo -i 
cp /vagrant/shell_provision/config/postgresql/postgresql.conf /var/lib/pgsql/10/data 
cp /vagrant/shell_provision/config/postgresql/pg_hba.conf /var/lib/pgsql/10/data


echo "Genereate certs"
pushd  /var/lib/pgsql/10/data/
openssl req -subj '/CN=masterdb/' -x509 -batch -nodes -newkey rsa:2048 -keyout server.key -out server.crt > /dev/null

echo "Set permissions on private key"
chown postgres.postgres server.key server.crt
chmod 600 server.key
sudo systemctl restart postgresql-10.service

echo "Set postgresql password"

sudo -i -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'password'"

sudo -i -u postgres psql -c "CREATE DATABASE vault;"
sudo -i -u postgres psql -c 'CREATE TABLE vault_kv_store (parent_path TEXT COLLATE "C" NOT NULL, path TEXT COLLATE "C",key TEXT COLLATE "C", value BYTEA, CONSTRAINT pkey PRIMARY KEY(path, key));'
sudo -i -u postgres psql -c "CREATE INDEX parent_path_idx ON vault_kv_store (parent_path);"
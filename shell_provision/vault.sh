#!/bin/bash

echo "Install Packages"
yum -y install wget unzip vim

echo "Download Vault"
wget https://releases.hashicorp.com/vault/1.0.1/vault_1.0.1_linux_amd64.zip > /dev/null

echo "Unzip Vault & move to bin"
unzip vault_1.0.1_linux_amd64.zip
mv vault /usr/local/bin/

echo "setcap"
setcap cap_ipc_lock=+ep /usr/local/bin/vault
echo "Add vault user"
useradd -r vault -d /var/lib/vault -s /bin/nologin

echo "Create config folder"
mkdir -p /etc/vault
chown vault.vagrant /etc/vault

#echo "File Backend storage: Add folder"
#mkdir /var/lib/vault
#chown vault.vault /var/lib/vault
#chmode 750 /var/lib/vault

#echo 'storage "file" {
#  address = "127.0.0.1:8500"
#  path    = "/var/lib/vault"
#}
#
#listener "tcp" {
#  address     = "127.0.0.1:8200"
#  tls_disable = 1
#}' > /etc/vault/vault.hcl

echo 'storage "postgresql" {
      connection_url = "postgres://postgres:password@10.0.0.25:5432/postgres"
}

listener "tcp" {
  address     = "10.0.0.21:8200"
  tls_cert_file ="/etc/vault/cert.pem"
  tls_key_file  ="/etc/vault/key.pem"
  tls_disable = 1
}
listener "tcp" {
  address 	="127.0.0.1:8200"
  tls_disable   = 1
}
api_addr="http://10.0.0.21:8200"' > /etc/vault/vault.hcl

chmod 640 /etc/vault/vault.hcl
chown vault.vault /etc/vault/vault.hcl

echo "Generate vault certs"


echo "Create Unit File"

echo "[Unit]
Description=a tool for managing secrets
Documentation=https://vaultproject.io/docs/
After=network.target
ConditionFileNotEmpty=/etc/vault/vault.hcl

[Service]
User=vault
Group=vault
ExecStart=/usr/local/bin/vault server -config=/etc/vault/vault.hcl
ExecReload=/usr/local/bin/kill --signal HUP $MAINPID
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
Capabilities=CAP_IPC_LOCK+ep
SecureBits=keep-caps
NoNewPrivileges=yes
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/vault.service

echo "export VAULT_ADDR='http://127.0.0.1:8200'" >>/home/vagrant/.bash_profile
source /home/vagrant/.bash_profile
echo "Start/Enable Vault"
sudo systemctl start vault
sudo systemctl enable vault

echo "sleep ..."
sleep 5
st=$(/usr/local/bin/vault status | grep Initialized | awk '{print $2}')

if [ $st == "false" ];then
  echo "Initialize Vault"
	/usr/local/bin/vault operator init > /etc/vault/init.file

  echo "Export root token"
  echo "export root_token=$(grep -i "Token:" /etc/vault/init.file  | awk '{print $4}')" >> /home/vagrant/.bash_profile
  #echo "Export Keys"
  echo "export key1=$(grep -i "1:" /etc/vault/init.file  | awk '{print $4}')">>/home/vagrant/.bash_profile
  echo "export key2=$(grep -i "2:" /etc/vault/init.file  | awk '{print $4}')">>/home/vagrant/.bash_profile
  echo "export key3=$(grep -i "3:" /etc/vault/init.file  | awk '{print $4}')">>/home/vagrant/.bash_profile
  chown .vagrant /etc/vault/init.file
  chmod 664 /etc/vault/init.file
else
  echo "Vault already initialized ????"
fi


Vagrant.configure("2") do |config|
  config.vm.define "postgresql" do |db|
    db.vm.box = "centos/7"
    db.vm.network "private_network", ip: "10.0.0.25"
    db.vm.hostname = "masterdb"
    db.vm.synced_folder "./", "/vagrant"
    db.vm.provision "shell" do |s|
      s.path = "shell_provision/postresql.sh"
    end
  end
  config.vm.define "vault" do |vault|
    vault.vm.box = "centos/7"
    vault.vm.network "private_network", ip: "10.0.0.21"
    vault.vm.hostname = "vault1.home"
    vault.vm.provision "shell" do |s|
      s.path = "shell_provision/vault.sh"
    end
  end
end

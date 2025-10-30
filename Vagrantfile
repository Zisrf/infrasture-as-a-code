Vagrant.configure("2") do |config|
  # Machine application - SEULEMENT 2 MACHINES
  config.vm.define "app1" do |app|
    app.vm.box = "ubuntu/focal64"
    app.vm.hostname = "app1"
    app.vm.network "private_network", ip: "192.168.56.10"
    app.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
      vb.name = "app1-lab-ansible"
    end
  end

  # Machine base de données
  config.vm.define "db1" do |db|
    db.vm.box = "ubuntu/focal64"
    db.vm.hostname = "db1"
    db.vm.network "private_network", ip: "192.168.56.11"
    db.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
      vb.name = "db1-lab-ansible"
    end
  end
end

# Vagrantfile to create 3 Debian hosts on VirtualBox
Vagrant.configure("2") do |config|
  
  # Define the base box to use
  config.vm.box = "debian/bookworm64"

  # Define the first VM
  config.vm.define "spark-master" do |host1|
    host1.vm.hostname = "spark-master"
    host1.vm.network "private_network", ip: "192.168.56.101"
  end

  # Define the second VM
  config.vm.define "spark-worker-1" do |host2|
    host2.vm.hostname = "spark-worker-1"
    host2.vm.network "private_network", ip: "192.168.56.102"
  end

  # Define the third VM
  config.vm.define "spark-worker-2" do |host3|
    host3.vm.hostname = "spark-worker-2"
    host3.vm.network "private_network", ip: "192.168.56.103"
  end

  # Provider-specific configuration
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "512"
    vb.cpus = 1
  end

end

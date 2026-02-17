# -*- mode: ruby -*-
# vi: set ft=ruby :

domain = "docker-lab.example"
network_ip_range = "192.168.200"

machines = {
  "master"   => {"memory" => "2048", "cpu" => "2", "ip" => "10", "image" => "debian/bookworm64"},
  "node01"   => {"memory" => "2048", "cpu" => "2", "ip" => "21", "image" => "debian/bookworm64"},
  "node02"   => {"memory" => "1024", "cpu" => "1", "ip" => "22", "image" => "almalinux/8"},  
  "registry" => {"memory" => "2048", "cpu" => "2", "ip" => "50", "image" => "debian/bookworm64"}
}

Vagrant.configure("2") do |config|
  config.vm.boot_timeout = 600

  config.vm.provider "libvirt" do |libvirt|
    libvirt.uri = "qemu:///system"
  end

  machines.each do |name, conf|
    config.vm.define name do |machine|
      machine.vm.box = conf["image"]
      machine.vm.hostname = "#{name}.#{domain}"

      machine.vm.network "private_network",
        ip: "#{network_ip_range}.#{conf["ip"]}",
        libvirt__network_name: "vagrant-private-net"

      machine.vm.provider "libvirt" do |libvirt|
        libvirt.memory = conf["memory"]
        libvirt.cpus = conf["cpu"]
      end

      # Passando variáveis de ambiente para o script
      machine.vm.provision "shell", 
        path: "provision.sh",
        env: {"REGISTRY_IP" => "#{network_ip_range}.50"}
    end
  end
end

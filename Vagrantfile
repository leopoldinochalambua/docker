# -*- mode: ruby -*-
# vi: set ft=ruby :

# Definindo o domínio e a faixa de IP da rede
domain = "docker-lab.example"
network_ip_range = "192.168.200"

# Definindo as máquinas do laboratório
# A chave "role" não é mais necessária, pois o provisionamento é genérico
machines = {
  "master"   => {"memory" => "2048", "cpu" => "2", "ip" => "10", "image" => "debian/bookworm64"},
  "node01"   => {"memory" => "2048", "cpu" => "2", "ip" => "21", "image" => "debian/bookworm64"},
  "node02"   => {"memory" => "1024", "cpu" => "1", "ip" => "22", "image" => "almalinux/8"},  
  "registry" => {"memory" => "2048", "cpu" => "2", "ip" => "50", "image" => "debian/bookworm64"}
}

Vagrant.configure("2") do |config|
  config.vm.boot_timeout = 600

  # Configuração padrão do provedor libvirt
  config.vm.provider "libvirt" do |libvirt|
    libvirt.uri = "qemu:///system" # URI do libvirt
    libvirt.memory = 2048         # Memória padrão
    libvirt.cpus = 2              # CPU padrão
  end

  # Loop para criar e configurar cada máquina
  machines.each do |name, conf|
    config.vm.define name do |machine|
      # Definindo a caixa (box) e o hostname
      machine.vm.box = conf["image"]
      machine.vm.hostname = "#{name}.#{domain}"

      # Configuração da rede privada com IP estático
      # O IP deve corresponder à faixa do seu script
      machine.vm.network "private_network",
        ip: "#{network_ip_range}.#{conf["ip"]}",
        libvirt__network_name: "default"  # Definindo a rede padrão do libvirt

      # Configuração de recursos específicos para o provedor libvirt
      machine.vm.provider "libvirt" do |libvirt|
        libvirt.memory = conf["memory"]
        libvirt.cpus = conf["cpu"]
      end

      # Provisionamento da máquina
      # O script 'provision.sh' deve ser localizado no mesmo diretório do Vagrantfile
      machine.vm.provision "shell", path: "provision.sh"
    end
  end
end


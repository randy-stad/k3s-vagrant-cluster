# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

$k3s_token = %x[ openssl rand -hex 32 ]

Vagrant.configure(2) do |config|

  # node_num=3
  node_num=1

  (1..node_num).each do |i|
    if i == 1 then
      vm_name = "k3s-master"
    else
      vm_name = "k3s-agent-#{i-1}"
    end

    config.vm.define vm_name do |s|

      s.vm.hostname = "#{vm_name}.cluster.test"
      s.vm.box = "generic/fedora31"
      private_ip = "192.168.33.#{i+10}"
      s.vm.network "private_network", ip: private_ip, netmask: "255.255.255.0", auto_config: true
      s.vm.provision 'hosts', :sync_hosts => true, :add_localhost_hostnames => false
      s.vm.provision "shell", reboot: true, path: 'provision-common.sh'

      if i == 1 then
        # master
        s.vm.provision "shell", path: 'provision-master.sh', args: [$k3s_token, private_ip]
        s.vm.provision "shell", path: 'provision-traefik.sh'
        s.vm.provision "shell", path: 'provision-dashboard.sh'
        s.vm.synced_folder '.', '/vagrant', type: ""
      else
        # agent
        # s.vm.provision "shell", inline: $configureNode
      end
    end
  end
end
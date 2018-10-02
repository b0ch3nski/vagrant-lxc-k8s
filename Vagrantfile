SLAVES = Integer(ENV['VAGRANT_LXC_K8S_SLAVES']) rescue 1
CONTAINERS = SLAVES + 1
ANSIBLE_GROUPS = {}
ANSIBLE_GROUPS['k8s'] = (1..CONTAINERS).map { |index| "k8s-#{index}" }
ANSIBLE_GROUPS['k8s_master'] = ANSIBLE_GROUPS['k8s'][0]
ANSIBLE_GROUPS['k8s_slave'] = SLAVES > 0 ? ANSIBLE_GROUPS['k8s'][1..CONTAINERS] : ''
ANSIBLE_GROUPS['k8s:vars'] = {
    lxc_network: %x(ip -o -4 addr | awk '/lxcbr0/ { print $4 }').chomp,
    timezone: %x(timedatectl show --property=Timezone --value).chomp
}

Vagrant.configure(2) do |config|
  config.vm.box = 'magneticone/centos-7'
  config.vm.box_version = '1805.01'
  config.vm.box_check_update = false
  config.ssh.insert_key = false

  ANSIBLE_GROUPS['k8s'].each_with_index do |container_name, index|
    config.vm.define container_name do |container|
      container.vm.hostname = container_name

      container.vm.provider :lxc do |lxc|
        lxc.privileged = true
        lxc.container_name = container_name
        lxc.customize 'cgroup.memory.limit_in_bytes', '8192M'
        lxc.customize 'cgroup.devices.allow', 'a'
        lxc.customize 'mount.auto', 'proc:rw sys:rw'
        lxc.customize 'cap.drop', nil
      end

      if index == (CONTAINERS - 1)
        container.vm.provision 'ansible' do |ansible|
          ansible.compatibility_mode = '2.0'
          ansible.groups = ANSIBLE_GROUPS
          ansible.playbook = 'playbooks/install_kubernetes.yml'
          ansible.verbose = ENV['VAGRANT_LOG'] == 'debug' ? 'vvvv' : ''
          ansible.limit = 'all'
        end
      end
    end
  end
end

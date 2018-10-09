Vagrant.require_version '>= 2.1.5'
raise 'vagrant-lxc plugin is not installed!' unless Vagrant.has_plugin?('vagrant-lxc', '>= 1.4.0')
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'lxc'

require 'yaml'
DIR = File.dirname(__FILE__)
PROFILE = YAML.load_file(File.join(DIR, (ENV['VAGRANT_LXC_K8S_PROFILE'] || 'default.yml')))

CONTAINERS = PROFILE['system']['slaves'] + 1
ANSIBLE_GROUPS = {}
ANSIBLE_GROUPS['k8s'] = (1..CONTAINERS).map { |index| "k8s-#{index}" }
ANSIBLE_GROUPS['k8s_master'] = ANSIBLE_GROUPS['k8s'][0]
ANSIBLE_GROUPS['k8s_slave'] = PROFILE['system']['slaves'] > 0 ? ANSIBLE_GROUPS['k8s'][1..CONTAINERS] : ''

ANSIBLE_GROUPS['k8s:vars'] = {
    lxc_network: %x(ip -o -4 addr | awk '/#{PROFILE['system']['lxc_bridge']}/ { print $4 }').chomp,
    timezone: %x(timedatectl | awk '/Time zone:/ { print $3 }').chomp
}
ANSIBLE_GROUPS['k8s:vars'].merge!(PROFILE['ansible'] || {})

Vagrant.configure(2) do |config|
  config.vm.box = PROFILE['system']['box']
  config.vm.box_version = PROFILE['system']['box_version']
  config.vm.box_check_update = false
  config.ssh.insert_key = false

  ANSIBLE_GROUPS['k8s'].each_with_index do |container_name, index|
    config.vm.define container_name do |container|
      container.vm.hostname = container_name

      container.vm.provider :lxc do |lxc|
        lxc.privileged = true
        lxc.container_name = container_name
        lxc.customize 'cgroup.memory.limit_in_bytes', PROFILE['system']['container_ram']
        lxc.customize 'cgroup.devices.allow', 'a'
        lxc.customize 'mount.auto', 'proc:rw sys:rw'
        lxc.customize 'cap.drop', nil
      end

      if index == (CONTAINERS - 1)
        container.vm.provision 'ansible' do |ansible|
          ansible.compatibility_mode = '2.0'
          ansible.groups = ANSIBLE_GROUPS
          ansible.playbook = File.join(DIR, 'playbooks', 'install_kubernetes.yml')
          ansible.verbose = ENV['VAGRANT_LOG'] == 'debug' ? 'vvvv' : ''
          ansible.limit = 'all'
        end
      end
    end
  end
end

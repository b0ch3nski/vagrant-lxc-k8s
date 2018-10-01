# vagrant-lxc-k8s
Run multi-node **Kubernetes** locally using **Linux Containers**.

## Requirements
* **LXC** configured
  * with IP address assigned to `lxcbr0` bridge
* **Vagrant** >= 2.1
  * with `vagrant-lxc` plugin installed
* **Ansible** >= 2.6

Optionally, **Kubectl** and **Helm** could be installed and used on host system to control the cluster in containers.

## Configuration

### Environment
Set **LXC** as default backend for **Vagrant**:
```bash
export VAGRANT_DEFAULT_PROVIDER=lxc
```

**(Optional)** Define amount of slave machines *(default: 1)*:
```bash
export VAGRANT_LXC_K8S_SLAVES=3
```

**(Optional)** Enable verbose logging:
```bash
export VAGRANT_LOG=debug
```

### Install specific versions
All tools versions are defined in following file:
```
roles/kubernetes/defaults/main.yml
```

## Usage

### Initialize
Create containers and install **Kubernetes**:
```bash
vagrant up
```
Following command will bring up desired amount of containers and deploy **Kubernetes** cluster using **Ansible**
provisioner.

Administrator **Kubectl** configuration will be automatically copied to your local `~/.kube/config`.

Dashboard should be available at following URL:
```
http://<K8S-1-CONTAINER-IP>:8080/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```

### Re-initialize
Reset **Kubernetes** configuration without recreating containers:
```bash
ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory playbooks/reset_kubernetes.yml
vagrant provision
```
**Hint:** Direct `install_kubernetes.yml` playbook launching is also possible (with support for tags).

### Status
Check containers status:
```bash
vagrant status
sudo lxc-ls -f
```
**Hint:** The latter one will also print IP addresses.

### Shutdown
Stop all containers:
```bash
vagrant halt
```
**Hint:** Append `--force` parameter to enforce shutdown.

### Removal
Remove all containers:
```bash
vagrant destroy
```
**Hint:** Append `--parallel` parameter to speed up.

# vagrant-lxc-k8s
Run multi-node **Kubernetes** locally using **Linux Containers**.

## Caveats
* Usage of `sudo` is required. Containers must start in `privileged` mode to ensure proper operation of **Docker** and
**Kubernetes**.
* Only 1 **Kubernetes** master configuration is currently supported.
* **Ansible** role that initializes **Kubernetes** is *NOT* idempotent. There is no easy way to find already initialized
clusters/nodes using `kubeadm`.

## Requirements
* **LXC** >= 2.1
  * configured to use `lxcbr0` network bridge
* **Vagrant** >= 2.1.5
  * with plugin **vagrant-lxc** >= 1.4.0
* **Ansible** >= 2.6

Optionally, **Kubectl** and **Helm** could be installed and used on host system to control the cluster in containers
(make sure that their versions match these installed in containers).

## Configuration
Basic support for profiles is included - default configuration is available in `default.yml` file.

Variable names are pretty much self-explanatory (-:

Use following environment variable to switch between profiles:
```bash
export VAGRANT_LXC_K8S_PROFILE=my-awesome-profile.yml
```

Any **Ansible** variable could be overridden in `ansible` section.

For example, to install different versions of **Kubernetes** and **Helm**, copy `default.yml` to
`my-awesome-profile.yml` with an addition of:
```yaml
ansible:
  k8s_version: 1.9.11
  k8s_helm_version: 2.9.1
```

To print all default **Ansible** variables, execute:
```bash
cat vars/global.yml roles/*/defaults/main.yml
```

## Usage

### Initialize
Create containers and install **Kubernetes**:
```bash
vagrant up
```
Following command will bring up desired amount of containers and deploy **Kubernetes** cluster using **Ansible**
provisioner.

Administrator **Kubectl** configuration will be automatically copied to your local `~/.kube/config` on host system.

Dashboard should be available at following URL:
```
http://<K8S-1-CONTAINER-IP>:8080/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```

### Re-initialize
Reset **Kubernetes** configuration without recreating **LXC** containers:
```bash
ansible-playbook -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory playbooks/reset_kubernetes.yml
vagrant provision
```
**Hint:** Direct `install_kubernetes.yml` playbook launch is also possible (with support for **Ansible tags**).

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

## Troubleshooting
Enable verbose logging:
```bash
export VAGRANT_LOG=debug
```

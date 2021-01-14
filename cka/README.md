# kubernetes

## CKA

### VirtualBox

VirtualBox is a prerequisite and should be installed on the host.
Follow this [link](https://www.virtualbox.org/)
### Packer

See [README](./packer/README.md)

### Vagrant

See [README](./vagrant/README.md)

### Quick Start

#### Create a new Box or download it

```bash
cd packer
packer build .
```

#### Import Box

```bash
vagrant box add output-vagrant/package.box --name "ubuntu-focal-kubernetes-1.18.12"
```

#### Create Environment

```bash
cd ../vagrant
# open Vagrantfile and set variables:
## `BOX`:            Box name (`ubuntu-focal-kubernetes-1.18.12`),
## `SSH_WITH_PASS`:  true or false,
## `PUBLIC_KEY`:     your public key,
## `MASTER_COUNT`:   the number of the master nodes,
## `WORKER_COUNT`:   the number of the worker nodes
vagrant up
```

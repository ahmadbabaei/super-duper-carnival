# Packer

[config.pkr.hcl](./config.pkr.hcl) contains the packer configs for creating an OVF file from an ISO image.

[scripts/bootstrap.sh](./scripts/bootstrap.sh) contains commands to install docker, kubectl, kubeadm, and used to prepare the new VM.

## Create a new Vagrant Box

Set variables properly in [variables file](variables.pkr.hcl)

```bash
packer build .
```

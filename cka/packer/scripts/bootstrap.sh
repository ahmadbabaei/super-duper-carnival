#!/usr/bin/env bash

set -o pipefail -o nounset -o xtrace -o errexit

# This script installs docker, kubectl, and minikube
LOG_FILE=/tmp/bootstrap.log
USER="${USER:-ubuntu}"
PASS="${PASS:-}"
HOME_DIR="/home/$USER"
SHELL="/bin/bash"
KUBE_VERSION="${KUBE_VERSION:-1.18.12}"
DOCKER_VERSION="${DOCKER_VERSION:-19.03.11}"
DNS_IPS=("178.22.122.100" "185.51.200.2")

# Create user
if [ "$USER" != "ubuntu" ]; then
	sudo useradd \
		--home-dir "$HOME_DIR" \
		--create-home \
		--password "$PASS" \
		--shell "$SHELL" \
		--groups sudo \
		"$USER"
fi

# Upgrade OS
{
	sudo apt-get update
	sudo apt-get upgrade --yes
}

# Disable swap
{
	sudo swapoff -v /swapfile || true
	sudo sed -i '/swap/d' /etc/fstab
	sudo rm /swapfile
} || true

# Load module and set sys params
{
	sudo modprobe br_netfilter
	cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
	sudo sysctl --system
}

# Install prerequisites
{
	sudo apt-get update
	sudo apt-get install --yes \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg-agent \
		software-properties-common \
		bash-completion
}

echo "Docker: Installing"
# Docker
## ref: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
{
	## Setup repository
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -
	sudo add-apt-repository \
	   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	   $(lsb_release -cs) \
	   stable"
	## Install docker engine
	sudo apt-get update
	sudo apt-get install --yes \
  		containerd.io=1.2.13-2 \
  		docker-ce=5:"$DOCKER_VERSION"~3-0~ubuntu-$(lsb_release -cs) \
  		docker-ce-cli=5:"$DOCKER_VERSION"~3-0~ubuntu-$(lsb_release -cs)
	cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
	sudo mkdir -p /etc/systemd/system/docker.service.d
	sudo systemctl daemon-reload
	sudo systemctl restart docker
	sudo systemctl enable docker

	## Enable user to execute docker without sudo
	sudo usermod -aG docker "$USER"
} #> "$LOG_FILE" 2>&1

echo "Kubeadm, Kubectl, Kubelet: Installing"
# Kubeadm, Kubectl, Kubelet
## ref:
{
	## Download and Install
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
	cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
	sudo apt-get update
	sudo apt-get install --yes \
		kubelet="$KUBE_VERSION-00" \
		kubeadm="$KUBE_VERSION-00" \
		kubectl="$KUBE_VERSION-00"
	sudo apt-mark hold kubelet kubeadm kubectl

} #>> "$LOG_FILE" 2>&1

# Pulling images required for setting up a Kubernetes cluster
sudo su \
	--login "$USER" \
	--shell "$SHELL" \
	--command \
"newgrp docker <<EOF
kubeadm config images pull --kubernetes-version=\"$KUBE_VERSION\"
EOF"

# Enable bash completion for kubectl, kubeadm
## define alias for kubectl
sudo su \
	--login "$USER" \
	--shell "$SHELL" \
	--command \
"cat >>\"$HOME_DIR\"/.bashrc <<EOF
source <(kubectl completion bash)
source <(kubeadm completion bash)

alias k='kubectl '
EOF"

# Set DNS IPs
sudo mv /etc/resolv.conf /etc/resolv.conf.old
for dns_ip in "${DNS_IPS[@]}"; do
	echo "nameserver $dns_ip" | sudo tee -a /etc/resolv.conf
done


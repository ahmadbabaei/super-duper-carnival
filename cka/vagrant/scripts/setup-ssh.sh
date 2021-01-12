#!/usr/bin/env bash
set -o xtrace -o errexit

if [ "$SSH_WITH_PASS" == "true" ]; then
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart sshd
fi

if [ ! -z "$PUBLIC_KEY" ]; then
    echo "Add public-key for ${USER} to authorized keys"
    mkdir /home/${USER}/.ssh || true
    echo "${PUBLIC_KEY}" >> /home/${USER}/.ssh/authorized_keys
fi
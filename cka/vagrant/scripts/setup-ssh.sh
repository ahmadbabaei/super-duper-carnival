#!/usr/bin/env bash
set -o xtrace -o errexit

echo "Add public-key for ${USER} to authorized keys"
mkdir /home/${USER}/.ssh || true
echo "${PUBLIC_KEY}" >> /home/${USER}/.ssh/authorized_keys
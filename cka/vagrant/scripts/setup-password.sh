#!/usr/bin/env bash
set -o pipefail -o xtrace -o errexit

echo "Set password for ${USER}"
echo -e "${PASSWORD}\n${PASSWORD}" | passwd ${USER}
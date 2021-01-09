#!/usr/bin/env bash
set -o pipefail -o nounset -o xtrace -o errexit

TMP_HOSTS=/tmp/hosts

echo "Fix /etc/hosts entries"
sed -e '/^.*ubuntu-focal.*/d' -i /etc/hosts
ip_address="$(ip -4 addr show ${PRIVATE_INTERFACE_NAME} | grep "inet" | head -1 | awk '{print $2}' | cut -d/ -f1)"
sed -e "s/^.*${HOSTNAME}.*/${ip_address} ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts

echo "Update /etc/hosts about other hosts"
master_first_ip="${MASTER_IP_START}"
worker_first_ip="${WORKER_IP_START}"
if [ "${MASTER_COUNT}" != "0" ]; then
    for i in $(seq 1 "$MASTER_COUNT"); do
        node_ip="${IP_NW}$(( master_first_ip + i ))"
        node_hostname="${MASTER_NAME}-$i"
        if [ "$node_hostname" != "$HOSTNAME" ]; then
            echo "$node_ip  $node_hostname" >> "$TMP_HOSTS"
        fi
    done
fi
if [ "${WORKER_COUNT}" != "0" ]; then
    for i in $(seq 1 "$WORKER_COUNT"); do
        node_ip="${IP_NW}$(( worker_first_ip + i ))"
        node_hostname="${WORKER_NAME}-$i"
        if [ "$node_hostname" != "$HOSTNAME" ]; then
            echo "$node_ip  $node_hostname" >> "$TMP_HOSTS"
        fi
    done
fi

if [ -f "$TMP_HOSTS" ]; then
    cat "$TMP_HOSTS" >> /etc/hosts
fi
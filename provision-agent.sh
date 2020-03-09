#!/bin/bash
set -eux

k3s_token="$1"; shift
master_ip="$1"; shift
ip_address="$1"; shift
fqdn="$(hostname --fqdn)"

# install k3s
curl -sfL https://get.k3s.io \
    | \
        K3S_TOKEN="$k3s_token" \
        K3S_URL="https://${master_ip}:6443" \
        sh -s -- \
            --node-ip "$ip_address" \
            --flannel-iface 'eth1'

# see the systemd unit
# systemctl cat k3s

# wait for this node to be ready
# $SHELL -c 'node_name=$(hostname); echo "waiting for node $node_name to be ready ..."; while [ -z "$(kubectl get nodes $node_name | grep -E "$node_name\s+Ready\s+")" ]; do sleep 3; done; echo "node ready"'

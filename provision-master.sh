#!/bin/bash
set -eux

k3s_token="$1"; shift
ip_address="$1"; shift
fqdn="$(hostname --fqdn)"

# allow stuff through the firewall (iptables now in legacy mode)
iptables -I INPUT -p tcp --dport 6443 -j ACCEPT

# install k3s
curl -sfL https://get.k3s.io \
    | \
        K3S_TOKEN="$k3s_token" \
        sh -s -- \
            server \
            --node-ip "$ip_address" \
            --cluster-cidr '10.12.0.0/16' \
            --service-cidr '10.13.0.0/16' \
            --cluster-dns '10.13.0.10' \
            --cluster-domain 'cluster.local' \
            --flannel-iface 'eth1'

# see the systemd unit
systemctl cat k3s

# wait for this node to be ready
$SHELL -c 'node_name=$(hostname); echo "waiting for node $node_name to be ready ..."; while [ -z "$(kubectl get nodes $node_name | grep -E "$node_name\s+Ready\s+")" ]; do sleep 3; done; echo "node ready"'

# wait for the kube-dns pod to be running
$SHELL -c 'node_name=$(hostname); echo "waiting for dns on $node_name to be ready ..."; while [ -z "$(kubectl get pods --selector k8s-app=kube-dns --namespace kube-system | grep -E "\s+Running\s+")" ]; do sleep 3; done; echo "dns ready"'

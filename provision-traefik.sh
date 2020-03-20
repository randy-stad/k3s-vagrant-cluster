#!/bin/bash
set -eux

# configure the traefik installation
printf "    dashboard.enabled: \"true\"\n    dashboard.domain: \"ingress.cluster.test\"\n    ssl.insecureSkipVerify: \"true\"" >> /var/lib/rancher/k3s/server/manifests/traefik.yaml

# wait for traefik to restart
$SHELL -c 'echo "waiting for traefik to be ready ..."; while [ -z "$(crictl pods --label app=svclb-traefik | grep -E "\s+Ready\s+")" ]; do sleep 3; done; echo "traefik ready"'

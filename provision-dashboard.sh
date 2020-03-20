#!/bin/bash
set -eux

# install the dashboard
kubectl apply -f "https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended.yaml"

# create the admin user
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: admin
    namespace: kubernetes-dashboard
EOF

# save the admin token (move this to a shared folder)
kubectl \
  -n kubernetes-dashboard \
  get \
  secret \
  $(kubectl -n kubernetes-dashboard get secret | grep admin-token- | awk '{print $1}') \
  -o json | jq -r .data.token | base64 --decode \
  >/tmp/admin-token.txt

# expose the kubernetes dashboard at k8s-dashboard.cluster.test
kubectl apply -n kubernetes-dashboard -f - <<'EOF'
kind: Ingress
apiVersion: networking.k8s.io/v1beta1
metadata:
  name: kubernetes-dashboard
spec:
  rules:
    - host: dashboard.cluster.test
      http:
        paths:
          - backend:
              serviceName: kubernetes-dashboard
              servicePort: 443
EOF
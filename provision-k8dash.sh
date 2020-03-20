#!/bin/bash
set -eux

# install the k8dash dashboard
kubectl apply -f "https://raw.githubusercontent.com/herbrandson/k8dash/master/kubernetes-k8dash.yaml"

# create the service account in the current namespace
kubectl -n kube-system create serviceaccount k8dash-sa

# Give that service account root on the cluster
kubectl -n kube-system create clusterrolebinding k8dash-sa --clusterrole=cluster-admin --serviceaccount=default:k8dash-sa

# Find the secret that was created to hold the token for the SA
kubectl -n kube-system get secrets

# Show the contents of the secret to extract the token
kubectl \
  -n kube-system \
  get \
  secret \
  $(kubectl -n kube-system get secret | grep k8dash-sa-token- | awk '{print $1}') \
  -o json | jq -r .data.token | base64 --decode \
  >/tmp/admin-token.txt

# expose k8dash at dashboard.cluster.test
kubectl apply -n kube-system -f - <<'EOF'
kind: Ingress
apiVersion: extensions/v1beta1
metadata:
  name: k8dash
  namespace: kube-system
spec:
  rules:
  -
    host: dashboard.cluster.test
    http:
      paths:
      -
        path: /
        backend:
          serviceName: k8dash
          servicePort: 80
EOF
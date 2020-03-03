#!/bin/bash
set -eux

# install the dashboard
kubectl apply -f "https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended.yaml"

# create the admin user.
# see https://github.com/kubernetes/dashboard/wiki/Creating-sample-user
# see https://github.com/kubernetes/dashboard/wiki/Access-control
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
# save the admin token.
kubectl \
  -n kubernetes-dashboard \
  get \
  secret \
  $(kubectl -n kubernetes-dashboard get secret | grep admin-token- | awk '{print $1}') \
  -o json | jq -r .data.token | base64 --decode \
  >/vagrant/admin-token.txt

# expose the kubernetes dashboard at k8s-dashboard.cluster.test.
# see kubectl get -n kubernetes-dashboard service/kubernetes-dashboard -o yaml
# see https://docs.traefik.io/providers/kubernetes-ingress/
# see https://docs.traefik.io/routing/providers/kubernetes-crd/
# see https://kubernetes.io/docs/concepts/services-networking/ingress/
# see https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.17/#ingress-v1beta1-networking-k8s-io
kubectl apply -n kubernetes-dashboard -f - <<'EOF'
kind: Ingress
apiVersion: networking.k8s.io/v1beta1
metadata:
  name: kubernetes-dashboard
spec:
  rules:
    # NB you can use any other host, but you have to make sure DNS resolves to one of k8s cluster IP addresses.
    # NB you can see the traefik configuration with:
    #       kubectl --namespace kube-system get $(kubectl --namespace kube-system get pods -l app=traefik -o name) -o yaml
    #       kubectl --namespace kube-system get configMap/traefik -o yaml
    #       kubectl --namespace kube-system logs $(kubectl --namespace kube-system get pods -l app=traefik -o name)
    - host: kubernetes-dashboard.cluster.test
      http:
        paths:
          - backend:
              serviceName: kubernetes-dashboard
              servicePort: 443
EOF
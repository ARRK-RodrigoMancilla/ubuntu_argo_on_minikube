
#!/usr/bin/env bash
set -euo pipefail

banner() { echo ""; echo "############################## $1"; echo ""; }

banner "kubectl: setup proxy on port 5555 for the kube-api-server of the minikube cluster"
# kube-api-server port forwarding: https://kubernetes.io/docs/tasks/extend-kubernetes/http-proxy-access-api/
# Examples of API usage with the proxy:
#   Try opening these in the browser:
#     - http://localhost:5555/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:80/proxy
#     - http://localhost:5555/api/v1/namespaces/argo/services/https:argo-server:2746/proxy
#     - http://localhost:5555/api/v1/namespaces/argo/services/http:minio:9001/proxy
kubectl --context minikube proxy --port 5555 &>> "$HOME/.minikube_proxy_logs.log" &

banner "kubectl: setup port-forwardig for argo server, minio (from argo deployment) and the argo events webhook"
kubectl -n argo        port-forward services/argo-server             2746:2746    &>> "$HOME/.minikube_proxy_logs.log" &
kubectl -n argo        port-forward services/minio                   9001:9001    &>> "$HOME/.minikube_proxy_logs.log" &
kubectl -n argo-events port-forward services/webhook-eventsource-svc 12000:12000  &>> "$HOME/.minikube_proxy_logs.log" &

set +euo pipefail

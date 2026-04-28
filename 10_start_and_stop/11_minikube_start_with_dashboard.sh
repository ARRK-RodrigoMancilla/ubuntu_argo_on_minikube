#!/usr/bin/env bash
set -euo pipefail

banner() { echo ""; echo "############################## $1"; echo ""; }

show_cluster_status() {
    banner "kubectl: list all minikube pods"
    kubectl get pods -A
    banner "kubectl: list all minikube services"
    kubectl get services -A
}

banner "minikube: start minikube"
minikube start

banner "minikube: enable addons"
minikube addons enable metrics-server
minikube addons enable dashboard

banner "minikube: list addons"
minikube addons list

banner "minikube: show status"
minikube status

show_cluster_status

banner "Waiting for all pods to be ready..."
kubectl wait --for=condition=Ready pods --all --all-namespaces --timeout=300s

banner "kubectl: setup proxy on port 5555 for the complete minikube cluster"
kubectl --context minikube proxy --port 5555 &>> "$HOME/.minikube_proxy_logs.log" &
# kube-api-server port forwarding: https://kubernetes.io/docs/tasks/extend-kubernetes/http-proxy-access-api/
# Examples of API usage with the proxy:
#   Try opening these in the browser:
#     - http://localhost:5555/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:80/proxy
#     - http://localhost:5555/api/v1/namespaces/argo/services/https:argo-server:2746/proxy
#     - http://localhost:5555/api/v1/namespaces/argo/services/http:minio:9001/proxy

show_cluster_status

set +euo pipefail

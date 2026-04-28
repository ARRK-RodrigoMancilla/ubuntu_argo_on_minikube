#!/usr/bin/env bash
set -euo pipefail

banner() { echo ""; echo "############################## $1"; echo ""; }

show_cluster_status() {
    banner "kubectl: list all minikube pods"
    kubectl get pods -A
    banner "kubectl: list all minikube services"
    kubectl get services -A
}

ARGO_WORKFLOWS_VERSION="v3.7.9"
ARGO_EVENTS_VERSION="v1.9.7"
MINIO_VERSION="RELEASE.2025-09-07T16-13-09Z"

banner "START Install Argo Workflows"

kubectl create namespace argo
kubectl apply -n argo -f "https://github.com/argoproj/argo-workflows/releases/download/${ARGO_WORKFLOWS_VERSION}/quick-start-minimal.yaml"

banner "END Install Argo Workflows"

show_cluster_status

banner "START Install Argo Events"

## Argo Events: install
kubectl create namespace argo-events
kubectl apply -f "https://raw.githubusercontent.com/argoproj/argo-events/${ARGO_EVENTS_VERSION}/manifests/install.yaml"
kubectl apply -f "https://raw.githubusercontent.com/argoproj/argo-events/${ARGO_EVENTS_VERSION}/manifests/install-validating-webhook.yaml" # Install with a validating admission controller

## Argo Events: Webhook: eventbus
kubectl apply -n argo-events -f "https://raw.githubusercontent.com/argoproj/argo-events/${ARGO_EVENTS_VERSION}/examples/eventbus/native.yaml"

## Argo Events: Webhook: event-source
kubectl apply -n argo-events -f "https://raw.githubusercontent.com/argoproj/argo-events/${ARGO_EVENTS_VERSION}/examples/event-sources/webhook.yaml"

## Argo Events: Webhook: service account, RBAC settings
kubectl apply -n argo-events -f "https://raw.githubusercontent.com/argoproj/argo-events/${ARGO_EVENTS_VERSION}/examples/rbac/sensor-rbac.yaml"
kubectl apply -n argo-events -f "https://raw.githubusercontent.com/argoproj/argo-events/${ARGO_EVENTS_VERSION}/examples/rbac/workflow-rbac.yaml"

## Argo Events: Webhook: sensor
kubectl apply -n argo-events -f "https://raw.githubusercontent.com/argoproj/argo-events/${ARGO_EVENTS_VERSION}/examples/sensors/webhook.yaml"

banner "END Install Argo Events"

show_cluster_status

banner "Waiting for Argo Workflows pods to be ready..."
kubectl wait --for=condition=Ready pods --all -n argo --timeout=300s

banner "Waiting for Argo Events pods to be ready..."
kubectl wait --for=condition=Ready pods --all -n argo-events --timeout=300s

show_cluster_status

banner "kubectl: setup proxies for argo server, minio (from argo deployment) and the argo events webhook"
kubectl -n argo        port-forward services/argo-server             2746:2746    &>> "$HOME/.minikube_proxy_logs.log" &
kubectl -n argo        port-forward services/minio                   9001:9001    &>> "$HOME/.minikube_proxy_logs.log" &
kubectl -n argo-events port-forward services/webhook-eventsource-svc 12000:12000  &>> "$HOME/.minikube_proxy_logs.log" &

banner "kubectl: show contexts"
kubectl config get-contexts

banner "kubectl: create context test_argo based on argo namespace"
kubectl config set-context test_argo --cluster=minikube --user=minikube --namespace=argo

banner "kubectl: create context test_events based on argo-events namespace"
kubectl config set-context test_events --cluster=minikube --user=minikube --namespace=argo-events

banner "kubectl: switch to new test_argo context"
kubectl config use-context test_argo

banner "kubectl: show contexts again"
kubectl config get-contexts

set +euo pipefail

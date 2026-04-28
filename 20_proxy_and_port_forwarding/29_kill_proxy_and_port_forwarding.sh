#!/usr/bin/env bash
# set -euo pipefail

banner() { echo ""; echo "############################## $1"; echo ""; }

banner "pgrep: kill kubectl kube-api-server proxy process running in the background"
pkill -f 'kubectl --context minikube proxy.*--port 5555.*'

banner "pgrep: kill kubectl port-forwarding processes running in the background"
pkill -f 'kubectl.*port-forward.*'
# pkill -f 'kubectl -n argo.*port-forward.*'




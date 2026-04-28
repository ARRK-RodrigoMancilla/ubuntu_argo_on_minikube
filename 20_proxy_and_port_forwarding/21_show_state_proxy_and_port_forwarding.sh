#!/usr/bin/env bash
# set -euo pipefail

banner() { echo ""; echo "############################## $1"; echo ""; }

banner "pgrep: show kubectl kube-api-server proxy process running in the background"
pgrep -fa 'kubectl --context minikube proxy.*--port 5555.*'

banner "pgrep: show kubectl port-forwarding processes running in the background"
pgrep -fa 'kubectl.*port-forward.*'

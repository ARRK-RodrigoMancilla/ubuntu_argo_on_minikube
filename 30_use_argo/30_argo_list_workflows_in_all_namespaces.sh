#!/usr/bin/env bash
set -euo pipefail

banner() { echo ""; echo "############################## $1"; echo ""; }

banner "argo: list Workflows in all namespaces"
argo list -A

banner "kubectl: list Workflows in all namespaces"
kubectl get workflows -A

set +euo pipefail

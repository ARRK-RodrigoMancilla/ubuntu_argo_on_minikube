#!/usr/bin/env bash
set -euo pipefail
# set -x

banner() { echo ""; echo "############################## $1"; echo ""; }

banner "START delete minikube and unset argo cli env vars"

# delete minikube and everything inside of it
minikube stop
minikube delete

banner "END delete minikube and unset argo cli env vars"

set +xeuo pipefail

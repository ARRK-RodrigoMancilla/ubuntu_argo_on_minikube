#!/usr/bin/env bash
set -euo pipefail

banner() { echo ""; echo "############################## $1"; echo ""; }

banner "argo: submit workflow with argo cli"
argo -n argo submit ./example_workflows/file_io_between_wfs_with_minio_s3.yaml

banner "argo: list workflows (depends on namespace/context)"
argo list

banner "kubectl: get workflows"
kubectl get workflows

### try these with a workflow on your cluster
# argo get  artifact-passing-clnpz
# argo logs artifact-passing-clnpz
# argo logs -f artifact-passing-clnpz # follow the logs as the are being written

set +euo pipefail

#!/usr/bin/env bash
set -euo pipefail
# set -x

banner() { echo ""; echo "############################## $1"; echo ""; }

banner "START install argo cli"

ORIG_DIR=$(pwd)
TMP_DIR=$(mktemp -d)
LOCAL_BIN_DIR="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN_DIR"
cd "$TMP_DIR"

# Download argo cli and install it to LOCAL_BIN_DIR (skip if already installed)
if ! command -v argo &>/dev/null; then
    curl -LO https://github.com/argoproj/argo-workflows/releases/download/v3.7.9/argo-linux-amd64.gz
    gunzip argo-linux-amd64.gz
    cp -t "$LOCAL_BIN_DIR" argo-linux-amd64
    cd "$LOCAL_BIN_DIR"
    chmod +x argo-linux-amd64
    ln -sf argo-linux-amd64 argo
else
    echo "argo is already installed: $(argo version --short) at $(command -v argo)"
fi

# Add argo completion to bashrc (idempotent)
if ! grep -q 'argo completion bash' "$HOME/.bashrc"; then
    cat <<'EOF' >> "$HOME/.bashrc"

# argo cli
source <(argo completion bash)
## Apparently we dont need this ENV vars. Leaving them here for docs
# export ARGO_SERVER='localhost:2746'
# export ARGO_HTTP1=true
# export ARGO_SECURE=true
# export ARGO_BASE_HREF=
# export ARGO_TOKEN=''
# export ARGO_NAMESPACE=argo
# export ARGO_INSECURE_SKIP_VERIFY=true
# export KUBECONFIG=/dev/null # This one makes a ton of problems with kubectl, can often be ignored. Leaving it here for docs.
EOF
fi

banner ">>>>>>>>>>>> remember to reload your bashrc: source "$HOME/.bashrc""

cd "$ORIG_DIR"
rm -rf "$TMP_DIR"

banner "END install argo cli"

set +xeuo pipefail

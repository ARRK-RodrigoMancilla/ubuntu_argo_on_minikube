#!/usr/bin/env bash
set -euo pipefail
# set -x

banner() { echo ""; echo "############################## $1"; echo ""; }

banner "START install minikube"

ORIG_DIR=$(pwd)
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Download and install minikube (skip if already installed)
if ! command -v minikube &>/dev/null; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
    sudo dpkg -i minikube_latest_amd64.deb
else
    echo "minikube is already installed: $(minikube version --short)"
fi

# Add minikube completion to bashrc (idempotent)
if ! grep -q 'minikube completion bash' "$HOME/.bashrc"; then
    cat <<'EOF' >> "$HOME/.bashrc"

# minikube
source <(minikube completion bash)
EOF
fi

banner ">>>>>>>>>>>> remember to reload your bashrc: source "$HOME/.bashrc""

cd "$ORIG_DIR"
rm -rf "$TMP_DIR"

banner "END install minikube"

set +xeuo pipefail

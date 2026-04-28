#!/usr/bin/env bash
set -euo pipefail
# set -x

banner() { echo ""; echo "############################## $1"; echo ""; }

banner "START install kubectl"

# Add kubernetes package repository, this overwrites any existing configuration in /etc/yum.repos.d/kubernetes.repo
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/repodata/repomd.xml.key
EOF

# Install kubectl (skip if already installed)
if ! command -v kubectl &>/dev/null; then
    sudo dnf install -y kubectl
else
    echo "kubectl is already installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
fi

# Add kubectl completion and editor to bashrc (idempotent)
if ! grep -q 'kubectl completion bash' "$HOME/.bashrc"; then
    cat <<'EOF' >> "$HOME/.bashrc"

# kubectl
source <(kubectl completion bash)
EOF
fi

banner ">>>>>>>>>>>> remember to reload your bashrc: source "$HOME/.bashrc""

banner "END install kubectl"

set +xeuo pipefail

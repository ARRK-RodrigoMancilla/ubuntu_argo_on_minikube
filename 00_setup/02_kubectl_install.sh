#!/usr/bin/env bash
set -euo pipefail
# set -x

banner() { echo ""; echo "############################## $1"; echo ""; }

banner "START install kubectl"

# Add kubernetes apt repository, this overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key \
    | sudo gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 0644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

# Install kubectl (skip if already installed)
if ! command -v kubectl &>/dev/null; then
    sudo apt-get install -y kubectl
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

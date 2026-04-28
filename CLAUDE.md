# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A collection of numbered bash scripts for setting up and operating Argo Workflows + Argo Events on a local minikube cluster. Targets Ubuntu 24.04 (uses `apt`/`dpkg` in the `00_setup/` installers). Scripts are designed to be run in numeric order.

## Script Execution Order

### One-time installation (run once per machine)
```bash
bash 00_setup/01_minikube_install.sh       # Install minikube via .deb (dpkg)
bash 00_setup/02_kubectl_install.sh        # Install kubectl via apt from k8s.io repo
bash 00_setup/03_argo_cli_install.sh       # Install argo CLI v3.7.9 to ~/.local/bin
source ~/.bashrc                           # Reload completions after each install
```

### Cluster lifecycle
```bash
bash 10_start_and_stop/11_minikube_start_with_dashboard.sh            # Start cluster, enable addons, start kube-api proxy on :5555
bash 10_start_and_stop/12_setup_argo_workflows_and_argo_events.sh     # Install Argo Workflows + Events, set up port-forwards
bash 10_start_and_stop/19_minikube_stop_and_delete.sh                 # Tear down everything
```

### Port-forward management
```bash
bash 20_proxy_and_port_forwarding/21_show_state_proxy_and_port_forwarding.sh   # Show running proxy/forward processes
bash 20_proxy_and_port_forwarding/22_setup_proxy_and_port_forwarding.sh        # Re-establish all port-forwards after a restart
bash 20_proxy_and_port_forwarding/29_kill_proxy_and_port_forwarding.sh         # Kill all proxy/forward processes
```

### Workflow operations
```bash
bash 30_use_argo/30_argo_list_workflows_in_all_namespaces.sh      # List all workflows via argo and kubectl
bash 30_use_argo/31_argo_submit_workflow_with_cli.sh              # Submit example workflow from ./example_workflows/
```

## Architecture

**Namespaces and contexts created by `12_`:**
| Context | Namespace | Purpose |
|---|---|---|
| `test_argo` | `argo` | Argo Workflows server + MinIO |
| `test_events` | `argo-events` | Argo Events webhook pipeline |

**Port mappings (all forwarded to localhost):**
| Port | Service |
|---|---|
| 5555 | kubectl kube-api proxy (full cluster HTTP access) |
| 2746 | Argo Workflows server UI/API |
| 9001 | MinIO console |
| 12000 | Argo Events webhook event source |
| 9002 | Harbor container registry (referenced in `22_`, no install script present) |

**Proxy logs** from all background `kubectl proxy` and `port-forward` processes append to `~/.minikube_proxy_logs.log`.

**kube-api proxy URLs** (usable in browser after `11_` or `22_`):
- `http://localhost:5555/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:80/proxy`
- `http://localhost:5555/api/v1/namespaces/argo/services/https:argo-server:2746/proxy`
- `http://localhost:5555/api/v1/namespaces/argo/services/http:minio:9001/proxy`

**Pinned versions:** Argo Workflows `v3.7.9`, Argo Events `v1.9.7`, MinIO `RELEASE.2025-09-07T16-13-09Z`. The MinIO deployment is patched after install to update the image and migrate deprecated `MINIO_ACCESS_KEY`/`MINIO_SECRET_KEY` env vars to `MINIO_ROOT_USER`/`MINIO_ROOT_PASSWORD`.

## Script Conventions

- All scripts use `set -euo pipefail` and define a local `banner()` function for section headers.
- Install steps check `command -v` before re-installing (idempotent).
- `.bashrc` additions are guarded with `grep -q` (idempotent).
- Background processes (`&`) always redirect stdout+stderr to the proxy log file.
- Scripts end with `set +euo pipefail` (intentional reset, not an error).

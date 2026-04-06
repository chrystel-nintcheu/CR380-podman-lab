#!/usr/bin/env bash
# =============================================================================
# CR380 - Podman Lab — Multipass VM Provisioner
# =============================================================================
#
# FR: Lance une VM Ubuntu 24.04 avec Multipass et la configure pour les labs.
#
# EN: Launches an Ubuntu 24.04 VM with Multipass and configures it for the labs.
#
# Prérequis / Prerequisites:
#   Multipass: https://multipass.run/install
#
# Usage:
#   ./cloud-init/provision-multipass.sh
# =============================================================================

set -euo pipefail

VM_NAME="cr380-podman"
CLOUD_INIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/user-data-fresh.yaml"

echo "=== CR380 Podman Lab — VM Provisioning ==="
echo "VM Name : ${VM_NAME}"
echo "Cloud-Init: ${CLOUD_INIT}"
echo ""

if ! command -v multipass &>/dev/null; then
    echo "ERROR: multipass not found."
    echo "Install: https://multipass.run/install"
    exit 1
fi

# Launch VM
multipass launch 24.04 \
    --name "${VM_NAME}" \
    --cloud-init "${CLOUD_INIT}" \
    --cpus 2 \
    --memory 4G \
    --disk 20G

echo ""
echo "=== VM ready! ==="
echo "Connect: multipass shell ${VM_NAME}"
echo "Then run: git clone <repo-url> && cd CR380-podman-lab && ./run-labs.sh --learn"

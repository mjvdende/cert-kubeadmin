#!/usr/bin/env bash
#
# recreate-cluster.sh
#
# Deletes (if present) and recreates the local `kind` cluster used for
# Kubernetes admin (CKA-style) study, using kind-config.yaml.
#
# Usage:
#   ./recreate-cluster.sh                # uses default cluster name "cka-lab"
#   ./recreate-cluster.sh my-cluster      # override cluster name
#
set -euo pipefail

CLUSTER_NAME="${1:-cka-lab}"
CONFIG_FILE="$(dirname "$0")/kind-config.yaml"

if ! command -v kind >/dev/null 2>&1; then
  echo "❌ kind is not installed. Run: brew install kind"
  exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "❌ kubectl is not installed. Run: brew install kubectl"
  exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Config file not found: $CONFIG_FILE"
  exit 1
fi

echo "🔎 Checking for existing kind cluster: $CLUSTER_NAME"
if kind get clusters | grep -qx "$CLUSTER_NAME"; then
  echo "🗑  Deleting existing cluster: $CLUSTER_NAME"
  kind delete cluster --name "$CLUSTER_NAME"
else
  echo "ℹ️  No existing cluster named '$CLUSTER_NAME' found, skipping delete."
fi

echo "🚀 Creating cluster: $CLUSTER_NAME (config: $CONFIG_FILE)"
kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_FILE"

echo "🔀 Switching kubectl context to kind-$CLUSTER_NAME"
kubectl config use-context "kind-$CLUSTER_NAME"

echo "✅ Cluster ready. Nodes:"
kubectl get nodes -o wide
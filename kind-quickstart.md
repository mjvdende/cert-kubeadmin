# Kubernetes Admin Study — `kind` Quickstart

Local multi-node Kubernetes cluster setup on macOS using `kind`, for CKA-style admin practice.

## 1. Prerequisites

```bash
# Container runtime (kind needs Docker or Podman running)
brew install --cask docker
open -a Docker   # start Docker Desktop, wait until it's running

# kind itself
brew install kind

# kubectl
brew install kubectl

# optional but recommended
brew install k9s kubectx
```

Verify:
```bash
docker version
kind version
kubectl version --client
```

## 2. Cluster config

`kind-config.yaml` — 1 control-plane + 2 workers, with ingress port mappings.

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
```

## 3. Create the cluster

```bash
kind create cluster --name cka-lab --config kind-config.yaml
```

This automatically sets your `kubectl` context to `kind-cka-lab`.

## 4. Verify

```bash
kubectl cluster-info --context kind-cka-lab
kubectl get nodes -o wide
kubectl get pods -A
```

Expect 3 nodes: `cka-lab-control-plane`, `cka-lab-worker`, `cka-lab-worker2`.

## 5. Useful daily commands

```bash
# List clusters
kind get clusters

# Delete cluster when done
kind delete cluster --name cka-lab

# Exec into a node (container, not a real VM)
docker exec -it cka-lab-control-plane bash

# TUI for browsing the cluster
k9s
```

## 6. What you CAN practice with kind
- Pods, Deployments, Services, ConfigMaps, Secrets, RBAC, NetworkPolicies
- Multi-node scheduling, taints/tolerations, affinity
- etcd inspection (etcd runs as a static pod in `kube-system` on the control-plane node — good for `etcdctl snapshot save` practice)
- Troubleshooting: `kubectl describe`, `kubectl logs`, `crictl` inside nodes
- Installing a CNI/Ingress controller (kind uses `kindnet` by default; Calico can be installed for practice)

## 7. What kind can't teach you (practice later via Multipass + kubeadm)
- Actual `kubeadm init` / `kubeadm join`
- OS-level container runtime installation (containerd/CRI-O setup)
- Real node provisioning, kernel modules, sysctl settings

## Shell setup (optional)

Add to `~/.zshrc`:
```bash
alias k=kubectl
source <(kubectl completion zsh)
complete -F __start_kubectl k
```
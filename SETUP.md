# macOS Kubernetes Admin Study — Environment Setup Summary

A snapshot of what's installed and configured on this machine for CKA-style
Kubernetes admin practice, so future-you doesn't have to reverse-engineer it.

## Installed tools (via Homebrew)

| Tool        | Purpose                                                        | Install command                  |
|-------------|-----------------------------------------------------------------|-----------------------------------|
| `docker`    | Container runtime — required by `kind` to run cluster nodes    | `brew install --cask docker`      |
| `kind`      | Runs local multi-node Kubernetes clusters inside Docker         | `brew install kind`               |
| `kubectl`   | CLI to talk to any Kubernetes cluster (local or remote)         | `brew install kubectl`            |
| `k9s`       | Terminal UI for browsing/managing cluster resources             | `brew install k9s`                |
| `kubectx`   | Fast switching between kubeconfig contexts (`kubectx`/`kubens`) | `brew install kubectx`            |

Check versions any time:
```bash
docker version
kind version
kubectl version --client
k9s version
kubectx -h   # confirms it's installed
```

## Shell setup (`~/.zshrc`)

```bash
alias k=kubectl
source <(kubectl completion zsh)
complete -F __start_kubectl k
```

After editing, reload with:
```bash
source ~/.zshrc
```

## Project files (in this repo)

| File                  | Purpose                                                        |
|-----------------------|------------------------------------------------------------------|
| `kind-config.yaml`    | Defines cluster topology: 1 control-plane + 2 workers, port 80/443 mapped for ingress practice |
| `recreate-cluster.sh` | Deletes + recreates the kind cluster from `kind-config.yaml`     |
| `Makefile`            | Shortcuts: `make cluster-up`, `make cluster-down`, `make cluster-recreate`, `make contexts` |
| `README.md`           | Explains kubectl **context** vs. **cluster** distinction in depth |
| `kind-quickstart.md`  | Standalone quickstart for creating/using a kind cluster          |
| `SETUP.md`            | **This file** — environment/tools snapshot                       |

## Daily commands cheat sheet

```bash
# --- Cluster lifecycle (kind) ---
kind get clusters                     # list local kind clusters
make cluster-up                       # create cluster from kind-config.yaml
make cluster-recreate                 # delete + recreate (needed after config changes)
make cluster-down                     # delete cluster

# --- Contexts (kubectl / kubectx) ---
kubectl config get-contexts           # list all known contexts (any cluster type)
kubectl config current-context        # show active context
kubectx                               # interactive context list/switch (kubectx tool)
kubectx kind-cka-lab                  # switch context directly
kubens <namespace>                    # switch default namespace in current context

# --- Inspecting the cluster ---
k                                     # alias for kubectl
k get nodes -o wide
k get pods -A
k9s                                   # TUI browser for the cluster
```

## Mental model recap

- **Cluster** = actual running nodes (Docker containers, for kind). Created/destroyed
  with `kind create/delete cluster`.
- **Context** = a saved "how to connect" profile in `~/.kube/config` (cluster + user +
  default namespace). `kind` auto-manages contexts for its clusters; `kubectx` just
  makes switching between *all* contexts (kind, docker-desktop, remote clusters, etc.) faster.
- Config changes to `kind-config.yaml` require a full cluster **recreate** — kind has
  no live-reconfigure/hot-reload.

## Known limitations of this setup (kind)

Practice these separately later via Multipass + real `kubeadm` VMs, since `kind`
abstracts them away:
- `kubeadm init` / `kubeadm join`
- containerd/CRI-O installation at the OS level
- Real node provisioning, kernel/sysctl tuning, CNI installed from scratch

## Next steps / resume-here checklist

- [ ] `make cluster-up` to spin the lab back up
- [ ] `kubectx` to confirm you're pointed at `kind-cka-lab`, not `docker-desktop` or a remote cluster
- [x] Capture `kubeadm init` / node add notes in [`docs/kubeadm-init-add.md`](./docs/kubeadm-init-add.md)
- [ ] Next topic: cluster upgrades in [`docs/upgrade-cluster.md`](./docs/upgrade-cluster.md)
- [ ] Continue CKA topics: RBAC, NetworkPolicies, etcd backup/restore, troubleshooting
- [ ] Later: set up Multipass + manual `kubeadm` cluster for deeper admin practice
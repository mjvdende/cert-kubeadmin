# Kubernetes Admin Study Environment (macOS + kind)

Local lab setup for practicing Kubernetes administration (CKA-style tasks) using
[`kind`](https://kind.sigs.k8s.io/) (Kubernetes IN Docker).

## Contents

- [`kind-config.yaml`](./kind-config.yaml) — cluster topology (1 control-plane + 2 workers)
- [`recreate-cluster.sh`](./recreate-cluster.sh) — delete + recreate the cluster in one command
- [`Makefile`](./Makefile) — shortcuts (`make cluster-up`, `make cluster-down`, `make cluster-recreate`)
- [`docs/`](./docs/) — certification section notes and topic checklists

---

## Key concept: kubectl "context" vs. a "cluster"

This trips a lot of people up, so here's the distinction clearly:

### A **cluster** is an actual running set of Kubernetes nodes
- With `kind`, this means Docker containers acting as nodes (control-plane + workers).
- Each cluster is created with `kind create cluster --name <name>` and destroyed with
  `kind delete cluster --name <name>`.
- List all kind-managed clusters on your machine with:
  ```bash
  kind get clusters
  ```
- These are **local to Docker** — they only exist while the containers exist.

### A **kubeconfig context** is just a saved connection profile
- Lives in `~/.kube/config`.
- A context bundles: which **cluster** to talk to (API server address), which
  **user/credentials** to use (`authinfo`), and which **namespace** to default to.
- One context = one cluster, but **one cluster can have multiple contexts**
  (e.g. different users/service accounts) and your kubeconfig can hold contexts
  for **many different clusters at once** — local kind clusters, Docker Desktop's
  built-in cluster, remote clusters (EKS/GKE/AKS, etc.).
- List all contexts you currently have configured:
  ```bash
  kubectl config get-contexts
  ```
- Switch which one `kubectl` talks to:
  ```bash
  kubectl config use-context <context-name>
  ```
- See which one is active right now:
  ```bash
  kubectl config current-context
  ```

### Why this matters in practice
Deleting a kind cluster does **not** automatically clean up unrelated contexts for
other clusters (like `docker-desktop` or a remote cluster) — they're independent.
Conversely, deleting/losing a context does **not** delete the cluster itself — you'd
just need to re-add the context (kind re-adds it automatically on `kind create cluster`).

Example kubeconfig:

| CONTEXT NAME        | Points to cluster                              | Notes                              |
|---------------------|------------------------------------------------|------------------------------------|
| `docker-desktop`    | Docker Desktop's built-in single-node cluster  | Not a kind cluster                 |
| `kind-cka-lab`      | A local `kind` cluster named `cka-lab`         | Created via `make cluster-up`      |
| `remote-cluster`    | A remote, cloud-hosted cluster                 | Not local                          |
| `remote-cluster-sa` | Same remote cluster, different service account | Same cluster, different auth       |

---

## Common workflow

```bash
# Create the study cluster (topology defined in kind-config.yaml)
make cluster-up

# ...do your CKA practice tasks...

# Made a config change (e.g. new node, new port mapping)? kind can't hot-reload —
# you must recreate:
make cluster-recreate

# Done for the day / want to free resources:
make cluster-down

# Not sure which cluster kubectl is pointed at right now?
kubectl config current-context

# See everything kubectl knows about:
make contexts
```

## Troubleshooting

- **`kubectl` is talking to the wrong cluster** → check
  `kubectl config current-context`, then `kubectl config use-context <name>`.
- **Old `kind-kind` context still lingering after you deleted the cluster** →
  `kind delete cluster` should remove its context automatically; if not:
  ```bash
  kubectl config delete-context kind-kind
  kubectl config delete-cluster kind-kind
  ```
- **Port 80/443 already in use when creating the cluster** → something else on
  your Mac (e.g. another local proxy) is bound to it; stop that service or edit
  `extraPortMappings` in `kind-config.yaml`.
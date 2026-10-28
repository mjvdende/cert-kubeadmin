# Upgrade Cluster

## Goal

Practice the kubeadm cluster upgrade workflow in the order expected for admin tasks.

## Commands

```bash
# Check current versions
kubectl get nodes
kubeadm version
kubectl version

# On the control-plane node
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply <target-version>

# Drain before upgrading node components
kubectl drain <node-name> --ignore-daemonsets

# Upgrade kubelet/kubectl with the OS package manager, then restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Bring the node back
kubectl uncordon <node-name>
```

## What to Remember

- Upgrade the control plane first, then worker nodes.
- Drain a node before upgrading its kubelet.
- `kubeadm upgrade plan` shows valid target versions and required steps.
- `kubectl drain` does not remove DaemonSet-managed pods unless explicitly told to.

## Practice Tasks

- [ ] Read `kubeadm upgrade plan` output and identify the next valid version.
- [ ] Drain and uncordon a node.
- [ ] Upgrade one worker node at a time.
- [ ] Verify all nodes return to `Ready`.

## Gotchas

- Kubernetes version skew rules matter: do not jump arbitrary minor versions.
- Package-manager commands differ by OS and repo setup, so write down the exact VM commands when you practice this for real.
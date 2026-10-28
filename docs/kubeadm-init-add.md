# Kubeadm Init and Add Nodes

## Goal

Understand how a kubeadm-based cluster is bootstrapped and how additional nodes join it.

## Commands

```bash
# On the control-plane node
kubeadm init

# Configure kubectl for the admin user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install a CNI plugin before expecting nodes/pods to become Ready
# Use the manifest from the curriculum/lab. Example with Calico:
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml

# Watch CNI and core system pods come up
kubectl get pods -n kube-system -w

# Verify the control-plane node becomes Ready
kubectl get nodes -o wide

# Print a fresh join command if needed
kubeadm token create --print-join-command

# On a worker node
kubeadm join <control-plane-endpoint>:6443 --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash>
```

## What to Remember

- `kubeadm init` creates the control-plane components and writes cluster admin kubeconfig to `/etc/kubernetes/admin.conf`.
- A CNI plugin is required before normal pod networking works.
- Install the CNI from the control-plane node after `kubectl` is configured.
- Use the CNI manifest required by the curriculum or exam task; Calico and Flannel are common lab choices.
- `kubeadm join` is run from the node being added, not from the control-plane node.
- Join tokens expire; generate a new command with `kubeadm token create --print-join-command`.

## Practice Tasks

- [ ] Explain what files `kubeadm init` creates under `/etc/kubernetes`.
- [ ] Generate a new worker join command.
- [ ] Identify why a node is `NotReady` before CNI is installed.
- [ ] Check node status with `kubectl get nodes -o wide`.

## Gotchas

- `kind` does not expose the full kubeadm workflow, so practice this later on real VMs, for example with Multipass.
- Never commit `admin.conf`, kubeconfigs, or real `kubeadm join` output — the token and CA hash are live credentials (tokens are valid for 24h by default). Redact them in notes.
- Forgetting the CNI step is a common reason the cluster appears bootstrapped but nodes stay unhealthy.
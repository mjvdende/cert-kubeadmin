.PHONY: cluster-up cluster-down cluster-recreate contexts

# Name of the kind cluster used for this study environment
CLUSTER_NAME ?= cka-lab

## Create the kind cluster (fails if it already exists)
cluster-up:
	kind create cluster --name $(CLUSTER_NAME) --config kind-config.yaml
	kubectl config use-context kind-$(CLUSTER_NAME)
	kubectl get nodes -o wide

## Delete the kind cluster
cluster-down:
	kind delete cluster --name $(CLUSTER_NAME)

## Delete + recreate the kind cluster from kind-config.yaml
cluster-recreate:
	./recreate-cluster.sh $(CLUSTER_NAME)

## Show all kubectl contexts and which one is active
contexts:
	kubectl config get-contexts
.PHONY: up down init cluster install

up: cluster init install

down:
	k3d cluster delete vault-labs

list:
	helm list --all-namespaces

init: logs repos namespaces

logs:
	touch output.log

repos:
	helm repo add stable https://kubernetes-charts.storage.googleapis.com/
	helm repo add hashicorp https://helm.releases.hashicorp.com
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update

namespaces:
	kubectl create namespace consul
	kubectl create namespace vault
	kubectl create namespace elf
	kubectl create namespace prograf
	kubectl create namespace corpora

cluster:
	k3d cluster create vault-labs \
	    -p 80:80@loadbalancer \
	    -p 443:443@loadbalancer \
	    -p 30000-32767:30000-32767@server[0] \
	    -v /etc/machine-id:/etc/machine-id:ro \
	    -v /var/log/journal:/var/log/journal:ro \
	    -v /var/run/docker.sock:/var/run/docker.sock \
	    --agents 3

install: install-consul install-vault install-prometheus

install-corpora:
	kubectl apply -f apps/corpora

delete-corpora:
	kubectl delete -f apps/corpora

install-consul:
	helm install consul hashicorp/consul -f platform/consul/values.yaml -n consul | tee -a output.log

delete-consul:
	helm delete -n consul consul

install-vault:
	helm install vault hashicorp/vault -f platform/vault/values.yaml -n vault | tee -a output.log
	sudo snap install vault
	cd platform/vault && config.sh

delete-vault:
	helm delete -n vault vault

.PHONY: up down init cluster install

up: cluster init install

down:
	k3d cluster delete vault-labs

list:
	helm list --all-namespaces

init: logs repos namespaces

provision:
	sudo snap install vault

logs:
	touch output.log

repos:
	helm repo add stable https://kubernetes-charts.storage.googleapis.com/
	helm repo add hashicorp https://helm.releases.hashicorp.com
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update

namespaces:
	kubectl apply -f init

cluster:
	k3d cluster create vault-labs \
	    -p 80:80@loadbalancer \
	    -p 443:443@loadbalancer \
	    -p 30000-32767:30000-32767@server[0] \
	    -v /etc/machine-id:/etc/machine-id:ro \
	    -v /var/log/journal:/var/log/journal:ro \
	    -v /var/run/docker.sock:/var/run/docker.sock \
	    --agents 3

install: install-consul install-vault

install-corpora:
	kubectl apply -f apps/corpora

delete-corpora:
	kubectl delete -f apps/corpora

install-consul:
	helm install consul hashicorp/consul -f platform/service-mesh/values.yaml -n service-mesh | tee -a output.log

delete-consul:
	helm delete -n service-mesh consul

install-vault:
	helm install vault hashicorp/vault -f platform/secrets/values.yaml -n secrets | tee -a output.log

delete-vault:
	helm delete -n secrets vault

install-ingress-nginx:
	kubectl apply -n ingress -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/cloud/deploy.yaml | tee -a output.log

delete-ingress-nginx:
	kubectl delete -n ingress -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/cloud/deploy.yaml | tee -a output.log

install-prometheus:
	helm install -n monitoring -f platform/monitoring/prometheus-values.yaml prometheus prometheus-community/prometheus| tee -a output.log

delete-prometheus:
	helm delete -n monitoring prometheus

install-grafana:
	helm install -n monitoring -f platform/monitoring/grafana-values.yaml grafana grafana/grafana | tee -a output.log

delete-grafana:
	helm delete -n monitoring grafana


.PHONY: up down init cluster install uninstall logs repos namespaces cluster-down clean provision

up: cluster init install

down: cluster-down

cluster-down:
	k3d cluster delete vault-labs

clean: logs
	
provision:
	sudo snap install vault

cluster:
	k3d cluster create vault-labs \
	    -p 80:80@loadbalancer \
	    -p 443:443@loadbalancer \
	    -p 30000-32767:30000-32767@server[0] \
	    -v /etc/machine-id:/etc/machine-id:ro \
	    -v /var/log/journal:/var/log/journal:ro \
	    -v /var/run/docker.sock:/var/run/docker.sock \
		--k3s-server-arg '--no-deploy=traefik' \
	    --agents 3

init: logs repos namespaces
install: install-service-mesh install-ingress install-logging install-monitoring install-secrets
uninstall: delete-service-mesh delete-ingress delete-logging delete-monitoring delete-secrets

logs:
	touch output.log
	rm -f output.log
	touch output.log

repos:
	helm repo add stable https://kubernetes-charts.storage.googleapis.com/
	helm repo add hashicorp https://helm.releases.hashicorp.com
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo add elastic https://helm.elastic.co
	helm repo add fluent https://fluent.github.io/helm-charts
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo update

namespaces:
	kubectl apply -f platform/init


install-app-corpora:
	echo "App-Corpora: install" | tee -a output.log
	kubectl apply -f apps/corpora

delete-app-corpora:
	echo "App-Corpora: delete" | tee -a output.log
	kubectl delete -f apps/corpora 2>/dev/null | true

install-app-address-reader:
	echo "App-Address-Reader: install" | tee -a output.log
	cd apps/address-reader && make 
	kubectl apply -f apps/address-reader/address-reader.yaml

delete-app-address-reader:
	echo "App-Address-Reader: delete" | tee -a output.log
	kubectl delete -f apps/address-reader/address-reader.yaml

install-service-mesh:
	echo "Service-Mesh: install" | tee -a output.log
	helm install consul hashicorp/consul -n service-mesh -f platform/service-mesh/values.yaml | tee -a output.log

delete-service-mesh:
	echo "Service-Mesh: delete" | tee -a output.log
	helm delete -n service-mesh consul 2>/dev/null | true

install-secrets:
	echo "Secrets: install" | tee -a output.log
	helm install vault hashicorp/vault -n secrets -f platform/secrets/values.yaml | tee -a output.log

delete-secrets:
	echo "Secrets: delete" | tee -a output.log
	helm delete -n secrets vault 2>/dev/null | true

install-ingress:
	echo "Ingress: install" | tee -a output.log
	kubectl apply -n ingress-nginx -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/cloud/deploy.yaml | tee -a output.log
	kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s

delete-ingress:
	echo "Ingress: delete" | tee -a output.log
	kubectl delete -n ingress -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/cloud/deploy.yaml | tee -a output.log 2>/dev/null | true

install-monitoring: install-prometheus install-grafana
delete-monitoring: delete-prometheus delete-grafana

install-prometheus:
	echo "Monitoring: install-grafana" | tee -a output.log
	helm install -n monitoring -f platform/monitoring/prometheus-values.yaml prometheus prometheus-community/prometheus| tee -a output.log

delete-prometheus:
	echo "Monitoring: delete-prometheus" | tee -a output.log
	helm delete -n monitoring prometheus 2>/dev/null | true

install-grafana:
	echo "Monitoring: install-grafana" | tee -a output.log
	helm install grafana grafana/grafana -n monitoring -f platform/monitoring/grafana-values.yaml | tee -a output.log

delete-grafana:
	echo "Monitoring: delete-grafana" | tee -a output.log
	helm delete -n monitoring grafana 2>/dev/null | true

install-logging:
	echo "Logging: install-elasticsearch" | tee -a output.log
	helm install elasticsearch elastic/elasticsearch -n logging -f platform/logging/elastic-values.yaml | tee -a output.log
	echo "Logging: install-fluent-bit" | tee -a output.log
	helm install fluent-bit fluent/fluent-bit -n logging -f platform/logging/fluent-values.yaml | tee -a output.log
	echo "Logging: install-kibana" | tee -a output.log
	helm install kibana elastic/kibana -n logging -f platform/logging/kibana-values.yaml | tee -a output.log

delete-logging:
	echo "Logging: delete-elasticsearch" | tee -a output.log
	helm delete elasticsearch -n logging  | tee -a output.log 2>/dev/null | true
	echo "Logging: delete-elasticsearch" | tee -a output.log
	helm delete fluent-bit -n logging | tee -a output.log 2>/dev/null | true
	echo "Logging: delete-elasticsearch" | tee -a output.log
	helm delete kibana elastic/kibana -n logging | tee -a output.log 2>/dev/null | true


install-database:
	echo "Logging: install-database" | tee -a output.log
	helm install database bitnami/postgresql -n database -f apps/database/values.yaml | tee -a output.log

delete-database:
	echo "Logging: delete-database" | tee -a output.log
	helm delete database -n database | tee -a output.log


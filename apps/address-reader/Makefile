all: init deploy

bryan: build push

build:
	docker build --tag bryandollery/address-reader .

push:
	docker push bryandollery/address-reader

test:
	kubectl run --image bryandollery/address-reader --rm -it --command -- bash

deploy:
	kubectl apply -f address-reader.yaml

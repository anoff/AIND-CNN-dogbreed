.PHONY: build push

build:
	docker build -t "anoff.azurecr.io/dogapp:$(shell git rev-parse --short HEAD)" .

push:
	docker push "anoff.azurecr.io/dogapp:$(shell git rev-parse --short HEAD)"
	docker tag "anoff.azurecr.io/dogapp:$(shell git rev-parse --short HEAD)" anoff.azurecr.io/dogapp:latest
	docker push anoff.azurecr.io/dogapp:latest

deploy:
	helm upgrade --install --reuse-values --set app.version=$(shell git rev-parse --short HEAD) --set app.port=80 dogapp ./helm
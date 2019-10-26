ROOT_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
KUBE_PROVIDERS_DIR=$(ROOT_DIR)/kubeProviders
# TODO add systems/vault
CHARTS=env repositories systems/acme systems/cm systems/external-dns systems/jxing

init:
	helm init --client-only
	helm repo add jenkins-x https://storage.googleapis.com/chartmuseum.jenkins-x.io
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo add stable https://kubernetes-charts.storage.googleapis.com

build: clean init
	@for c in $(CHARTS); do  \
		echo "\nBUILDING $(ROOT_DIR)$$c\n\n"; \
		pushd $(ROOT_DIR)$$c > /dev/null; \
		jx step helm build --boot --provider-values-dir=$(KUBE_PROVIDERS_DIR); \
		helm lint .; \
		popd > /dev/null; \
	done

clean:
	@for chart in $(CHARTS); do  \
		rm -rf $(ROOT_DIR)/$(chart)/charts; \
		rm -rf $(ROOT_DIR)/$(chart)/requirements.lock; \
	done

.PHONY: clean kubeProviders build
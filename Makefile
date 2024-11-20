
# Root Makefile
PROJECT_NAME ?= provider-proxmox-crossplane
PROJECT_REPO ?= github.com/joekky/$(PROJECT_NAME)
REGISTRY ?= ghcr.io/joekky
VERSION ?= $(shell git describe --tags --always --dirty)
OUTPUT_DIR ?= _output
TARGETOS ?= linux
TARGETARCH ?= amd64
TERRAFORM_VERSION ?= 1.3.5

-include build/makelib/common.mk
-include build/makelib/output.mk
-include build/makelib/golang.mk

.PHONY: build-provider
build-provider:
	@$(INFO) building Crossplane provider binary
	@mkdir -p bin/$(TARGETOS)_$(TARGETARCH)
	@go mod vendor
	@CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) \
		go build -mod=vendor -o bin/$(TARGETOS)_$(TARGETARCH)/provider ./cmd/provider
	@$(OK) Crossplane provider built

.PHONY: build-terraform-provider
build-terraform-provider:
	@$(INFO) building Terraform Proxmox provider
	@cd third_party/terraform-provider-proxmox && \
		CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) make build
	@$(OK) Terraform Proxmox provider built

.PHONY: image.build
image.build: build-provider build-terraform-provider
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane img.build

.PHONY: image.publish
image.publish:
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane img.publish

.PHONY: package.prepare
package.prepare:
	@$(INFO) preparing package structure
	@mkdir -p $(PACKAGE_ROOT)/crds
	@$(OK) package structure prepared

.PHONY: package
package: package.prepare
	@$(INFO) building provider package
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane package.$(TARGETARCH) PACKAGE_ROOT=$(abspath package)
	@$(OK) provider package built

.PHONY: package.push
package.push:
	@$(INFO) pushing package to registry
	@crossplane xpkg push \
		-f $(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg \
		$(REGISTRY)/$(PROJECT_NAME):$(VERSION)-$(TARGETARCH)
	@$(OK) package pushed

.PHONY: save-artifacts
save-artifacts:
	@echo "Saving artifacts..."
	@mkdir -p _output/air-gapped
	@docker save $(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH):$(VERSION) > _output/air-gapped/provider-image-$(TARGETARCH).tar
	@cp $(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg _output/air-gapped/
	@echo "Artifacts saved successfully."

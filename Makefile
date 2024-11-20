# Setup Project
PROJECT_NAME ?= provider-proxmox-crossplane
PROJECT_REPO ?= github.com/joekky/$(PROJECT_NAME)
REGISTRY ?= ghcr.io/joekky
VERSION ?= $(shell git describe --tags --always --dirty)
OUTPUT_DIR ?= _output
TARGETOS ?= linux
TARGETARCH ?= amd64
PACKAGE_ROOT ?= package

# Include essential build tools
-include build/makelib/common.mk
-include build/makelib/output.mk
-include build/makelib/golang.mk

# Define Terraform version with a default value
TERRAFORM_VERSION ?= 1.3.5

# Build provider binary
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

# Build and publish Docker image
.PHONY: image.build
image.build:
	@$(INFO) building Docker image
	@mkdir -p cluster/images/provider-proxmox-crossplane
	@docker buildx build \
		--platform $(TARGETOS)/$(TARGETARCH) \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		--build-arg CONTROLLER=$(CONTROLLER) \
		-t $(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH):$(VERSION) \
		--load \
		cluster/images/provider-proxmox-crossplane || $(FAIL)
	@$(OK) Docker image built

.PHONY: image.publish
image.publish:
	@docker push $(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH):$(VERSION)
	@docker tag $(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH):$(VERSION) $(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH):latest
	@docker push $(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH):latest

# Package preparation and building
.PHONY: package.prepare
package.prepare:
	@$(INFO) preparing package structure
	@mkdir -p $(PACKAGE_ROOT)/crds
	@$(OK) package structure prepared

.PHONY: package
package: package.prepare
	@$(INFO) building provider package
	@crossplane xpkg build \
		--package-root $(PACKAGE_ROOT) \
		--embed-runtime-image=$(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH):$(VERSION) \
		-o $(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg
	@$(OK) provider package built

.PHONY: package.push
package.push:
	@$(INFO) pushing package to registry
	@crossplane xpkg push \
		-f $(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg \
		$(REGISTRY)/$(PROJECT_NAME):$(VERSION)-$(TARGETARCH)
	@$(OK) package pushed

# Save artifacts for air-gapped environment
.PHONY: save-artifacts
save-artifacts:
	@echo "Saving artifacts..."
	@mkdir -p _output/air-gapped
	@docker save $(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH):$(VERSION) > _output/air-gapped/provider-image-$(TARGETARCH).tar || { echo "Failed to save Docker image"; exit 1; }
	@cp $(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg _output/air-gapped/ || { echo "Failed to copy .xpkg file"; exit 1; }
	@echo "Artifacts saved successfully."

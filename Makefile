# Setup Project
PROJECT_NAME ?= provider-proxmox-crossplane
PROJECT_REPO ?= github.com/joekky/$(PROJECT_NAME)
REGISTRY ?= ghcr.io/joekky
VERSION ?= v1.0.0
OUTPUT_DIR ?= _output
TARGETOS ?= linux
TARGETARCH ?= amd64
PACKAGE_ROOT ?= package

# Set the controller image name
CONTROLLER_IMAGE ?= $(REGISTRY)/$(PROJECT_NAME)-controller-$(TARGETARCH)
# Set the package image name
PACKAGE_IMAGE ?= $(REGISTRY)/$(PROJECT_NAME)-package-$(TARGETARCH)

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

# Build Terraform provider binary
.PHONY: build-terraform-provider
build-terraform-provider:
	@$(INFO) building Terraform Proxmox provider
	@cd third_party/terraform-provider-proxmox && \
		CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) go build -o terraform-provider-proxmox
	@mkdir -p bin/$(TARGETOS)_$(TARGETARCH)
	@cp third_party/terraform-provider-proxmox/terraform-provider-proxmox bin/$(TARGETOS)_$(TARGETARCH)/
	@$(OK) Terraform Proxmox provider built

# Build and publish Docker image
.PHONY: image.build
image.build: build-provider build-terraform-provider
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane img.build

.PHONY: image.publish
image.publish:
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane img.publish

# Package preparation and building
.PHONY: package.prepare
package.prepare:
	@$(INFO) preparing package structure
	@mkdir -p $(PACKAGE_ROOT)/crds
	@$(OK) package structure prepared

.PHONY: package
package: package.prepare
	@$(INFO) building provider package
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane package.$(TARGETARCH) PACKAGE_ROOT=$(abspath $(PACKAGE_ROOT))
	@$(OK) provider package built

# Push Crossplane package
.PHONY: package.publish
package.publish:
	@$(INFO) pushing package to registry
	@crossplane xpkg push \
		-f $(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg \
		$(PACKAGE_IMAGE):$(VERSION)
	@$(OK) package pushed

# Save artifacts for air-gapped environment
.PHONY: save-artifacts
save-artifacts:
	@echo "Saving artifacts..."
	@mkdir -p _output/air-gapped
	@docker save $(CONTROLLER_IMAGE):$(VERSION) > _output/air-gapped/controller-image-$(TARGETARCH).tar || { echo "Failed to save Docker image"; exit 1; }
	@cp $(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg _output/air-gapped/package-$(TARGETARCH).xpkg || { echo "Failed to copy .xpkg file"; exit 1; }
	@echo "Artifacts saved successfully."

# Debug provider
.PHONY: debug-provider
debug-provider:
	@$(INFO) running Crossplane provider in debug mode
	@dlv exec bin/$(TARGETOS)_$(TARGETARCH)/provider -- --terraform-version=$(TERRAFORM_VERSION) --debug
	@$(OK) Provider debug mode active

# Run provider
.PHONY: run-provider
run-provider:
	@$(INFO) running Crossplane provider with Terraform version $(TERRAFORM_VERSION)
	@bin/$(TARGETOS)_$(TARGETARCH)/provider --terraform-version=$(TERRAFORM_VERSION)
	@$(OK) Provider is running
#
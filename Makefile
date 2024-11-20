# Project Setup
PROJECT_NAME ?= provider-proxmox-crossplane
PROJECT_REPO ?= github.com/joekky/$(PROJECT_NAME)
REGISTRY ?= ghcr.io/joekky
VERSION ?= $(shell git describe --tags --always --dirty)
OUTPUT_DIR ?= _output
PACKAGE_ROOT ?= package

# Platform Configuration
TARGETOS ?= linux
TARGETARCH ?= amd64
TERRAFORM_VERSION ?= 1.3.5

# Import build system
-include build/makelib/common.mk
-include build/makelib/output.mk
-include build/makelib/golang.mk

# Go settings
GO_LDFLAGS += -X $(GO_PROJECT)/internal/version.Version=$(VERSION)
GO_SUBDIRS ?= cmd internal apis
GO_STATIC_PACKAGES = $(GO_PROJECT)/cmd/provider

# Clean Directories
CLEAN_DIRS += bin/ vendor/ $(OUTPUT_DIR) $(PACKAGE_ROOT)/_output $(PACKAGE_ROOT)/temp

#====================================================================================
# Preparation Targets
#====================================================================================

.PHONY: package.prepare
package.prepare:
	@$(INFO) preparing package structure
	@mkdir -p $(PACKAGE_ROOT)/crds
	@$(OK) package structure prepared

# Extend generate target from build system
generate.run: package.prepare

#====================================================================================
# Core Targets
#====================================================================================
.PHONY: submodules
submodules:
	@$(INFO) updating git submodules
	@git submodule sync
	@git submodule update --init --recursive
	@$(OK) git submodules updated

.PHONY: vendor.prepare
vendor.prepare:
	@$(INFO) preparing vendor directory
	@go mod tidy
	@rm -rf vendor
	@$(OK) vendor directory prepared

.PHONY: vendor
vendor: vendor.prepare
	@$(INFO) vendoring dependencies
	@go mod vendor
	@go mod verify
	@$(OK) dependencies vendored
.PHONY: build-provider

build-provider: vendor generate
	@$(INFO) building Crossplane provider binary
	@mkdir -p bin/$(TARGETOS)_$(TARGETARCH)
	@go mod vendor
	@CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) \
		go build -mod=vendor -o bin/$(TARGETOS)_$(TARGETARCH)/provider ./cmd/provider
	@$(OK) Crossplane provider built

.PHONY: build-terraform-provider
build-terraform-provider: submodules
	@$(INFO) building Terraform Proxmox provider
	@cd third_party/terraform-provider-proxmox && \
		CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) make build
	@$(OK) Terraform Proxmox provider built

.PHONY: build
build: build-provider build-terraform-provider

#====================================================================================
# Package & Image Targets
#====================================================================================

.PHONY: image.build
image.build:
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane img.build

.PHONY: image.publish
image.publish:
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane img.publish

.PHONY: package
package: 
	@mkdir -p $(PACKAGE_ROOT)/crds
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane package.$(TARGETARCH) \
		PACKAGE_ROOT=$(abspath package)

.PHONY: package.push
package.push:
	@crossplane xpkg push \
		-f $(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg \
		$(REGISTRY)/$(PROJECT_NAME):$(VERSION)-$(TARGETARCH)

#====================================================================================
# Development Targets
#====================================================================================

.PHONY: build.all
build.all: submodules vendor generate build
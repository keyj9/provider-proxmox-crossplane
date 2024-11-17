# Setup Project
PROJECT_NAME ?= provider-proxmox-crossplane
PROJECT_REPO ?= github.com/keyj9/$(PROJECT_NAME)
REGISTRY ?= ghcr.io/keyj9
VERSION ?= $(shell git describe --tags --always --dirty)
OUTPUT_DIR ?= bin
PACKAGE_ROOT ?= package
TARGETOS ?= linux
TARGETARCH ?= amd64

# Include build tools
include build/makelib/common.mk
include build/makelib/imagelight.mk

# Build targets
.PHONY: provider.build build.init build.provider build.artifacts publish

provider.build:
	@echo "Building terraform provider..."
	@cd third_party/terraform-provider-proxmox && \
	CGO_ENABLED=0 go build -trimpath -o ../../$(OUTPUT_DIR)/$(TARGETOS)_$(TARGETARCH)/provider

build.init: provider.build
	@mkdir -p $(OUTPUT_DIR)/$(TARGETOS)_$(TARGETARCH)

build.provider: build.init
	@echo "Building crossplane provider..."

build.artifacts:
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane img.build
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane package.$(TARGETARCH)

publish: build.provider build.artifacts
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane img.publish
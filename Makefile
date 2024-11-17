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
.PHONY: build.init build.provider build.artifacts publish img.build img.publish

img.build:
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane img.build

img.publish:
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane img.publish

build.init:
	@echo "Initializing build..."

build.provider: build.init
	@echo "Building crossplane provider..."

build.artifacts:
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane package.$(TARGETARCH)

publish: build.provider build.artifacts
	@$(MAKE) img.publish
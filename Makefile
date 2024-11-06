# Setup Project
PROJECT_NAME ?= provider-proxmox-crossplane
PROJECT_REPO ?= github.com/joekky/$(PROJECT_NAME)
REGISTRY ?= ghcr.io/joekky
VERSION ?= $(shell git describe --tags --always --dirty)
OUTPUT_DIR ?= _output
TARGETOS ?= linux
TARGETARCH ?= amd64

# Include essential build tools
-include build/makelib/common.mk
-include build/makelib/output.mk
-include build/makelib/golang.mk

# Build the provider binary
.PHONY: build
build:
	@$(INFO) building provider binary
	@mkdir -p $(OUTPUT_DIR)/bin/linux_amd64
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
		go build -o $(OUTPUT_DIR)/bin/linux_amd64/provider cmd/provider/main.go
	@$(OK) building provider binary

# Build the provider image
.PHONY: image.build
image.build: build
	@TARGETOS=$(TARGETOS) TARGETARCH=$(TARGETARCH) \
	$(MAKE) -C cluster/images/provider-proxmox-crossplane img.build

# Generation control
SKIP_GENERATE ?= false

.PHONY: generate
generate:
ifeq ($(SKIP_GENERATE),true)
	@echo "Skipping generation as SKIP_GENERATE=true"
else
	@echo "Running generation..."
	go generate ./...
endif

# Build the provider package
.PHONY: package
package:
	@$(INFO) building provider package
	@mkdir -p $(OUTPUT_DIR)
	@cd package && \
		REGISTRY_IMAGE=$(REGISTRY)/provider-proxmox-crossplane-$(TARGETARCH) \
		VERSION=$(VERSION) \
		envsubst < crossplane.yaml > crossplane.yaml.tmp && \
		mv crossplane.yaml.tmp crossplane.yaml && \
		crossplane xpkg build \
			--package-root . \
			--embed-runtime-image=$(REGISTRY)/provider-proxmox-crossplane-$(TARGETARCH):$(VERSION) \
			-o ../_output/provider-proxmox-$(TARGETARCH).xpkg
	@$(OK) building provider package
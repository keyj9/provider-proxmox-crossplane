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

# Define submodules target
.PHONY: submodules
submodules:
	@$(INFO) initializing submodules
	@git submodule update --init --recursive
	@$(OK) submodules initialized

# Build the provider binary
.PHONY: build
build: override
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

# Build the XPKG
.PHONY: xpkg.build
xpkg.build: build
	@$(INFO) building xpkg
	@mkdir -p $(OUTPUT_DIR)/xpkg
	@crossplane xpkg build \
		--package-root=package \
		--embed-runtime-image=$(REGISTRY)/$(PROJECT_NAME)-amd64:$(VERSION) \
		-o $(OUTPUT_DIR)/xpkg/$(PROJECT_NAME).xpkg
	@$(OK) building xpkg

# Push artifacts
.PHONY: publish
publish: override
	@docker push $(REGISTRY)/$(PROJECT_NAME)-amd64:$(VERSION)
	@crossplane xpkg push \
		-f $(OUTPUT_DIR)/xpkg/$(PROJECT_NAME).xpkg \
		$(REGISTRY)/$(PROJECT_NAME)-package:$(VERSION)

# Add these variables at the top of your Makefile
SKIP_GENERATE ?= false

# Modify the generate target
.PHONY: generate
generate: override
ifeq ($(SKIP_GENERATE),true)
	@echo "Skipping generation as SKIP_GENERATE=true"
else
	@echo "Running generation..."
	go generate ./...
endif

# Modify the schema.json target (if it exists)
config/schema.json:
ifeq ($(SKIP_GENERATE),true)
	@echo "Skipping schema generation as SKIP_GENERATE=true"
	@touch config/schema.json
else
	@echo "Generating provider schema..."
	# Your existing schema generation commands here
endif

# Modify any other targets that involve generation
build.init: override
ifeq ($(SKIP_GENERATE),true)
	@echo "Skipping build initialization steps that involve generation"
else
	@echo "Running full build initialization..."
	# Your existing build.init commands here
endif
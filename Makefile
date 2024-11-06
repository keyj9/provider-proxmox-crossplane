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

# Add these variables at the top of your Makefile
SKIP_GENERATE ?= false

# Modify the generate target
.PHONY: generate
generate:
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
build.init:
ifeq ($(SKIP_GENERATE),true)
	@echo "Skipping build initialization steps that involve generation"
else
	@echo "Running full build initialization..."
	# Your existing build.init commands here
endif

# Build the XPKG
.PHONY: xpkg.build
xpkg.build: build
	@$(INFO) building xpkg
	@mkdir -p $(OUTPUT_DIR)/xpkg
	@crossplane xpkg build \
		--package-root=package \
		--embed-runtime-image=$(IMAGE_NAME):$(VERSION) \
		-o $(OUTPUT_DIR)/xpkg/$(PROJECT_NAME).xpkg
	@$(OK) building xpkg

xpkg.build.amd64:
	$(CROSSPLANE) xpkg build --package-file=package/crossplane.yaml --ignore="examples/" --arch=amd64 -o $(OUTPUT_DIR)/package-amd64.xpkg

xpkg.build.arm64:
	$(CROSSPLANE) xpkg build --package-file=package/crossplane.yaml --ignore="examples/" --arch=arm64 -o $(OUTPUT_DIR)/package-arm64.xpkg

img.build:
	@$(INFO) docker build $(IMAGE)
	@mkdir -p $(CURDIR)/bin/linux_$(TARGETARCH)
	@cp $(CURDIR)/bin/linux_$(TARGETARCH)/provider $(IMAGE_TEMP_DIR)/bin/linux_$(TARGETARCH)/ || $(FAIL)
	@cp $(CURDIR)/cluster/images/provider-proxmox-crossplane/Dockerfile $(IMAGE_TEMP_DIR)/ || $(FAIL)
	@docker buildx build \
		--platform $(TARGETOS)/$(TARGETARCH) \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		-t $(IMAGE) \
		--load \
		$(IMAGE_TEMP_DIR) || $(FAIL)
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

.PHONY: build
build:
	@$(INFO) building provider binary
	@mkdir -p bin/$(TARGETOS)_$(TARGETARCH)
	@CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) \
		go build -o bin/$(TARGETOS)_$(TARGETARCH)/provider ./cmd/provider
	@$(OK) building provider binary

.PHONY: image.build
image.build: build
	@TARGETOS=$(TARGETOS) TARGETARCH=$(TARGETARCH) \
	$(MAKE) -C cluster/images/provider-proxmox-crossplane img.build

.PHONY: package
package: image.build
	@$(INFO) building provider package
	@mkdir -p $(OUTPUT_DIR)
	@cd package && \
		REGISTRY_IMAGE=$(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH) \
		VERSION=$(VERSION) \
		envsubst < crossplane.yaml > crossplane.yaml.tmp && \
		mv crossplane.yaml.tmp crossplane.yaml && \
		crossplane xpkg build \
			--package-root . \
			--embed-runtime-image=$(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH):$(VERSION) \
			-o ../_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg
	@$(OK) building provider package

.PHONY: verify
verify:
	@$(INFO) verifying package
	@cd $(OUTPUT_DIR) && \
		mkdir -p verify && \
		cd verify && \
		tar xf ../$(PROJECT_NAME)-$(TARGETARCH).xpkg && \
		test -f package.yaml || (echo "package.yaml missing" && exit 1)
	@$(OK) package verified
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

.PHONY: build-provider
build-provider:
	@$(INFO) building provider binary
	@mkdir -p bin/$(TARGETOS)_$(TARGETARCH)
	@CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) \
		go build -o bin/$(TARGETOS)_$(TARGETARCH)/provider ./cmd/provider
	@$(OK) building provider binary

.PHONY: image.build
image.build: build-provider
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane img.build

.PHONY: image.publish
image.publish:
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane img.publish

.PHONY: package
package:
	@$(INFO) building provider package
	@mkdir -p $(OUTPUT_DIR)
	@$(MAKE) -C cluster/images/provider-proxmox-crossplane package.$(TARGETARCH)
	@$(OK) building provider package

.PHONY: verify
verify:
	@$(INFO) verifying package
	@mkdir -p _output/verify
	@cp $(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg _output/verify/
	@tar -xvf _output/verify/$(PROJECT_NAME)-$(TARGETARCH).xpkg -C _output/verify
	@$(OK) package verified successfully

# Debug target for package creation
.PHONY: package-debug
package-debug:
	@echo "🔍 Debugging Package Creation"
	@echo "Environment Variables:"
	@env | grep -E "PACKAGE_ROOT|REGISTRY|VERSION|PROJECT_NAME"
	@echo "Directory Structure:"
	@tree $(PACKAGE_ROOT)

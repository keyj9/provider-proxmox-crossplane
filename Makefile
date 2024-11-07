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

.PHONY: package.push
package.push:
	@$(INFO) pushing package to registry
	@crossplane xpkg push \
		$(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg \
		$(REGISTRY)/$(PROJECT_NAME)-xpkg:$(VERSION)-$(TARGETARCH)
	@$(OK) package pushed

# Save artifacts to downloadable files
.PHONY: save-artifacts
save-artifacts:
	@$(INFO) saving artifacts
	@mkdir -p _output/artifacts
	@docker save $(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH):$(VERSION) > _output/artifacts/provider-image-$(TARGETARCH).tar
	@cp $(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg _output/artifacts/
	@$(OK) artifacts saved
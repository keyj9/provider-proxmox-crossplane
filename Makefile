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
	@cp $(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg _output/verify/$(PROJECT_NAME)-$(TARGETARCH).tar.gz
	@cd _output/verify && tar -xzf $(PROJECT_NAME)-$(TARGETARCH).tar.gz
	@test -f _output/verify/package.yaml || (echo "❌ package.yaml not found" && exit 1)
	@$(INFO) cleaning up verification files
	@rm -rf _output/verify
	@mkdir -p _output/verify
	@$(OK) package verified

.PHONY: package-debug
package-debug:
	@$(INFO) debugging package
	@mkdir -p _output/debug
	@cp $(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg _output/debug/$(PROJECT_NAME)-$(TARGETARCH).tar.gz
	@cd _output/debug && tar -xzf $(PROJECT_NAME)-$(TARGETARCH).tar.gz
	@echo "Package contents:"
	@ls -la _output/debug
	@cat _output/debug/package.yaml || true
	@$(INFO) cleaning up debug files
	@rm -rf _output/debug
	@$(OK) package debugged

.PHONY: package.push
package.push:
	@$(INFO) pushing package to registry
	@crossplane xpkg push \
		$(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg \
		$(REGISTRY)/$(PROJECT_NAME)-xpkg:$(VERSION)-$(TARGETARCH)
	@$(OK) package pushed

.PHONY: clean
clean:
	@$(INFO) cleaning up
	@rm -rf _output/verify _output/debug
	@$(OK) cleanup complete
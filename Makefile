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

.PHONY: verify-deps
verify-deps:
	@command -v skopeo >/dev/null 2>&1 || { echo "❌ skopeo is required but not installed. Install with: apt-get install skopeo or brew install skopeo"; exit 1; }

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
verify: verify-deps
	@$(INFO) verifying package
	@mkdir -p _output/verify _output/tmp
	@TMPDIR=$(PWD)/_output/tmp skopeo copy \
		--override-os linux \
		--override-arch $(TARGETARCH) \
		oci-archive:$(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg \
		dir:_output/verify
	@test -f _output/verify/package.yaml || (echo "❌ package.yaml not found" && exit 1)
	@$(OK) package verified

.PHONY: package.push
package.push:
	@$(INFO) pushing package to registry
	@crossplane xpkg push \
		$(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg \
		$(REGISTRY)/$(PROJECT_NAME)-xpkg:$(VERSION)-$(TARGETARCH)
	@$(OK) package pushed
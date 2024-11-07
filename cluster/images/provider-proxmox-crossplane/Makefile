include ../../../build/makelib/common.mk
include ../../../build/makelib/imagelight.mk

# Define IMAGE_TEMP_DIR if not already defined
IMAGE_TEMP_DIR ?= $(shell mktemp -d -t provider-proxmox-crossplane-XXXX)

IMAGE = $(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH)
PLATFORMS ?= linux_amd64 # linux_arm64
TARGETOS ?= linux
TARGETARCH ?= amd64

.PHONY: image.build
image.build:
	@echo "🔍 IMAGE_TEMP_DIR: '$(IMAGE_TEMP_DIR)'"
	@echo "🔍 Building Docker image: $(IMAGE)"
	@mkdir -p $(IMAGE_TEMP_DIR)/bin/$(TARGETOS)_$(TARGETARCH)
	@cp ../../../bin/$(TARGETOS)_$(TARGETARCH)/provider $(IMAGE_TEMP_DIR)/bin/$(TARGETOS)_$(TARGETARCH)/ || (echo "❌ Failed to copy provider binary" && exit 1)
	@cp Dockerfile $(IMAGE_TEMP_DIR)/ || (echo "❌ Failed to copy Dockerfile" && exit 1)
	@echo "🔍 Contents of IMAGE_TEMP_DIR:"
	@ls -la $(IMAGE_TEMP_DIR)
	@docker buildx build \
		--platform $(TARGETOS)/$(TARGETARCH) \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		--no-cache \  # Prevent using cached layers
		-t $(IMAGE):$(VERSION) \
		--load \
		$(IMAGE_TEMP_DIR) || (echo "❌ Docker build failed" && exit 1)
	@echo "✅ Docker image built and tagged successfully"

.PHONY: image.publish
image.publish:
	@echo "🔍 Publishing Docker image: $(IMAGE):$(VERSION)"
	@docker push $(IMAGE):$(VERSION) || (echo "❌ Failed to push Docker image: $(IMAGE):$(VERSION)" && exit 1)
	@docker tag $(IMAGE):$(VERSION) $(IMAGE):latest || (echo "❌ Failed to tag Docker image as latest" && exit 1)
	@docker push $(IMAGE):latest || (echo "❌ Failed to push Docker image: $(IMAGE):latest" && exit 1)
	@echo "✅ Docker image pushed successfully"

.PHONY: package
package.%:
	@echo "🔍 Packaging Provider for Architecture: $*"
	@echo "📂 Package Root: $(PACKAGE_ROOT)"
	@echo "🌍 Current Directory: $(shell pwd)"

	@mkdir -p $(PACKAGE_ROOT)/_output
	@mkdir -p $(PACKAGE_ROOT)/temp

	@test -f $(PACKAGE_ROOT)/crossplane.yaml || (echo "❌ ERROR: crossplane.yaml not found" && exit 1)

	@echo "📄 Copying crossplane.yaml to package.yaml"
	@cp $(PACKAGE_ROOT)/crossplane.yaml $(PACKAGE_ROOT)/temp/package.yaml

	@echo "🔄 Replacing placeholders in package.yaml"
	@sed -i 's|$${REGISTRY_IMAGE}|$(REGISTRY)/$(PROJECT_NAME)-$*|g' $(PACKAGE_ROOT)/temp/package.yaml
	@sed -i 's|$${VERSION}|$(VERSION)|g' $(PACKAGE_ROOT)/temp/package.yaml

	@echo "📄 Copying CRDs to temp directory"
	@cp -r $(PACKAGE_ROOT)/crds $(PACKAGE_ROOT)/temp/crds

	@echo "📜 Contents of temp/package.yaml:"
	@cat $(PACKAGE_ROOT)/temp/package.yaml

	@cd $(PACKAGE_ROOT) && \
		crossplane xpkg build \
			--package-root temp \
			--embed-runtime-image=$(REGISTRY)/$(PROJECT_NAME)-$*:$(VERSION) \
			-o $(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$*.xpkg || \
		(echo "❌ Packaging failed" && exit 1)

	@test -f $(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$*.xpkg || \
		(echo "❌ Package file not created" && exit 1)
	
	@echo "✅ Successfully created package: $(PROJECT_NAME)-$*.xpkg"

.PHONY: verify
verify:
	@echo "🔍 Verifying Package"
	@mkdir -p _output/verify
	@cp $(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg _output/verify/ || (echo "❌ Failed to copy .xpkg file" && exit 1)
	@unzip -o _output/verify/$(PROJECT_NAME)-$(TARGETARCH).xpkg -C _output/verify/ || (echo "❌ Failed to extract package" && exit 1)
	@test -f _output/verify/package.yaml || (echo "❌ package.yaml missing" && exit 1)
	@echo "✅ Package verified successfully"

.PHONY: package-debug
package-debug:
	@echo "🔍 Debugging Package Creation"
	@echo "Environment Variables:"
	@echo "PACKAGE_ROOT: $(PACKAGE_ROOT)"
	@echo "REGISTRY: $(REGISTRY)"
	@echo "VERSION: $(VERSION)"
	@echo "PROJECT_NAME: $(PROJECT_NAME)"
	@echo "Directory Structure:"
	@tree $(PACKAGE_ROOT)

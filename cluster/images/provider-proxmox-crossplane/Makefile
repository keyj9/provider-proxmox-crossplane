# cluster/images/provider-proxmox-crossplane/Makefile

include ../../../build/makelib/common.mk
include ../../../build/makelib/imagelight.mk

IMAGE = $(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH)
PLATFORMS ?= linux_amd64 linux_arm64
TARGETOS ?= linux
TARGETARCH ?= amd64

.PHONY: img.build
img.build:
	@$(INFO) docker build $(IMAGE)
	@mkdir -p $(IMAGE_TEMP_DIR)/bin/$(TARGETOS)_$(TARGETARCH)
	@cp ../../../bin/$(TARGETOS)_$(TARGETARCH)/provider $(IMAGE_TEMP_DIR)/bin/$(TARGETOS)_$(TARGETARCH)/ || $(FAIL)
	@cp Dockerfile $(IMAGE_TEMP_DIR)/ || $(FAIL)
	@docker buildx build \
		--platform $(TARGETOS)/$(TARGETARCH) \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		-t $(IMAGE):$(VERSION) \
		--load \
		$(IMAGE_TEMP_DIR) || $(FAIL)
	@$(OK) docker build $(IMAGE)

.PHONY: img.publish
img.publish:
	@docker push $(IMAGE):$(VERSION)
	@docker tag $(IMAGE):$(VERSION) $(IMAGE):latest
	@docker push $(IMAGE):latest

.PHONY: img.promote
img.promote:
	@docker tag $(FROM_IMAGE) $(TO_IMAGE)
	@docker push $(TO_IMAGE)

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
	@mkdir -p _output/verify
	@cp $(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$(TARGETARCH).xpkg _output/verify/
	@unzip -o _output/verify/$(PROJECT_NAME)-$(TARGETARCH).xpkg -C _output/verify || (echo "❌ Failed to extract package" && exit 1)
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
	@echo "Directory Structure: $(PACKAGE_ROOT)"
	@tree $(PACKAGE_ROOT)
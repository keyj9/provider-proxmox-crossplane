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
	@echo "Packaging provider for architecture: $*"
	@echo "PACKAGE_ROOT: $(PACKAGE_ROOT)"
	@echo "Current directory: $(shell pwd)"
	@echo "Listing package directory contents:"
	@ls -la $(PACKAGE_ROOT)
	
	@if [ ! -d "$(PACKAGE_ROOT)" ]; then \
		echo "ERROR: Package root directory does not exist: $(PACKAGE_ROOT)"; \
		exit 1; \
	fi
	
	@test -f $(PACKAGE_ROOT)/crossplane.yaml || (echo "ERROR: crossplane.yaml not found in $(PACKAGE_ROOT)" && exit 1)
	
	@cd $(PACKAGE_ROOT) && \
		REGISTRY_IMAGE=$(REGISTRY)/$(PROJECT_NAME)-$* \
		VERSION=$(VERSION) \
		envsubst < crossplane.yaml > crossplane.yaml.tmp && \
		mv crossplane.yaml.tmp crossplane.yaml && \
		crossplane xpkg build \
			--package-root . \
			--embed-runtime-image=$(REGISTRY)/$(PROJECT_NAME)-$*:$(VERSION) \
			-o $(OUTPUT_DIR)/$(PROJECT_NAME)-$*.xpkg

include ../../../build/makelib/common.mk
include ../../../build/makelib/imagelight.mk

IMAGE = $(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH)
PLATFORMS ?= linux_amd64 linux_arm64
TARGETOS ?= linux
TARGETARCH ?= amd64

.PHONY: img.build
img.build:
	@$(INFO) docker build $(IMAGE) for $(TARGETARCH)
	@mkdir -p $(IMAGE_TEMP_DIR)
	@mkdir -p $(IMAGE_TEMP_DIR)/third_party
	# Copy provider source files
	@cp -R ../../../cmd $(IMAGE_TEMP_DIR)/ || $(FAIL)
	@cp -R ../../../apis $(IMAGE_TEMP_DIR)/ || $(FAIL)
	@cp -R ../../../internal $(IMAGE_TEMP_DIR)/ || $(FAIL)
	@cp -R ../../../config $(IMAGE_TEMP_DIR)/ || $(FAIL)
	# Copy Terraform provider
	@cp -R ../../../third_party/terraform-provider-proxmox $(IMAGE_TEMP_DIR)/third_party/ || $(FAIL)
	@cp ../../../go.mod ../../../go.sum $(IMAGE_TEMP_DIR)/ || $(FAIL)
	@cp Dockerfile $(IMAGE_TEMP_DIR)/ || $(FAIL)
	@docker buildx build \
		--platform $(TARGETOS)/$(TARGETARCH) \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		-t $(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH):$(VERSION) \
		--load \
		$(IMAGE_TEMP_DIR) || $(FAIL)
	@$(OK) docker build $(IMAGE) for $(TARGETARCH)

.PHONY: img.publish
img.publish:
	@docker push $(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH):$(VERSION)
	@docker tag $(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH):$(VERSION) $(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH):latest
	@docker push $(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH):latest

.PHONY: package.%
package.%:
	@$(INFO) packaging provider for architecture: $*
	@mkdir -p $(PACKAGE_ROOT)/_output $(PACKAGE_ROOT)/temp/crds
	@cp $(PACKAGE_ROOT)/crossplane.yaml $(PACKAGE_ROOT)/temp/
	@cp $(PACKAGE_ROOT)/crds/* $(PACKAGE_ROOT)/temp/crds/ || true
	@sed -i 's|$${REGISTRY_IMAGE}|$(REGISTRY)/$(PROJECT_NAME)-$*|g' $(PACKAGE_ROOT)/temp/crossplane.yaml
	@sed -i 's|$${VERSION}|$(VERSION)|g' $(PACKAGE_ROOT)/temp/crossplane.yaml
	@crossplane xpkg build \
		--package-root $(PACKAGE_ROOT)/temp \
		--embed-runtime-image=$(REGISTRY)/$(PROJECT_NAME)-$*:$(VERSION) \
		-o $(PACKAGE_ROOT)/_output/$(PROJECT_NAME)-$*.xpkg
	@$(OK) package built for $*

.PHONY: package
package:
	@$(MAKE) package.$(TARGETARCH)
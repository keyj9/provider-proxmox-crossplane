include ../../../build/makelib/common.mk
include ../../../build/makelib/imagelight.mk

PROJECT_NAME ?= provider-proxmox-crossplane
REGISTRY ?= ghcr.io/joekky
VERSION ?= v1.0.0
TARGETOS ?= linux
TARGETARCH ?= amd64
PACKAGE_ROOT ?= ../../../package

IMAGE ?= $(REGISTRY)/$(PROJECT_NAME)-controller-$(TARGETARCH)
PLATFORMS ?= linux_amd64 linux_arm64

.PHONY: img.build
img.build:
	@$(INFO) docker build $(IMAGE) for $(TARGETARCH)
	@mkdir -p $(IMAGE_TEMP_DIR)
	# Copy provider binary
	@cp ../../../bin/$(TARGETOS)_$(TARGETARCH)/provider $(IMAGE_TEMP_DIR)/ || $(FAIL)
	# Copy Terraform provider binary
	@mkdir -p $(IMAGE_TEMP_DIR)/terraform.d/plugins/localhost/telmate/proxmox/1.0.0/$(TARGETOS)_$(TARGETARCH)
	@cp ../../../bin/$(TARGETOS)_$(TARGETARCH)/terraform-provider-proxmox $(IMAGE_TEMP_DIR)/terraform.d/plugins/localhost/telmate/proxmox/1.0.0/$(TARGETOS)_$(TARGETARCH)/ || $(FAIL)
	# Copy Dockerfile
	@cp Dockerfile $(IMAGE_TEMP_DIR)/ || $(FAIL)
	@docker buildx build \
		--platform $(TARGETOS)/$(TARGETARCH) \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		-t $(IMAGE):$(VERSION) \
		--load \
		$(IMAGE_TEMP_DIR) || $(FAIL)
	@$(OK) docker build $(IMAGE) for $(TARGETARCH)

.PHONY: img.publish
img.publish:
	@docker push $(IMAGE):$(VERSION)
	@docker tag $(IMAGE):$(VERSION) $(IMAGE):latest
	@docker push $(IMAGE):latest

.PHONY: package.%
package.%:
	@$(INFO) packaging provider for architecture: $*
	@mkdir -p $(PACKAGE_ROOT)/_output $(PACKAGE_ROOT)/temp/crds
	@cp $(PACKAGE_ROOT)/crossplane.yaml $(PACKAGE_ROOT)/temp/
	@cp $(PACKAGE_ROOT)/crds/* $(PACKAGE_ROOT)/temp/crds/ || true
	@sed -i 's|$${REGISTRY_IMAGE}|$(IMAGE)|g' $(PACKAGE_ROOT)/temp/crossplane.yaml
	@sed -i 's|$${VERSION}|$(VERSION)|g' $(PACKAGE_ROOT)/temp/crossplane.yaml
	@cd $(PACKAGE_ROOT)/temp && crossplane xpkg build \
		--package-root . \
		--embed-runtime-image=$(IMAGE):$(VERSION) \
		-o ../_output/$(PROJECT_NAME)-$*.xpkg
	@$(OK) package built for $*

.PHONY: package
package:
	@$(MAKE) package.$(TARGETARCH)

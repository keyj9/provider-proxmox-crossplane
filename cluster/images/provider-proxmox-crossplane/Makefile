# cluster/images/provider-proxmox-crossplane/Makefile

include ../../../build/makelib/common.mk
include ../../../build/makelib/imagelight.mk

DOCKER_REGISTRY ?= docker.io
IMAGE = $(BUILD_REGISTRY)/provider-proxmox-crossplane-$(ARCH)
PLATFORMS ?= linux_amd64 linux_arm64
TARGETOS ?= linux
TARGETARCH ?= amd64
VERSION ?= latest

img.build:
	@$(INFO) docker build $(IMAGE)
	@mkdir -p $(IMAGE_TEMP_DIR)/bin/linux_$(TARGETARCH)
	@cp $(PWD)/bin/linux_$(TARGETARCH)/provider $(IMAGE_TEMP_DIR)/bin/linux_$(TARGETARCH)/ || $(FAIL)
	@cp $(PWD)/cluster/images/provider-proxmox-crossplane/Dockerfile $(IMAGE_TEMP_DIR)/ || $(FAIL)
	@docker buildx build \
		--platform $(TARGETOS)/$(TARGETARCH) \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		-t $(IMAGE) \
		--load \
		$(IMAGE_TEMP_DIR) || $(FAIL)
	@$(OK) docker build $(IMAGE)

img.publish:
	@docker push $(IMAGE)

img.promote:
	@docker tag $(FROM_IMAGE) $(TO_IMAGE)
	@docker push $(TO_IMAGE)

xpkg.build.%:
	@echo "Building XPKG for architecture: $*"
	xpkg build --package-file=package/crossplane.yaml --ignore="examples/" --arch=$* -o _output/package-$*.xpkg

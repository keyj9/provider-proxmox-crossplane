# cluster/images/provider-proxmox-crossplane/Makefile

include ../../../build/makelib/common.mk
include ../../../build/makelib/imagelight.mk

DOCKER_REGISTRY ?= docker.io
IMAGE = $(BUILD_REGISTRY)/provider-proxmox-crossplane-$(ARCH)
OSVERSION ?= $(shell cat /etc/os-release | grep VERSION_ID | cut -d= -d'"' -f2)

PLATFORMS ?= linux_amd64 linux_arm64
TEMP_DIR := $(shell mktemp -d)
TERRAFORM_VERSION ?= 1.5.5
TERRAFORM_PROVIDER_SOURCE ?= joekky/proxmox
TERRAFORM_PROVIDER_VERSION ?= 0.1.0
TERRAFORM_PROVIDER_DOWNLOAD_NAME ?= terraform-provider-proxmox
TERRAFORM_PROVIDER_DOWNLOAD_URL_PREFIX ?= https://github.com/joekky/terraform-provider-proxmox/releases/download
TERRAFORM_NATIVE_PROVIDER_BINARY ?= terraform-provider-proxmox_v${TERRAFORM_PROVIDER_VERSION}

SKIP_GENERATE ?= false

img.build.shared:
ifeq ($(SKIP_GENERATE),true)
	@echo "Building image with pre-generated files..."
	@cp Dockerfile $(IMAGE_TEMP_DIR) || $(FAIL)
	@cp terraformrc.hcl $(IMAGE_TEMP_DIR) || $(FAIL)
	@cp -r $(OUTPUT_DIR)/bin/ $(IMAGE_TEMP_DIR)/bin || $(FAIL)
	@docker buildx build $(BUILD_ARGS) \
		--platform $(IMAGE_PLATFORMS) \
		--build-arg TERRAFORM_VERSION=$(TERRAFORM_VERSION) \
		--build-arg TERRAFORM_PROVIDER_SOURCE=$(TERRAFORM_PROVIDER_SOURCE) \
		--build-arg TERRAFORM_PROVIDER_VERSION=$(TERRAFORM_PROVIDER_VERSION) \
		--build-arg TERRAFORM_PROVIDER_DOWNLOAD_NAME=$(TERRAFORM_PROVIDER_DOWNLOAD_NAME) \
		--build-arg TERRAFORM_PROVIDER_DOWNLOAD_URL_PREFIX=$(TERRAFORM_PROVIDER_DOWNLOAD_URL_PREFIX) \
		--build-arg TERRAFORM_NATIVE_PROVIDER_BINARY=$(TERRAFORM_NATIVE_PROVIDER_BINARY) \
		-t $(IMAGE) \
		$(IMAGE_TEMP_DIR) || $(FAIL)
else
	@cp Dockerfile $(IMAGE_TEMP_DIR) || $(FAIL)
	@cp terraformrc.hcl $(IMAGE_TEMP_DIR) || $(FAIL)
	@cp -r $(OUTPUT_DIR)/bin/ $(IMAGE_TEMP_DIR)/bin || $(FAIL)
	@docker buildx build $(BUILD_ARGS) \
		--platform $(IMAGE_PLATFORMS) \
		--build-arg TERRAFORM_VERSION=$(TERRAFORM_VERSION) \
		--build-arg TERRAFORM_PROVIDER_SOURCE=$(TERRAFORM_PROVIDER_SOURCE) \
		--build-arg TERRAFORM_PROVIDER_VERSION=$(TERRAFORM_PROVIDER_VERSION) \
		--build-arg TERRAFORM_PROVIDER_DOWNLOAD_NAME=$(TERRAFORM_PROVIDER_DOWNLOAD_NAME) \
		--build-arg TERRAFORM_PROVIDER_DOWNLOAD_URL_PREFIX=$(TERRAFORM_PROVIDER_DOWNLOAD_URL_PREFIX) \
		--build-arg TERRAFORM_NATIVE_PROVIDER_BINARY=$(TERRAFORM_NATIVE_PROVIDER_BINARY) \
		-t $(IMAGE) \
		$(IMAGE_TEMP_DIR) || $(FAIL)
endif

img.build:
	@$(INFO) docker build $(IMAGE)
	@cp Dockerfile $(IMAGE_TEMP_DIR)
	@cp terraformrc.hcl $(IMAGE_TEMP_DIR)
	@cp -r $(OUTPUT_DIR)/bin/ $(IMAGE_TEMP_DIR)/bin
	@docker build $(BUILD_ARGS) \
		--platform $(IMAGE_PLATFORMS) \
		--build-arg TERRAFORM_VERSION=$(TERRAFORM_VERSION) \
		--build-arg TERRAFORM_PROVIDER_SOURCE=$(TERRAFORM_PROVIDER_SOURCE) \
		--build-arg TERRAFORM_PROVIDER_VERSION=$(TERRAFORM_PROVIDER_VERSION) \
		--build-arg TARGETOS=$(OS) \
		--build-arg TARGETARCH=$(ARCH) \
		-t $(IMAGE) \
		$(IMAGE_TEMP_DIR)
	@$(OK) docker build $(IMAGE)

img.publish:
	@docker push $(IMAGE)

img.promote:
	@docker tag $(FROM_IMAGE) $(TO_IMAGE)
	@docker push $(TO_IMAGE)

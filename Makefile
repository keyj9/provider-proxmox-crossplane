# ====================================================================================
# Setup Project

PROJECT_NAME ?= provider-proxmox-crossplane
PROJECT_REPO ?= github.com/joekky/$(PROJECT_NAME)

export TERRAFORM_VERSION ?= 1.5.7
TERRAFORM_VERSION_VALID := $(shell [ "$(TERRAFORM_VERSION)" = "`printf "$(TERRAFORM_VERSION)\n1.6" | sort -V | head -n1`" ] && echo 1 || echo 0)

export TERRAFORM_PROVIDER_SOURCE ?= registry.terraform.io/joekky/proxmox
export TERRAFORM_PROVIDER_REPO ?= https://github.com/joekky/terraform-provider-proxmox
export TERRAFORM_PROVIDER_VERSION ?= main
export TERRAFORM_PROVIDER_DOWNLOAD_NAME ?= terraform-provider-proxmox
export TERRAFORM_PROVIDER_BINARY ?= $(TOOLS_HOST_DIR)/$(TERRAFORM_PROVIDER_DOWNLOAD_NAME)
export TERRAFORM_WORKDIR ?= $(TOOLS_HOST_DIR)/terraform-workdir

export TERRAFORM_NATIVE_PROVIDER_BINARY ?= terraform-provider-proxmox
export TERRAFORM_DOCS_PATH ?= docs
export TERRAFORM_LOCAL_PROVIDER_VERSION ?= 0.0.1
export TERRAFORM_PROVIDER_FILENAME := terraform-provider-proxmox_v$(TERRAFORM_LOCAL_PROVIDER_VERSION)

PLATFORMS ?= linux_amd64 linux_arm64

# -include will silently skip missing files, which allows us
# to load those files with a target in the Makefile. If only
# "include" was used, the make command would fail and refuse
# to run a target until the include commands succeeded.
-include build/makelib/common.mk

# ====================================================================================
# Setup Output

-include build/makelib/output.mk

# ====================================================================================
# Setup Go

# Set a sane default so that the nprocs calculation below is less noisy on the initial
# loading of this file
NPROCS ?= 1

# each of our test suites starts a kube-apiserver and running many test suites in
# parallel can lead to high CPU utilization. by default we reduce the parallelism
# to half the number of CPU cores.
GO_TEST_PARALLEL := $(shell echo $$(( $(NPROCS) / 2 )))

GO_REQUIRED_VERSION ?= 1.21
GOLANGCILINT_VERSION ?= 1.54.0
GO_STATIC_PACKAGES = $(GO_PROJECT)/cmd/provider $(GO_PROJECT)/cmd/generator
GO_LDFLAGS += -X $(GO_PROJECT)/internal/version.Version=$(VERSION)
GO_SUBDIRS += cmd internal apis
-include build/makelib/golang.mk

# ====================================================================================
# Setup Kubernetes tools

KIND_VERSION = v0.15.0
UP_VERSION = v0.28.0
UP_CHANNEL = stable
UPTEST_VERSION = v0.5.0
-include build/makelib/k8s_tools.mk

# ====================================================================================
# Setup Images

REGISTRY_ORGS ?= xpkg.upbound.io/upbound
IMAGES = $(PROJECT_NAME)
-include build/makelib/imagelight.mk

# ====================================================================================
# Setup XPKG

XPKG_REG_ORGS ?= xpkg.upbound.io/upbound
# NOTE(hasheddan): skip promoting on xpkg.upbound.io as channel tags are
# inferred.
XPKG_REG_ORGS_NO_PROMOTE ?= xpkg.upbound.io/upbound
XPKGS = $(PROJECT_NAME)
-include build/makelib/xpkg.mk

# ====================================================================================
# Fallthrough

# run `make help` to see the targets and options

# We want submodules to be set up the first time `make` is run.
# We manage the build/ folder and its Makefiles as a submodule.
# The first time `make` is run, the includes of build/*.mk files will
# all fail, and this target will be run. The next time, the default as defined
# by the includes will be run instead.
fallthrough: submodules
	@echo Initial setup complete. Running make again . . .
	@make

# NOTE(hasheddan): we force image building to happen prior to xpkg build so that
# we ensure image is present in daemon.
xpkg.build.provider-proxmox-crossplane: do.build.images

# NOTE(hasheddan): we ensure up is installed prior to running platform-specific
# build steps in parallel to avoid encountering an installation race condition.
build.init: $(UP) check-terraform-version

# ====================================================================================
# Setup Terraform for fetching provider schema
TERRAFORM := $(TOOLS_HOST_DIR)/terraform-$(TERRAFORM_VERSION)
TERRAFORM_WORKDIR := $(WORK_DIR)/terraform
TERRAFORM_PROVIDER_SCHEMA := config/schema.json

check-terraform-version:
ifneq ($(TERRAFORM_VERSION_VALID),1)
	$(error invalid TERRAFORM_VERSION $(TERRAFORM_VERSION), must be less than 1.6.0 since that version introduced a not permitted BSL license)
endif

$(TERRAFORM): $(TOOLS_HOST_DIR) check-terraform-version
	@$(INFO) installing terraform $(HOSTOS)-$(HOSTARCH)
	@mkdir -p $(TOOLS_HOST_DIR)/tmp-terraform
	@curl -fsSL https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_$(SAFEHOST_PLATFORM).zip -o $(TOOLS_HOST_DIR)/tmp-terraform/terraform.zip
	@unzip $(TOOLS_HOST_DIR)/tmp-terraform/terraform.zip -d $(TOOLS_HOST_DIR)/tmp-terraform
	@mv $(TOOLS_HOST_DIR)/tmp-terraform/terraform $(TERRAFORM)
	@rm -fr $(TOOLS_HOST_DIR)/tmp-terraform
	@$(OK) installing terraform $(HOSTOS)-$(HOSTARCH)

$(TERRAFORM_PROVIDER_BINARY):
	@$(INFO) building terraform provider from source
	@mkdir -p $(TOOLS_HOST_DIR)
	@git clone --depth 1 $(TERRAFORM_PROVIDER_REPO) $(TOOLS_HOST_DIR)/provider-source
	@cd $(TOOLS_HOST_DIR)/provider-source && \
		go mod download && \
		go build -o $(TERRAFORM_PROVIDER_BINARY)
	@rm -rf $(TOOLS_HOST_DIR)/provider-source
	@$(OK) building terraform provider from source

$(TERRAFORM_PROVIDER_SCHEMA): $(TERRAFORM) $(TERRAFORM_PROVIDER_BINARY)
	@$(INFO) generating provider schema for $(TERRAFORM_PROVIDER_SOURCE)
	@mkdir -p $(TERRAFORM_WORKDIR)
	@echo '{"terraform":[{"required_providers":[{"provider":{"source":"'"$(TERRAFORM_PROVIDER_SOURCE)"'","version":"'"$(TERRAFORM_LOCAL_PROVIDER_VERSION)"'"}}]}]}' > $(TERRAFORM_WORKDIR)/main.tf.json
	@mkdir -p $(TERRAFORM_WORKDIR)/.terraform/plugins/registry.terraform.io/joekky/proxmox/$(TERRAFORM_LOCAL_PROVIDER_VERSION)/$(HOSTOS)_$(HOSTARCH)
	@cp $(TERRAFORM_PROVIDER_BINARY) $(TERRAFORM_WORKDIR)/.terraform/plugins/registry.terraform.io/joekky/proxmox/$(TERRAFORM_LOCAL_PROVIDER_VERSION)/$(HOSTOS)_$(HOSTARCH)/$(TERRAFORM_PROVIDER_FILENAME)
	@$(TERRAFORM) -chdir=$(TERRAFORM_WORKDIR) init -plugin-dir=$(TERRAFORM_WORKDIR)/.terraform/plugins > $(TERRAFORM_WORKDIR)/terraform-logs.txt 2>&1
	@$(TERRAFORM) -chdir=$(TERRAFORM_WORKDIR) providers schema -json > $(TERRAFORM_PROVIDER_SCHEMA) 2>> $(TERRAFORM_WORKDIR)/terraform-logs.txt
	@$(OK) generating provider schema for $(TERRAFORM_PROVIDER_SOURCE)

# Modified pull-docs target
pull-docs:
	@if [ ! -d "$(WORK_DIR)/$(TERRAFORM_PROVIDER_SOURCE)" ]; then \
				mkdir -p "$(WORK_DIR)/$(TERRAFORM_PROVIDER_SOURCE)" && \
				git clone --depth 1 "$(TERRAFORM_PROVIDER_REPO)" "$(WORK_DIR)/$(TERRAFORM_PROVIDER_SOURCE)"; \
		fi
	@mkdir -p "$(WORK_DIR)/$(TERRAFORM_PROVIDER_SOURCE)/docs/data-sources"
	@mkdir -p "$(WORK_DIR)/$(TERRAFORM_PROVIDER_SOURCE)/docs/resources"
	@touch "$(WORK_DIR)/$(TERRAFORM_PROVIDER_SOURCE)/docs/data-sources/.gitkeep"
	@touch "$(WORK_DIR)/$(TERRAFORM_PROVIDER_SOURCE)/docs/resources/.gitkeep"

clean-schema:
	@rm -f $(TERRAFORM_PROVIDER_SCHEMA)
	@rm -rf $(TERRAFORM_WORKDIR)

generate.init: clean-schema $(TERRAFORM_PROVIDER_SCHEMA) pull-docs


submodules:
	@git submodule sync
	@git submodule update --init --recursive

.PHONY: submodules fallthrough generate pull-docs

# Add this after the includes section
$(TOOLS_HOST_DIR):
	@mkdir -p $(TOOLS_HOST_DIR)
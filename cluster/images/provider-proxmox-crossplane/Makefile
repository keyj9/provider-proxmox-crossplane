include ../../../build/makelib/common.mk
include ../../../build/makelib/imagelight.mk

IMAGE = $(REGISTRY)/$(PROJECT_NAME)-$(TARGETARCH)
TARGETOS ?= linux
TARGETARCH ?= amd64

.PHONY: img.build
img.build:
	@$(INFO) building Docker image for $(TARGETARCH)
	@mkdir -p $(OUTPUT_DIR)/temp
	# Copy provider source files
	@cp -R ../../../cmd $(OUTPUT_DIR)/temp/
	@cp -R ../../../apis $(OUTPUT_DIR)/temp/
	@cp -R ../../../internal $(OUTPUT_DIR)/temp/
	@cp -R ../../../config $(OUTPUT_DIR)/temp/
	@cp ../../../go.mod ../../../go.sum $(OUTPUT_DIR)/temp/
	@cp Dockerfile $(OUTPUT_DIR)/temp/
	@docker buildx build \
		--platform $(TARGETOS)/$(TARGETARCH) \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		-t $(IMAGE):$(VERSION) \
		--load \
		$(OUTPUT_DIR)/temp || $(FAIL)
	@$(OK) Docker image built for $(TARGETARCH)

.PHONY: img.publish
img.publish:
	@docker push $(IMAGE):$(VERSION)
	@docker tag $(IMAGE):$(VERSION) $(IMAGE):latest
	@docker push $(IMAGE):latest

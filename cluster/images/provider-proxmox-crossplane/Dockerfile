# Start with Alpine 3.20.3
FROM alpine:3.20.3

# Install necessary packages
RUN apk --no-cache add ca-certificates bash git go

# Define build arguments
ARG TARGETOS
ARG TARGETARCH
ARG TERRAFORM_VERSION
ARG TERRAFORM_PROVIDER_SOURCE
ARG TERRAFORM_PROVIDER_VERSION

# Add the provider binary
ADD "bin/${TARGETOS}_${TARGETARCH}/provider" /usr/local/bin/provider

# Set environment variables
ENV USER_ID=65532
ENV PLUGIN_DIR=/terraform/provider-mirror/registry.terraform.io/joekky/proxmox/${TERRAFORM_PROVIDER_VERSION}/${TARGETOS}_${TARGETARCH}
ENV TF_FORK=0
ENV GOPATH=/go

# Create directories and clone the provider source
RUN mkdir -p ${PLUGIN_DIR} && \
    mkdir -p /go/src/github.com/joekky && \
    cd /go/src/github.com/joekky && \
    git clone https://github.com/joekky/terraform-provider-proxmox.git && \
    cd terraform-provider-proxmox && \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o ${PLUGIN_DIR}/terraform-provider-proxmox_v${TERRAFORM_PROVIDER_VERSION} && \
    chmod +x ${PLUGIN_DIR}/terraform-provider-proxmox_v${TERRAFORM_PROVIDER_VERSION}

# Download and install Terraform
ADD https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TARGETOS}_${TARGETARCH}.zip /tmp
RUN unzip "/tmp/terraform_${TERRAFORM_VERSION}_${TARGETOS}_${TARGETARCH}.zip" -d /usr/local/bin && \
    chmod +x /usr/local/bin/terraform && \
    rm "/tmp/terraform_${TERRAFORM_VERSION}_${TARGETOS}_${TARGETARCH}.zip" && \
    chown -R ${USER_ID}:${USER_ID} /terraform

# Additional environment variables
ENV TERRAFORM_VERSION=${TERRAFORM_VERSION}
ENV TERRAFORM_PROVIDER_SOURCE=${TERRAFORM_PROVIDER_SOURCE}
ENV TERRAFORM_PROVIDER_VERSION=${TERRAFORM_PROVIDER_VERSION}
ENV TERRAFORM_NATIVE_PROVIDER_PATH=${PLUGIN_DIR}/terraform-provider-proxmox_v${TERRAFORM_PROVIDER_VERSION}

# Switch to non-root user and expose the port
USER ${USER_ID}
EXPOSE 8080

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/provider"]

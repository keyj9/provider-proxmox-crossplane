FROM alpine:3.20.3

ARG TARGETOS
ARG TARGETARCH

# Create necessary directories
RUN mkdir -p /terraform.d/plugins/localhost/telmate/proxmox/1.0.0/${TARGETOS}_${TARGETARCH}

# Copy binaries
COPY provider /usr/local/bin/provider
COPY terraform.d/ /terraform.d/

# Set permissions
RUN chmod +x /usr/local/bin/provider && \
    chmod +x /terraform.d/plugins/localhost/telmate/proxmox/1.0.0/${TARGETOS}_${TARGETARCH}/terraform-provider-proxmox

# Air-gapped environment configuration
ENV TERRAFORM_PROVIDER_PATH=/terraform.d/plugins
ENV TERRAFORM_PROVIDER_VERSION=1.0.0
ENV USER_ID=65532
USER ${USER_ID}

ENTRYPOINT ["/usr/local/bin/provider"]

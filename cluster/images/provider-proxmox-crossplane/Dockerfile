# Final Stage
FROM alpine:3.20.3

# Create necessary directories for air-gapped setup
RUN mkdir -p /terraform.d/plugins/localhost/telmate/proxmox/1.0.0/linux_amd64/

# Copy binaries with proper permissions
COPY --from=crossplane-builder /provider /usr/local/bin/provider
COPY --from=terraform-builder /workspace/terraform-provider-proxmox/bin/terraform-provider-proxmox \
    /terraform.d/plugins/localhost/telmate/proxmox/1.0.0/linux_amd64/

RUN chmod +x /usr/local/bin/provider && \
    chmod +x /terraform.d/plugins/localhost/telmate/proxmox/1.0.0/linux_amd64/terraform-provider-proxmox

# Air-gapped environment configuration
ENV TERRAFORM_PROVIDER_PATH=/terraform.d/plugins
ENV TERRAFORM_PROVIDER_VERSION=1.0.0
ENV USER_ID=65532
USER ${USER_ID}

ENTRYPOINT ["/usr/local/bin/provider"]

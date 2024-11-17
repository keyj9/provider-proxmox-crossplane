# Build Stage - Build the Crossplane Provider
FROM --platform=$BUILDPLATFORM golang:1.21-alpine3.17 AS crossplane-builder

ARG TARGETOS
ARG TARGETARCH

# Install necessary packages
RUN apk --no-cache add make git

# Set the working directory
WORKDIR /workspace

# Copy the Crossplane provider source code
COPY cmd/ /workspace/cmd/
COPY go.mod go.sum /workspace/

# Build the Crossplane provider
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /provider ./cmd/provider

# Build Stage - Build the Terraform Proxmox Provider
FROM --platform=$BUILDPLATFORM golang:1.21-alpine3.17 AS terraform-builder

ARG TARGETOS
ARG TARGETARCH

# Install necessary packages
RUN apk --no-cache add make git

# Set the working directory
WORKDIR /workspace/terraform-provider-proxmox

# Copy the Terraform provider source code
COPY third_party/terraform-provider-proxmox/ ./

# Build the Terraform provider
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -trimpath -o bin/terraform-provider-proxmox

# Final Stage
FROM alpine:3.20.3

# Install necessary packages
RUN apk --no-cache add ca-certificates

# Create necessary directories
RUN mkdir -p /terraform.d/plugins/localhost/telmate/proxmox/1.0.0/linux_amd64/

# Copy the Crossplane provider binary
COPY --from=crossplane-builder /provider /usr/local/bin/provider

# Copy the Terraform provider binary
COPY --from=terraform-builder /workspace/terraform-provider-proxmox/bin/terraform-provider-proxmox /terraform.d/plugins/localhost/telmate/proxmox/1.0.0/linux_amd64/

# Set permissions
RUN chmod +x /usr/local/bin/provider && \
    chmod +x /terraform.d/plugins/localhost/telmate/proxmox/1.0.0/linux_amd64/terraform-provider-proxmox

# Set environment variables for air-gapped environment
ENV TERRAFORM_PROVIDER_PATH=/terraform.d/plugins
ENV USER_ID=65532
USER ${USER_ID}

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/provider"]
#
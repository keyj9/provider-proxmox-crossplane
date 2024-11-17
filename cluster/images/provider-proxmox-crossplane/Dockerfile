# Build the Terraform module
FROM --platform=$BUILDPLATFORM hashicorp/terraform:1.5.6 as terraform-builder
WORKDIR /workspace
COPY third_party/terraform-module /workspace/terraform-module/
RUN terraform -chdir=terraform-module init && \
    terraform -chdir=terraform-module plan -out=tfplan && \
    terraform -chdir=terraform-module apply -auto-approve tfplan

# Build the Terraform provider
FROM --platform=$BUILDPLATFORM golang:1.21-alpine3.20 as provider-builder
WORKDIR /workspace
RUN apk --no-cache add git make build-base

COPY third_party/terraform-provider-proxmox /workspace/
WORKDIR /workspace/third_party/terraform-provider-proxmox
RUN make build
RUN cp bin/terraform-provider-proxmox /workspace/

# Build the Crossplane provider
FROM --platform=$BUILDPLATFORM golang:1.21-alpine3.20 as crossplane-builder
WORKDIR /workspace
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o provider ./cmd/provider

# Final minimal image
FROM --platform=$TARGETPLATFORM alpine:3.20.3
RUN apk --no-cache add ca-certificates && \
    adduser -D -u 65532 crossplane

# Copy binaries and Terraform module from builders
COPY --from=provider-builder /workspace/terraform-provider-proxmox /terraform-plugins/
COPY --from=crossplane-builder /workspace/provider /usr/local/bin/
COPY --from=terraform-builder /workspace/terraform-module /terraform-module/
RUN chmod +x /usr/local/bin/provider /terraform-plugins/terraform-provider-proxmox

USER 65532
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/provider"]
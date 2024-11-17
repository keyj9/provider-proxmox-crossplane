# Build Stage - Build the Crossplane Provider
FROM --platform=$BUILDPLATFORM golang:1.21-alpine3.17 AS crossplane-builder

ARG TARGETOS
ARG TARGETARCH

# Install necessary packages
RUN apk --no-cache add make git

# Set the working directory
WORKDIR /app

# Copy the Crossplane provider source code
COPY cmd/provider /app/cmd/provider
COPY main.go go.mod go.sum vendor /app/

# Build the Crossplane provider
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -mod=vendor -o /provider /app/main.go

# Build Stage - Build the Terraform Proxmox Provider
FROM --platform=$BUILDPLATFORM golang:1.21-alpine3.17 AS terraform-builder

ARG TARGETOS
ARG TARGETARCH

# Install necessary packages
RUN apk --no-cache add make git

# Set the working directory
WORKDIR /terraform-provider-proxmox

# Copy the Terraform provider source code
COPY third_party/terraform-provider-proxmox /terraform-provider-proxmox

# Build the Terraform provider
RUN make build

# Final Stage - Create the runtime image
FROM alpine:3.20.3

# Install necessary packages
RUN apk --no-cache add ca-certificates

# Set the working directory
WORKDIR /app

# Copy the Crossplane provider binary from the builder stage
COPY --from=crossplane-builder /provider /usr/local/bin/provider

# Copy the Terraform provider binary
COPY --from=terraform-builder /terraform-provider-proxmox/bin/terraform-provider-proxmox /terraform.d/plugins/localhost/telmate/proxmox/1.0.0/linux_amd64/

# Set permissions
RUN chmod +x /usr/local/bin/provider
RUN chmod +x /terraform.d/plugins/localhost/telmate/proxmox/1.0.0/linux_amd64/terraform-provider-proxmox

# Set environment variables
ENV USER_ID=65532
USER ${USER_ID}

# Expose port and set entrypoint
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/provider"]
#
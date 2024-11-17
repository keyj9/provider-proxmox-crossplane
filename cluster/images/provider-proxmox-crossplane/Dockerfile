# Build Stage
FROM --platform=$BUILDPLATFORM golang:1.21-alpine3.17 AS builder

# Set build-time variables
ARG TARGETOS
ARG TARGETARCH

# Install necessary packages
RUN apk --no-cache add make git

# Set the working directory
WORKDIR /app

# Copy only the required source code
COPY third_party/terraform-provider-proxmox /app/third_party/terraform-provider-proxmox

# Build the Terraform provider
RUN cd third_party/terraform-provider-proxmox && \
    GOOS=$TARGETOS GOARCH=$TARGETARCH CGO_ENABLED=0 go build -trimpath -o /provider

# Final Stage
FROM alpine:3.20.3

# Install necessary packages
RUN apk --no-cache add ca-certificates

# Copy the provider binary from the builder stage
COPY --from=builder /provider /usr/local/bin/provider

# Set permissions
RUN chmod +x /usr/local/bin/provider

# Set user and entrypoint
ENV USER_ID=65532
USER ${USER_ID}

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/provider"]
#

# Copy the main application code
COPY . /app

# If needed, install dependencies from the submodule
RUN cd /app/third_party/terraform-provider-proxmox && make install
#
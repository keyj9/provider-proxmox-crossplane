# Start with Alpine 3.20.3
FROM --platform=$BUILDPLATFORM alpine:3.20.3

# Install minimal requirements
RUN apk --no-cache add ca-certificates

# Define build arguments
ARG TARGETOS
ARG TARGETARCH

# Add the provider binary
COPY bin/${TARGETOS}_${TARGETARCH}/provider /usr/local/bin/provider

# Set non-root user
ENV USER_ID=65532
USER ${USER_ID}

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/provider"]
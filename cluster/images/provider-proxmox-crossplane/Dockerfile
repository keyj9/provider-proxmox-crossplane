FROM --platform=$BUILDPLATFORM alpine:3.20.3

RUN apk --no-cache add ca-certificates

ARG TARGETOS
ARG TARGETARCH

COPY bin/${TARGETOS}_${TARGETARCH}/provider /usr/local/bin/provider
RUN chmod +x /usr/local/bin/provider

ENV USER_ID=65532
USER ${USER_ID}

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/provider"]
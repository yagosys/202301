# Use Alpine Linux as the base image
FROM alpine:latest

# Install curl, tar, and CA certificates
RUN apk add --no-cache curl jq tar bash ca-certificates

# Set the kubectl version
ARG KUBECTL_VERSION="v1.25.0"

# Download and install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

COPY script.sh /script.sh
RUN chmod +x /script.sh
ENTRYPOINT ["/script.sh"]

FROM mcr.microsoft.com/devcontainers/base:noble
ARG TARGETPLATFORM
ARG PODMAN_VERSION="v5.5.1"
ARG PODMAN_URL="https://github.com/containers/podman/releases/download/${PODMAN_VERSION}"
RUN curl -sSL ${PODMAN_URL}/podman-remote-static-linux_${TARGETPLATFORM##*/}.tar.gz | tar xz -C /usr/local/ bin/podman-remote-static-linux_${TARGETPLATFORM##*/} && \
    chmod +x /usr/local/bin/podman-remote-static-linux_${TARGETPLATFORM##*/} && \
    ln -s /usr/local/bin/podman-remote-static-linux_${TARGETPLATFORM##*/} /usr/local/bin/podman

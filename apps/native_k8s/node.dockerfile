FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive
#
# Util Respository
#
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    # network
    curl \
    dnsutils \
    netcat-openbsd \
    net-tools \
    iproute2 \
    iputils-ping \
    tcpdump \
    traceroute \
    tshark \
    wget \
    # util
    vim \
    sudo \
    procps \
    ca-certificates \
    gnupg \
    apt-transport-https \
    && apt-get clean\
    && rm -rf /var/lib/apt/lists/*

#
# Kubernetes Repository
#
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key \
    | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

RUN echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' \
    > /etc/apt/sources.list.d/kubernetes.list

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    kubelet \
    kubeadm \
    kubectl \
    containerd \
    systemd \
    systemd-sysv \
    && apt-get clean\
    && rm -rf /var/lib/apt/lists/*

# 意図しないアップグレードの防止
RUN apt-mark hold kubelet kubeadm kubectl

# RUN mkdir -p /etc/containerd && \
# containerd config default > /etc/containerd/config.toml
COPY /etc/containerd/config.toml /etc/containerd/config.toml

# bashではなくsystemdを起動
CMD ["/sbin/init"]

FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive
#
# Util Respository
#
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    curl \
    wget \
    vim \
    sudo \
    iproute2 \
    iputils-ping \
    net-tools \
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
    && apt-get clean\
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/containerd && \
    containerd config default > /etc/containerd/config.toml

# 意図しないアップグレードの防止
RUN apt-mark hold kubelet kubeadm kubectl

CMD ["/bin/bash"]

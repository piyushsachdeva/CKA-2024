FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    bash \
    iptables \
    iproute2 \
    sudo \
    systemd \
    containerd \
    openssh-client \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Kubernetes binaries
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" > /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && apt-get install -y kubelet kubeadm kubectl && \
    apt-mark hold kubelet kubeadm kubectl

# Disable swap (kubeadm requirement)
RUN swapoff -a || true

# Patch containerd config to use 'native' snapshotter
RUN mkdir -p /etc/containerd && containerd config default > /etc/containerd/config.toml && \
    sed -i 's/snapshotter = "overlayfs"/snapshotter = "native"/' /etc/containerd/config.toml

# Install minimal CNI plugins manually
RUN mkdir -p /opt/cni/bin && cd /opt/cni/bin && \
    wget https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz && \
    tar -xvf cni-plugins-linux-amd64-v1.3.0.tgz && \
    rm cni-plugins-linux-amd64-v1.3.0.tgz

COPY start-master.sh /start-master.sh
COPY start-worker.sh /start-worker.sh
RUN chmod +x /start-master.sh /start-worker.sh

CMD ["/bin/bash"]

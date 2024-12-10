# Base 이미지 설정 (ARM64 아키텍처용)
FROM --platform=linux/arm64 ubuntu:24.04

# 환경 변수 설정
ENV PATH="/usr/local/bin:${PATH}"

# 필수 패키지 업데이트 및 설치
RUN apt-get update && apt-get install -y \
    bash-completion \
    ca-certificates \
    curl \
    wget \
    git \
    jq \
    dnsutils \
    net-tools \
    unzip \
    vim \
    less \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

## Bash completion
RUN echo 'if [ -f /usr/share/bash-completion/bash_completion ]; then' >> /etc/bash.bashrc && \
    echo '    . /usr/share/bash-completion/bash_completion' >> /etc/bash.bashrc && \
    echo 'fi' >> /etc/bash.bashrc

# Helm 설치
RUN curl -fsSL https://get.helm.sh/helm-v3.12.0-linux-arm64.tar.gz -o helm.tar.gz && \
    tar -zxvf helm.tar.gz && \
    mv linux-arm64/helm /usr/local/bin/helm && \
    rm -rf helm.tar.gz linux-arm64

# kubectl 1.31 설치
RUN curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/arm64/kubectl && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/kubectl

# Terraform 1.10.0 설치
RUN curl -fsSL https://releases.hashicorp.com/terraform/1.10.0/terraform_1.10.0_linux_arm64.zip -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/terraform && \
    rm terraform.zip

# yq 설치
RUN curl -LO https://github.com/mikefarah/yq/releases/download/v4.36.0/yq_linux_arm64 && \
    chmod +x yq_linux_arm64 && \
    mv yq_linux_arm64 /usr/local/bin/yq

# kubecolor 설치
RUN curl -LO https://github.com/kubecolor/kubecolor/releases/download/v0.4.0/kubecolor_0.4.0_linux_arm64.tar.gz && \
    tar -zxvf kubecolor_0.4.0_linux_arm64.tar.gz && \
    mv kubecolor /usr/local/bin/kubecolor && \
    rm kubecolor_0.4.0_linux_arm64.tar.gz

# kubectx 설치
RUN curl -LO https://github.com/ahmetb/kubectx/releases/download/v0.9.5/kubectx_v0.9.5_linux_arm64.tar.gz && \
    tar -zxvf kubectx_v0.9.5_linux_arm64.tar.gz && \
    mv kubectx /usr/local/bin/kubectx && \
    rm kubectx_v0.9.5_linux_arm64.tar.gz

# krew 설치 (kubectl 플러그인 관리 도구)
RUN curl -fsSL https://github.com/kubernetes-sigs/krew/releases/download/v0.4.4/krew-linux_arm64.tar.gz -o krew.tar.gz && \
    tar -zxvf krew.tar.gz && \
    mv krew-linux_arm64 /usr/local/bin/krew && \
    rm krew.tar.gz

# awscli 설치
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip

# kube-ps1 설치 (kubectl 자동완성)
RUN git clone https://github.com/jonmosco/kube-ps1.git /tmp/kube-ps1 && \
    cp /tmp/kube-ps1/kube-ps1.sh /usr/local/bin && \
    rm -rf /tmp/kube-ps1

# eks-node-view
RUN curl -LO https://github.com/awslabs/eks-node-viewer/releases/download/v0.7.1/eks-node-viewer_Linux_arm64 && \
    chmod +x eks-node-viewer_Linux_arm64 && \
    mv eks-node-viewer_Linux_arm64 /usr/local/bin/eks-node-viewer

# aws-runas
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    wget https://github.com/mmmorris1975/aws-runas/releases/download/3.5.2/aws-runas-3.5.2-linux-${arch}.zip && \
    unzip aws-runas-3.5.2-linux-${arch}.zip && \
    chmod +x aws-runas && \
    mv aws-runas /usr/local/bin/ && \
    rm aws-runas-3.5.2-linux-${arch}.zip

# 터미널에서 한글 입력이 가능하도록 설정
# PATH와 자동완성 설정
RUN echo 'source /usr/local/bin/kube-ps1.sh' >> /etc/bash.bashrc && \
    echo 'source /usr/local/bin/kube-ps1.sh' >> /root/.bashrc && \
    echo 'source <(kubectl completion bash)' >> /etc/bash.bashrc && \
    echo 'source <(helm completion bash)' >> /etc/bash.bashrc && \
    echo 'source <(kubectl completion bash)' >> /root/.bashrc && \
    echo 'source <(helm completion bash)' >> /root/.bashrc && \
    echo 'alias kubectl="kubecolor"' >> /root/.bashrc && \
    echo 'complete -C "/usr/local/bin/aws_completer" aws' >> /root/.bashrc && \
    echo "PS1='[\u@\h \W \$(kube_ps1)]\\$ '" >> /root/.bashrc && \
    echo 'alias karpenter-node-view="eks-node-viewer"' >> /root/.bashrc && \
    echo 'export LANG=C.UTF-8' >> /.bashrc

# 기본 쉘을 bash로 설정
WORKDIR /root

CMD [ "sleep", "infinity" ]

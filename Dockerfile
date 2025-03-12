FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    python3.8 \
    python3.8-dev \
    python3-pip \
    openssh-server \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# SSH configuration
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Create working directory
WORKDIR /app

# Install conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/conda \
    && rm miniconda.sh
ENV PATH="/opt/conda/bin:${PATH}"

# Create conda environment
RUN conda create -n selfocc python=3.8.16 -y
SHELL ["conda", "run", "-n", "selfocc", "/bin/bash", "-c"]

# Install PyTorch
RUN pip install torch==2.0.0 torchvision==0.15.1 torchaudio==2.0.1 --index-url https://download.pytorch.org/whl/cu118

# Install MMLab packages
RUN pip install openmim \
    && mim install mmcv==2.0.1 \
    && mim install mmdet==3.0.0 \
    && mim install mmsegmentation==1.0.0 \
    && mim install mmdet3d==1.1.1

# Install other dependencies
RUN pip install spconv-cu117 timm

# Clone GaussianFormer repository
RUN git clone https://github.com/wzzheng/GaussianFormer.git /app/GaussianFormer

# Install custom CUDA ops
WORKDIR /app/GaussianFormer
RUN cd model/encoder/gaussian_encoder/ops && pip install -e . \
    && cd /app/GaussianFormer/model/head/localagg && pip install -e . \
    && cd /app/GaussianFormer/model/head/localagg_prob && pip install -e . \
    && cd /app/GaussianFormer/model/head/localagg_prob_fast && pip install -e .

# Install visualization dependencies (optional for inference)
RUN pip install pyvirtualdisplay mayavi matplotlib==3.7.2 PyQt5

# Download pretrained weights
RUN mkdir -p /app/GaussianFormer/ckpts \
    && wget -P /app/GaussianFormer/ckpts https://github.com/zhiqi-li/storage/releases/download/v1.0/r101_dcn_fcos3d_pretrain.pth

# Create output directory
RUN mkdir -p /app/GaussianFormer/out

# Setup entry point script
RUN echo '#!/bin/bash\n\
service ssh start\n\
tail -f /dev/null' > /app/start.sh && \
    chmod +x /app/start.sh

# Set default command
ENTRYPOINT ["/app/start.sh"]
EXPOSE 22

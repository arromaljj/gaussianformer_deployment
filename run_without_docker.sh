#!/bin/bash

# Create directories
mkdir -p data models

# Clone GaussianFormer if not already present
if [ ! -d "GaussianFormer" ]; then
    git clone https://github.com/wzzheng/GaussianFormer.git
fi

# Set up Python environment
if ! command -v conda &> /dev/null; then
    echo "Installing Miniconda..."
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
    bash miniconda.sh -b -p $HOME/miniconda
    rm miniconda.sh
    export PATH="$HOME/miniconda/bin:$PATH"
fi

# Create and activate conda environment
echo "Setting up conda environment..."
conda create -n selfocc python=3.8.16 -y
source $(conda info --base)/etc/profile.d/conda.sh
conda activate selfocc

# Install dependencies
echo "Installing PyTorch..."
pip install torch==2.0.0 torchvision==0.15.1 torchaudio==2.0.1 --index-url https://download.pytorch.org/whl/cu118

echo "Installing MMLab packages..."
pip install openmim
mim install mmcv==2.0.1
mim install mmdet==3.0.0
mim install mmsegmentation==1.0.0
mim install mmdet3d==1.1.1

echo "Installing other dependencies..."
pip install spconv-cu117 timm
pip install pyvirtualdisplay mayavi matplotlib==3.7.2 PyQt5

# Install custom CUDA ops
echo "Installing custom CUDA operations..."
cd GaussianFormer
cd model/encoder/gaussian_encoder/ops && pip install -e .
cd ../../../..
cd model/head/localagg && pip install -e .
cd ../..
cd model/head/localagg_prob && pip install -e .
cd ../..
cd model/head/localagg_prob_fast && pip install -e .
cd ../../..

# Download pretrained weights
echo "Downloading pretrained backbone..."
mkdir -p ckpts
wget -P ckpts https://github.com/zhiqi-li/storage/releases/download/v1.0/r101_dcn_fcos3d_pretrain.pth

# Create output directory
mkdir -p out

echo "Setup complete. You can now run GaussianFormer with:"
echo "conda activate selfocc"
echo "python eval.py --py-config config/nuscenes_gs25600_solid.py --work-dir out/nuscenes_gs25600_solid/ --resume-from out/nuscenes_gs25600_solid/state_dict.pth" 
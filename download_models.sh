#!/bin/bash

# Create directories
mkdir -p models/nuscenes_gs144000 models/nuscenes_gs25600_solid models/prob_gs6400 models/prob_gs12800 models/prob_gs25600

# Download model weights
echo "Downloading GaussianFormer Baseline model..."
wget -O models/nuscenes_gs144000/state_dict.pth "https://cloud.tsinghua.edu.cn/seafhttp/files/b751f8f7-9a28-4be7-aa4e-385c4349f1b0/state_dict.pth"

echo "Downloading GaussianFormer NonEmpty model..."
wget -O models/nuscenes_gs25600_solid/state_dict.pth "https://cloud.tsinghua.edu.cn/f/d1766fff8ad74756920b/?dl=1"

echo "Downloading GaussianFormer-2 Prob-64 model..."
wget -O models/prob_gs6400/state_dict.pth "https://cloud.tsinghua.edu.cn/f/d041974bd900419fb141/?dl=1"

echo "Downloading GaussianFormer-2 Prob-128 model..."
wget -O models/prob_gs12800/state_dict.pth "https://cloud.tsinghua.edu.cn/f/b6038dca93574244ad57/?dl=1"

echo "Downloading GaussianFormer-2 Prob-256 model..."
wget -O models/prob_gs25600/state_dict.pth "https://cloud.tsinghua.edu.cn/f/e30c9c92e4344783a7de/?dl=1"

echo "All models downloaded successfully!" 
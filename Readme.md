# GaussianFormer Deployment

This directory contains the necessary files to deploy GaussianFormer/GaussianFormer-2 for inference in a Docker container.

## Getting Started

### Option 1: Docker Compose Development Environment

The easiest way to get started is using the included Docker Compose file, which creates a development environment with SSH access.

#### Prerequisites
- Docker and Docker Compose
- NVIDIA GPU with CUDA support
- NVIDIA Container Toolkit installed

#### Setting up the Development Environment

1. Create the required directories:
```bash
mkdir -p data models
```

2. Start the Docker Compose environment:
```bash
docker-compose up -d
```

3. Connect to the container via SSH:
```bash
ssh -p 2222 root@localhost
```
The default password is `password`. For security, you should either:
- Change this password after first login: `passwd`
- Use SSH key authentication by adding your public key to `~/.ssh/authorized_keys` before starting the container

4. Once connected, you can run inference commands using the conda environment:
```bash
conda activate selfocc
cd /app/GaussianFormer
python eval.py --py-config config/nuscenes_gs25600_solid.py --work-dir out/nuscenes_gs25600_solid/ --resume-from out/nuscenes_gs25600_solid/state_dict.pth
```

### Option 2: Building the Docker Image Manually

```bash
docker build -t gaussianformer:inference -f Dockerfile .
```

### Data Preparation

Before running inference, you need to prepare the dataset with the following structure:

```
data/
├── nuscenes/
│   ├── maps/
│   ├── samples/
│   ├── sweeps/
│   ├── v1.0-test/
│   ├── v1.0-trainval/
├── nuscenes_cam/
│   ├── nuscenes_infos_train_sweeps_occ.pkl
│   ├── nuscenes_infos_val_sweeps_occ.pkl
│   ├── nuscenes_infos_val_sweeps_lid.pkl
├── surroundocc/
│   ├── samples/
│   │   ├── xxxxxxxx.pcd.bin.npy
│   │   ├── ...
```

You can download the required files from:
- [nuScenes V1.0 full dataset](https://www.nuscenes.org/download)
- [Occupancy annotations from SurroundOcc](https://github.com/weiyithu/SurroundOcc)
- [Required PKL files](https://cloud.tsinghua.edu.cn/d/bb96379a3e46442c8898/)

### Download Pre-trained Models

The following pre-trained models are available:

| Name  | Type | #Gaussians | mIoU | Config | Weight |
| :---: | :---: | :---: | :---: | :---: | :---: |
| Baseline | GaussianFormer | 144000 | 19.10 | [config](https://github.com/wzzheng/GaussianFormer/blob/main/config/nuscenes_gs144000.py) | [weight](https://cloud.tsinghua.edu.cn/seafhttp/files/b751f8f7-9a28-4be7-aa4e-385c4349f1b0/state_dict.pth) |
| NonEmpty | GaussianFormer | 25600  | 19.31 | [config](https://github.com/wzzheng/GaussianFormer/blob/main/config/nuscenes_gs25600_solid.py) | [weight](https://cloud.tsinghua.edu.cn/f/d1766fff8ad74756920b/?dl=1) |
| Prob-64  | GaussianFormer-2 | 6400 | 20.04 | [config](https://github.com/wzzheng/GaussianFormer/blob/main/config/prob/nuscenes_gs6400.py) | [weight](https://cloud.tsinghua.edu.cn/f/d041974bd900419fb141/?dl=1) |
| Prob-128 | GaussianFormer-2 | 12800 | 20.08 | [config](https://github.com/wzzheng/GaussianFormer/blob/main/config/prob/nuscenes_gs12800.py) | [weight](https://cloud.tsinghua.edu.cn/f/b6038dca93574244ad57/?dl=1) |
| Prob-256 | GaussianFormer-2 | 25600 | 20.33 | [config](https://github.com/wzzheng/GaussianFormer/blob/main/config/prob/nuscenes_gs25600.py) | [weight](https://cloud.tsinghua.edu.cn/f/e30c9c92e4344783a7de/?dl=1) |

Download your preferred model weights and place them in the models directory.

### Running Inference Manually

If not using Docker Compose, you can run inference with:

```bash
# Mount your data and run inference
docker run --gpus all -v /path/to/data:/app/GaussianFormer/data -v /path/to/output:/app/GaussianFormer/out gaussianformer:inference \
    conda run -n selfocc python /app/GaussianFormer/eval.py \
    --py-config /app/GaussianFormer/config/nuscenes_gs25600_solid.py \
    --work-dir /app/GaussianFormer/out/nuscenes_gs25600_solid/ \
    --resume-from /app/GaussianFormer/out/nuscenes_gs25600_solid/state_dict.pth
```

### Visualization

For visualization, use the following command:

```bash
conda run -n selfocc python /app/GaussianFormer/visualize.py \
    --py-config /app/GaussianFormer/config/nuscenes_gs25600_solid.py \
    --work-dir /app/GaussianFormer/out/nuscenes_gs25600_solid \
    --resume-from /app/GaussianFormer/out/nuscenes_gs25600_solid/state_dict.pth \
    --vis-occ --vis-gaussian --num-samples 3 --model-type base
```

## Notes

- This Docker setup is designed for inference only. For training, additional configurations might be needed.
- Make sure to use a machine with NVIDIA GPU and proper drivers installed.
- The container requires CUDA 11.8 compatibility.
- Remember to change the default password when using the development environment for security.

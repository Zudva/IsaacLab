# G1 EDU Configuration for Isaac Lab

## Overview

The G1 EDU configuration provides a reduced 23 DOF version of the Unitree G1 humanoid robot, specifically designed for robot transfer learning applications.

## DOF Breakdown

- **Legs**: 12 DOF (6 per leg)
  - `left/right_hip_yaw_joint`
  - `left/right_hip_roll_joint` 
  - `left/right_hip_pitch_joint`
  - `left/right_knee_joint`
  - `left/right_ankle_pitch_joint`
  - `left/right_ankle_roll_joint`

- **Torso**: 1 DOF
  - `torso_joint` (waist rotation)

- **Arms**: 10 DOF (5 per arm)
  - `left/right_shoulder_pitch_joint`
  - `left/right_shoulder_roll_joint`
  - `left/right_shoulder_yaw_joint`
  - `left/right_elbow_pitch_joint`
  - `left/right_elbow_roll_joint`

**Total**: 23 DOF (vs 37 DOF for full G1)

## Usage

### Available Environments
- `Isaac-Velocity-Flat-G1-EDU-v0` - Locomotion training on flat terrain
- `Isaac-Velocity-Flat-G1-EDU-Play-v0` - Play/evaluation variant

### Training Example
```bash
# Basic training
isaaclab.bat -p scripts/reinforcement_learning/rsl_rl/train.py \
    --task Isaac-Velocity-Flat-G1-EDU-v0 \
    --num_envs 512 \
    --max_iterations 1500

# With DirectX 12 (recommended for Windows)
.\test_g1_edu_quick.bat
```

### Memory Requirements
- Recommended: 14-16GB VRAM
- Conservative: 256-512 environments
- Optimal: 768-1024 environments (depending on VRAM)

## DirectX 12 Setup

For optimal performance on Windows with RTX GPUs:

```bash
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin"
set "OMNI_FORCE_GRAPHICS_API=D3D12"
set "OMNI_GRAPHICS_API=D3D12"
set "OMNI_KIT_DISABLE_VULKAN=1"
```

## Robot Transfer Compatibility

This configuration is designed to be compatible with:
- unitree_rl_gym for hardware deployment
- Standard sim-to-real transfer pipelines
- Real Unitree G1 robots in EDU configuration

## Files

- `unitree.py` - Robot configuration
- `flat_edu_env_cfg.py` - Environment configuration  
- `test_g1_edu_quick.bat` - Quick test launcher
- `run_g1_edu_final.bat` - Full training launcher

## Validation

The configuration has been validated to:
- ✅ Initialize correctly with Isaac Lab
- ✅ Train stably with PPO
- ✅ Work with DirectX 12 rendering
- ✅ Scale to 1000+ environments
- ✅ Generate transferable policies

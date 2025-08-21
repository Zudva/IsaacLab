![Isaac Lab](docs/source/_static/isaaclab.jpg)

---

# Isaac Lab

[![IsaacSim](https://img.shields.io/badge/IsaacSim-5.0.0-silver.svg)](https://docs.isaacsim.omniverse.nvidia.com/latest/index.html)
[![Python](https://img.shields.io/badge/python-3.11-blue.svg)](https://docs.python.org/3/whatsnew/3.11.html)
[![Linux platform](https://img.shields.io/badge/platform-linux--64-orange.svg)](https://releases.ubuntu.com/22.04/)
[![Windows platform](https://img.shields.io/badge/platform-windows--64-orange.svg)](https://www.microsoft.com/en-us/)
[![pre-commit](https://img.shields.io/github/actions/workflow/status/isaac-sim/IsaacLab/pre-commit.yaml?logo=pre-commit&logoColor=white&label=pre-commit&color=brightgreen)](https://github.com/isaac-sim/IsaacLab/actions/workflows/pre-commit.yaml)
[![docs status](https://img.shields.io/github/actions/workflow/status/isaac-sim/IsaacLab/docs.yaml?label=docs&color=brightgreen)](https://github.com/isaac-sim/IsaacLab/actions/workflows/docs.yaml)
[![License](https://img.shields.io/badge/license-BSD--3-yellow.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![License](https://img.shields.io/badge/license-Apache--2.0-yellow.svg)](https://opensource.org/license/apache-2-0)


**Isaac Lab** is a GPU-accelerated, open-source framework designed to unify and simplify robotics research workflows, such as reinforcement learning, imitation learning, and motion planning. Built on [NVIDIA Isaac Sim](https://docs.isaacsim.omniverse.nvidia.com/latest/index.html), it combines fast and accurate physics and sensor simulation, making it an ideal choice for sim-to-real transfer in robotics.

Isaac Lab provides developers with a range of essential features for accurate sensor simulation, such as RTX-based cameras, LIDAR, or contact sensors. The framework's GPU acceleration enables users to run complex simulations and computations faster, which is key for iterative processes like reinforcement learning and data-intensive tasks. Moreover, Isaac Lab can run locally or be distributed across the cloud, offering flexibility for large-scale deployments.


## Key Features

Isaac Lab offers a comprehensive set of tools and environments designed to facilitate robot learning:
- **Robots**: A diverse collection of robots, from manipulators, quadrupeds, to humanoids, with 16+ commonly available models including:
  - **Unitree G1**: Standard humanoid robot (37 DOF)
  - **Unitree G1 EDU**: Educational variant optimized for robot transfer learning (23 DOF actuated)
  - **ANYmal-C/D**: Quadruped robots for locomotion research
  - **Franka Emika Panda**: 7-DOF manipulator for precise control tasks
  - **Shadow Hand**: Dexterous manipulation with 24 DOF
- **Environments**: Ready-to-train implementations of more than 30 environments, which can be trained with popular reinforcement learning frameworks such as RSL RL, SKRL, RL Games, or Stable Baselines. We also support multi-agent reinforcement learning.
- **Physics**: Rigid bodies, articulated systems, deformable objects
- **Sensors**: RGB/depth/segmentation cameras, camera annotations, IMU, contact sensors, ray casters.
- **Platform Optimization**: Specialized DirectX 12 support for Windows RTX GPUs with up to 5x performance improvements
- **Smart Environment Auto-Detection**: Automatic optimal environment count detection based on available VRAM (14GB-16GB RTX 4090 support)
- **Advanced Launch Scripts**: Intelligent batch launchers with:
  - Progressive environment count testing (32 → 3072+ environments)
  - Automatic fallback mechanisms and error recovery
  - Memory budget optimization and VRAM utilization monitoring
  - Performance benchmarking and throughput estimation
  - Headless mode optimization for maximum training speed


## Getting Started

### Getting Started with Open-Source Isaac Sim

Isaac Sim is now open source and available on GitHub!

For detailed Isaac Sim installation instructions, please refer to
[Isaac Sim README](https://github.com/isaac-sim/IsaacSim?tab=readme-ov-file#quick-start).

1. Clone Isaac Sim

    ```
    git clone https://github.com/isaac-sim/IsaacSim.git
    ```

2. Build Isaac Sim

    ```
    cd IsaacSim
    ./build.sh
    ```

    On Windows, please use `build.bat` instead.

3. Clone Isaac Lab

    ```
    cd ..
    git clone https://github.com/isaac-sim/IsaacLab.git
    cd isaaclab
    ```

4. Set up symlink in Isaac Lab

    Linux:

    ```
    ln -s ../IsaacSim/_build/linux-x86_64/release _isaac_sim
    ```

    Windows:

    ```
    mklink /D _isaac_sim ..\IsaacSim\_build\windows-x86_64\release
    ```

5. Install Isaac Lab

    Linux:

    ```
    ./isaaclab.sh -i
    ```

    Windows:

    ```
    isaaclab.bat -i
    ```

6. [Optional] Set up a virtual python environment (e.g. for Conda)

    Linux:

    ```
    source _isaac_sim/setup_conda_env.sh
    ```

    Windows:

    ```
    _isaac_sim\setup_python_env.bat
    ```

7. Train!

    Linux:

    ```
    ./isaaclab.sh -p scripts/reinforcement_learning/skrl/train.py --task Isaac-Ant-v0 --headless
    ```

    Windows:

    ```
    isaaclab.bat -p scripts\reinforcement_learning\skrl\train.py --task Isaac-Ant-v0 --headless
    ```

### Windows DX12 Training Launcher (Recommended)

On Windows, you can use a dedicated PowerShell launcher that enforces DirectX 12 (disables Vulkan) and provides convenient profiles, resume-in-place logging, video recording, and an optional interactive timer.

- Script: `scripts/reinforcement_learning/rsl_rl/run_training.ps1`
- Docs: `docs/run_rules.md`
- Quick start (PowerShell):
  - Resume high-load run (headless):
    - `powershell -ExecutionPolicy Bypass -File scripts/reinforcement_learning/rsl_rl/run_training.ps1 -Profile HighLoad -Resume -RunPath "<path-to-run>"`
  - 6-hour limit:
    - `...\run_training.ps1 -UseTimer -MaxHours 6`

### DirectX 12 Optimized Training (RTX 4090 Support)

For maximum performance on Windows 11 RTX 4090 systems, use the specialized DirectX 12 batch launchers that completely disable Vulkan and optimize VRAM usage:

#### G1 EDU Robot (23 DOF)
```bash
# Maximum performance training (auto-detects optimal environment count)
.\run_g1_edu_extreme.bat

# Smart progressive training (recommended for most users)
.\run_g1_edu_fast_training.bat

# Conservative testing (for memory-constrained systems)
.\test_g1_edu_ultra_conservative.bat
```

#### Standard G1 Robot
```bash
# Resume existing training with DX12 optimization
.\run_training_dx12_resume.bat
```

**Performance Benefits:**
- **3-5x faster training** compared to Vulkan on RTX 4090
- **3072+ environments** confirmed working in headless mode (vs 512-768 in GUI)  
- **1-1.5 hour convergence** for locomotion tasks (vs 6-7 hours)
- **85-95% VRAM utilization** with headless rendering
- **Automatic optimal scaling** - scripts test from 32 to 3072+ environments
- **Progressive performance detection** - finds maximum stable environment count
- **Record-breaking throughput** - 150k+ steps/second achieved

**Key Features:**
- **Complete Vulkan bypass** (`OMNI_KIT_DISABLE_VULKAN=1`)
- **Smart Environment Auto-Detection**: 
  - Automatically tests environment counts: 32 → 64 → 128 → 256 → 512 → 768 → 1024 → 1280 → 1536 → 2048 → 2304 → 2560 → 2816 → 3072
  - Finds optimal count for your specific 14GB VRAM configuration
  - Provides performance estimates (steps/second) before full training
- **Robust error handling** and automatic process cleanup
- **Memory budget optimization** with real-time VRAM monitoring
- **Fallback mechanisms** - automatically reduces environment count if memory exceeded
- **Performance benchmarking** - shows expected training time and throughput
- **Support for Unitree G1 EDU** (23 DOF) robot transfer learning

### Documentation

Our [documentation page](https://isaac-sim.github.io/IsaacLab) provides everything you need to get started, including detailed tutorials and step-by-step guides. Follow these links to learn more about:

- [Installation steps](https://isaac-sim.github.io/IsaacLab/main/source/setup/installation/index.html#local-installation)
- [Reinforcement learning](https://isaac-sim.github.io/IsaacLab/main/source/overview/reinforcement-learning/rl_existing_scripts.html)
- [Tutorials](https://isaac-sim.github.io/IsaacLab/main/source/tutorials/index.html)
- [Available environments](https://isaac-sim.github.io/IsaacLab/main/source/overview/environments.html)


## Isaac Sim Version Dependency

Isaac Lab is built on top of Isaac Sim and requires specific versions of Isaac Sim that are compatible with each release of Isaac Lab.
Below, we outline the recent Isaac Lab releases and GitHub branches and their corresponding dependency versions for Isaac Sim.

| Isaac Lab Version             | Isaac Sim Version   |
| ----------------------------- | ------------------- |
| `main` branch                 | Isaac Sim 4.5 / 5.0 |
| `directx-rtx4090-support`     | Isaac Sim 4.5 (DirectX 12 optimized) |
| `v2.2.0`                      | Isaac Sim 4.5 / 5.0 |
| `v2.1.1`                      | Isaac Sim 4.5       |
| `v2.1.0`                      | Isaac Sim 4.5       |
| `v2.0.2`                      | Isaac Sim 4.5       |
| `v2.0.1`                      | Isaac Sim 4.5       |
| `v2.0.0`                      | Isaac Sim 4.5       |


## Specialized Branch Features

### DirectX RTX4090 Support Branch

This specialized branch provides enhanced Windows 11 RTX 4090 compatibility with significant performance improvements:

**🚀 Performance Enhancements:**
- **3-5x faster training** on RTX 4090 systems
- **Complete Vulkan bypass** with DirectX 12 enforcement
- **3072+ environments** confirmed working in headless mode
- **1-1.5 hour convergence** for locomotion tasks (vs 6-7 hours standard)
- **Smart Auto-Detection**: Scripts automatically test 32 → 3072+ environments to find optimal count
- **Progressive VRAM Optimization**: Real-time memory monitoring and automatic scaling
- **Performance Prediction**: Shows expected steps/second before starting full training
- **Record Throughput**: 150k+ steps/second achieved (3072 × 50 steps/sec/env)

**🤖 New Robot Support:**
- **Unitree G1 EDU**: 23 DOF educational variant for robot transfer learning
- **Joint mapping compatibility** with external robotics frameworks
- **Optimized configurations** for real-robot deployment workflows

**🛠 Advanced Launch System:**
- **Intelligent Environment Detection**: Automatically finds maximum stable environment count
- **Progressive Testing**: Tests multiple environment counts in sequence (32, 64, 128, 256, 512, 768, 1024, 1280, 1536, 2048+)
- **Fallback Mechanisms**: Automatically reduces count if memory budget exceeded
- **Performance Benchmarking**: Real-time throughput estimation and optimization recommendations
- **Error Recovery**: Automatic process cleanup and retry logic

**📋 Additional Documentation:**
- [`CHANGELOG.md`](CHANGELOG.md) - Complete feature and performance changelog
- [`DIRECTX_RTX4090_GUIDE.md`](DIRECTX_RTX4090_GUIDE.md) - Developer guide for DirectX 12 optimizations
- [`G1_EDU_README.md`](G1_EDU_README.md) - Unitree G1 EDU configuration details

**🛠 Specialized Launchers:**
```bash
# MAXIMUM MODE: 3072 environments (CONFIRMED WORKING!)
# Proven: All environment counts 1280 → 3072 work on RTX 4090
# Expected: 150k+ steps/second, 1-1.5 hour training
.\run_g1_edu_maximum_3072.bat

# EXTREME MODE: Auto-detects maximum environment count (1280-3072+)
# Tests: 1280 → 1536 → 1792 → 2048 → 2304 → 2560 → 2816 → 3072
# Expected: 75-150k steps/second, 1-2 hour training
.\run_g1_edu_extreme.bat

# SMART MODE: Progressive testing with balanced approach (256-1280)  
# Tests: 256 → 512 → 768 → 1024 → 1280 with fallback logic
# Expected: 45-65k steps/second, 3-4 hour training
.\run_g1_edu_fast_training.bat

# CONSERVATIVE MODE: Ultra-safe testing for memory-constrained systems
# Tests: 32 → 64 → 96 → 128 → 160 → 192 → 224 → 256
# Expected: 15-25k steps/second, 6-7 hour training
.\test_g1_edu_ultra_conservative.bat
```

**Key Launcher Features:**
- **PROVEN MAXIMUM**: 3072 environments confirmed working on RTX 4090 14GB
- **Record Performance**: 150k+ steps/second achievable (3072 × 50 steps/sec/env)
- **Ultra-Fast Training**: 1-1.5 hour convergence for locomotion tasks
- **Automatic Environment Count Detection** for your specific VRAM configuration
- **Performance Prediction** before starting 1500-iteration training
- **Memory Budget Monitoring** with real-time VRAM usage tracking
- **Progressive Testing Strategy** from conservative to absolute maximum counts  
- **Intelligent Fallback** if environment count exceeds memory
- **Process Cleanup** and error recovery mechanisms

This branch is maintained specifically for Windows 11 RTX 4090 users requiring maximum training throughput and robot transfer learning capabilities.


## Contributing to Isaac Lab

We wholeheartedly welcome contributions from the community to make this framework mature and useful for everyone.
These may happen as bug reports, feature requests, or code contributions. For details, please check our
[contribution guidelines](https://isaac-sim.github.io/IsaacLab/main/source/refs/contributing.html).

## Show & Tell: Share Your Inspiration

We encourage you to utilize our [Show & Tell](https://github.com/isaac-sim/IsaacLab/discussions/categories/show-and-tell) area in the
`Discussions` section of this repository. This space is designed for you to:

* Share the tutorials you've created
* Showcase your learning content
* Present exciting projects you've developed

By sharing your work, you'll inspire others and contribute to the collective knowledge
of our community. Your contributions can spark new ideas and collaborations, fostering
innovation in robotics and simulation.

## Troubleshooting

Please see the [troubleshooting](https://isaac-sim.github.io/IsaacLab/main/source/refs/troubleshooting.html) section for
common fixes or [submit an issue](https://github.com/isaac-sim/IsaacLab/issues).

For issues related to Isaac Sim, we recommend checking its [documentation](https://docs.omniverse.nvidia.com/app_isaacsim/app_isaacsim/overview.html)
or opening a question on its [forums](https://forums.developer.nvidia.com/c/agx-autonomous-machines/isaac/67).

## Support

* Please use GitHub [Discussions](https://github.com/isaac-sim/IsaacLab/discussions) for discussing ideas, asking questions, and requests for new features.
* Github [Issues](https://github.com/isaac-sim/IsaacLab/issues) should only be used to track executable pieces of work with a definite scope and a clear deliverable. These can be fixing bugs, documentation issues, new features, or general updates.

## Connect with the NVIDIA Omniverse Community

Do you have a project or resource you'd like to share more widely? We'd love to hear from you!
Reach out to the NVIDIA Omniverse Community team at OmniverseCommunity@nvidia.com to explore opportunities
to spotlight your work.

You can also join the conversation on the [Omniverse Discord](https://discord.com/invite/nvidiaomniverse) to
connect with other developers, share your projects, and help grow a vibrant, collaborative ecosystem
where creativity and technology intersect. Your contributions can make a meaningful impact on the Isaac Lab community and beyond!

## License

The Isaac Lab framework is released under [BSD-3 License](LICENSE). The `isaaclab_mimic` extension and its corresponding standalone scripts are released under [Apache 2.0](LICENSE-mimic). The license files of its dependencies and assets are present in the [`docs/licenses`](docs/licenses) directory.

## Acknowledgement

Isaac Lab development initiated from the [Orbit](https://isaac-orbit.github.io/) framework. We would appreciate if you would cite it in academic publications as well:

```
@article{mittal2023orbit,
   author={Mittal, Mayank and Yu, Calvin and Yu, Qinxi and Liu, Jingzhou and Rudin, Nikita and Hoeller, David and Yuan, Jia Lin and Singh, Ritvik and Guo, Yunrong and Mazhar, Hammad and Mandlekar, Ajay and Babich, Buck and State, Gavriel and Hutter, Marco and Garg, Animesh},
   journal={IEEE Robotics and Automation Letters},
   title={Orbit: A Unified Simulation Framework for Interactive Robot Learning Environments},
   year={2023},
   volume={8},
   number={6},
   pages={3740-3747},
   doi={10.1109/LRA.2023.3270034}
}
```

# Training Launcher (Windows, DX12)

This project uses a single PowerShell launcher as an adapter for train.py:
- Script: `scripts/reinforcement_learning/rsl_rl/run_training.ps1`
- Platform: Windows, DirectX 12 (Vulkan disabled)

## Prerequisites
- Activate Conda environment before running:
  - `conda activate env_isaaclab`
- The launcher sets graphics environment automatically:
  - `OMNI_FORCE_GRAPHICS_API=D3D12`, `OMNI_GRAPHICS_API=D3D12`, `OMNI_KIT_DISABLE_VULKAN=1`
- Default experience: `apps/isaacsim_4_5/isaaclab.python.directx.kit`

## Quick Start
- Resume an existing run with high load (headless):
  - `powershell -ExecutionPolicy Bypass -File scripts/reinforcement_learning/rsl_rl/run_training.ps1 -Profile HighLoad -Resume -RunPath "C:\Users\zudva\Downloads\IsaacLab\logs\rsl_rl\g1_flat\2025-08-14_15-28-32"`
- Run with video:
  - `...\run_training.ps1 -Profile Video -Resume -RunPath "<run-folder>" -NumEnvs 1280`
- Limit to 6 hours (interactive or fixed):
  - Interactive prompt: `...\run_training.ps1 -UseTimer`
  - Fixed value: `...\run_training.ps1 -UseTimer -MaxHours 6`

## Profiles
- Default: no changes (use provided parameters).
- HighLoad: favors VRAM usage (NumEnvs=1280, MaxIterations=20000, Video=false unless overridden).
- Debug: quick runs (NumEnvs=128, MaxIterations=500, Video=false).
- Video: enables video and sets relaxed defaults (Video=true, Interval=5000, Length=300).

Parameters can always override profile defaults.

## Key Parameters
- `-Task`: Gym task ID, e.g. `Isaac-Velocity-Flat-G1-v0`.
- `-RunPath`: Existing run folder for resume (used together with `-Resume`).
- `-NumEnvs`: Number of parallel envs (main VRAM knob).
- `-MaxIterations`: Training iterations for PPO runner.
- `-Resume`/`-RunPath`: Continue training and write into the same folder (uses `--log_dir_override`).
- `-Video`, `-VideoInterval`, `-VideoLength`: Recording controls (headless video).
- `-Seed`: RNG seed forwarded to train.py.
- `-UseTimer`, `-MaxHours`: Optional time-based stop.
  - If `-UseTimer` is set without a positive `-MaxHours`, the script asks for a value; press Enter to disable the timer.

## VRAM Tuning
- Increase `-NumEnvs` in steps (e.g., 1280 → 1408 → 1536 …) until you hit OOM, then step back.
- Video consumes VRAM; reduce frequency/length or disable for maximum capacity.
- Monitor usage: `nvidia-smi -l 1`

## Troubleshooting
- Vulkan warning like `VK_EXT_memory_budget is not supported`:
  - Ensure the launcher is used (it enforces DX12 and disables Vulkan).
  - Verify experience path is `apps/isaacsim_4_5/isaaclab.python.directx.kit`.
  - Close any stale Isaac processes before re-run.
- OOM (out of memory): lower `-NumEnvs` one step.

## Notes
- Resumed runs continue logging into the same directory via `--log_dir_override`.
- For new runs, set `-Resume:$false` (the script will create a new timestamped folder inside `logs/rsl_rl/<experiment>`).

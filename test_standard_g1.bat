@echo off
echo Quick test: Does standard G1 work?

REM DX12 setup
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin"
set "OMNI_FORCE_GRAPHICS_API=D3D12"
set "OMNI_GRAPHICS_API=D3D12"
set "OMNI_KIT_DISABLE_VULKAN=1"

echo Testing standard G1 with 512 environments...
isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-v0 --num_envs 512 --max_iterations 1 --seed 42 --headless

if %ERRORLEVEL% EQU 0 (
    echo Standard G1 works! Problem is with G1 EDU configuration.
) else (
    echo Standard G1 also fails. System memory issue.
)

pause

@echo off
setlocal enableextensions enabledelayedexpansion

echo ========================================
echo     G1 EDU Training - Simple DX12
echo ========================================
echo Task: Isaac-Velocity-Flat-G1-EDU-v0
echo Target: 1024 environments (safe for 14GB)
echo Iterations: 1500
echo Mode: GUI + DX12 forced
echo ========================================

REM Standard DX12 setup (проверенный метод)
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin;omni.kit.renderer.core.plugin.vulkan;omni.render.rtx.plugin.vulkan;omni.gpu_foundation_factory.plugin.vulkan"
set OMNI_KIT_FORCE_RENDER_API=dx12
set OMNI_KIT_DISABLE_VULKAN=1
set CARB_ENABLE_VULKAN=0
set OMNI_RENDER_DISABLE_PLUGINS=omni.render.rtx.plugin.vulkan

echo DX12 forced, Vulkan disabled ✓
echo.
echo Launching Isaac Lab with G1 EDU...
echo Please wait for Isaac Sim to load (1-2 minutes)...
echo.

REM Standard launch command
isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs 1024 --max_iterations 1500 --seed 42

if errorlevel 1 (
    echo.
    echo ERROR: G1 EDU failed. Trying standard G1...
    echo.
    isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-v0 --num_envs 1024 --max_iterations 100 --seed 42
)

echo.
echo Training completed.
pause
endlocal

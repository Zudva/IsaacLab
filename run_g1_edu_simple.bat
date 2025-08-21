@echo off
setlocal enableextensions enabledelayedexpansion

REM Simple G1 EDU launcher without complex probing
set CONDA_ENV=env_isaaclab
set TASK=Isaac-Velocity-Flat-G1-EDU-v0
set NUM_ENVS=1024
set MAX_ITERS=1500
set SEED=42

echo ===== G1 EDU Training Launcher =====
echo Task: %TASK%
echo Environments: %NUM_ENVS%
echo Max Iterations: %MAX_ITERS%
echo =====================================

call conda activate %CONDA_ENV%
if errorlevel 1 (
    echo ERROR: Failed to activate conda environment %CONDA_ENV%
    pause
    exit /b 1
)

REM Force DX12 / disable Vulkan
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin;omni.kit.renderer.core.plugin.vulkan;omni.render.rtx.plugin.vulkan;omni.gpu_foundation_factory.plugin.vulkan"
set OMNI_KIT_FORCE_RENDER_API=dx12
set OMNI_KIT_DISABLE_VULKAN=1
set CARB_ENABLE_VULKAN=0
set OMNI_RENDER_DISABLE_PLUGINS=omni.render.rtx.plugin.vulkan
echo DX12 forced, Vulkan disabled

echo.
echo Starting G1 EDU training with GUI...
echo.

REM Launch training with GUI
isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task %TASK% --num_envs %NUM_ENVS% --max_iterations %MAX_ITERS% --seed %SEED%

echo.
echo Training completed.
pause
endlocal

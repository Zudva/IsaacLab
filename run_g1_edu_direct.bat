@echo off
setlocal enableextensions enabledelayedexpansion

echo ===== G1 EDU Training - Direct Launch =====
echo Task: Isaac-Velocity-Flat-G1-EDU-v0
echo Environments: 1024 (safe for 14GB)
echo Max Iterations: 1500
echo Mode: GUI (with rendering)
echo ==========================================

REM Force DX12 / disable Vulkan
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin;omni.kit.renderer.core.plugin.vulkan;omni.render.rtx.plugin.vulkan;omni.gpu_foundation_factory.plugin.vulkan"
set OMNI_KIT_FORCE_RENDER_API=dx12
set OMNI_KIT_DISABLE_VULKAN=1
set CARB_ENABLE_VULKAN=0
set OMNI_RENDER_DISABLE_PLUGINS=omni.render.rtx.plugin.vulkan
echo DX12 forced, Vulkan disabled

echo.
echo Starting G1 EDU training with GUI...
echo Please wait - Isaac Sim is loading...
echo.

REM Launch training directly with GUI
isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs 1024 --max_iterations 1500 --seed 42

echo.
echo Training completed.
pause
endlocal

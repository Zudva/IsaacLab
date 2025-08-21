@echo off
echo Testing standard G1 (not EDU) to check if Isaac Lab works...

REM Force DX12 / disable Vulkan
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin;omni.kit.renderer.core.plugin.vulkan;omni.render.rtx.plugin.vulkan;omni.gpu_foundation_factory.plugin.vulkan"
set OMNI_KIT_FORCE_RENDER_API=dx12
set OMNI_KIT_DISABLE_VULKAN=1
set CARB_ENABLE_VULKAN=0
set OMNI_RENDER_DISABLE_PLUGINS=omni.render.rtx.plugin.vulkan

echo Starting standard G1 task for testing...
isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-v0 --num_envs 512 --max_iterations 10 --seed 42

pause

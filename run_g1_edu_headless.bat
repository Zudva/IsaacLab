@echo off
setlocal enableextensions enabledelayedexpansion

echo =======================================
echo G1 EDU Headless Training (No GUI)
echo =======================================
echo Environment count: 128 (conservative)
echo Iterations: 200 (medium test)
echo Mode: Headless (no visual interface)
echo =======================================

REM DX12 setup for headless
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin"
set "OMNI_FORCE_GRAPHICS_API=D3D12"
set "OMNI_GRAPHICS_API=D3D12"
set "OMNI_KIT_DISABLE_VULKAN=1"
set "OMNI_KIT_DISABLE_CRASH_REPORTER=1"
set "OMNI_KIT_DISABLE_HANG_REPORTER=1"
set "HYDRA_FULL_ERROR=1"

echo DX12 configured for headless mode ✓
echo Starting G1 EDU training without GUI...
echo.

REM Direct headless training - no GUI, more stable
isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs 128 --max_iterations 200 --seed 42 --headless

if %ERRORLEVEL% EQU 0 (
    echo.
    echo =======================================
    echo G1 EDU Headless Training SUCCESS! ✅
    echo.
    echo Benefits of headless mode:
    echo - Stable training without GUI issues
    echo - Lower VRAM usage
    echo - Better performance
    echo - Can run in background
    echo.
    echo Check logs\rsl_rl\g1_flat\ for results
    echo =======================================
) else (
    echo.
    echo =======================================
    echo Training failed even in headless mode ❌
    echo.
    echo Trying with even smaller environment count...
    echo.
    
    isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs 64 --max_iterations 50 --seed 42 --headless
    
    if %ERRORLEVEL% EQU 0 (
        echo 64 environments works in headless mode
    ) else (
        echo System has fundamental issues - check VRAM/memory
    )
    echo =======================================
)

pause
endlocal

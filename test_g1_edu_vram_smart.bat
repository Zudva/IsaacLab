@echo off
setlocal enableextensions enabledelayedexpansion

echo =======================================
echo G1 EDU VRAM Analysis and Safe Launch
echo =======================================

REM DX12 setup
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin"
set "OMNI_FORCE_GRAPHICS_API=D3D12"
set "OMNI_GRAPHICS_API=D3D12"
set "OMNI_KIT_DISABLE_VULKAN=1"
set "OMNI_KIT_DISABLE_CRASH_REPORTER=1"
set "OMNI_KIT_DISABLE_HANG_REPORTER=1"

echo Checking current VRAM usage...
for /f "tokens=1" %%A in ('powershell -NoLogo -NoProfile -Command "(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)[0]"') do set CURRENT_VRAM=%%A
for /f "tokens=1" %%B in ('powershell -NoLogo -NoProfile -Command "(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits)[0]"') do set TOTAL_VRAM=%%B

set /a FREE_VRAM=TOTAL_VRAM-CURRENT_VRAM
set /a TARGET_USAGE=FREE_VRAM-2048

echo VRAM Status:
echo - Total VRAM: %TOTAL_VRAM%MB
echo - Current usage: %CURRENT_VRAM%MB  
echo - Free VRAM: %FREE_VRAM%MB
echo - Target usage: %TARGET_USAGE%MB (with 2GB safety buffer)
echo.

if %TARGET_USAGE% LSS 4096 (
    echo WARNING: Less than 4GB available for training
    echo Recommended: Close other GPU applications
    set "SAFE_ENVS=32"
) else if %TARGET_USAGE% LSS 8192 (
    echo MODERATE: 4-8GB available 
    set "SAFE_ENVS=64"
) else if %TARGET_USAGE% LSS 12288 (
    echo GOOD: 8-12GB available
    set "SAFE_ENVS=128"
) else (
    echo EXCELLENT: 12GB+ available
    set "SAFE_ENVS=256"
)

echo.
echo Recommended safe environment count: %SAFE_ENVS%
echo Testing G1 EDU with %SAFE_ENVS% environments...
echo.

isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs %SAFE_ENVS% --max_iterations 50 --seed 42

if %ERRORLEVEL% EQU 0 (
    echo.
    echo SUCCESS! G1 EDU works with %SAFE_ENVS% environments.
    echo Ready for longer training runs.
) else (
    echo.
    echo FAILED even with conservative settings.
    echo Try closing other applications and running again.
)

pause
endlocal

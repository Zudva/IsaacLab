@echo off
setlocal enableextensions enabledelayedexpansion

echo =========================================
echo G1 EDU Full Training - Working Config
echo =========================================

REM DX12 setup - proven working
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin"
set "OMNI_FORCE_GRAPHICS_API=D3D12"
set "OMNI_GRAPHICS_API=D3D12"
set "OMNI_KIT_DISABLE_VULKAN=1"
set "OMNI_KIT_DISABLE_CRASH_REPORTER=1"
set "OMNI_KIT_DISABLE_HANG_REPORTER=1"
set "HYDRA_FULL_ERROR=1"

echo G1 EDU is working! Finding optimal environment count for 14GB...
echo.

REM Test progressively larger environment counts
for %%N in (128 256 384 512 640 768 896 1024) do (
    echo Testing %%N environments...
    
    isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs %%N --max_iterations 2 --seed 42 --headless
    
    if !ERRORLEVEL! EQU 0 (
        echo SUCCESS with %%N environments!
        set "MAX_WORKING=%%N"
    ) else (
        echo FAILED with %%N environments - memory limit reached.
        goto :START_TRAINING
    )
    
    REM Clean up
    taskkill /f /im "python.exe" >nul 2>&1
    timeout /t 3 >nul
)

:START_TRAINING
if not defined MAX_WORKING set "MAX_WORKING=64"

echo.
echo ============================================
echo Starting G1 EDU Training
echo Environment count: !MAX_WORKING!
echo Iterations: 1500
echo Mode: GUI (remove --headless for visualization)
echo ============================================
echo.

REM Full training run - remove --headless to see GUI
isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs !MAX_WORKING! --max_iterations 1500 --seed 42

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo G1 EDU Training completed successfully!
    echo Check logs\rsl_rl\g1_flat\ for results
    echo ============================================
) else (
    echo.
    echo Training failed. Check error messages above.
)

pause
endlocal

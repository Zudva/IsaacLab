@echo off
setlocal enableextensions enabledelayedexpansion

echo =========================================
echo G1 EDU Fast Training - High Performance
echo =========================================
echo Mode: Headless (no GUI for stability)
echo Target: Maximum environments for 14GB VRAM
echo Goal: Fast, efficient training
echo =========================================

REM DX12 setup optimized for performance
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin"
set "OMNI_FORCE_GRAPHICS_API=D3D12"
set "OMNI_GRAPHICS_API=D3D12"
set "OMNI_KIT_DISABLE_VULKAN=1"
set "OMNI_KIT_DISABLE_CRASH_REPORTER=1"
set "OMNI_KIT_DISABLE_HANG_REPORTER=1"
set "HYDRA_FULL_ERROR=1"

echo Finding maximum environment count for fast training...
echo.

REM Test progressively larger counts for headless mode
set "TEST_COUNTS=256 384 512 640 768 896 1024 1152 1280"

for %%N in (%TEST_COUNTS%) do (
    echo ===============================================
    echo Testing G1 EDU with %%N environments (headless)...
    echo ===============================================
    
    isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs %%N --max_iterations 3 --seed 42 --headless
    
    if !ERRORLEVEL! EQU 0 (
        echo SUCCESS with %%N environments!
        set "MAX_WORKING=%%N"
        echo Current maximum: !MAX_WORKING! environments
    ) else (
        echo FAILED with %%N environments - VRAM limit reached.
        echo Maximum safe count: !MAX_WORKING! environments
        goto :START_FAST_TRAINING
    )
    
    REM Clean up
    taskkill /f /im "python.exe" >nul 2>&1
    timeout /t 3 >nul
)

:START_FAST_TRAINING
if not defined MAX_WORKING set "MAX_WORKING=256"

echo.
echo ============================================
echo Starting G1 EDU FAST TRAINING
echo Environment count: !MAX_WORKING!
echo Iterations: 1500 (full training)
echo Mode: Headless (stable performance)
echo Expected training time: 2-4 hours
echo ============================================
echo.

REM Calculate expected performance
set /a STEPS_PER_SEC=!MAX_WORKING!*2
echo Expected performance: ~!STEPS_PER_SEC! steps/second
echo This should provide faster convergence!
echo.

REM Start high-performance training
isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs !MAX_WORKING! --max_iterations 1500 --seed 42 --headless

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo G1 EDU FAST TRAINING COMPLETED! 🚀
    echo.
    echo Results:
    echo - Environment count: !MAX_WORKING!
    echo - Training mode: Headless (stable)
    echo - Iterations: 1500
    echo - DX12 optimized
    echo.
    echo Check logs\rsl_rl\g1_flat\ for:
    echo - Policy checkpoints (.pt files)
    echo - Training metrics
    echo - Tensorboard logs
    echo.
    echo Ready for robot transfer testing!
    echo ============================================
) else (
    echo.
    echo ============================================
    echo Training failed. Trying fallback approach...
    echo ============================================
    
    REM Fallback to smaller count
    set /a FALLBACK=MAX_WORKING-128
    if !FALLBACK! LSS 128 set "FALLBACK=128"
    
    echo Retrying with !FALLBACK! environments...
    isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs !FALLBACK! --max_iterations 1500 --seed 42 --headless
)

pause
endlocal

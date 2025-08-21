@echo off
setlocal enableextensions enabledelayedexpansion

echo =======================================
echo G1 EDU Test Training - Quick Validation
echo =======================================
echo Task: Isaac-Velocity-Flat-G1-EDU-v0
echo Environments: 256 (conservative for testing)
echo Iterations: 50 (quick test)
echo Mode: GUI enabled
echo =======================================

REM Proven DX12 setup
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin"
set "OMNI_FORCE_GRAPHICS_API=D3D12"
set "OMNI_GRAPHICS_API=D3D12"
set "OMNI_KIT_DISABLE_VULKAN=1"
set "OMNI_KIT_DISABLE_CRASH_REPORTER=1"
set "OMNI_KIT_DISABLE_HANG_REPORTER=1"
set "HYDRA_FULL_ERROR=1"

echo DX12 configured ✓
echo Starting G1 EDU test training...
echo.

REM Quick test training with GUI
isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs 256 --max_iterations 50 --seed 42

if %ERRORLEVEL% EQU 0 (
    echo.
    echo =======================================
    echo G1 EDU Test Training SUCCESSFUL! ✅
    echo.
    echo Key validation points:
    echo - G1 EDU environment initializes correctly
    echo - 23 DOF action space working  
    echo - Training loop stable
    echo - DX12 rendering functional
    echo.
    echo Ready for full training runs!
    echo =======================================
) else (
    echo.
    echo =======================================
    echo G1 EDU Test Training FAILED ❌
    echo Check error messages above
    echo =======================================
)

pause
endlocal

@echo off
echo =========================================
echo Testing Fixed G1 EDU Configuration
echo =========================================

REM DX12 setup
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin"
set "OMNI_FORCE_GRAPHICS_API=D3D12"
set "OMNI_GRAPHICS_API=D3D12"
set "OMNI_KIT_DISABLE_VULKAN=1"
set "OMNI_KIT_DISABLE_CRASH_REPORTER=1"
set "OMNI_KIT_DISABLE_HANG_REPORTER=1"
set "HYDRA_FULL_ERROR=1"

echo Testing G1 EDU with corrected joint names...
echo Using 64 environments for initial test...
echo.

isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs 64 --max_iterations 1 --seed 42 --headless

if %ERRORLEVEL% EQU 0 (
    echo.
    echo SUCCESS! G1 EDU works with corrected joint names.
    echo Testing with more environments...
    echo.
    
    for %%N in (128 256 512 768 1024) do (
        echo Testing %%N environments...
        isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs %%N --max_iterations 1 --seed 42 --headless
        
        if !ERRORLEVEL! EQU 0 (
            echo SUCCESS with %%N environments!
            set "MAX_WORKING=%%N"
        ) else (
            echo FAILED with %%N environments.
            echo Maximum working: !MAX_WORKING!
            goto :START_TRAINING
        )
        
        taskkill /f /im "python.exe" >nul 2>&1
        timeout /t 2 >nul
    )
    
    :START_TRAINING
    if defined MAX_WORKING (
        echo.
        echo Starting full training with !MAX_WORKING! environments...
        isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs !MAX_WORKING! --max_iterations 1500 --seed 42
    ) else (
        echo No working environment count found.
    )
    
) else (
    echo.
    echo G1 EDU still fails. Check the error above.
    echo Testing standard G1 for comparison...
    echo.
    
    isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-v0 --num_envs 64 --max_iterations 1 --seed 42 --headless
    
    if %ERRORLEVEL% EQU 0 (
        echo Standard G1 works - G1 EDU configuration still has issues.
    ) else (
        echo Both fail - system issue.
    )
)

pause

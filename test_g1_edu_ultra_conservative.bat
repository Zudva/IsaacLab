@echo off
setlocal enableextensions enabledelayedexpansion

echo =======================================
echo G1 EDU Ultra Conservative Test
echo =======================================
echo Starting with VERY small environment count
echo Target: 14GB VRAM (conservative approach)
echo =======================================

REM DX12 setup
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin"
set "OMNI_FORCE_GRAPHICS_API=D3D12"
set "OMNI_GRAPHICS_API=D3D12"
set "OMNI_KIT_DISABLE_VULKAN=1"
set "OMNI_KIT_DISABLE_CRASH_REPORTER=1"
set "OMNI_KIT_DISABLE_HANG_REPORTER=1"
set "HYDRA_FULL_ERROR=1"

echo Testing ultra-small environment counts for 14GB...
echo.

REM Start with very small counts
for %%N in (32 64 96 128 160 192 224 256) do (
    echo ===============================================
    echo Testing G1 EDU with %%N environments...
    echo ===============================================
    
    isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs %%N --max_iterations 2 --seed 42 --headless
    
    if !ERRORLEVEL! EQU 0 (
        echo SUCCESS with %%N environments!
        set "LAST_WORKING=%%N"
    ) else (
        echo FAILED with %%N environments - too much for 14GB VRAM.
        if defined LAST_WORKING (
            echo Maximum safe count for 14GB: !LAST_WORKING!
            goto :START_TRAINING
        ) else (
            echo Even %%N is too much. System may have memory issues.
            goto :TEST_STANDARD
        )
    )
    
    REM Clean up
    taskkill /f /im "python.exe" >nul 2>&1
    timeout /t 3 >nul
)

:START_TRAINING
echo.
echo ============================================
echo Starting safe training with !LAST_WORKING! environments
echo Iterations: 100 (longer test)
echo ============================================
echo.

isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs !LAST_WORKING! --max_iterations 100 --seed 42 --headless

goto :END

:TEST_STANDARD
echo.
echo Testing if standard G1 works better...
echo.

isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-v0 --num_envs 64 --max_iterations 2 --seed 42 --headless

if %ERRORLEVEL% EQU 0 (
    echo Standard G1 works - issue is with G1 EDU memory usage.
) else (
    echo Both fail - system memory configuration issue.
)

:END
echo.
echo Analysis complete.
pause
endlocal

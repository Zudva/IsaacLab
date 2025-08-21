@echo off
setlocal enableextensions enabledelayedexpansion

echo =========================================
echo G1 EDU Memory Budget Debug
echo =========================================

REM DX12 setup
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin"
set "OMNI_FORCE_GRAPHICS_API=D3D12"
set "OMNI_GRAPHICS_API=D3D12"
set "OMNI_KIT_DISABLE_VULKAN=1"
set "OMNI_KIT_DISABLE_CRASH_REPORTER=1"
set "OMNI_KIT_DISABLE_HANG_REPORTER=1"

echo Testing G1 EDU with minimal environments...
echo.

REM Test very small environment counts
set "TEST_COUNTS=16 32 64 128 256"

for %%N in (%TEST_COUNTS%) do (
    echo ===============================================
    echo Testing G1 EDU with %%N environments...
    echo ===============================================
    
    isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs %%N --max_iterations 1 --seed 42 --headless
    
    if !ERRORLEVEL! EQU 0 (
        echo SUCCESS with %%N environments!
        echo G1 EDU works, memory issue is quantity-related.
        goto :FOUND_WORKING
    ) else (
        echo FAILED with %%N environments.
        taskkill /f /im "python.exe" >nul 2>&1
        timeout /t 2 >nul
    )
)

echo.
echo G1 EDU failed even with minimal environments.
echo Testing standard G1 for comparison...
echo.

isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-v0 --num_envs 64 --max_iterations 1 --seed 42 --headless

if !ERRORLEVEL! EQU 0 (
    echo Standard G1 works - problem is with G1 EDU configuration.
) else (
    echo Both G1 and G1 EDU fail - system issue.
)

goto :END

:FOUND_WORKING
echo.
echo Found working environment count. Testing larger counts...
echo.

REM Now test larger counts starting from what worked
if %%N==16 set "NEXT_COUNTS=32 64 128 256 384 512"
if %%N==32 set "NEXT_COUNTS=64 128 256 384 512 640"
if %%N==64 set "NEXT_COUNTS=128 256 384 512 640 768"
if %%N==128 set "NEXT_COUNTS=256 384 512 640 768 896"
if %%N==256 set "NEXT_COUNTS=384 512 640 768 896 1024"

for %%M in (!NEXT_COUNTS!) do (
    echo Testing %%M environments...
    isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs %%M --max_iterations 1 --seed 42 --headless
    
    if !ERRORLEVEL! EQU 0 (
        echo SUCCESS with %%M environments!
        set "MAX_WORKING=%%M"
    ) else (
        echo FAILED with %%M environments.
        echo Maximum working count: !MAX_WORKING!
        goto :START_TRAINING
    )
    
    taskkill /f /im "python.exe" >nul 2>&1
    timeout /t 2 >nul
)

:START_TRAINING
echo.
echo Starting full training with !MAX_WORKING! environments...
echo.

isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs !MAX_WORKING! --max_iterations 1500 --seed 42

:END
pause
endlocal

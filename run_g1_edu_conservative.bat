@echo off
setlocal enableextensions enabledelayedexpansion

echo =========================================
echo G1 EDU Training - Conservative 14GB
echo =========================================
echo Task: Isaac-Velocity-Flat-G1-EDU-v0
echo Conservative environments for 14GB VRAM
echo Mode: DirectX 12 Forced
echo =========================================

REM Proven DX12 setup from successful commit 535a6c95
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin"
set "OMNI_FORCE_GRAPHICS_API=D3D12"
set "OMNI_GRAPHICS_API=D3D12"
set "OMNI_KIT_DISABLE_VULKAN=1"

REM Additional stability settings
set "OMNI_KIT_DISABLE_CRASH_REPORTER=1"
set "OMNI_KIT_DISABLE_HANG_REPORTER=1"
set "HYDRA_FULL_ERROR=1"

echo DX12 configured with proven settings ✓

REM Use DirectX kit specifically for DX12
set "DX12_KIT=%~dp0apps\isaacsim_4_5\isaaclab.python.directx.kit"
set "GUI_KIT=%~dp0apps\isaacsim_4_5\isaaclab.python.kit"
set "HEADLESS_KIT=%~dp0apps\isaacsim_4_5\isaaclab.python.headless.kit"

if exist "%DX12_KIT%" (
    echo DirectX kit found: %DX12_KIT%
    set "SELECTED_KIT=%DX12_KIT%"
) else if exist "%GUI_KIT%" (
    echo GUI kit found: %GUI_KIT%
    set "SELECTED_KIT=%GUI_KIT%"
) else if exist "%HEADLESS_KIT%" (
    echo Headless kit found: %HEADLESS_KIT%
    set "SELECTED_KIT=%HEADLESS_KIT%"
    set "USE_HEADLESS=1"
) else (
    echo No experience kit found, using default
    set "SELECTED_KIT="
)

echo.
echo Conservative environment count calculation for G1 EDU (23 DOF):
echo Standard G1 (37 DOF): ~896 envs worked at 16GB
echo G1 EDU (23 DOF): Should use less VRAM per env
echo Target: 14GB (2GB less than 16GB)
echo.

REM Try different environment counts, starting conservative
set "ENV_COUNTS=512 640 768 896 1024"

for %%N in (%ENV_COUNTS%) do (
    echo ===============================================
    echo Testing %%N environments...
    echo ===============================================
    
    if defined USE_HEADLESS (
        set "CMD_ARGS=--headless"
    ) else (
        set "CMD_ARGS="
    )
    
    if defined SELECTED_KIT (
        isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs %%N --max_iterations 10 --seed 42 !CMD_ARGS! --experience "%SELECTED_KIT%"
    ) else (
        isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs %%N --max_iterations 10 --seed 42 !CMD_ARGS!
    )
    
    if !ERRORLEVEL! EQU 0 (
        echo.
        echo SUCCESS with %%N environments!
        echo Starting full training...
        echo.
        
        if defined SELECTED_KIT (
            isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs %%N --max_iterations 1500 --seed 42 !CMD_ARGS! --experience "%SELECTED_KIT%"
        ) else (
            isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs %%N --max_iterations 1500 --seed 42 !CMD_ARGS!
        )
        goto :SUCCESS
    ) else (
        echo.
        echo FAILED with %%N environments, trying next...
        echo.
        
        REM Clean up processes
        taskkill /f /im "python.exe" >nul 2>&1
        timeout /t 3 >nul
    )
)

echo.
echo All environment counts failed. Trying standard G1 for comparison...
echo.

if defined SELECTED_KIT (
    isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-v0 --num_envs 512 --max_iterations 100 --seed 42 !CMD_ARGS! --experience "%SELECTED_KIT%"
) else (
    isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-v0 --num_envs 512 --max_iterations 100 --seed 42 !CMD_ARGS!
)

:SUCCESS
echo.
echo Training process completed.
pause
endlocal

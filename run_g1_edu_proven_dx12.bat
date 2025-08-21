@echo off
setlocal enableextensions enabledelayedexpansion

echo ========================================
echo G1 EDU Training - Proven DX12 Setup
echo ========================================
echo Task: Isaac-Velocity-Flat-G1-EDU-v0
echo Environments: 1024 (safe for 14GB)
echo Iterations: 1500
echo Mode: GUI (we'll try headless if GUI fails)
echo ========================================

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

REM Auto-select experience kit - GUI version for GUI mode
set "GUI_EXPERIENCE=%~dp0apps\isaacsim_4_5\isaaclab.python.kit"
if not exist "%GUI_EXPERIENCE%" set "GUI_EXPERIENCE=%~dp0apps\isaaclab.python.kit"
if not exist "%GUI_EXPERIENCE%" set "GUI_EXPERIENCE=%~dp0apps\isaacsim_4_5\isaaclab.python.rendering.kit"

REM Headless version for headless mode
set "HEADLESS_EXPERIENCE=%~dp0apps\isaacsim_4_5\isaaclab.python.headless.kit"
if not exist "%HEADLESS_EXPERIENCE%" set "HEADLESS_EXPERIENCE=%~dp0apps\isaaclab.python.headless.kit"
if not exist "%HEADLESS_EXPERIENCE%" set "HEADLESS_EXPERIENCE=%~dp0apps\isaacsim_4_5\isaaclab.python.headless.rendering.kit"

if exist "%GUI_EXPERIENCE%" (
    echo GUI Experience kit found: %GUI_EXPERIENCE%
) else (
    echo No GUI experience kit found
)

if exist "%HEADLESS_EXPERIENCE%" (
    echo Headless Experience kit found: %HEADLESS_EXPERIENCE%
) else (
    echo No headless experience kit found
)

echo.
echo Attempting G1 EDU with GUI...
echo.

REM Try G1 EDU with GUI first using GUI experience kit
if exist "%GUI_EXPERIENCE%" (
    isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs 1024 --max_iterations 1500 --seed 42 --experience "%GUI_EXPERIENCE%"
) else (
    isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs 1024 --max_iterations 1500 --seed 42
)

if errorlevel 1 (
    echo.
    echo G1 EDU failed. Trying headless mode...
    echo.
    if exist "%HEADLESS_EXPERIENCE%" (
        isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs 1024 --max_iterations 1500 --seed 42 --headless --experience "%HEADLESS_EXPERIENCE%"
    ) else (
        isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-EDU-v0 --num_envs 1024 --max_iterations 1500 --seed 42 --headless
    )
    
    if errorlevel 1 (
        echo.
        echo G1 EDU still failing. Trying standard G1 for comparison...
        echo.
        if exist "%GUI_EXPERIENCE%" (
            isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-v0 --num_envs 1024 --max_iterations 100 --seed 42 --experience "%GUI_EXPERIENCE%"
        ) else (
            isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task Isaac-Velocity-Flat-G1-v0 --num_envs 1024 --max_iterations 100 --seed 42
        )
    )
)

echo.
echo Training completed.
pause
endlocal

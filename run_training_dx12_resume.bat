@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ===== User config =====
set "CONDA_ENV=env_isaaclab"
set "TASK=Isaac-Velocity-Flat-G1-v0"
set "NUM_ENVS=1280"
set "MAX_ITERS=20000"
set "SEED=42"
set "RUN_PATH=C:\Users\zudva\Downloads\IsaacLab\logs\rsl_rl\g1_flat\2025-08-14_15-28-32"
set "VIDEO=0"
set "VIDEO_INTERVAL=5000"
set "VIDEO_LENGTH=300"
rem ========================

rem Resolve workspace (folder of this script)
set "WORKSPACE=%~dp0"
for %%A in ("%WORKSPACE%.") do set "WORKSPACE=%%~fA"
pushd "%WORKSPACE%" >nul 2>&1

rem Force DX12, disable Vulkan entirely
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin"
set "OMNI_FORCE_GRAPHICS_API=D3D12"
set "OMNI_GRAPHICS_API=D3D12"
set "OMNI_KIT_DISABLE_VULKAN=1"

rem PYTHONPATH
if defined PYTHONPATH (
  set "PYTHONPATH=%WORKSPACE%\source;%PYTHONPATH%"
) else (
  set "PYTHONPATH=%WORKSPACE%\source"
)

rem Activate conda if available
set "CONDA_BAT=%USERPROFILE%\miniconda3\condabin\conda.bat"
if not exist "%CONDA_BAT%" set "CONDA_BAT=%USERPROFILE%\anaconda3\condabin\conda.bat"
if not exist "%CONDA_BAT%" set "CONDA_BAT=C:\ProgramData\Miniconda3\condabin\conda.bat"
if not exist "%CONDA_BAT%" set "CONDA_BAT=C:\ProgramData\Anaconda3\condabin\conda.bat"
if exist "%CONDA_BAT%" (
  call "%CONDA_BAT%" activate "%CONDA_ENV%"
) else (
  echo [WARN] conda.bat not found. Continuing without activation.
)

rem Validate run path
if not exist "%RUN_PATH%" (
  echo [ERROR] RunPath not found: %RUN_PATH%
  popd & exit /b 1
)
for %%I in ("%RUN_PATH%") do set "RUN_NAME=%%~nxI"

rem Experience kit for DirectX
set "EXPERIENCE=%WORKSPACE%\apps\isaacsim_4_5\isaaclab.python.directx.kit"

rem Build args
set "ARGS=-p scripts\reinforcement_learning\rsl_rl\train.py --task %TASK% --num_envs %NUM_ENVS% --max_iterations %MAX_ITERS% --headless --seed %SEED% --experience ^"%EXPERIENCE%^" --resume --load_run %RUN_NAME% --log_dir_override ^"%RUN_PATH%^""
if "%VIDEO%"=="1" set "ARGS=%ARGS% --video --video_interval %VIDEO_INTERVAL% --video_length %VIDEO_LENGTH%"

echo Launching training...
echo isaaclab.bat %ARGS%
call "%WORKSPACE%\isaaclab.bat" %ARGS%
set "CODE=%ERRORLEVEL%"

popd
exit /b %CODE%

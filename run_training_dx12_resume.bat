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
rem Auto-size NumEnvs to saturate VRAM (1=on, 0=off)
set "AUTO_NUM_ENVS=1"
set "TARGET_VRAM_GB=16"
set "PROBE_NUM_ENVS=512"
set "PROBE_WAIT_SEC=45"
set "SAFETY_MB=1024"
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

rem When resuming, keep the original env count. Disable auto sizing to avoid mismatch.
if "%AUTO_NUM_ENVS%"=="1" (
  echo [INFO] Resume detected for %%RUN_NAME%%. Disabling AUTO_NUM_ENVS to keep env count compatible with existing run.
  set "AUTO_NUM_ENVS=0"
)

rem Experience kit for DirectX
set "EXPERIENCE=%WORKSPACE%\apps\isaacsim_4_5\isaaclab.python.directx.kit"

rem Optional: auto-compute NUM_ENVS to match target VRAM using a short probe
if "%AUTO_NUM_ENVS%"=="1" (
  set "PS_WS=%WORKSPACE%"
  set "PS_BAT=%WORKSPACE%\isaaclab.bat"
  set "PS_TRAIN=scripts\reinforcement_learning\rsl_rl\train.py"
  set "PS_EXP=%EXPERIENCE%"
  for /f "usebackq delims=" %%N in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; function Get-GpuMemMB { try { $v = & nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits 2>$null; if (-not $v) { return $null }; ($v -split '\r?\n')[0].Trim() } catch { return $null } }; $base=[int](Get-GpuMemMB); if($null -eq $base){ Write-Output -1; exit 0 }; $probe=[int]$env:PROBE_NUM_ENVS; $seed=[int]$env:SEED; $p=Start-Process -FilePath $env:PS_BAT -WorkingDirectory $env:PS_WS -ArgumentList @('-p',$env:PS_TRAIN,'--task',$env:TASK,'--num_envs',$probe,'--max_iterations','1','--headless','--seed',$seed,'--experience',$env:PS_EXP) -PassThru; Start-Sleep -Seconds ([int]$env:PROBE_WAIT_SEC); $peak=[int](Get-GpuMemMB); if(-not $peak){ $peak=$base }; try{ if(-not $p.HasExited){ Stop-Process -Id $p.Id -Force } } catch {}; $per=[math]::Max([math]::Round( ($peak-$base) / [double][math]::Max($probe,1) ),1); $target=([int]$env:TARGET_VRAM_GB)*1024; $safety=[int]$env:SAFETY_MB; $calc=[math]::Floor( ($target-$base-$safety)/[double][math]::Max($per,1) ); if($calc -lt 1){$calc=1}; Write-Output $calc"` ) do set "NUM_ENVS=%%N"
  if not defined NUM_ENVS (
    echo [WARN] AutoNumEnvs failed. Keeping preset NUM_ENVS.
  ) else if "%NUM_ENVS%"=="-1" (
    echo [WARN] AutoNumEnvs: nvidia-smi unavailable. Keeping preset NUM_ENVS.
  ) else (
    echo [INFO] AutoNumEnvs computed NUM_ENVS=%NUM_ENVS% for target %TARGET_VRAM_GB%GB (probe=%PROBE_NUM_ENVS%, wait=%PROBE_WAIT_SEC%s)
  )
)

rem Build args
set "ARGS=-p scripts\reinforcement_learning\rsl_rl\train.py --task %TASK% --num_envs %NUM_ENVS% --max_iterations %MAX_ITERS% --headless --seed %SEED% --experience ^"%EXPERIENCE%^" --resume --load_run %RUN_NAME% --log_dir_override ^"%RUN_PATH%^""
if "%VIDEO%"=="1" set "ARGS=%ARGS% --video --video_interval %VIDEO_INTERVAL% --video_length %VIDEO_LENGTH%"

echo [INFO] FINAL NUM_ENVS=%NUM_ENVS%
echo Launching training...
echo isaaclab.bat %ARGS%
call "%WORKSPACE%\isaaclab.bat" %ARGS%
set "CODE=%ERRORLEVEL%"

popd
exit /b %CODE%

@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ===== User config =====
set "CONDA_ENV=env_isaaclab"
set "TASK=Isaac-Velocity-Flat-G1-v0"
set "NUM_ENVS=3136"
set "MAX_ITERS=20000"
set "SEED=42"
set "RUN_PATH=C:\Users\zudva\Downloads\IsaacLab\logs\rsl_rl\g1_flat\2025-08-14_15-28-32"
set "VIDEO=0"
set "VIDEO_INTERVAL=5000"
set "VIDEO_LENGTH=300"
rem Auto-size NumEnvs to saturate VRAM (1=on, 0=off)
set "AUTO_NUM_ENVS=0"
set "TARGET_VRAM_GB=14"
set "PROBE_NUM_ENVS=512"
set "PROBE_WAIT_SEC=45"
set "SAFETY_MB=2048"
rem Stability options
set "KILL_OLD_PROCS=1"
set "ALLOW_CHANGE_NUM_ENVS_ON_ERROR=0"
set "MIN_NUM_ENVS=768"
set "DECR_STEP=64"
rem Control whether to RESUME an old run (1) or start a NEW run (0)
set "USE_RESUME=0"
rem ========================

rem Resolve workspace (folder of this script)
set "WORKSPACE=%~dp0"
for %%A in ("%WORKSPACE%.") do set "WORKSPACE=%%~fA"
pushd "%WORKSPACE%" >nul 2>&1

rem Early log creation so file always exists
set "LOG_DIR=%WORKSPACE%\logs"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>&1
set "LOG_FILE=%LOG_DIR%\last_run.log"
echo [BOOT] %DATE% %TIME% Starting run_training_dx12_resume.bat (env=%CONDA_ENV%, task=%TASK%) > "%LOG_FILE%"

rem Force DX12, disable Vulkan entirely
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin"
set "OMNI_FORCE_GRAPHICS_API=D3D12"
set "OMNI_GRAPHICS_API=D3D12"
set "OMNI_KIT_DISABLE_VULKAN=1"
rem Disable Kit popups and enable full Python errors
set "OMNI_KIT_DISABLE_CRASH_REPORTER=1"
set "OMNI_KIT_DISABLE_HANG_REPORTER=1"
set "HYDRA_FULL_ERROR=1"

rem PYTHONPATH
if defined PYTHONPATH (
  set "PYTHONPATH=%WORKSPACE%\source;%PYTHONPATH%"
) else (
  set "PYTHONPATH=%WORKSPACE%\source"
)

rem ------------------------------------------------------------------
rem Activate conda (STRICT) with robust discovery of conda.bat
rem 1) Respect user-provided CONDA_BAT if already set and exists
rem 2) Try auto-detect via `where conda.bat` or `where conda`
rem 3) Fall back to common install paths
rem ------------------------------------------------------------------
rem 0) Pre-seed a known conda.bat path for this machine if available
if not defined CONDA_BAT if exist "C:\Users\zudva\anaconda3\condabin\conda.bat" set "CONDA_BAT=C:\Users\zudva\anaconda3\condabin\conda.bat"
set "_FOUND_CONDA_BAT="
if not "%CONDA_BAT%"=="" if exist "%CONDA_BAT%" set "_FOUND_CONDA_BAT=%CONDA_BAT%"

if "%_FOUND_CONDA_BAT%"=="" (
  for /f "usebackq delims=" %%C in (`where conda.bat 2^>nul`) do if "%_FOUND_CONDA_BAT%"=="" set "_FOUND_CONDA_BAT=%%C"
)
if "%_FOUND_CONDA_BAT%"=="" (
  for /f "usebackq delims=" %%C in (`where conda 2^>nul`) do (
    if /i "%%~nxC"=="conda.bat" if "%_FOUND_CONDA_BAT%"=="" set "_FOUND_CONDA_BAT=%%C"
    if /i "%%~nxC"=="conda.exe" if "%_FOUND_CONDA_BAT%"=="" set "_FOUND_CONDA_BAT=%%~dpCconda.bat"
  )
)
if "%_FOUND_CONDA_BAT%"=="" if exist "%USERPROFILE%\miniconda3\condabin\conda.bat" set "_FOUND_CONDA_BAT=%USERPROFILE%\miniconda3\condabin\conda.bat"
if "%_FOUND_CONDA_BAT%"=="" if exist "%USERPROFILE%\anaconda3\condabin\conda.bat"   set "_FOUND_CONDA_BAT=%USERPROFILE%\anaconda3\condabin\conda.bat"
if "%_FOUND_CONDA_BAT%"=="" if exist "C:\ProgramData\Miniconda3\condabin\conda.bat" set "_FOUND_CONDA_BAT=C:\ProgramData\Miniconda3\condabin\conda.bat"
if "%_FOUND_CONDA_BAT%"=="" if exist "C:\ProgramData\Anaconda3\condabin\conda.bat"  set "_FOUND_CONDA_BAT=C:\ProgramData\Anaconda3\condabin\conda.bat"

if not "%_FOUND_CONDA_BAT%"=="" (
  set "CONDA_BAT=%_FOUND_CONDA_BAT%"
  echo [INFO] Using conda.bat: %CONDA_BAT%
  echo [INFO] Using conda.bat: %CONDA_BAT%>>"%LOG_FILE%"
  call "%CONDA_BAT%" activate "%CONDA_ENV%"
) else (
  rem Try activate.bat fallback
  set "_FOUND_ACTIVATE_BAT="
  if "%_FOUND_ACTIVATE_BAT%"=="" if exist "%USERPROFILE%\anaconda3\Scripts\activate.bat" set "_FOUND_ACTIVATE_BAT=%USERPROFILE%\anaconda3\Scripts\activate.bat"
  if "%_FOUND_ACTIVATE_BAT%"=="" if exist "%USERPROFILE%\miniconda3\Scripts\activate.bat" set "_FOUND_ACTIVATE_BAT=%USERPROFILE%\miniconda3\Scripts\activate.bat"
  if "%_FOUND_ACTIVATE_BAT%"=="" if exist "C:\ProgramData\Anaconda3\Scripts\activate.bat" set "_FOUND_ACTIVATE_BAT=C:\ProgramData\Anaconda3\Scripts\activate.bat"
  if "%_FOUND_ACTIVATE_BAT%"=="" if exist "C:\ProgramData\Miniconda3\Scripts\activate.bat" set "_FOUND_ACTIVATE_BAT=C:\ProgramData\Miniconda3\Scripts\activate.bat"
  if not "%_FOUND_ACTIVATE_BAT%"=="" (
    echo [INFO] Using activate.bat: %_FOUND_ACTIVATE_BAT%
    echo [INFO] Using activate.bat: %_FOUND_ACTIVATE_BAT%>>"%LOG_FILE%"
    call "%_FOUND_ACTIVATE_BAT%" "%CONDA_ENV%"
  ) else (
    echo [ERROR] conda.bat/activate.bat not found. Set CONDA_BAT to the full path, or run from an Anaconda/Miniconda Prompt.
    echo [ERROR] conda.bat/activate.bat not found. Set CONDA_BAT to the full path, or run from an Anaconda/Miniconda Prompt.>>"%LOG_FILE%"
    popd & exit /b 2
  )
)
rem Validate the active Python comes from the requested env (robust)
set "PY="
for /f "usebackq delims=" %%P in (`python -c "import sys; print(sys.executable)" 2^>nul`) do set "PY=%%P"
if "%PY%"=="" (
  echo [ERROR] python not found after conda activation.
  echo [ERROR] python not found after conda activation.>>"%LOG_FILE%"
  popd & exit /b 3
)
echo [INFO] Using python: %PY%
echo [INFO] Using python: %PY%>>"%LOG_FILE%"
echo %PY% | findstr /i "\\envs\\%CONDA_ENV%\\python.exe" >nul
if errorlevel 1 (
  echo [ERROR] Active python is not from env "%CONDA_ENV%". Aborting.
  echo [ERROR] Active python is not from env "%CONDA_ENV%". Aborting.>>"%LOG_FILE%"
  popd & exit /b 4
)

rem Validate run path only if resuming
if "%USE_RESUME%"=="1" (
  if not exist "%RUN_PATH%" (
    echo [ERROR] RunPath not found: %RUN_PATH%
    echo [ERROR] RunPath not found: %RUN_PATH%>>"%LOG_FILE%"
    popd & exit /b 1
  )
  for %%I in ("%RUN_PATH%") do set "RUN_NAME=%%~nxI"
) else (
  set "RUN_NAME="
)

rem Ensure we don't have stale parallel env_isaaclab python processes (can lock KVDB)
if "%KILL_OLD_PROCS%"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='SilentlyContinue'; $procs = Get-Process -Name python -ErrorAction SilentlyContinue | Where-Object { $_.Path -match '\\anaconda3\\envs\\%CONDA_ENV%\\python.exe$' }; if ($procs) { $ids = ($procs | Select-Object -ExpandProperty Id) -join ', '; Write-Output ('[INFO] Killing stale env_isaaclab python PIDs: ' + $ids); $procs | Stop-Process -Force } else { Write-Output '[INFO] No stale env_isaaclab python processes found' }" 1>>"%LOG_FILE%" 2>&1
)

rem When resuming, keep the original env count. Disable auto sizing to avoid mismatch.
if "%USE_RESUME%"=="1" if "%AUTO_NUM_ENVS%"=="1" (
  echo [INFO] Resume detected for %RUN_NAME%. Disabling AUTO_NUM_ENVS to keep env count compatible with existing run.
  echo [INFO] Resume detected for %RUN_NAME%. Disabling AUTO_NUM_ENVS to keep env count compatible with existing run.>>"%LOG_FILE%"
  set "AUTO_NUM_ENVS=0"
)

rem Experience kit (headless to avoid RTX renderer)
set "EXPERIENCE=%WORKSPACE%\apps\isaacsim_4_5\isaaclab.python.headless.kit"
if not exist "%EXPERIENCE%" set "EXPERIENCE=%WORKSPACE%\apps\isaaclab.python.headless.kit"
if not exist "%EXPERIENCE%" set "EXPERIENCE=%WORKSPACE%\apps\isaacsim_4_5\isaaclab.python.headless.rendering.kit"
if not exist "%EXPERIENCE%" set "EXPERIENCE=%WORKSPACE%\apps\isaacsim_4_5\isaaclab.python.kit"
if not exist "%EXPERIENCE%" set "EXPERIENCE=%WORKSPACE%\apps\isaaclab.python.kit"
if not exist "%EXPERIENCE%" (
  echo [ERROR] Experience kit not found under %WORKSPACE%\apps or apps\isaacsim_4_5.
  echo [ERROR] Experience kit not found under %WORKSPACE%\apps or apps\isaacsim_4_5.>>"%LOG_FILE%"
  popd & exit /b 5
)
echo [INFO] Using experience: %EXPERIENCE%
echo [INFO] Using experience: %EXPERIENCE%>>"%LOG_FILE%"

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

rem -----------------------------
rem Build args and launch (with optional retry on error)
rem -----------------------------
set "RETRY_ALLOWED=%ALLOW_CHANGE_NUM_ENVS_ON_ERROR%"
rem Disable retries that change NUM_ENVS for resume runs (to keep shapes consistent)
if "%USE_RESUME%"=="1" if exist "%RUN_PATH%" set "RETRY_ALLOWED=0"
set "ATTEMPT=1"

:LAUNCH_ATTEMPT
set "ARGS=-p scripts\reinforcement_learning\rsl_rl\train.py --task %TASK% --num_envs %NUM_ENVS% --max_iterations %MAX_ITERS% --headless --seed %SEED% --experience ^"%EXPERIENCE%^""
if "%USE_RESUME%"=="1" set "ARGS=%ARGS% --resume --load_run %RUN_NAME% --log_dir_override ^"%RUN_PATH%^""
if "%VIDEO%"=="1" set "ARGS=%ARGS% --video --video_interval %VIDEO_INTERVAL% --video_length %VIDEO_LENGTH%"

echo [INFO] ATTEMPT %ATTEMPT% with NUM_ENVS=%NUM_ENVS%
echo [INFO] ATTEMPT %ATTEMPT% with NUM_ENVS=%NUM_ENVS%>>"%LOG_FILE%"
echo [INFO] Logging to "%LOG_FILE%"
echo [INFO] Logging to "%LOG_FILE%" >>"%LOG_FILE%"
echo Launching training...
echo Launching training...>>"%LOG_FILE%"
echo isaaclab.bat %ARGS%
echo isaaclab.bat %ARGS%>>"%LOG_FILE%"

rem Redirect all output to log so Python tracebacks are saved even if window closes
call "%WORKSPACE%\isaaclab.bat" %ARGS% 1>>"%LOG_FILE%" 2>&1
set "CODE=%ERRORLEVEL%"

if "%CODE%"=="0" (
  echo [OK] Completed. See log: "%LOG_FILE%"
  goto :EPILOG
)

if "%RETRY_ALLOWED%"=="1" (
  rem Lower NUM_ENVS and retry until MIN_NUM_ENVS
  if %NUM_ENVS% GTR %MIN_NUM_ENVS% (
    set /a NUM_ENVS=%NUM_ENVS%-%DECR_STEP%
    if %NUM_ENVS% LSS %MIN_NUM_ENVS% set "NUM_ENVS=%MIN_NUM_ENVS%"
    echo [WARN] Exit code %CODE%. Lowering NUM_ENVS to %NUM_ENVS% and retrying...>>"%LOG_FILE%"
    set /a ATTEMPT=%ATTEMPT%+1
    goto :LAUNCH_ATTEMPT
  )
)

echo [ERROR] Exit code %CODE%. See log: "%LOG_FILE%"

:EPILOG
popd
exit /b %CODE%

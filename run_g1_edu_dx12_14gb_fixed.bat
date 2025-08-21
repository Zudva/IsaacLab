@echo off
setlocal enableextensions enabledelayedexpansion

REM ==== USER PARAMS ====
set CONDA_ENV=env_isaaclab
set TASK=Isaac-Velocity-Flat-G1-EDU-v0
set TARGET_VRAM_GB=14
set SAFETY_MB=300
set MAX_ITERS=1500
set SEED=42
set CAND_LIST=3200 3072 2944 2816 2688 2560 2432 2304 2176 2048 1920 1792 1664 1536 1408 1280 1152 1024 896 768 640 512
REM ======================

if not exist logs mkdir logs
set LOG=logs\g1_edu_autosize_14gb.log
echo [START] %date% %time% > "%LOG%"
echo [TARGET] %TARGET_VRAM_GB%GB VRAM with %SAFETY_MB%MB safety >> "%LOG%"

call conda activate %CONDA_ENV%
if errorlevel 1 (
    echo ERROR: Failed to activate conda environment %CONDA_ENV%
    pause
    exit /b 1
)

REM --- Force DX12 / disable Vulkan ---
set "CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin;omni.kit.renderer.core.plugin.vulkan;omni.render.rtx.plugin.vulkan;omni.gpu_foundation_factory.plugin.vulkan"
set OMNI_KIT_FORCE_RENDER_API=dx12
set OMNI_KIT_DISABLE_VULKAN=1
set CARB_ENABLE_VULKAN=0
set OMNI_RENDER_DISABLE_PLUGINS=omni.render.rtx.plugin.vulkan
echo [INFO] DX12 forced, Vulkan disabled >> "%LOG%"

REM Get baseline VRAM usage
for /f "tokens=1" %%A in ('powershell -NoLogo -NoProfile -Command "(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)[0]"') do set BASE_VRAM=%%A
echo [BASELINE] Base VRAM: %BASE_VRAM%MB >> "%LOG%"

set BEST=0
set /a TARGET_MB=%TARGET_VRAM_GB%*1024

echo [INFO] Probing environments to find optimal count for %TARGET_VRAM_GB%GB target...

for %%N in (%CAND_LIST%) do (
    echo [PROBE] Testing %%N environments...
    echo [PROBE] %%N >> "%LOG%"
    
    REM Get VRAM before test
    for /f "tokens=1" %%A in ('powershell -NoLogo -NoProfile -Command "(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)[0]"') do set BEFORE=%%A
    
    REM Run quick test
    isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task %TASK% --num_envs %%N --max_iterations 1 --seed %SEED% --headless >nul 2>&1
    set RC=!ERRORLEVEL!
    
    REM Wait and get VRAM after test
    powershell -NoLogo -NoProfile -Command "Start-Sleep -Seconds 3" >nul
    for /f "tokens=1" %%A in ('powershell -NoLogo -NoProfile -Command "(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)[0]"') do set AFTER=%%A
    
    set /a DELTA=AFTER-BEFORE
    if !DELTA! LSS 0 set DELTA=0
    
    set /a TOTAL_USAGE=BASE_VRAM+DELTA
    set /a REMAINING=TARGET_MB-TOTAL_USAGE-SAFETY_MB
    
    echo [RESULT] N=%%N RC=!RC! DELTA=!DELTA!MB TOTAL=!TOTAL_USAGE!MB REMAINING=!REMAINING!MB >> "%LOG%"
    
    if !RC! EQU 0 (
        if !TOTAL_USAGE! LEQ %TARGET_MB% (
            if !REMAINING! GEQ 0 (
                set BEST=%%N
                echo [ACCEPTED] %%N environments >> "%LOG%"
            ) else (
                echo [REJECTED] %%N environments >> "%LOG%"
                goto :found_best
            )
        ) else (
            echo [REJECTED] %%N environments >> "%LOG%"
            goto :found_best
        )
    ) else (
        echo [FAILED] %%N environments >> "%LOG%"
    )
    
    REM Clean up
    taskkill /f /im "python.exe" >nul 2>&1
    powershell -NoLogo -NoProfile -Command "Start-Sleep -Seconds 2" >nul
)

:found_best
if %BEST% EQU 0 (
    echo [FALLBACK] Using 512 >> "%LOG%"
    set BEST=512
)

echo ========= SUMMARY =========
type "%LOG%"
echo ===========================
echo.
echo [FINAL] Selected %BEST% environments
echo [FINAL] Starting training with GUI...
echo.

REM Kill processes before final run
taskkill /f /im "python.exe" >nul 2>&1
powershell -NoLogo -NoProfile -Command "Start-Sleep -Seconds 3" >nul

REM Final training run with GUI
echo [TRAINING] %BEST% envs, %MAX_ITERS% iterations >> "%LOG%"
isaaclab.bat -p scripts\reinforcement_learning\rsl_rl\train.py --task %TASK% --num_envs %BEST% --max_iterations %MAX_ITERS% --seed %SEED%

echo [END] %date% %time% >> "%LOG%"
echo Training completed.
pause
endlocal

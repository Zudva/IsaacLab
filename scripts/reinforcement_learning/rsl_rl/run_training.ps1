param(
  [string]$Task = "Isaac-Velocity-Flat-G1-v0",
  [string]$RunPath = "C:\Users\zudva\Downloads\IsaacLab\logs\rsl_rl\g1_flat\2025-08-14_15-28-32",
  [int]$NumEnvs = 1280,
  [int]$MaxIterations = 20000,
  [switch]$Resume = $true,
  [switch]$Video = $false,
  [int]$VideoInterval = 5000,
  [int]$VideoLength = 300,
  [int]$Seed = 42,
  [ValidateSet("Default","HighLoad","Debug","Video")]
  [string]$Profile = "HighLoad",
  [int]$MaxHours = 0,
  [switch]$UseTimer = $false,
  # Conda prompt integration
  [string]$CondaEnv = "env_isaaclab",
  [switch]$OpenCondaPrompt = $false
)

$ErrorActionPreference = "Stop"

# Resolve workspace root (this script is in scripts/reinforcement_learning/rsl_rl)
$workspace = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$bat = Join-Path $workspace "isaaclab.bat"
$trainPy = "scripts\reinforcement_learning\rsl_rl\train.py"
$experience = Join-Path $workspace "apps\isaacsim_4_5\isaaclab.python.directx.kit"

function Resolve-CondaBat {
  # Try deriving from CONDA_EXE if available
  if ($env:CONDA_EXE) {
    $root = Split-Path -Parent (Split-Path -Parent $env:CONDA_EXE)
    $cb = Join-Path $root "condabin\conda.bat"
    if (Test-Path -LiteralPath $cb) { return $cb }
  }
  # Common install locations
  $candidates = @(
    (Join-Path $env:USERPROFILE "anaconda3\condabin\conda.bat"),
    (Join-Path $env:USERPROFILE "miniconda3\condabin\conda.bat"),
    "C:\ProgramData\Anaconda3\condabin\conda.bat",
    "C:\ProgramData\Miniconda3\condabin\conda.bat"
  )
  foreach ($p in $candidates) { if (Test-Path -LiteralPath $p) { return $p } }
  return $null
}

# Apply profile defaults unless explicitly overridden
switch ($Profile) {
  "HighLoad" {
    if (-not $PSBoundParameters.ContainsKey('NumEnvs')) { $NumEnvs = 1280 }
    if (-not $PSBoundParameters.ContainsKey('MaxIterations')) { $MaxIterations = 20000 }
    if (-not $PSBoundParameters.ContainsKey('Video')) { $Video = $false }
  }
  "Debug" {
    $NumEnvs = 128
    $MaxIterations = 500
    $Video = $false
  }
  "Video" {
    if (-not $PSBoundParameters.ContainsKey('Video')) { $Video = $true }
    if (-not $PSBoundParameters.ContainsKey('VideoInterval')) { $VideoInterval = 5000 }
    if (-not $PSBoundParameters.ContainsKey('VideoLength')) { $VideoLength = 300 }
  }
  default { }
}

# Enforce DirectX12 / disable Vulkan
$env:OMNI_FORCE_GRAPHICS_API = "D3D12"
$env:OMNI_GRAPHICS_API = "D3D12"
$env:OMNI_KIT_DISABLE_VULKAN = "1"
# Hard-disable Vulkan plugin loading (prevents carb.graphics-vulkan.plugin from being loaded at all)
$env:CARB_DISABLE_MODULES = "carb.graphics-vulkan.plugin"

# Ensure Python sees local packages (when not using Conda)
if ($env:PYTHONPATH) {
  $env:PYTHONPATH = "$workspace\source;$env:PYTHONPATH"
}
else {
  $env:PYTHONPATH = "$workspace\source"
}

Write-Host "Workspace:" $workspace
Write-Host "Experience:" $experience
Write-Host "Profile:" $Profile

# Validate resume path when requested
if ($Resume) {
  if (-not (Test-Path -LiteralPath $RunPath)) {
    throw "RunPath not found: $RunPath"
  }
  $runName = Split-Path -Leaf $RunPath
}

# Build argument list for train.py
$argsList = @(
  "-p",
  $trainPy,
  "--task", $Task,
  "--num_envs", $NumEnvs.ToString(),
  "--max_iterations", $MaxIterations.ToString(),
  "--headless",
  "--seed", $Seed.ToString(),
  "--experience", $experience
)

if ($Video) {
  $argsList += @("--video", "--video_interval", $VideoInterval.ToString(), "--video_length", $VideoLength.ToString())
}

if ($Resume) {
  $argsList += @("--resume", "--load_run", $runName, "--log_dir_override", $RunPath)
}

Write-Host "Launching training..." -ForegroundColor Cyan
Write-Host "`n$bat $($argsList -join ' ')`n" -ForegroundColor DarkGray

# Auto-detect VS Code integrated terminal and missing conda -> open Anaconda Prompt
$isVSCode = $false
if ($env:TERM_PROGRAM -eq 'vscode' -or $env:VSCODE_PID -or $env:VSCODE_CWD -or $env:VSCODE_NLS_CONFIG) { $isVSCode = $true }
$condaFound = $false
try { if (Get-Command conda -ErrorAction Stop) { $condaFound = $true } } catch { $condaFound = $false }
if (-not $condaFound -and $env:CONDA_EXE) { $condaFound = Test-Path -LiteralPath $env:CONDA_EXE }
if ($isVSCode -and -not $OpenCondaPrompt -and -not $condaFound) {
  Write-Host "VS Code detected and conda not found in PATH. Opening Anaconda Prompt automatically..." -ForegroundColor Yellow
  $OpenCondaPrompt = $true
}

# Open a new Command Prompt with Conda env activated (timer ignored)
if ($OpenCondaPrompt) {
  $condaBat = Resolve-CondaBat
  if (-not $condaBat) { Write-Warning "conda.bat not found. Opening plain cmd without activation." }
  $joined = ($argsList -join ' ')
  # Include Vulkan hard-disable in the cmd environment as well
  $dxEnv = 'set CARB_DISABLE_MODULES=carb.graphics-vulkan.plugin && set OMNI_FORCE_GRAPHICS_API=D3D12 && set OMNI_GRAPHICS_API=D3D12 && set OMNI_KIT_DISABLE_VULKAN=1'
  if ($condaBat) {
    $cmdLine = '"' + $condaBat + '" activate ' + $CondaEnv + ' && ' + $dxEnv + ' && cd /d ' + '"' + $workspace + '"' + ' && ' + '"' + $bat + '" ' + $joined
  }
  else {
    $cmdLine = $dxEnv + ' && cd /d ' + '"' + $workspace + '"' + ' && ' + '"' + $bat + '" ' + $joined
  }
  if ($isVSCode) {
    # Run inline inside VS Code terminal panel
    & cmd.exe /k $cmdLine
    exit $LASTEXITCODE
  }
  else {
    # Open separate window
    Start-Process -FilePath "cmd.exe" -ArgumentList "/k", $cmdLine -WorkingDirectory $workspace
    exit 0
  }
}

# Interactive timer setup when requested
if ($UseTimer) {
  if (-not $PSBoundParameters.ContainsKey('MaxHours') -or $MaxHours -le 0) {
    while ($true) {
      $in = Read-Host "Enter MaxHours (integer > 0) or press Enter to disable timer"
      if ([string]::IsNullOrWhiteSpace($in)) {
        $MaxHours = 0
        $UseTimer = $false
        Write-Host "Timer disabled (no value provided)."
        break
      }
      $parsed = 0
      if ([int]::TryParse($in, [ref]$parsed) -and $parsed -gt 0) {
        $MaxHours = $parsed
        Write-Host "Timer set to $MaxHours hour(s)."
        break
      }
      else {
        Write-Warning "Invalid value. Please enter a positive integer or press Enter to skip."
      }
    }
  }
}

# Run with optional timeout
if ($UseTimer -and $MaxHours -gt 0) {
  $p = Start-Process -FilePath $bat -WorkingDirectory $workspace -ArgumentList $argsList -PassThru
  try { Wait-Process -Id $p.Id -Timeout ($MaxHours * 3600) | Out-Null }
  catch { Write-Warning "Time limit reached ($MaxHours h). Stopping training process..." }
  if (-not $p.HasExited) { try { Stop-Process -Id $p.Id -Force } catch { Write-Warning "Failed to stop process: $($_.Exception.Message)" } }
  exit $p.ExitCode
}
else {
  & $bat @argsList
  exit $LASTEXITCODE
}

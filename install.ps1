#!/usr/bin/env pwsh
#Requires -Version 7.2

<#
.SYNOPSIS
    Builds and installs Lucas.PowerShellPredictor module.

.DESCRIPTION
    This script builds the PowerShell predictor module and installs it to ~/.local/pwsh-modules/Lucas.PowerShellPredictor.
    After installation, add the module path to your PowerShell profile if needed.

.EXAMPLE
    ./install.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

Write-Host "Building Lucas.PowerShellPredictor..." -ForegroundColor Cyan

# Build the project
$projectPath = Join-Path $PSScriptRoot 'src' 'PowerShellPredictor' 'PowerShellPredictor.csproj'
$buildPath = Join-Path $PSScriptRoot 'src' 'PowerShellPredictor' 'bin' 'Release' 'net9.0'

dotnet build $projectPath -c Release

if ($LASTEXITCODE -ne 0) {
    throw "Build failed with exit code $LASTEXITCODE"
}

$dllPath = Join-Path $buildPath 'Lucas.PowerShellPredictor.dll'

if (-not (Test-Path $dllPath)) {
    throw "Assembly not found at $dllPath"
}

Write-Host "Build successful!" -ForegroundColor Green

# Create installation directory
$installDir = Join-Path $HOME '.local' 'pwsh-modules' 'Lucas.PowerShellPredictor'

if (Test-Path $installDir) {
    Write-Host "Removing existing installation at $installDir..." -ForegroundColor Yellow
    Remove-Item $installDir -Recurse -Force
}

Write-Host "Creating installation directory at $installDir..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $installDir -Force | Out-Null

# Copy assembly
Write-Host "Copying assembly..." -ForegroundColor Cyan
Copy-Item $dllPath $installDir

# Copy module files
Write-Host "Copying module files..." -ForegroundColor Cyan
$moduleDir = Join-Path $PSScriptRoot 'module'
Copy-Item (Join-Path $moduleDir 'Lucas.PowerShellPredictor.psm1') $installDir
Copy-Item (Join-Path $moduleDir 'Lucas.PowerShellPredictor.psd1') $installDir

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "To use the module, add these lines to your PowerShell profile:" -ForegroundColor Cyan
Write-Host "    Import-Module ~/.local/pwsh-modules/Lucas.PowerShellPredictor/Lucas.PowerShellPredictor.psd1" -ForegroundColor White
Write-Host "    Set-PSReadLineOption -PredictionSource HistoryAndPlugin" -ForegroundColor White
Write-Host ""
Write-Host "To edit your profile, run:" -ForegroundColor Cyan
Write-Host "    code `$PROFILE" -ForegroundColor White

#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Downloads Phi-3 model using git-lfs (recommended method).

.DESCRIPTION
    This script clones the Phi-3 model repository from Hugging Face using git-lfs,
    which is the most reliable way to download large model files.

.PARAMETER ModelType
    The type of model to download: 'cpu' (default) or 'directml' (GPU).

.PARAMETER Force
    Force re-download even if the model already exists.

.EXAMPLE
    .\setup-ai-model-git.ps1
    Downloads the CPU version of the model using git-lfs.

.EXAMPLE
    .\setup-ai-model-git.ps1 -ModelType directml
    Downloads the DirectML (GPU) version of the model.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('cpu', 'directml')]
    [string]$ModelType = 'cpu',

    [Parameter()]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

Write-Host "PowerShell AI Predictor - Model Setup (git-lfs method)" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""

# Check if git is installed
try {
    $gitVersion = git --version
    Write-Host "✓ Git found: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Git is not installed or not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Git from: https://git-scm.com/downloads" -ForegroundColor Yellow
    exit 1
}

# Check if git-lfs is installed
try {
    $lfsVersion = git lfs version
    Write-Host "✓ Git LFS found: $lfsVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Git LFS is not installed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Installing Git LFS..." -ForegroundColor Yellow
    try {
        git lfs install
        Write-Host "✓ Git LFS installed successfully" -ForegroundColor Green
    } catch {
        Write-Host "Failed to install Git LFS automatically." -ForegroundColor Red
        Write-Host "Please install it manually from: https://git-lfs.github.com/" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""

# Model configuration
$modelConfigs = @{
    cpu = @{
        Name = 'Phi-3-mini-4k-instruct-onnx (CPU INT4)'
        SubPath = 'cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4'
    }
    directml = @{
        Name = 'Phi-3-mini-4k-instruct-onnx (DirectML INT4)'
        SubPath = 'directml/directml-int4-awq-block-128'
    }
}

$config = $modelConfigs[$ModelType]

# Paths
$tempDir = Join-Path $env:TEMP "phi3-download"
$modelDir = Join-Path $env:USERPROFILE '.powershell-predictor\models\phi3'
$repoUrl = 'https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-onnx'

Write-Host "Model: $($config.Name)" -ForegroundColor Green
Write-Host "Target: $modelDir" -ForegroundColor Green
Write-Host ""

# Check if model already exists
if ((Test-Path $modelDir) -and -not $Force) {
    $existingFiles = Get-ChildItem -Path $modelDir -File
    if ($existingFiles.Count -gt 0) {
        Write-Host "Model directory already exists and contains files." -ForegroundColor Yellow
        $response = Read-Host "Do you want to re-download? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Host "Setup cancelled." -ForegroundColor Yellow
            exit 0
        }
        Write-Host ""
    }
}

# Create temp directory
if (Test-Path $tempDir) {
    Write-Host "Cleaning up previous download..." -ForegroundColor Yellow
    Remove-Item -Path $tempDir -Recurse -Force
}

Write-Host "Creating temporary directory..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {
    # Clone only the specific directory using sparse checkout
    Write-Host "Cloning model repository (this may take 10-20 minutes)..." -ForegroundColor Cyan
    Write-Host "Download size: ~2GB" -ForegroundColor Gray
    Write-Host ""

    Push-Location $tempDir

    # Initialize repo
    git init
    git remote add origin $repoUrl

    # Enable sparse checkout
    git config core.sparseCheckout true

    # Specify which folder to download
    Set-Content -Path ".git/info/sparse-checkout" -Value $config.SubPath

    # Pull the files
    Write-Host "Fetching files from Hugging Face..." -ForegroundColor Cyan
    git pull origin main

    Pop-Location

    # Copy files to target directory
    Write-Host ""
    Write-Host "Copying files to target directory..." -ForegroundColor Cyan

    $sourceDir = Join-Path $tempDir $config.SubPath

    if (-not (Test-Path $sourceDir)) {
        throw "Downloaded files not found at expected location: $sourceDir"
    }

    # Create target directory
    New-Item -ItemType Directory -Path $modelDir -Force | Out-Null

    # Copy all files
    Get-ChildItem -Path $sourceDir -File | ForEach-Object {
        $targetPath = Join-Path $modelDir $_.Name
        Copy-Item -Path $_.FullName -Destination $targetPath -Force
        $fileSizeMB = [math]::Round($_.Length / 1MB, 2)
        Write-Host "  ✓ Copied $($_.Name) ($fileSizeMB MB)" -ForegroundColor Green
    }

    # Cleanup
    Write-Host ""
    Write-Host "Cleaning up temporary files..." -ForegroundColor Cyan
    Remove-Item -Path $tempDir -Recurse -Force

    Write-Host ""
    Write-Host "Setup completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Model installed to: $modelDir" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Files installed:" -ForegroundColor Yellow
    Get-ChildItem -Path $modelDir -File | ForEach-Object {
        $sizeMB = [math]::Round($_.Length / 1MB, 2)
        Write-Host "  - $($_.Name) ($sizeMB MB)" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Build the project: dotnet build" -ForegroundColor White
    Write-Host "2. Import the module in PowerShell" -ForegroundColor White
    Write-Host "3. The AI predictor will automatically load on first use" -ForegroundColor White
    Write-Host ""
    Write-Host "Note: First-time model loading may take 5-15 seconds." -ForegroundColor Gray

} catch {
    Write-Host ""
    Write-Host "✗ Download failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Check your internet connection" -ForegroundColor White
    Write-Host "2. Ensure git-lfs is properly installed: git lfs install" -ForegroundColor White
    Write-Host "3. Try the alternative download script: .\setup-ai-model.ps1" -ForegroundColor White
    Write-Host "4. Or download manually from: $repoUrl" -ForegroundColor White

    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force
    }

    exit 1
} finally {
    Pop-Location -ErrorAction SilentlyContinue
}

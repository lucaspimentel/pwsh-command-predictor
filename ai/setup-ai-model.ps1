#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Downloads and sets up the Phi-3 model for the AI predictor.

.DESCRIPTION
    This script downloads the Phi-3 Mini ONNX model from Hugging Face and extracts it
    to the expected location for the PowerShell AI predictor.

.PARAMETER ModelType
    The type of model to download: 'cpu' (default) or 'directml' (GPU).

.PARAMETER Force
    Force re-download even if the model already exists.

.EXAMPLE
    .\setup-ai-model.ps1
    Downloads the CPU version of the model.

.EXAMPLE
    .\setup-ai-model.ps1 -ModelType directml
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

# Model configuration
$modelConfigs = @{
    cpu = @{
        Name = 'Phi-3-mini-4k-instruct-onnx (CPU INT4)'
        Repo = 'microsoft/Phi-3-mini-4k-instruct-onnx'
        Path = 'cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4'
        Files = @(
            @{ Source = 'added_tokens.json'; Target = 'added_tokens.json' },
            @{ Source = 'genai_config.json'; Target = 'genai_config.json' },
            @{ Source = 'phi3-mini-4k-instruct-cpu-int4-rtn-block-32-acc-level-4.onnx'; Target = 'phi3-mini-4k-instruct-cpu-int4-rtn-block-32-acc-level-4.onnx' },
            @{ Source = 'phi3-mini-4k-instruct-cpu-int4-rtn-block-32-acc-level-4.onnx.data'; Target = 'phi3-mini-4k-instruct-cpu-int4-rtn-block-32-acc-level-4.onnx.data' },
            @{ Source = 'special_tokens_map.json'; Target = 'special_tokens_map.json' },
            @{ Source = 'tokenizer.json'; Target = 'tokenizer.json' },
            @{ Source = 'tokenizer.model'; Target = 'tokenizer.model' },
            @{ Source = 'tokenizer_config.json'; Target = 'tokenizer_config.json' }
        )
    }
    directml = @{
        Name = 'Phi-3-mini-4k-instruct-onnx (DirectML INT4)'
        Repo = 'microsoft/Phi-3-mini-4k-instruct-onnx'
        Path = 'directml/directml-int4-awq-block-128'
        Files = @(
            @{ Source = 'added_tokens.json'; Target = 'added_tokens.json' },
            @{ Source = 'genai_config.json'; Target = 'genai_config.json' },
            @{ Source = 'phi3-mini-4k-instruct-directml-int4-awq-block-128.onnx'; Target = 'phi3-mini-4k-instruct-directml-int4-awq-block-128.onnx' },
            @{ Source = 'phi3-mini-4k-instruct-directml-int4-awq-block-128.onnx.data'; Target = 'phi3-mini-4k-instruct-directml-int4-awq-block-128.onnx.data' },
            @{ Source = 'special_tokens_map.json'; Target = 'special_tokens_map.json' },
            @{ Source = 'tokenizer.json'; Target = 'tokenizer.json' },
            @{ Source = 'tokenizer.model'; Target = 'tokenizer.model' },
            @{ Source = 'tokenizer_config.json'; Target = 'tokenizer_config.json' }
        )
    }
}

$config = $modelConfigs[$ModelType]

# Target directory
$modelDir = Join-Path $env:USERPROFILE '.powershell-predictor\models\phi3'

Write-Host "PowerShell AI Predictor - Model Setup" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Model: $($config.Name)" -ForegroundColor Green
Write-Host "Target directory: $modelDir" -ForegroundColor Green
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

# Create target directory
Write-Host "Creating model directory..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $modelDir -Force | Out-Null

# Download files from Hugging Face
Write-Host "Downloading model files from Hugging Face..." -ForegroundColor Cyan
Write-Host "This may take several minutes depending on your connection speed." -ForegroundColor Gray
Write-Host ""

$baseUrl = "https://huggingface.co/$($config.Repo)/resolve/main/$($config.Path)"
$totalFiles = $config.Files.Count
$currentFile = 0

foreach ($fileInfo in $config.Files) {
    $currentFile++
    $sourceFile = $fileInfo.Source
    $targetFile = $fileInfo.Target
    $url = "$baseUrl/$sourceFile"
    $destination = Join-Path $modelDir $targetFile

    Write-Host "[$currentFile/$totalFiles] Downloading $sourceFile..." -ForegroundColor White

    try {
        # Use Invoke-WebRequest with progress
        $ProgressPreference = 'SilentlyContinue'  # Faster downloads

        # For large files, use HttpClient for better reliability
        $fileSize = 0
        try {
            $headRequest = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -ErrorAction SilentlyContinue
            if ($headRequest.Headers.'Content-Length') {
                $fileSize = [long]$headRequest.Headers.'Content-Length'[0]
            }
        } catch {}

        if ($fileSize -gt 100MB) {
            # Use .NET HttpClient for large files
            Write-Host "  Large file detected, using streaming download..." -ForegroundColor Gray

            $httpClient = New-Object System.Net.Http.HttpClient
            $httpClient.Timeout = [TimeSpan]::FromMinutes(30)

            $response = $httpClient.GetAsync($url, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result
            $response.EnsureSuccessStatusCode()

            $stream = $response.Content.ReadAsStreamAsync().Result
            $fileStream = [System.IO.File]::Create($destination)

            $buffer = New-Object byte[] 8192
            $totalRead = 0
            $lastPercent = -1

            while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $fileStream.Write($buffer, 0, $read)
                $totalRead += $read

                if ($fileSize -gt 0) {
                    $percent = [math]::Floor(($totalRead / $fileSize) * 100)
                    if ($percent -ne $lastPercent -and $percent % 10 -eq 0) {
                        Write-Host "  Progress: $percent%" -ForegroundColor Gray
                        $lastPercent = $percent
                    }
                }
            }

            $fileStream.Close()
            $stream.Close()
            $httpClient.Dispose()
        } else {
            # Use Invoke-WebRequest for small files
            Invoke-WebRequest -Uri $url -OutFile $destination -UseBasicParsing
        }

        $actualFileSize = (Get-Item $destination).Length
        $fileSizeMB = [math]::Round($actualFileSize / 1MB, 2)
        Write-Host "  ✓ Downloaded ($fileSizeMB MB)" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ Failed to download $sourceFile" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red

        # Try to get more detailed error
        if ($_.Exception.InnerException) {
            Write-Host "  Inner Error: $($_.Exception.InnerException.Message)" -ForegroundColor Red
        }

        Write-Host ""
        Write-Host "You can manually download the files from:" -ForegroundColor Yellow
        Write-Host "https://huggingface.co/$($config.Repo)/tree/main/$($config.Path)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Or try using git-lfs:" -ForegroundColor Yellow
        Write-Host "  git lfs install" -ForegroundColor White
        Write-Host "  git clone https://huggingface.co/$($config.Repo)" -ForegroundColor White
        exit 1
    }
}

Write-Host ""
Write-Host "Setup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Model installed to: $modelDir" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Build the project: dotnet build" -ForegroundColor White
Write-Host "2. Import the module in PowerShell" -ForegroundColor White
Write-Host "3. The AI predictor will automatically load on first use" -ForegroundColor White
Write-Host ""
Write-Host "Note: First-time model loading may take 5-15 seconds." -ForegroundColor Gray

# AI Model Setup Guide

The AI predictor requires the Phi-3 Mini ONNX model (~2GB). Here are several ways to set it up:

## Method 1: Automated Setup with Git LFS (Recommended)

This is the most reliable method for downloading the model.

### Prerequisites
- Git installed ([download](https://git-scm.com/downloads))
- Git LFS installed (usually comes with Git, or run `git lfs install`)

### Steps
```powershell
.\setup-ai-model-git.ps1
```

This will:
1. Clone only the necessary model files from Hugging Face
2. Copy them to `%USERPROFILE%\.powershell-predictor\models\phi3\`
3. Clean up temporary files

## Method 2: Direct HTTP Download

Try the HTTP download script (may fail for large files):

```powershell
.\setup-ai-model.ps1
```

If this fails with large files (model.onnx), use Method 1 or Method 3 instead.

## Method 3: Manual Download via Web Browser

1. Go to: https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-onnx/tree/main/cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4

2. Download these files (click each file, then click "download"):
   - `added_tokens.json`
   - `genai_config.json`
   - `phi3-mini-4k-instruct-cpu-int4-rtn-block-32-acc-level-4.onnx` (~195 MB)
   - `phi3-mini-4k-instruct-cpu-int4-rtn-block-32-acc-level-4.onnx.data` (~2 GB) ⚠️ Large file!
   - `special_tokens_map.json`
   - `tokenizer.json`
   - `tokenizer.model`
   - `tokenizer_config.json`

3. Create the directory:
   ```powershell
   New-Item -ItemType Directory -Path "$env:USERPROFILE\.powershell-predictor\models\phi3" -Force
   ```

4. Move all downloaded files to: `%USERPROFILE%\.powershell-predictor\models\phi3\`

## Method 4: Clone Entire Repository

If you have plenty of disk space (~20GB):

```bash
git lfs install
git clone https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-onnx
```

Then copy the files from `Phi-3-mini-4k-instruct-onnx/cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4/` to `%USERPROFILE%\.powershell-predictor\models\phi3\`

## GPU Version (DirectML)

For GPU acceleration on Windows with AMD/Intel/NVIDIA GPUs:

```powershell
.\setup-ai-model-git.ps1 -ModelType directml
```

Or manually download from:
https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-onnx/tree/main/directml/directml-int4-awq-block-128

## Verification

After setup, verify the files are in place:

```powershell
Get-ChildItem "$env:USERPROFILE\.powershell-predictor\models\phi3"
```

You should see 8 files totaling ~2-2.5 GB.

## Troubleshooting

### "Failed to download" errors
- Use Method 1 (git-lfs) instead of Method 2
- Or use Method 3 (manual download via browser)
- Check your internet connection
- Some corporate networks block Hugging Face

### Git LFS issues
```bash
git lfs install --force
```

### Still having issues?
The predictor will gracefully degrade if the model isn't found. You can still use the CommandCompleterPredictor without AI by commenting out the AI predictor in `Init.cs`:

```csharp
// RegisterSubsystem(new AiPredictor());
```

## Next Steps

Once the model is installed:

1. Build the project:
   ```bash
   dotnet build
   ```

2. Import the module in PowerShell:
   ```powershell
   Import-Module .\src\PowerShellPredictor\bin\Debug\net9.0\Lucas.PowerShellPredictor.dll
   ```

3. Start typing commands - the AI predictor will load on first use (takes 5-15 seconds)

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a PowerShell predictor module that provides command-line suggestions using PowerShell's prediction subsystem. The predictor integrates with PSReadLine to offer auto-completion suggestions based on the PowerShellArgumentCompleter library.

## Architecture

The project consists of three main components:

1. **PowerShellPredictor** (src/PowerShellPredictor/): The core predictor module
   - `Init.cs:21-27`: Registers predictor subsystems on module load via `IModuleAssemblyInitializer`
   - `CommandCompleterPredictor.cs`: Main predictor implementation using PowerShellArgumentCompleter
   - `CommandCompleterPredictor.cs:49-70`: The `Combine()` method intelligently merges input text with completions by finding overlaps
   - `AiPredictor.cs`: AI-powered predictor using local Phi-3 model via ONNX Runtime GenAI
   - `AiPredictor.cs:35-75`: Lazy model loading with singleton pattern for performance

2. **PowerShellPredictor.Cli** (src/PowerShellPredictor.Cli/): A simple CLI tool for testing predictors outside of PowerShell

3. **PowerShellPredictor.Tests** (test/PowerShellPredictor.Tests/): xUnit test project

### Key Dependencies

- Microsoft.PowerShell.SDK (v7.5.0) - provides PowerShell subsystem APIs
- Microsoft.ML.OnnxRuntimeGenAI (v0.10.0) - local AI inference with Phi-3 models
- PowerShellArgumentCompleter - external project referenced at `../pwsh-argument-completer/src/` (sibling repository)
- xUnit + Moq for testing

## Building and Testing

### Build
```bash
dotnet build
```

### Build specific project
```bash
dotnet build src/PowerShellPredictor/
dotnet build src/PowerShellPredictor.Cli/
```

### Run tests
```bash
dotnet test
```

### Run CLI tool
```bash
dotnet run --project src/PowerShellPredictor.Cli/ -- "your command here"
```

## Development Notes

- Target framework: .NET 9.0
- Nullable reference types enabled
- Uses implicit usings
- Assembly name: `Lucas.PowerShellPredictor`
- Test assembly is marked as `InternalsVisibleTo` for testing internal methods (AssemblyInfo.cs:3)
- Some predictor implementations are excluded from compilation (PowerShellPredictor.csproj:18-20): `KnownCommandsPredictor.cs` and `SamplePredictor.cs`

## PowerShell Predictor Subsystem

The predictor follows Microsoft's command predictor pattern:
- Implements `ICommandPredictor` interface
- Registers via `SubsystemManager.RegisterSubsystem(SubsystemKind.CommandPredictor, ...)`
- Each predictor has a unique GUID identifier
- The `GetSuggestion()` method returns `SuggestionPackage` with predictive suggestions

## AI Predictor Setup

The `AiPredictor` uses a local Phi-3 model for intelligent command suggestions. To enable it:

### Download the Phi-3 Model

Use the provided setup script for automatic download:

```powershell
# CPU version (recommended)
.\setup-ai-model.ps1

# GPU version (DirectML)
.\setup-ai-model.ps1 -ModelType directml
```

Or manually download from Hugging Face:
- CPU: https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-onnx/tree/main/cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4
- DirectML: https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-onnx/tree/main/directml/directml-int4-awq-block-128

Extract to: `%USERPROFILE%\.powershell-predictor\models\phi3\`

### Model Loading

- Model loads lazily on first prediction request
- Singleton pattern keeps model in memory for performance (AiPredictor.cs:35-75)
- Model cleanup happens on module unload (Init.cs:46)
- If model is not found, predictor gracefully degrades with console warnings

### Performance Considerations

- Model loading takes 5-15 seconds on first use
- Inference takes 100-500ms per suggestion depending on hardware
- Uses optimized generation parameters for speed:
  - `max_length: 100` tokens
  - `temperature: 0.3` for deterministic output
  - `top_p: 0.9` for quality

### Disabling AI Predictor

To disable the AI predictor, comment out the registration in `Init.cs:26`:
```csharp
// RegisterSubsystem(new AiPredictor());
```

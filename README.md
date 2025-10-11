# PowerShell Predictor with AI

A PowerShell predictor module that provides intelligent command-line suggestions using both traditional completion and local AI models.

## Features

- **Command Completer Predictor**: Fast suggestions using PowerShellArgumentCompleter
- **AI Predictor**: Intelligent suggestions powered by local Phi-3 model via ONNX Runtime
- **Offline**: All predictions work locally without internet connection (once model is downloaded)
- **Fast**: Optimized for real-time suggestions in your terminal

## Quick Start

### 1. Setup the AI Model (Optional)

The AI predictor requires downloading the Phi-3 model (~2GB).

**Recommended method** (most reliable):
```powershell
.\setup-ai-model-git.ps1
```

**Alternative methods**: See [SETUP-MODEL.md](SETUP-MODEL.md) for:
- Direct HTTP download
- Manual browser download
- GPU (DirectML) version

**Skip this step** if you only want to use the CommandCompleter predictor without AI.

### 2. Build the Module

```bash
dotnet build
```

### 3. Import the Module

```powershell
Import-Module .\src\PowerShellPredictor\bin\Debug\net9.0\Lucas.PowerShellPredictor.dll
```

### 4. Start Typing!

The predictors will automatically suggest completions as you type in PowerShell.

## Configuration

### Enable/Disable Predictors

Edit `src/PowerShellPredictor/Init.cs` to enable or disable specific predictors:

```csharp
public void OnImport()
{
    RegisterSubsystem(new CommandCompleterPredictor());  // Fast completions
    RegisterSubsystem(new AiPredictor());                 // AI-powered suggestions
    // RegisterSubsystem(new KnownCommandsPredictor());   // Static command list
}
```

## Architecture

### Predictors

1. **CommandCompleterPredictor**: Uses PowerShellArgumentCompleter for fast, context-aware completions
2. **AiPredictor**: Uses local Phi-3 Mini model for intelligent command predictions
3. **KnownCommandsPredictor**: Simple static list of common commands (disabled by default)

### How It Works

- Implements PowerShell's `ICommandPredictor` subsystem interface
- Registers predictors via `SubsystemManager` on module load
- Integrates with PSReadLine for terminal suggestions
- Model loads lazily on first AI prediction request

## Performance

- **CommandCompleter**: <10ms per suggestion
- **AI Predictor**:
  - First load: 5-15 seconds (model initialization)
  - Subsequent predictions: 100-500ms depending on hardware
  - Model stays in memory for the session

## Development

### Build
```bash
dotnet build
```

### Run Tests
```bash
dotnet test
```

### Test Predictors via CLI
```bash
dotnet run --project src/PowerShellPredictor.Cli/ -- "git che"
```

## Model Information

- **Model**: Phi-3 Mini 4K Instruct (3.8B parameters)
- **Format**: ONNX (optimized for inference)
- **Quantization**: INT4 (balanced quality and speed)
- **Size**: ~2GB download
- **Source**: [microsoft/Phi-3-mini-4k-instruct-onnx](https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-onnx)

## Requirements

- .NET 9.0
- PowerShell 7.5+
- Windows/Linux/macOS
- ~2GB disk space for AI model (optional)

## References

- [PowerShell Predictors Documentation](https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/using-predictors)
- [ONNX Runtime GenAI](https://github.com/microsoft/onnxruntime-genai)
- [Phi-3 Models](https://azure.microsoft.com/en-us/products/phi-3)

## License

MIT License - see [LICENSE](LICENSE) for details.

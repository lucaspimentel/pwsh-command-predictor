# PowerShell Predictor

PowerShell predictor module providing intelligent command-line suggestions via PowerShell's prediction subsystem.

## Quick Start

### Build

```powershell
dotnet build
```

### Install

```powershell
# Build the module
dotnet build src/PowerShellPredictor/ -c Release

# Copy the built DLL to the module directory
Copy-Item src/PowerShellPredictor/bin/Release/net9.0/PowerShellPredictor.dll module/Lucas.PowerShellPredictor.dll

# Import the module
Import-Module ./module/Lucas.PowerShellPredictor.psd1

# Enable predictions
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
```

**For permanent installation**, copy the `module/` directory to one of your PowerShell module paths:

```powershell
# View module paths
$env:PSModulePath -split [IO.Path]::PathSeparator

# Example: Copy to user modules directory
Copy-Item -Recurse ./module/ "$HOME\Documents\PowerShell\Modules\Lucas.PowerShellPredictor"
```

### Test

```powershell
# Try typing a command
git che  # Should suggest "git checkout"
```

## How It Works

The module uses `CommandCompleterPredictor` which leverages PowerShell's native argument completer to provide context-aware suggestions based on:
- Command syntax
- Available parameters
- File paths
- History patterns

## Development

### Run Tests

```powershell
dotnet test
```

### Test Predictor via CLI

```powershell
dotnet run --project src/PowerShellPredictor.Cli/ -- "git che"
```

## Requirements

- .NET 9.0 SDK
- PowerShell 7.5+

## Architecture

- **PowerShellPredictor** - Core module with predictor implementations
- **PowerShellPredictor.Cli** - CLI testing tool
- **PowerShellPredictor.Tests** - xUnit test suite

See [CLAUDE.md](CLAUDE.md) for detailed architecture and development guidance.

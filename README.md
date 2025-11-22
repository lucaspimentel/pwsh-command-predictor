⚠️ *NOTE: this project has moved to https://github.com/lucaspimentel/PSCue*

# PowerShell Predictor

PowerShell predictor module providing intelligent command-line suggestions via PowerShell's prediction subsystem.

## Quick Start

### Installation

**Automated installation (recommended):**

```powershell
# Clone the repository
git clone https://github.com/lucaspimentel/pwsh-command-predictor.git
cd pwsh-command-predictor

# Run installation script
pwsh -NoProfile ./install.ps1
```

The installation script will:
- Build the module using `dotnet build`
- Install to `~/.local/pwsh-modules/Lucas.PowerShellPredictor/`
- Provide instructions for adding to your PowerShell profile

**After installation**, add these lines to your PowerShell profile (`$PROFILE`):

```powershell
Import-Module ~/.local/pwsh-modules/Lucas.PowerShellPredictor/Lucas.PowerShellPredictor.psd1
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
```

### Manual Installation

```powershell
# Build the module
dotnet build src/PowerShellPredictor/ -c Release

# Copy the built DLL to the module directory
Copy-Item src/PowerShellPredictor/bin/Release/net9.0/Lucas.PowerShellPredictor.dll module/

# Import the module
Import-Module ./module/Lucas.PowerShellPredictor.psd1

# Enable predictions
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
```

### Test

```powershell
# Try typing a command
git che  # Should suggest "git checkout"
```

## How It Works

The module uses `CommandCompleterPredictor` which integrates with [PowerShellArgumentCompleter](https://github.com/lucaspimentel/pwsh-argument-completer) to provide intelligent command-line suggestions. The predictor:
- Detects command and parameter context from partial input
- Queries available completions via PowerShellArgumentCompleter
- Merges completions with the input line using overlap detection
- Provides context-aware suggestions for commands, parameters, and values

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

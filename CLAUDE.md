# CLAUDE.md

AI agent guidance for working with this PowerShell predictor module.

## Project Overview

PowerShell predictor module providing command-line suggestions via PowerShell's prediction subsystem.

**Current State**: CommandCompleterPredictor is active. AI predictor is disabled and excluded from compilation.

## Architecture

### Core Components

1. **PowerShellPredictor** (`src/PowerShellPredictor/`)
   - `Init.cs:23`: Registers CommandCompleterPredictor on module load
   - `CommandCompleterPredictor.cs`: Active predictor using PowerShellArgumentCompleter
   - `CommandCompleterPredictor.cs:49-70`: `Combine()` method merges input with completions via overlap detection
   - `AiPredictor.cs`: EXCLUDED from compilation (PowerShellPredictor.csproj:23)
   - `KnownCommandsPredictor.cs`, `SamplePredictor.cs`: EXCLUDED from compilation

2. **PowerShellPredictor.Cli** (`src/PowerShellPredictor.Cli/`)
   - CLI testing tool for predictors
   - `Program.cs:7`: Currently uses CommandCompleterPredictor

3. **PowerShellPredictor.Tests** (`test/PowerShellPredictor.Tests/`)
   - xUnit test project

4. **module/** (PowerShell Module Distribution)
   - `Lucas.PowerShellPredictor.psd1`: Module manifest (v0.1.0)
   - `Lucas.PowerShellPredictor.psm1`: Script module wrapper
   - Requires compiled `Lucas.PowerShellPredictor.dll` from build output

### Key Dependencies

- **Microsoft.PowerShell.SDK** (v7.5.0, PrivateAssets=all) - PowerShell subsystem APIs
- **PowerShellArgumentCompleter** - sibling repository at `../pwsh-argument-completer/src/`
- **xUnit + Moq** - testing framework
- **Microsoft.ML.OnnxRuntimeGenAI** - REMOVED (was v0.10.0, removed when AI predictor disabled)

## Quick Commands

```bash
# Build all
dotnet build

# Build specific projects
dotnet build src/PowerShellPredictor/
dotnet build src/PowerShellPredictor.Cli/

# Run tests
dotnet test

# Test predictor via CLI
dotnet run --project src/PowerShellPredictor.Cli/ -- "git che"

# Build and install module (automated)
pwsh -NoProfile ./install.ps1

# Manual installation
dotnet build src/PowerShellPredictor/ -c Release
Copy-Item src/PowerShellPredictor/bin/Release/net9.0/Lucas.PowerShellPredictor.dll module/
Import-Module ./module/Lucas.PowerShellPredictor.psd1
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
```

## Key Implementation Details

### Configuration
- **Target**: .NET 9.0
- **Assembly**: `Lucas.PowerShellPredictor`
- **Nullable**: Enabled
- **Implicit usings**: Enabled
- **Test visibility**: `InternalsVisibleTo` for test assembly (AssemblyInfo.cs:3)

### Excluded Files (PowerShellPredictor.csproj:18-23)
- `KnownCommandsPredictor.cs`
- `SamplePredictor.cs`
- `AiPredictor.cs`

### PowerShell Predictor Pattern
- **Interface**: `ICommandPredictor`
- **Registration**: `SubsystemManager.RegisterSubsystem(SubsystemKind.CommandPredictor, ...)`
- **Identifier**: Each predictor has unique GUID
- **Core method**: `GetSuggestion()` returns `SuggestionPackage`

## AI Predictor (Currently Disabled)

**Status**: AI predictor is DISABLED and excluded from compilation.

### Re-enabling AI Predictor

To re-enable the AI predictor:

1. **Restore dependency** in `PowerShellPredictor.csproj`:
   ```xml
   <PackageReference Include="Microsoft.ML.OnnxRuntimeGenAI" Version="0.10.0" />
   ```

2. **Remove exclusion** in `PowerShellPredictor.csproj` (remove this line):
   ```xml
   <Compile Remove="AiPredictor.cs" />
   ```

3. **Enable registration** in `Init.cs:26`:
   ```csharp
   RegisterSubsystem(new AiPredictor());
   ```

4. **Uncomment cleanup** in `Init.cs:46`:
   ```csharp
   AiPredictor.Cleanup();
   ```

5. **Setup model** (see `ai/SETUP-MODEL.md` for detailed instructions):
   ```powershell
   .\ai\setup-ai-model-git.ps1
   ```

### AI Implementation Notes

- **Model**: Phi-3 Mini 4K Instruct (ONNX, INT4, ~2GB)
- **Location**: `%USERPROFILE%\.powershell-predictor\models\phi3\`
- **Loading**: Lazy singleton pattern (AiPredictor.cs:35-75)
- **Performance**: 5-15s initial load, 100-500ms per prediction
- **Documentation**: See `ai/README.md` and `ai/SETUP-MODEL.md`

## Installation

### Automated Installation (Recommended)

```bash
pwsh -NoProfile ./install.ps1
```

**What it does**:
- Builds the module with `dotnet build` (Release configuration)
- Installs to `~/.local/pwsh-modules/Lucas.PowerShellPredictor/`
- Provides instructions for adding to PowerShell profile

**Post-install**: Add to your `$PROFILE`:
```powershell
Import-Module ~/.local/pwsh-modules/Lucas.PowerShellPredictor/Lucas.PowerShellPredictor.psd1
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
```

### Manual Installation

See Quick Commands section above for manual build/install steps.

## What's Next (Future Features)

- **Remote Installation**: Enable web-based installation
  - Install script: `irm https://github.com/lucaspimentel/pwsh-predictor/main/install.ps1 | iex`
  - Requires HTTPS hosting and proper script signing
- **GitHub Releases**: Automated releases via GitHub Actions
  - Version tag triggers build workflow
  - Publish pre-built binaries as release artifacts
  - Create release notes from commit history
- **PowerShell Gallery**: Optional publication for `Install-Module` support
  - Register as PSGallery publisher
  - Automate gallery publishing on releases
  - Enable `Install-Module Lucas.PowerShellPredictor`

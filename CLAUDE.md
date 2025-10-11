# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a PowerShell predictor module that provides command-line suggestions using PowerShell's prediction subsystem. The predictor integrates with PSReadLine to offer auto-completion suggestions based on the PowerShellArgumentCompleter library.

## Architecture

The project consists of three main components:

1. **PowerShellPredictor** (src/PowerShellPredictor/): The core predictor module
   - `Init.cs:22-33`: Registers predictor subsystems on module load via `IModuleAssemblyInitializer`
   - `CommandCompleterPredictor.cs`: Main predictor implementation using PowerShellArgumentCompleter
   - `CommandCompleterPredictor.cs:49-70`: The `Combine()` method intelligently merges input text with completions by finding overlaps

2. **PowerShellPredictor.Cli** (src/PowerShellPredictor.Cli/): A simple CLI tool for testing predictors outside of PowerShell

3. **PowerShellPredictor.Tests** (test/PowerShellPredictor.Tests/): xUnit test project

### Key Dependencies

- Microsoft.PowerShell.SDK (v7.5.0) - provides PowerShell subsystem APIs
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

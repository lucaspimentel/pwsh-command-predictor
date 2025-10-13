# Lucas.PowerShellPredictor Module
#
# This is a binary PowerShell module that implements command prediction
# through the ICommandPredictor interface. The predictors are automatically
# registered via IModuleAssemblyInitializer when the DLL is loaded.
#
# Currently active predictor: CommandCompleterPredictor
# - Uses PowerShellArgumentCompleter for intelligent command suggestions
#
# No additional initialization is required in this script module as the
# C# Init class handles all predictor registration automatically.
